# VNC Client Design (with macOS Screen Sharing Support)

**Date:** 2026-11-24
**Scope:** GSMLG Toolbox VNC Client (macOS / Linux / Windows / iOS / Android)
**Status:** Design Approved, Pending Implementation Plan

---

## 1. Goals & Non-Goals

### Goals
- Add a first-class **VNC** tool to GSMLG Toolbox (`lib/screens/toolbox/vnc/`) supporting all native platforms (macOS, Linux, Windows, iOS, Android).
- Support connecting directly to **macOS Screen Sharing / Remote Management (`screensharingd`)** out of the box without requiring users to downgrade macOS to legacy VNC password mode:
  - Handle non-standard banner `RFB 003.889` alongside standard `RFB 003.003` / `003.007` / `003.008`.
  - Support **Apple ARD authentication (Security Type 30)** with macOS username + password, as well as **VNC Authentication (Security Type 2)** and **None (Security Type 1)**.
- Provide smooth remote desktop interaction: compressed framebuffer decoding (`ZRLE`, `CopyRect`, `Hextile`, `Raw`), dynamic resolution updates (`DesktopSize`, `ExtendedDesktopSize`), remote cursor (`Cursor`), zoom/pan canvas, mouse & touch gestures, hardware keyboard + macOS modifier key mapping, mobile virtual shortcut bar, and bidirectional clipboard sync.
- Reuse GSMLG's existing infrastructure:
  - Persist saved VNC host profiles in `app_database` (Drift) and passwords in `app_secure_storage` (`VaultRepository`).
  - Discover LAN macOS / VNC hosts via Bonjour/mDNS (`_rfb._tcp.local`) using `multicast_dns`.
  - Support SSH port-forwarding tunnels by reusing `app_ssh` (`SSHClient.forwardLocal`) and existing saved `SshHosts`.

### Non-Goals (Out of Scope for v1)
- Flutter Web support (browsers cannot open raw TCP sockets without a WebSocket/websockify proxy; VNC tile is hidden when `kIsWeb`).
- Multi-tab simultaneous VNC sessions (single active session screen in v1; architecture keeps `VncSessionBloc` session-scoped so multi-tab can be added later without refactoring `app_vnc`).
- VeNCrypt / TLS / Kerberos (Type 19 / 35) and Tight+JPEG encoding (designed as clean extension points in `app_vnc` for future follow-ups).
- Audio forwarding or file transfer over VNC.

---

## 2. Chosen Approach & Rationale

**Approach:** Pure-Dart RFB protocol engine (`app_lib/vnc`) executing network I/O, optional `app_ssh` tunneling, decompression, and framebuffer composition inside a dedicated background `Isolate`, transferring RGBA frames to the UI isolate via `TransferableTypedData`.

**Why this approach over Rust FFI or `libvncclient` C FFI:**
- Zero cross-compilation or native packaging overhead across 5 platforms (macOS, Linux incl. ARM64 kiosk, Windows, iOS, Android) and zero CI build-chain expansion.
- Native, zero-local-port integration with GSMLG's pure-Dart `app_ssh` (`SSHForwardChannel` implements the exact stream/sink shape needed by `VncTransport`).
- All cryptographic primitives for macOS ARD Type 30 already exist in the workspace (`BigInt.modPow` in `dart:core`, `crypto` MD5, `pointycastle` AES-128-ECB) and `RawZLibFilter` in `dart:io` provides persistent zlib streams for `ZRLE`.
- Avoids GPLv2+ licensing concerns of `libvncclient` and avoids the lack of `RFB 003.889` / ARD Type 30 / `ZRLE` in existing `pub.dev` VNC packages.

---

## 3. Package & Module Architecture

### 3.1 Workspace Packages

Add 4 focused packages to root `pubspec.yaml` (`workspace:` and `dependencies:` with `any`):

| Path | Package Name | Type | Responsibilities | Key Dependencies |
| :--- | :--- | :--- | :--- | :--- |
| `app_lib/vnc` | `app_vnc` | Pure Dart | RFB 3.3/3.7/3.8/`003.889` client, Type 1/2/30 auth, `ZRLE`/`CopyRect`/`Hextile`/`Raw` decoders, `VncTransport` (TCP & SSH tunnel), `VncIsolateClient`, `VncMdnsDiscovery`, X11 keysym constants | `app_ssh`, `app_logging`, `crypto`, `pointycastle`, `multicast_dns`, `equatable`, `meta` |
| `app_bloc/vnc_host` | `vnc_host_bloc` | Flutter BLoC | CRUD for saved VNC hosts, `VaultRepository` password storage, LAN mDNS `_rfb._tcp` discovery state | `app_database`, `app_secure_storage`, `app_vnc`, `bloc`, `drift`, `equatable` |
| `app_bloc/vnc_session` | `vnc_session_bloc` | Flutter BLoC | Single VNC session lifecycle (connecting, auth prompt, connected, reconnecting, error), frame delivery notifications, stats, clipboard & input dispatch | `app_vnc`, `bloc`, `equatable` |
| `app_widget/vnc_viewer` | `vnc_viewer_widgets` | Flutter Widgets | `VncViewerCanvas` (`CustomPaint` + `ui.Image` lifecycle + zoom/pan), desktop mouse/wheel & mobile trackpad/direct-touch gesture handling, `KeysymMapper`, mobile virtual shortcut bar | `app_vnc`, `duskmoon_ui` |

### 3.2 Main App Integration (`lib/`)
- `lib/screens/toolbox/toolbox_screen.dart`: add `VNC` `AppGridTile` gated by `if (!kIsWeb)`.
- `lib/screens/toolbox/toolbox_routes.dart`: add nested routes under `/toolbox`:
  - `VncHostsScreen` (`name: 'Vnc'`, `path: 'vnc'`)
  - `VncSessionScreen` (`name: 'VncSession'`, `path: 'session'`, receiving a `VncLaunchConfig` via route `extra`)
- `app_lib/provider/lib/src/main.dart`: register `VncHostBloc` in `MainProvider` (long-lived, backed by `AppDatabase` + `VaultRepository`). `VncSessionBloc` is created per `VncSessionScreen` via `BlocProvider` and closed immediately when leaving the session screen so sockets, SSH tunnels, and isolates never leak.
- `app_lib/locale`: add localized strings (`vncTitle`, connection labels, auth prompts, error messages) to ARB files and run `melos run gen-l10n`.

---

## 4. Data Layer & Credential Storage

### 4.1 Drift Table (`app_lib/database/lib/src/tables/vnc_hosts.dart`)

Bump `AppDatabase.schemaVersion` from `22` to `23` and create `vncHosts` in `onUpgrade` when `from < 23`.

```dart
enum VncAuthType {
  auto(0),
  none(1),
  vncPassword(2),
  appleArd(30);

  const VncAuthType(this.value);
  final int value;
}

@DataClassName('VncHost')
class VncHosts extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text()();
  TextColumn get host => text()();
  IntColumn get port => integer().withDefault(const Constant(5900))();
  IntColumn get authType => integer().withDefault(const Constant(0))();
  TextColumn get username => text().nullable()();
  TextColumn get passwordRef => text().nullable()();
  IntColumn get sshHostId =>
      integer().nullable().references(SshHosts, #id, onDelete: KeyAction.setNull)();
  BoolColumn get viewOnly => boolean().withDefault(const Constant(false))();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get lastConnectedAt => dateTime().nullable()();
}
```

### 4.2 Secure Storage Rules
- Passwords are **never** stored in SQLite.
- When saving a host with a password, `VncHostBloc` writes the secret to `VaultRepository` under key `vnc_host:<id>:password` and stores that key in `passwordRef`.
- Deleting a `VncHost` deletes its `passwordRef` entry from `VaultRepository`.
- Quick-connect / mDNS one-off sessions hold credentials only in memory for the duration of the session and discard them on disconnect.
- When a `VncHost` references an `sshHostId`, `VncSessionScreen` resolves the SSH host record and its credential (password or decrypted PEM key via `SshCredentialRepository` / `SshKeyBloc`) right before spawning the VNC worker isolate.

---

## 5. RFB Protocol, macOS ARD & Isolate Rendering Pipeline

### 5.1 Transport Abstraction (`app_lib/vnc/lib/src/transport/`)
```dart
abstract interface class VncTransport {
  Stream<Uint8List> get stream;
  void add(Uint8List data);
  Future<void> flush();
  Future<void> close();
  Future<void> get done;
}
```
- **`TcpVncTransport`**: connects via `Socket.connect(host, port, timeout: timeout)` with `SocketOption.tcpNoDelay = true`.
- **`SshTunnelVncTransport`**: connects an `app_ssh` `SSHClient` (supporting password and private key auth) inside the worker isolate, invokes `sshClient.forwardLocal(vncHost, vncPort)`, and wraps `SSHForwardChannel` as a `VncTransport`. `close()` tears down both the forwarded channel and the underlying `SSHClient`.

### 5.2 RFB Handshake & Authentication (`app_lib/vnc/lib/src/protocol/`)
1. **ProtocolVersion**:
   - Read 12-byte server banner `RFB XXX.YYY\n`.
   - Accept `3.3`, `3.7`, `3.8`, and macOS `3.889` (and any `3.xxx >= 3.8`).
   - Respond with `RFB 003.008\n` for `>= 3.8` (including `003.889`), `RFB 003.007\n` for `3.7`, `RFB 003.003\n` for `3.3`.
2. **Security Negotiation**:
   - In RFB 3.7/3.8, read the server's list of offered security types.
   - Selection priority when `authType == auto`: `30 (Apple ARD)` if offered (and preferred for macOS) → `2 (VNC Auth)` → `1 (None)`. If user explicitly picked a type, verify the server offers it; otherwise fail with a typed `VncUnsupportedSecurityTypeException(offeredTypes)`.
   - If the selected security type requires credentials not yet provided (e.g. connecting to an mDNS-discovered Mac), pause handshake and emit `VncAuthChallengeRequest(securityType, requiresUsername)` to the UI isolate; resume once credentials arrive (or cancel cleanly if user dismisses).
3. **Security Type 30 — Apple Remote Desktop (ARD / Apple-DH)**:
   - Read `generator` (`uint16` BE), `keyLength` (`uint16` BE), `prime` (`keyLength` bytes unsigned BE), `serverPubKey` (`keyLength` bytes unsigned BE).
   - Generate cryptographically secure random `privKey` (`keyLength` bytes via `Random.secure()`).
   - Compute `clientPubKey = g.modPow(privKey, prime)` and `sharedSecret = serverPubKey.modPow(privKey, prime)`, both left-padded to exactly `keyLength` bytes big-endian.
   - Derive `aesKey = md5.convert(sharedSecretBytes).bytes` (16 bytes).
   - Build 128-byte credential buffer:
     - Bytes `0..63`: UTF-8 `username` (truncated to at most 63 bytes) + `0x00` + `Random.secure()` padding bytes to length 64.
     - Bytes `64..127`: UTF-8 `password` (truncated to at most 63 bytes) + `0x00` + `Random.secure()` padding bytes to length 64.
   - Encrypt all 128 bytes using `pointycastle` `AESEngine` in ECB mode (8 × 16-byte blocks) with `aesKey`.
   - Send `[128B ciphertext][keyLength bytes clientPubKey]`.
   - Read 4-byte `SecurityResult` (`0` = OK; non-zero = read reason string in 3.8 and report `VncAuthenticationException`).
4. **Security Type 2 — Standard VNC Authentication**:
   - Read 16-byte challenge.
   - Pad/truncate password to 8 bytes, reverse bit order of each byte (per RFB spec), encrypt the two 8-byte blocks of the challenge with standard DES-ECB (implemented in ~80 lines of pure Dart in `app_lib/vnc/lib/src/crypto/vnc_des.dart` with RFC test vectors).
   - Send 16-byte response and read `SecurityResult`.
5. **Security Type 1 — None**:
   - In RFB 3.8 read `SecurityResult`; in 3.7 proceed directly to `ClientInit`.

### 5.3 Initialization, Pixel Format & Framebuffer Decoders
- Send `ClientInit(sharedFlag: 1)` → parse `ServerInit` (width, height, server pixel format, desktop name).
- Immediately send `SetPixelFormat` requesting **32-bit little-endian RGBA8888**:
  - `bitsPerPixel = 32`, `depth = 24`, `bigEndian = 0`, `trueColor = 1`
  - `redMax = 255`, `greenMax = 255`, `blueMax = 255`
  - `redShift = 0`, `greenShift = 8`, `blueShift = 16`
  - Framebuffer alpha byte is filled with `0xFF` on decode so the buffer is directly consumable by Flutter's `ui.PixelFormat.rgba8888`.
- Send `SetEncodings` in priority order:
  1. `ZRLE (16)` — persistent `RawZLibFilter.inflateFilter()` stream across updates; supports all CPIXEL (24-bit packed RGB) sub-encodings: `Raw (0)`, `Solid (1)`, `Packed Palette (2..16)`, `Plain RLE (128)`, `Palette RLE (130..255)` over 64×64 tiles.
  2. `CopyRect (1)` — overlap-safe rectangle copy within the RGBA framebuffer.
  3. `Hextile (5)` — 16×16 tiles (`Raw`, `BackgroundSpecified`, `ForegroundSpecified`, `AnySubrects`, `SubrectsColoured`).
  4. `Raw (0)` — uncompressed fallback.
  5. Pseudo-encodings: `DesktopSize (-223)`, `ExtendedDesktopSize (-308)`, `Cursor (-239)`, `LastRect (-224)`.

### 5.4 Background Isolate & Zero-Copy Frame Pipeline
- `VncIsolateClient` spawns a dedicated worker `Isolate` that owns:
  - `VncTransport` (TCP socket or SSH tunnel),
  - RFB state machine & byte reader (`BufferedByteReader`),
  - Persistent Zlib inflater & full-screen RGBA `Uint8List` framebuffer.
- **Pull-based incremental update loop**:
  - After `ServerInit`, send `FramebufferUpdateRequest(incremental: false, full rect)`.
  - After decoding each `FramebufferUpdate`, immediately issue `FramebufferUpdateRequest(incremental: true, full rect)` (or `incremental: false` after `DesktopSize` resize).
- **UI delivery throttling**:
  - Frame snapshots are throttled to at most every ~16–33 ms (30–60 fps cap) and sent to the UI isolate via `TransferableTypedData.fromList([rgbaCopy])` along with `width`, `height`, and `frameId`.
  - On the UI isolate, `VncViewerCanvas` decodes `TransferableTypedData` with `ui.decodeImageFromPixels(..., ui.PixelFormat.rgba8888, callback)`, drops stale in-flight frames if a newer `frameId` arrived, replaces the rendered `ui.Image`, and immediately calls `previousImage.dispose()`.
- **Deterministic shutdown**:
  - `disconnect()` sends a shutdown command → worker closes `VncTransport` (and SSH client) → exits cleanly; if unresponsive after 1 second, UI isolate calls `isolate.kill(priority: Isolate.immediate)` and closes `ReceivePort`.

### 5.5 Input Mapping & Clipboard
- **Pointer**: `VncViewerCanvas` tracks an `InteractiveViewer` / `TransformationController` matrix and maps local pointer coordinates back to remote `(x, y)` clamped to `[0, fbWidth - 1] × [0, fbHeight - 1]`. Sends RFB `PointerEvent (5)` with standard button mask (`bit 0` left, `bit 1` middle, `bit 2` right, `bit 3/4` wheel up/down, `bit 5/6` wheel left/right). Ignored when `viewOnly == true`.
- **Keyboard (`KeysymMapper`)**: translates Flutter `KeyEvent` (`KeyDownEvent` / `KeyUpEvent`) to RFB `KeyEvent (4)` X11 keysyms:
  - Printable Unicode characters: `0x0020..0x007E` directly, other Unicode via `0x01000000 | codePoint`.
  - macOS-accurate modifiers: `Meta/Command → Super_L (0xFFEB)` / `Super_R (0xFFEC)`, `Alt/Option → Alt_L (0xFFE9)` / `Alt_R (0xFFEA)`, `Control → Control_L (0xFFE3)` / `Control_R (0xFFE4)`, `Shift → Shift_L (0xFFE1)` / `Shift_R (0xFFE2)`.
  - Navigation/editing/function keys (`Return`, `BackSpace`, `Delete`, `Tab`, `Escape`, `Home`, `End`, `Page_Up`, `Page_Down`, `Left/Up/Right/Down`, `F1..F12`).
- **Clipboard**:
  - Server → Client: on `ServerCutText (3)`, decode Latin-1 text and offer/sync to system clipboard (`Clipboard.setData`).
  - Client → Server: toolbar action (and optional auto-sync on focus) encodes system clipboard text to Latin-1 (replacing non-Latin-1 code points safely with `?`) and sends `ClientCutText (6)`.

---

## 6. UI Flows, mDNS Discovery & Platform Permissions

### 6.1 `VncHostsScreen` (`/toolbox/vnc`)
- Uses `AppAdaptiveScaffold` (`navigationRestoreInHeader: true`, selected tab = `ToolboxScreen.name`) and `duskmoon_ui` components.
- **Top actions**: "Quick Connect" button + "Add Host" button + "Refresh LAN" button.
- **Saved Hosts section**: cards displaying host name, `host:port`, auth badge (`Auto` / `ARD` / `VNC` / `None`), SSH tunnel badge (linked SSH host name if configured), last connected timestamp; tap to connect, overflow menu to edit/delete.
- **LAN Discovered (Bonjour / mDNS) section**:
  - Automatically runs a 5-second bounded browse on screen open (matching `MonitorScreen` pattern) via `VncMdnsDiscovery`: queries `ResourceRecordQuery.serverPointer('_rfb._tcp.local')` → resolves `SRV` (`target`, `port`) → resolves `IPv4`/`IPv6` `A`/`AAAA` records.
  - Lists discovered Macs/VNC hosts with one-tap **Connect** (prompts for credentials on demand if needed) and **Save** (pre-fills the Add Host form with `authType: auto`).
- **Add / Edit / Quick Connect form**:
  - Fields: Name (saved only), Host, Port (default `5900`), Auth Type (`Auto` / `macOS ARD` / `VNC Password` / `None`), Username (shown for `Auto` / `macOS ARD`), Password (obscured, stored in `VaultRepository` for saved hosts), Optional SSH Tunnel dropdown (populated from `SshHostBloc`), View-Only toggle.

### 6.2 `VncSessionScreen` (`/toolbox/vnc/session`)
- Full-bleed dark canvas (`VncViewerCanvas`) with a collapsible top HUD toolbar:
  - Status dot + desktop name + remote resolution (`e.g. 2560×1600`).
  - Fit-to-screen / 1:1 scale toggle, View-Only toggle, Sync Clipboard button, Fullscreen + `WakelockPlus` toggle, Disconnect button.
- **Desktop interaction**: direct mouse hover/click/right-click/scroll wheel + direct hardware keyboard focus.
- **Mobile interaction**:
  - Mode toggle between **Trackpad mode** (1-finger relative cursor drag, tap = left click, 2-finger tap = right click, 2-finger scroll = wheel, pinch = zoom) and **Direct touch mode** (tap at coordinate).
  - Expandable **Virtual Shortcut Bar**: sticky toggle modifiers (`⌘`, `⌥`, `⌃`, `⇧`) + one-tap keys (`Esc`, `Tab`, `← ↑ ↓ →`, `Del`, `Ctrl+Alt+Del`, software keyboard toggle).

### 6.3 Error Handling & Recovery
Typed exceptions in `app_vnc` map cleanly to `VncSessionError` states and actionable UI prompts:
- `VncConnectionException` (timeout / refused / DNS failure) → show host:port & Retry button.
- `VncSshTunnelException` (SSH auth/connect/forward failure) → distinguish SSH tunnel failure from VNC server failure.
- `VncAuthenticationException` (bad username/password) → keep session screen open and re-show credential dialog for immediate retry.
- `VncUnsupportedSecurityTypeException(offeredTypes)` → display offered security type IDs and a macOS hint pointing to *System Settings → General → Sharing → Screen Sharing*.
- Unexpected socket EOF → transition to disconnected banner with **Reconnect** button.

### 6.4 Platform Permissions
- **iOS (`ios/Runner/Info.plist`)**: append `<string>_rfb._tcp</string>` to existing `NSBonjourServices` array and update `NSLocalNetworkUsageDescription` to mention VNC/macOS Screen Sharing discovery.
- **macOS (`macos/Runner/Info.plist`)**: add `NSBonjourServices` (`_rfb._tcp`) and `NSLocalNetworkUsageDescription` for macOS Sequoia+ local network discovery; `com.apple.security.network.client` is already enabled in `macos/Runner/*.entitlements`.
- **Android**: `INTERNET` and multicast/LAN permissions checked in `AndroidManifest.xml`.

---

## 7. Testing & Verification Strategy

1. **Pure Dart Unit & Protocol Tests (`app_lib/vnc/test/`)**:
   - Handshake tests: `RFB 003.003`, `003.007`, `003.008`, `003.889` banner negotiation & error handling.
   - Crypto & Auth tests:
     - `vnc_des_test.dart`: VNC DES bit-reversed key & challenge-response vectors.
     - `ard_auth_test.dart`: fixed DH parameters (`g`, `p`, `serverPubKey`) verifying `clientPubKey`, `sharedSecret`, `MD5` key derivation, 128-byte AES-128-ECB ciphertext, and end-to-end handshake against an in-memory mock RFB server.
   - Decoder tests: `Raw`, `CopyRect` (including overlapping rects), `Hextile` (all flags), `ZRLE` (all 5 tile sub-encodings across multi-message persistent zlib streams), `DesktopSize` & `ExtendedDesktopSize`, `Cursor`.
   - `keysym_test.dart`: ASCII and Unicode-to-X11 keysym conversion rules in `app_vnc`.
   - `transport_test.dart`: in-memory mock `VncTransport` and `SshTunnelVncTransport` teardown verification.
2. **BLoC Tests (`app_bloc/vnc_host/test/`, `app_bloc/vnc_session/test/`)**:
   - `VncHostBloc` CRUD + `VaultRepository` write/delete cleanup using `AppDatabase.forTesting()`.
   - `VncSessionBloc` state transitions (connecting → auth prompt → connected → resize → error → reconnect → dispose).
3. **Widget & Route Tests (`app_widget/vnc_viewer/test/`, `test/screens/toolbox/vnc/`)**:
   - `keysym_mapper_test.dart`: Flutter `LogicalKeyboardKey` → X11 keysym mapping (including macOS `Command`/`Option`/`Control` and function keys).
   - `VncViewerCanvas` coordinate mapping under zoom/pan transforms and `ui.Image` disposal.
   - `VncHostsScreen` rendering saved hosts + discovered hosts + quick-connect dialog.
4. **Workspace Quality Gates**:
   - `melos run prepare`, `melos run analyze`, `melos run format-check`, `melos run test`.
5. **Real macOS Manual Verification**:
   - Connect GSMLG (macOS & iOS/Android) to a real macOS host with Screen Sharing enabled: verify `_rfb._tcp` mDNS discovery, ARD Type 30 username+password login, ZRLE rendering, `⌘` shortcuts, clipboard sync, and SSH-tunneled VNC connection.
