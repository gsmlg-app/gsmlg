# VNC Client (with macOS Screen Sharing Support) Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Build a cross-platform native VNC client in GSMLG Toolbox supporting macOS Screen Sharing (`RFB 003.889` + Apple ARD Security Type 30), standard VNC authentication (Type 1/2), compressed framebuffer decoding (`ZRLE`/`CopyRect`/`Hextile`/`Raw`), saved hosts with `VaultRepository` credentials, Bonjour/mDNS LAN discovery (`_rfb._tcp`), and `app_ssh` tunneling.

**Architecture:** A pure-Dart RFB protocol engine (`app_lib/vnc`) runs network I/O (TCP or `app_ssh` `SSHForwardChannel`), authentication, decompression, and RGBA framebuffer updates inside a dedicated background `Isolate`, pushing throttled `TransferableTypedData` snapshots to the UI isolate. State management is split into `app_bloc/vnc_host` (Drift `VncHosts` + `VaultRepository` + mDNS) and `app_bloc/vnc_session` (per-session lifecycle), rendered by `app_widget/vnc_viewer` and wired into `lib/screens/toolbox/vnc/`.

**Tech Stack:** Dart `>=3.12.0`, Flutter, `bloc` / `flutter_bloc`, `drift`, `app_ssh`, `app_secure_storage`, `pointycastle`, `crypto`, `multicast_dns`, `duskmoon_ui`, `wakelock_plus`, `go_router`, `melos`.

**Design Spec:** [docs/superpowers/specs/2026-11-24-vnc-client-design.md](../specs/2026-11-24-vnc-client-design.md)

---

## File Map

### New Packages
- `app_lib/vnc/` (`app_vnc` — pure Dart):
  - `pubspec.yaml`, `analysis_options.yaml`, `lib/app_vnc.dart`
  - `lib/src/models/vnc_models.dart` — `VncAuthType`, `VncConnectionConfig`, `VncSshTunnelConfig`, `VncCredentials`, `VncDesktopInfo`, `VncCursorData`, `VncFrameData`, `VncDiscoveredHost`, `VncPixelFormat`
  - `lib/src/models/vnc_exceptions.dart` — `VncException`, `VncConnectionException`, `VncSshTunnelException`, `VncAuthenticationException`, `VncUnsupportedSecurityTypeException`, `VncProtocolException`
  - `lib/src/protocol/keysyms.dart` — X11 keysym constants & `unicodeToKeysym(int codePoint)`
  - `lib/src/protocol/byte_reader.dart` — `BufferedByteReader` for async stream reads
  - `lib/src/crypto/vnc_des.dart` — standard DES-ECB + VNC bit-reversed 8-byte key routine
  - `lib/src/crypto/ard_auth.dart` — Apple ARD Type 30 DH + MD5 + AES-128-ECB credential encryption
  - `lib/src/transport/vnc_transport.dart` — `VncTransport` interface, `TcpVncTransport`, `SshTunnelVncTransport`
  - `lib/src/protocol/rfb_handshake.dart` — protocol version negotiation (`3.3`/`3.7`/`3.8`/`003.889`), security type negotiation (1/2/30), `ClientInit`/`ServerInit`
  - `lib/src/protocol/framebuffer.dart` — RGBA8888 `VncFramebuffer` + `Raw`/`CopyRect`/`Hextile`/`ZRLE` decoders
  - `lib/src/protocol/rfb_session.dart` — RFB message loop, incremental update requests, pointer/key/clipboard encoding
  - `lib/src/isolate/vnc_isolate_client.dart` — background worker `Isolate` host/worker protocol + `TransferableTypedData` throttling + deterministic teardown
  - `lib/src/discovery/vnc_mdns_discovery.dart` — bounded `_rfb._tcp` mDNS scanner
- `app_bloc/vnc_host/` (`vnc_host_bloc`):
  - `pubspec.yaml`, `analysis_options.yaml`, `lib/vnc_host_bloc.dart`
  - `lib/src/repository.dart`, `lib/src/bloc.dart`, `lib/src/event.dart`, `lib/src/state.dart`
- `app_bloc/vnc_session/` (`vnc_session_bloc`):
  - `pubspec.yaml`, `analysis_options.yaml`, `lib/vnc_session_bloc.dart`
  - `lib/src/bloc.dart`, `lib/src/event.dart`, `lib/src/state.dart`
- `app_widget/vnc_viewer/` (`vnc_viewer_widgets`):
  - `pubspec.yaml`, `analysis_options.yaml`, `lib/vnc_viewer_widgets.dart`
  - `lib/src/keysym_mapper.dart`, `lib/src/vnc_viewer_canvas.dart`, `lib/src/vnc_shortcut_bar.dart`

### Modified Existing Files
- `pubspec.yaml` — add 4 packages to `workspace:` and `dependencies:`
- `app_lib/database/lib/src/tables/vnc_hosts.dart` — new Drift table `VncHosts`
- `app_lib/database/lib/src/database.dart` — register `VncHosts`, bump `schemaVersion` `22 -> 23`, add `onUpgrade` migration
- `app_lib/provider/pubspec.yaml` + `app_lib/provider/lib/src/vnc_dependencies_{stub,native}.dart` + `app_lib/provider/lib/src/main.dart` — register `VncHostBloc`
- `app_lib/locale/lib/arb/app_en.arb` + `app_zh.arb` + `app_zh_Hans.arb` + `app_zh_Hant.arb` — VNC UI strings
- `lib/screens/toolbox/vnc/vnc_screen.dart` (conditional export), `vnc_unsupported_screen.dart`, `vnc_hosts_screen.dart`, `vnc_session_screen.dart`, `widgets/vnc_host_form_dialog.dart`, `widgets/vnc_auth_dialog.dart`
- `lib/screens/toolbox/toolbox_screen.dart` & `lib/screens/toolbox/toolbox_routes.dart` — Toolbox tile & routes
- `ios/Runner/Info.plist` & `macos/Runner/Info.plist` — `_rfb._tcp` Bonjour declaration

---

## Phase 1: Pure-Dart RFB Engine (`app_lib/vnc`)

### Task 1: Scaffold `app_lib/vnc`, Core Models, Exceptions & Keysyms

**Files:**
- Modify: `pubspec.yaml` (add `app_lib/vnc` to `workspace:` and `app_vnc: any` to `dependencies:`)
- Create: `app_lib/vnc/pubspec.yaml`
- Create: `app_lib/vnc/analysis_options.yaml`
- Create: `app_lib/vnc/lib/app_vnc.dart`
- Create: `app_lib/vnc/lib/src/models/vnc_models.dart`
- Create: `app_lib/vnc/lib/src/models/vnc_exceptions.dart`
- Create: `app_lib/vnc/lib/src/protocol/keysyms.dart`
- Test: `app_lib/vnc/test/keysym_test.dart`

- [ ] **Step 1: Create `app_lib/vnc` package files and wire into root `pubspec.yaml`**

Create `app_lib/vnc/pubspec.yaml`:
```yaml
name: app_vnc
description: Pure-Dart RFB/VNC client with macOS ARD authentication, ZRLE decoding, SSH tunnel transport, and mDNS discovery.
version: 1.0.0
publish_to: "none"

environment:
  sdk: ">=3.8.0 <4.0.0"
resolution: workspace

dependencies:
  app_logging: any
  app_ssh: any
  crypto: any
  equatable: ^3.0.0
  meta: ^1.19.0
  multicast_dns: any
  pointycastle: ^4.0.0

dev_dependencies:
  lints: ^6.1.0
  test: ^1.31.1
```

Create `app_lib/vnc/analysis_options.yaml`:
```yaml
include: package:lints/recommended.yaml
```

Add `- app_lib/vnc` to `workspace:` and `app_vnc: any` to `dependencies:` in root `pubspec.yaml`, then run `melos bootstrap`.

- [ ] **Step 2: Write the failing test `app_lib/vnc/test/keysym_test.dart`**

```dart
import 'package:app_vnc/app_vnc.dart';
import 'package:test/test.dart';

void main() {
  group('unicodeToKeysym', () {
    test('maps printable ASCII directly', () {
      expect(unicodeToKeysym('A'.codeUnitAt(0)), 0x0041);
      expect(unicodeToKeysym(' '.codeUnitAt(0)), 0x0020);
      expect(unicodeToKeysym('~'.codeUnitAt(0)), 0x007E);
    });

    test('maps Latin-1 supplement directly', () {
      expect(unicodeToKeysym(0x00E9), 0x00E9); // é
    });

    test('maps non-Latin-1 Unicode with 0x01000000 offset', () {
      expect(unicodeToKeysym(0x20AC), 0x010020AC); // €
      expect(unicodeToKeysym(0x4E2D), 0x01004E2D); // 中
    });

    test('returns 0 for control characters without direct mapping', () {
      expect(unicodeToKeysym(0x0000), 0);
      expect(unicodeToKeysym(0x001F), 0);
    });
  });

  group('VncPixelFormat', () {
    test('rgba8888 matches Flutter RGBA8888 layout', () {
      const fmt = VncPixelFormat.rgba8888;
      expect(fmt.bitsPerPixel, 32);
      expect(fmt.depth, 24);
      expect(fmt.bigEndian, isFalse);
      expect(fmt.trueColor, isTrue);
      expect(fmt.redShift, 0);
      expect(fmt.greenShift, 8);
      expect(fmt.blueShift, 16);
    });
  });
}
```

- [ ] **Step 3: Run test to verify it fails**

Run: `dart test app_lib/vnc/test/keysym_test.dart`
Expected: FAIL (missing `app_vnc.dart` / undefined symbols).

- [ ] **Step 4: Implement models, exceptions, keysyms, and barrel export**

Create `app_lib/vnc/lib/src/models/vnc_exceptions.dart`:
```dart
sealed class VncException implements Exception {
  const VncException(this.message, [this.cause]);

  final String message;
  final Object? cause;

  @override
  String toString() => '$runtimeType: $message${cause != null ? ' ($cause)' : ''}';
}

final class VncConnectionException extends VncException {
  const VncConnectionException(super.message, [super.cause]);
}

final class VncSshTunnelException extends VncException {
  const VncSshTunnelException(super.message, [super.cause]);
}

final class VncAuthenticationException extends VncException {
  const VncAuthenticationException(super.message, [super.cause]);
}

final class VncUnsupportedSecurityTypeException extends VncException {
  const VncUnsupportedSecurityTypeException(
    this.offeredTypes, {
    String? message,
  }) : super(
          message ??
              'Server offered unsupported VNC security types: $offeredTypes',
        );

  final List<int> offeredTypes;
}

final class VncProtocolException extends VncException {
  const VncProtocolException(super.message, [super.cause]);
}
```

Create `app_lib/vnc/lib/src/models/vnc_models.dart`:
```dart
import 'dart:typed_data';
import 'package:equatable/equatable.dart';

enum VncAuthPreference {
  auto(0),
  none(1),
  vncPassword(2),
  appleArd(30);

  const VncAuthPreference(this.code);
  final int code;

  static VncAuthPreference fromCode(int code) =>
      VncAuthPreference.values.firstWhere(
        (v) => v.code == code,
        orElse: () => VncAuthPreference.auto,
      );
}

class VncSshTunnelConfig extends Equatable {
  const VncSshTunnelConfig({
    required this.host,
    this.port = 22,
    required this.username,
    this.password,
    this.privateKeyPem,
    this.privateKeyPassphrase,
  });

  final String host;
  final int port;
  final String username;
  final String? password;
  final String? privateKeyPem;
  final String? privateKeyPassphrase;

  @override
  List<Object?> get props => [
        host,
        port,
        username,
        password,
        privateKeyPem,
        privateKeyPassphrase,
      ];
}

class VncCredentials extends Equatable {
  const VncCredentials({this.username, this.password});

  final String? username;
  final String? password;

  @override
  List<Object?> get props => [username, password];
}

class VncConnectionConfig extends Equatable {
  const VncConnectionConfig({
    required this.host,
    this.port = 5900,
    this.authPreference = VncAuthPreference.auto,
    this.credentials = const VncCredentials(),
    this.sshTunnel,
    this.viewOnly = false,
    this.sharedDesktop = true,
    this.connectTimeout = const Duration(seconds: 15),
  });

  final String host;
  final int port;
  final VncAuthPreference authPreference;
  final VncCredentials credentials;
  final VncSshTunnelConfig? sshTunnel;
  final bool viewOnly;
  final bool sharedDesktop;
  final Duration connectTimeout;

  @override
  List<Object?> get props => [
        host,
        port,
        authPreference,
        credentials,
        sshTunnel,
        viewOnly,
        sharedDesktop,
        connectTimeout,
      ];
}

class VncPixelFormat extends Equatable {
  const VncPixelFormat({
    required this.bitsPerPixel,
    required this.depth,
    required this.bigEndian,
    required this.trueColor,
    required this.redMax,
    required this.greenMax,
    required this.blueMax,
    required this.redShift,
    required this.greenShift,
    required this.blueShift,
  });

  static const rgba8888 = VncPixelFormat(
    bitsPerPixel: 32,
    depth: 24,
    bigEndian: false,
    trueColor: true,
    redMax: 255,
    greenMax: 255,
    blueMax: 255,
    redShift: 0,
    greenShift: 8,
    blueShift: 16,
  );

  final int bitsPerPixel;
  final int depth;
  final bool bigEndian;
  final bool trueColor;
  final int redMax;
  final int greenMax;
  final int blueMax;
  final int redShift;
  final int greenShift;
  final int blueShift;

  int get bytesPerPixel => bitsPerPixel ~/ 8;

  Uint8List toBytes() {
    final bd = ByteData(16)
      ..setUint8(0, bitsPerPixel)
      ..setUint8(1, depth)
      ..setUint8(2, bigEndian ? 1 : 0)
      ..setUint8(3, trueColor ? 1 : 0)
      ..setUint16(4, redMax, Endian.big)
      ..setUint16(6, greenMax, Endian.big)
      ..setUint16(8, blueMax, Endian.big)
      ..setUint8(10, redShift)
      ..setUint8(11, greenShift)
      ..setUint8(12, blueShift);
    return bd.buffer.asUint8List();
  }

  factory VncPixelFormat.fromBytes(Uint8List bytes, [int offset = 0]) {
    final bd = ByteData.sublistView(bytes, offset, offset + 16);
    return VncPixelFormat(
      bitsPerPixel: bd.getUint8(0),
      depth: bd.getUint8(1),
      bigEndian: bd.getUint8(2) != 0,
      trueColor: bd.getUint8(3) != 0,
      redMax: bd.getUint16(4, Endian.big),
      greenMax: bd.getUint16(6, Endian.big),
      blueMax: bd.getUint16(8, Endian.big),
      redShift: bd.getUint8(10),
      greenShift: bd.getUint8(11),
      blueShift: bd.getUint8(12),
    );
  }

  @override
  List<Object?> get props => [
        bitsPerPixel,
        depth,
        bigEndian,
        trueColor,
        redMax,
        greenMax,
        blueMax,
        redShift,
        greenShift,
        blueShift,
      ];
}

class VncDesktopInfo extends Equatable {
  const VncDesktopInfo({
    required this.name,
    required this.width,
    required this.height,
    required this.protocolVersion,
    required this.securityType,
  });

  final String name;
  final int width;
  final int height;
  final String protocolVersion;
  final int securityType;

  @override
  List<Object?> get props => [name, width, height, protocolVersion, securityType];
}

class VncCursorData extends Equatable {
  const VncCursorData({
    required this.width,
    required this.height,
    required this.hotspotX,
    required this.hotspotY,
    required this.rgbaPixels,
  });

  final int width;
  final int height;
  final int hotspotX;
  final int hotspotY;
  final Uint8List rgbaPixels;

  @override
  List<Object?> get props => [width, height, hotspotX, hotspotY, rgbaPixels.length];
}

class VncFrameData {
  const VncFrameData({
    required this.frameId,
    required this.width,
    required this.height,
    required this.rgbaPixels,
  });

  final int frameId;
  final int width;
  final int height;
  final Uint8List rgbaPixels;
}

class VncDiscoveredHost extends Equatable {
  const VncDiscoveredHost({
    required this.name,
    required this.host,
    required this.port,
    this.addresses = const [],
  });

  final String name;
  final String host;
  final int port;
  final List<String> addresses;

  String get preferredAddress => addresses.isNotEmpty ? addresses.first : host;
  String get id => '$preferredAddress:$port';

  @override
  List<Object?> get props => [name, host, port, addresses];
}
```

Create `app_lib/vnc/lib/src/protocol/keysyms.dart`:
```dart
abstract final class X11Keysym {
  static const int backSpace = 0xFF08;
  static const int tab = 0xFF09;
  static const int returnKey = 0xFF0D;
  static const int escape = 0xFF1B;
  static const int insert = 0xFF63;
  static const int delete = 0xFFFF;
  static const int home = 0xFF50;
  static const int left = 0xFF51;
  static const int up = 0xFF52;
  static const int right = 0xFF53;
  static const int down = 0xFF54;
  static const int pageUp = 0xFF55;
  static const int pageDown = 0xFF56;
  static const int end = 0xFF57;

  static const int f1 = 0xFFBE;
  static const int f2 = 0xFFBF;
  static const int f3 = 0xFFC0;
  static const int f4 = 0xFFC1;
  static const int f5 = 0xFFC2;
  static const int f6 = 0xFFC3;
  static const int f7 = 0xFFC4;
  static const int f8 = 0xFFC5;
  static const int f9 = 0xFFC6;
  static const int f10 = 0xFFC7;
  static const int f11 = 0xFFC8;
  static const int f12 = 0xFFC9;

  static const int shiftL = 0xFFE1;
  static const int shiftR = 0xFFE2;
  static const int controlL = 0xFFE3;
  static const int controlR = 0xFFE4;
  static const int capsLock = 0xFFE5;
  static const int metaL = 0xFFE7;
  static const int metaR = 0xFFE8;
  static const int altL = 0xFFE9;
  static const int altR = 0xFFEA;
  static const int superL = 0xFFEB; // macOS Left Command
  static const int superR = 0xFFEC; // macOS Right Command
}

/// Converts a Unicode scalar value to an X11 keysym per RFC 6143 §7.5.4.
int unicodeToKeysym(int codePoint) {
  if (codePoint >= 0x0020 && codePoint <= 0x007E) return codePoint;
  if (codePoint >= 0x00A0 && codePoint <= 0x00FF) return codePoint;
  if (codePoint >= 0x0100 && codePoint <= 0x10FFFF) {
    return 0x01000000 | codePoint;
  }
  return 0;
}
```

Create `app_lib/vnc/lib/app_vnc.dart`:
```dart
export 'src/models/vnc_exceptions.dart';
export 'src/models/vnc_models.dart';
export 'src/protocol/keysyms.dart';
```

- [ ] **Step 5: Run test and commit**

Run: `dart test app_lib/vnc/test/keysym_test.dart`
Expected: PASS (5 tests).

```bash
git add pubspec.yaml app_lib/vnc/
git commit -m "feat(vnc): scaffold app_vnc package with models, exceptions, and keysyms"
```

---

### Task 2: BufferedByteReader & VNC/ARD Cryptographic Primitives

**Files:**
- Create: `app_lib/vnc/lib/src/protocol/byte_reader.dart`
- Create: `app_lib/vnc/lib/src/crypto/vnc_des.dart`
- Create: `app_lib/vnc/lib/src/crypto/ard_auth.dart`
- Modify: `app_lib/vnc/lib/app_vnc.dart`
- Test: `app_lib/vnc/test/vnc_crypto_test.dart`

- [ ] **Step 1: Write failing crypto & byte-reader tests (`app_lib/vnc/test/vnc_crypto_test.dart`)**

```dart
import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:app_vnc/app_vnc.dart';
import 'package:crypto/crypto.dart';
import 'package:pointycastle/export.dart';
import 'package:test/test.dart';

void main() {
  group('BufferedByteReader', () {
    test('reads exact lengths across arbitrary chunk boundaries', () async {
      final controller = StreamController<Uint8List>();
      final reader = BufferedByteReader(controller.stream);

      controller.add(Uint8List.fromList([0x01, 0x02]));
      controller.add(Uint8List.fromList([0x03, 0x04, 0x05, 0x06]));
      await controller.close();

      expect(await reader.readUint16(), 0x0102);
      expect(await reader.readUint32(), 0x03040506);
      await expectLater(reader.readUint8(), throwsA(isA<VncConnectionException>()));
    });
  });

  group('VncDes (RFC 6143 VNC Auth)', () {
    test('reverses bit order of each password byte per RFB spec', () {
      // 0x80 (1000_0000) -> 0x01 (0000_0001), 0x5A (0101_1010) -> 0x5A
      expect(VncDes.reverseBits(0x80), 0x01);
      expect(VncDes.reverseBits(0x01), 0x80);
      expect(VncDes.reverseBits(0xC3), 0xC3);
      expect(VncDes.reverseBits(0x0F), 0xF0);
    });

    test('matches known DES-ECB NIST vector before bit reversal', () {
      // Standard DES test vector: key=0x0123456789ABCDEF, pt=0x0123456789ABCDEF -> ct=0x85E813540F0AB405
      final key = Uint8List.fromList([0x01, 0x23, 0x45, 0x67, 0x89, 0xAB, 0xCD, 0xEF]);
      final pt = Uint8List.fromList([0x01, 0x23, 0x45, 0x67, 0x89, 0xAB, 0xCD, 0xEF]);
      final ct = VncDes.encryptBlock(pt, key);
      expect(ct, Uint8List.fromList([0x85, 0xE8, 0x13, 0x54, 0x0F, 0x0A, 0xB4, 0x05]));
    });

    test('encrypts 16-byte VNC challenge into 16-byte response', () {
      final challenge = Uint8List.fromList(List.generate(16, (i) => i));
      final response = VncDes.encryptChallenge(challenge, 'secret12');
      expect(response.length, 16);
      // Verify determinism and password truncation at 8 chars
      expect(response, VncDes.encryptChallenge(challenge, 'secret12extra'));
    });
  });

  group('ArdAuthCrypto (macOS Security Type 30)', () {
    test('computes DH public key, MD5 AES key, and decryptable 128B credential block', () {
      // Small deterministic prime p=0xFFFFFFFB (4-byte keyLength) for exact verification
      const generator = 5;
      const keyLength = 4;
      final prime = BigInt.parse('FFFFFFFB', radix: 16);
      final serverPriv = BigInt.from(0x1234567);
      final serverPub = BigInt.from(generator).modPow(serverPriv, prime);
      final clientPriv = BigInt.from(0x7654321);

      final result = ArdAuthCrypto.buildResponse(
        generator: generator,
        keyLength: keyLength,
        primeBytes: ArdAuthCrypto.bigIntToFixedBytes(prime, keyLength),
        serverPublicKeyBytes: ArdAuthCrypto.bigIntToFixedBytes(serverPub, keyLength),
        username: 'gao',
        password: 'mac-password!',
        clientPrivateKeyOverride: clientPriv,
      );

      expect(result.encryptedCredentials.length, 128);
      expect(result.clientPublicKey.length, keyLength);

      // Server side: derive same shared secret using clientPublicKey^serverPriv mod prime
      final clientPubBig = ArdAuthCrypto.bytesToBigInt(result.clientPublicKey);
      final serverShared = clientPubBig.modPow(serverPriv, prime);
      final serverAesKey = Uint8List.fromList(
        md5.convert(ArdAuthCrypto.bigIntToFixedBytes(serverShared, keyLength)).bytes,
      );

      // Decrypt 128 bytes with AES-128-ECB and verify username & password NUL-terminated
      final aes = AESEngine()..init(false, KeyParameter(serverAesKey));
      final plain = Uint8List(128);
      for (var off = 0; off < 128; off += 16) {
        aes.processBlock(result.encryptedCredentials, off, plain, off);
      }

      String readCStr(Uint8List buf, int offset, int maxLen) {
        var end = offset;
        while (end < offset + maxLen && buf[end] != 0) {
          end++;
        }
        return utf8.decode(buf.sublist(offset, end));
      }

      expect(readCStr(plain, 0, 64), 'gao');
      expect(readCStr(plain, 64, 64), 'mac-password!');
    });
  });
}
```

- [ ] **Step 2: Run test to verify it fails**

Run: `dart test app_lib/vnc/test/vnc_crypto_test.dart`
Expected: FAIL (missing classes).

- [ ] **Step 3: Implement `BufferedByteReader`, `VncDes`, and `ArdAuthCrypto`**

Create `app_lib/vnc/lib/src/protocol/byte_reader.dart`:
```dart
import 'dart:async';
import 'dart:collection';
import 'dart:typed_data';

import '../models/vnc_exceptions.dart';

class BufferedByteReader {
  BufferedByteReader(Stream<Uint8List> stream) {
    _sub = stream.listen(
      (chunk) {
        if (chunk.isEmpty) return;
        _chunks.add(chunk);
        _bufferedBytes += chunk.length;
        _tryFulfill();
      },
      onError: (Object err, StackTrace st) {
        _error = err;
        _closed = true;
        _failWaiter(VncConnectionException('Transport read error', err));
      },
      onDone: () {
        _closed = true;
        _failWaiter(const VncConnectionException('Connection closed by remote host'));
      },
    );
  }

  late final StreamSubscription<Uint8List> _sub;
  final Queue<Uint8List> _chunks = Queue<Uint8List>();
  int _headOffset = 0;
  int _bufferedBytes = 0;
  bool _closed = false;
  Object? _error;

  Completer<Uint8List>? _waiter;
  int _neededBytes = 0;

  Future<Uint8List> readBytes(int count) {
    if (count == 0) return Future.value(Uint8List(0));
    if (_bufferedBytes >= count) {
      return Future.value(_take(count));
    }
    if (_closed) {
      return Future.error(
        VncConnectionException(
          'Unexpected EOF while reading $count bytes',
          _error,
        ),
      );
    }
    final completer = Completer<Uint8List>();
    _waiter = completer;
    _neededBytes = count;
    return completer.future;
  }

  Future<int> readUint8() async => (await readBytes(1))[0];

  Future<int> readUint16() async {
    final b = await readBytes(2);
    return (b[0] << 8) | b[1];
  }

  Future<int> readUint32() async {
    final b = await readBytes(4);
    return (b[0] << 24) | (b[1] << 16) | (b[2] << 8) | b[3];
  }

  Future<int> readInt32() async {
    final b = await readBytes(4);
    return ByteData.sublistView(b).getInt32(0, Endian.big);
  }

  Future<void> skip(int count) async {
    await readBytes(count);
  }

  void _tryFulfill() {
    if (_waiter != null && _bufferedBytes >= _neededBytes) {
      final completer = _waiter!;
      final count = _neededBytes;
      _waiter = null;
      _neededBytes = 0;
      completer.complete(_take(count));
    }
  }

  void _failWaiter(Object error) {
    final completer = _waiter;
    if (completer != null && !completer.isCompleted) {
      _waiter = null;
      _neededBytes = 0;
      completer.completeError(error);
    }
  }

  Uint8List _take(int count) {
    final out = Uint8List(count);
    var written = 0;
    while (written < count) {
      final head = _chunks.first;
      final available = head.length - _headOffset;
      final toCopy = (count - written) < available ? (count - written) : available;
      out.setRange(written, written + toCopy, head, _headOffset);
      written += toCopy;
      _headOffset += toCopy;
      _bufferedBytes -= toCopy;
      if (_headOffset == head.length) {
        _chunks.removeFirst();
        _headOffset = 0;
      }
    }
    return out;
  }

  Future<void> dispose() => _sub.cancel();
}
```

Create `app_lib/vnc/lib/src/crypto/vnc_des.dart` (full FIPS 46-3 DES single-block cipher + RFB bit-reversed 8-byte key derivation):
```dart
import 'dart:convert';
import 'dart:typed_data';

/// Standard DES-ECB implementation for RFB Security Type 2 (VNC Authentication).
abstract final class VncDes {
  static const _ip = [
    58, 50, 42, 34, 26, 18, 10, 2, 60, 52, 44, 36, 28, 20, 12, 4,
    62, 54, 46, 38, 30, 22, 14, 6, 64, 56, 48, 40, 32, 24, 16, 8,
    57, 49, 41, 33, 25, 17, 9, 1, 59, 51, 43, 35, 27, 19, 11, 3,
    61, 53, 45, 37, 29, 21, 13, 5, 63, 55, 47, 39, 31, 23, 15, 7,
  ];
  static const _fp = [
    40, 8, 48, 16, 56, 24, 64, 32, 39, 7, 47, 15, 55, 23, 63, 31,
    38, 6, 46, 14, 54, 22, 62, 30, 37, 5, 45, 13, 53, 21, 61, 29,
    36, 4, 44, 12, 52, 20, 60, 28, 35, 3, 43, 11, 51, 19, 59, 27,
    34, 2, 42, 10, 50, 18, 58, 26, 33, 1, 41, 9, 49, 17, 57, 25,
  ];
  static const _pc1 = [
    57, 49, 41, 33, 25, 17, 9, 1, 58, 50, 42, 34, 26, 18,
    10, 2, 59, 51, 43, 35, 27, 19, 11, 3, 60, 52, 44, 36,
    63, 55, 47, 39, 31, 23, 15, 7, 62, 54, 46, 38, 30, 22,
    14, 6, 61, 53, 45, 37, 29, 21, 13, 5, 28, 20, 12, 4,
  ];
  static const _pc2 = [
    14, 17, 11, 24, 1, 5, 3, 28, 15, 6, 21, 10,
    23, 19, 12, 4, 26, 8, 16, 7, 27, 20, 13, 2,
    41, 52, 31, 37, 47, 55, 30, 40, 51, 45, 33, 48,
    44, 49, 39, 56, 34, 53, 46, 42, 50, 36, 29, 32,
  ];
  static const _shifts = [1, 1, 2, 2, 2, 2, 2, 2, 1, 2, 2, 2, 2, 2, 2, 1];
  static const _e = [
    32, 1, 2, 3, 4, 5, 4, 5, 6, 7, 8, 9,
    8, 9, 10, 11, 12, 13, 12, 13, 14, 15, 16, 17,
    16, 17, 18, 19, 20, 21, 20, 21, 22, 23, 24, 25,
    24, 25, 26, 27, 28, 29, 28, 29, 30, 31, 32, 1,
  ];
  static const _p = [
    16, 7, 20, 21, 29, 12, 28, 17, 1, 15, 23, 26, 5, 18, 31, 10,
    2, 8, 24, 14, 32, 27, 3, 9, 19, 13, 30, 6, 22, 11, 4, 25,
  ];
  static const _s = [
    [
      14, 4, 13, 1, 2, 15, 11, 8, 3, 10, 6, 12, 5, 9, 0, 7,
      0, 15, 7, 4, 14, 2, 13, 1, 10, 6, 12, 11, 9, 5, 3, 8,
      4, 1, 14, 8, 13, 6, 2, 11, 15, 12, 9, 7, 3, 10, 5, 0,
      15, 12, 8, 2, 4, 9, 1, 7, 5, 11, 3, 14, 10, 0, 6, 13,
    ],
    [
      15, 1, 8, 14, 6, 11, 3, 4, 9, 7, 2, 13, 12, 0, 5, 10,
      3, 13, 4, 7, 15, 2, 8, 14, 12, 0, 1, 10, 6, 9, 11, 5,
      0, 14, 7, 11, 10, 4, 13, 1, 5, 8, 12, 6, 9, 3, 2, 15,
      13, 8, 10, 1, 3, 15, 4, 2, 11, 6, 7, 12, 0, 5, 14, 9,
    ],
    [
      10, 0, 9, 14, 6, 3, 15, 5, 1, 13, 12, 7, 11, 4, 2, 8,
      13, 7, 0, 9, 3, 4, 6, 10, 2, 8, 5, 14, 12, 11, 15, 1,
      13, 6, 4, 9, 8, 15, 3, 0, 11, 1, 2, 12, 5, 10, 14, 7,
      1, 10, 13, 0, 6, 9, 8, 7, 4, 15, 14, 3, 11, 5, 2, 12,
    ],
    [
      7, 13, 14, 3, 0, 6, 9, 10, 1, 2, 8, 5, 11, 12, 4, 15,
      13, 8, 11, 5, 6, 15, 0, 3, 4, 7, 2, 12, 1, 10, 14, 9,
      10, 6, 9, 0, 12, 11, 7, 13, 15, 1, 3, 14, 5, 2, 8, 4,
      3, 15, 0, 6, 10, 1, 13, 8, 9, 4, 5, 11, 12, 7, 2, 14,
    ],
    [
      2, 12, 4, 1, 7, 10, 11, 6, 8, 5, 3, 15, 13, 0, 14, 9,
      14, 11, 2, 12, 4, 7, 13, 1, 5, 0, 15, 10, 3, 9, 8, 6,
      4, 2, 1, 11, 10, 13, 7, 8, 15, 9, 12, 5, 6, 3, 0, 14,
      11, 8, 12, 7, 1, 14, 2, 13, 6, 15, 0, 9, 10, 4, 5, 3,
    ],
    [
      12, 1, 10, 15, 9, 2, 6, 8, 0, 13, 3, 4, 14, 7, 5, 11,
      10, 15, 4, 2, 7, 12, 9, 5, 6, 1, 13, 14, 0, 11, 3, 8,
      9, 14, 15, 5, 2, 8, 12, 3, 7, 0, 4, 10, 1, 13, 11, 6,
      4, 3, 2, 12, 9, 5, 15, 10, 11, 14, 1, 7, 6, 0, 8, 13,
    ],
    [
      4, 11, 2, 14, 15, 0, 8, 13, 3, 12, 9, 7, 5, 10, 6, 1,
      13, 0, 11, 7, 4, 9, 1, 10, 14, 3, 5, 12, 2, 15, 8, 6,
      1, 4, 11, 13, 12, 3, 7, 14, 10, 15, 6, 8, 0, 5, 9, 2,
      6, 11, 13, 8, 1, 4, 10, 7, 9, 5, 0, 15, 14, 2, 3, 12,
    ],
    [
      13, 2, 8, 4, 6, 15, 11, 1, 10, 9, 3, 14, 5, 0, 12, 7,
      1, 15, 13, 8, 10, 3, 7, 4, 12, 5, 6, 11, 0, 14, 9, 2,
      7, 11, 4, 1, 9, 12, 14, 2, 0, 6, 10, 13, 15, 3, 5, 8,
      2, 1, 14, 7, 4, 10, 8, 13, 15, 12, 9, 0, 3, 5, 6, 11,
    ],
  ];

  static int reverseBits(int byte) {
    var b = byte & 0xFF;
    var r = 0;
    for (var i = 0; i < 8; i++) {
      r = (r << 1) | (b & 1);
      b >>= 1;
    }
    return r;
  }

  static int _getBit(int val, int bit1Based, int width) =>
      (val >> (width - bit1Based)) & 1;

  static int _permute(int val, List<int> table, int inWidth) {
    var out = 0;
    for (final pos in table) {
      out = (out << 1) | _getBit(val, pos, inWidth);
    }
    return out;
  }

  static int _rotL28(int val, int shift) =>
      ((val << shift) | (val >> (28 - shift))) & 0x0FFFFFFF;

  static List<int> _subkeys(int key64) {
    final k56 = _permute(key64, _pc1, 64);
    var c = (k56 >> 28) & 0x0FFFFFFF;
    var d = k56 & 0x0FFFFFFF;
    final keys = List<int>.filled(16, 0);
    for (var i = 0; i < 16; i++) {
      c = _rotL28(c, _shifts[i]);
      d = _rotL28(d, _shifts[i]);
      keys[i] = _permute((c << 28) | d, _pc2, 56);
    }
    return keys;
  }

  static int _feistel(int r, int subkey) {
    final expanded = _permute(r, _e, 32) ^ subkey;
    var sOut = 0;
    for (var i = 0; i < 8; i++) {
      final chunk = (expanded >> (42 - i * 6)) & 0x3F;
      final row = ((chunk & 0x20) >> 4) | (chunk & 0x01);
      final col = (chunk >> 1) & 0x0F;
      sOut = (sOut << 4) | _s[i][(row << 4) | col];
    }
    return _permute(sOut, _p, 32);
  }

  static Uint8List encryptBlock(Uint8List block8, Uint8List key8) {
    var key64 = 0;
    var data64 = 0;
    for (var i = 0; i < 8; i++) {
      key64 = (key64 << 8) | key8[i];
      data64 = (data64 << 8) | block8[i];
    }
    final subkeys = _subkeys(key64);
    final ip = _permute(data64, _ip, 64);
    var l = (ip >> 32) & 0xFFFFFFFF;
    var r = ip & 0xFFFFFFFF;
    for (var i = 0; i < 16; i++) {
      final nextR = l ^ _feistel(r, subkeys[i]);
      l = r;
      r = nextR;
    }
    final preOut = (r << 32) | l;
    var cipher = _permute(preOut, _fp, 64);
    final out = Uint8List(8);
    for (var i = 7; i >= 0; i--) {
      out[i] = cipher & 0xFF;
      cipher >>= 8;
    }
    return out;
  }

  static Uint8List encryptChallenge(Uint8List challenge16, String password) {
    final raw = utf8.encode(password);
    final key = Uint8List(8);
    for (var i = 0; i < 8 && i < raw.length; i++) {
      key[i] = reverseBits(raw[i]);
    }
    final out = Uint8List(16);
    out.setRange(0, 8, encryptBlock(challenge16.sublist(0, 8), key));
    out.setRange(8, 16, encryptBlock(challenge16.sublist(8, 16), key));
    return out;
  }
}
```

Create `app_lib/vnc/lib/src/crypto/ard_auth.dart`:
```dart
import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';

import 'package:crypto/crypto.dart';
import 'package:pointycastle/export.dart';

class ArdAuthResponse {
  const ArdAuthResponse({
    required this.encryptedCredentials,
    required this.clientPublicKey,
  });

  final Uint8List encryptedCredentials;
  final Uint8List clientPublicKey;
}

/// Cryptographic handshake for Apple Remote Desktop (RFB Security Type 30).
abstract final class ArdAuthCrypto {
  static BigInt bytesToBigInt(Uint8List bytes) {
    var result = BigInt.zero;
    for (final b in bytes) {
      result = (result << 8) | BigInt.from(b);
    }
    return result;
  }

  static Uint8List bigIntToFixedBytes(BigInt value, int length) {
    final out = Uint8List(length);
    var v = value;
    for (var i = length - 1; i >= 0; i--) {
      out[i] = (v & BigInt.from(0xFF)).toInt();
      v >>= 8;
    }
    return out;
  }

  static ArdAuthResponse buildResponse({
    required int generator,
    required int keyLength,
    required Uint8List primeBytes,
    required Uint8List serverPublicKeyBytes,
    required String username,
    required String password,
    BigInt? clientPrivateKeyOverride,
  }) {
    final rng = Random.secure();
    final prime = bytesToBigInt(primeBytes);
    final serverPub = bytesToBigInt(serverPublicKeyBytes);
    final g = BigInt.from(generator);

    final priv = clientPrivateKeyOverride ??
        bytesToBigInt(
          Uint8List.fromList(List.generate(keyLength, (_) => rng.nextInt(256))),
        );

    final clientPub = g.modPow(priv, prime);
    final shared = serverPub.modPow(priv, prime);
    final sharedBytes = bigIntToFixedBytes(shared, keyLength);
    final aesKey = Uint8List.fromList(md5.convert(sharedBytes).bytes);

    final plain = Uint8List(128);
    _writeNullTerminatedField(plain, 0, username, rng);
    _writeNullTerminatedField(plain, 64, password, rng);

    final aes = AESEngine()..init(true, KeyParameter(aesKey));
    final encrypted = Uint8List(128);
    for (var off = 0; off < 128; off += 16) {
      aes.processBlock(plain, off, encrypted, off);
    }

    return ArdAuthResponse(
      encryptedCredentials: encrypted,
      clientPublicKey: bigIntToFixedBytes(clientPub, keyLength),
    );
  }

  static void _writeNullTerminatedField(
    Uint8List target,
    int offset,
    String value,
    Random rng,
  ) {
    final raw = utf8.encode(value);
    final len = raw.length > 63 ? 63 : raw.length;
    target.setRange(offset, offset + len, raw);
    target[offset + len] = 0;
    for (var i = len + 1; i < 64; i++) {
      target[offset + i] = rng.nextInt(256);
    }
  }
}
```

Export `byte_reader.dart`, `vnc_des.dart`, and `ard_auth.dart` from `app_lib/vnc/lib/app_vnc.dart`.

- [ ] **Step 4: Run tests and commit**

Run: `dart test app_lib/vnc/test/vnc_crypto_test.dart`
Expected: PASS (all 5 tests).

```bash
git add app_lib/vnc/
git commit -m "feat(vnc): add BufferedByteReader, VNC DES, and macOS ARD Type 30 crypto"
```

---

### Task 3: `VncTransport` Abstraction (TCP & `app_ssh` Tunnel)

**Files:**
- Create: `app_lib/vnc/lib/src/transport/vnc_transport.dart`
- Modify: `app_lib/vnc/lib/app_vnc.dart`
- Test: `app_lib/vnc/test/transport_test.dart`

- [ ] **Step 1: Write failing transport test (`app_lib/vnc/test/transport_test.dart`)**

```dart
import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:app_vnc/app_vnc.dart';
import 'package:test/test.dart';

void main() {
  test('TcpVncTransport connects, transfers bytes, and closes cleanly', () async {
    final server = await ServerSocket.bind(InternetAddress.loopbackIPv4, 0);
    final received = Completer<Uint8List>();
    server.listen((client) {
      client.listen((data) {
        if (!received.isCompleted) received.complete(Uint8List.fromList(data));
        client.add(Uint8List.fromList([9, 8, 7]));
      });
    });

    final transport = await TcpVncTransport.connect(
      host: InternetAddress.loopbackIPv4.address,
      port: server.port,
      timeout: const Duration(seconds: 5),
    );
    transport.add(Uint8List.fromList([1, 2, 3]));
    await transport.flush();

    expect(await received.future, Uint8List.fromList([1, 2, 3]));
    expect(await transport.stream.first, Uint8List.fromList([9, 8, 7]));

    await transport.close();
    await server.close();
  });

  test('TcpVncTransport wraps connection failures as VncConnectionException', () async {
    await expectLater(
      TcpVncTransport.connect(
        host: '127.0.0.1',
        port: 1,
        timeout: const Duration(seconds: 2),
      ),
      throwsA(isA<VncConnectionException>()),
    );
  });
}
```

- [ ] **Step 2: Run test to verify it fails**

Run: `dart test app_lib/vnc/test/transport_test.dart`
Expected: FAIL.

- [ ] **Step 3: Implement `VncTransport`, `TcpVncTransport`, and `SshTunnelVncTransport`**

Create `app_lib/vnc/lib/src/transport/vnc_transport.dart`:
```dart
import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:app_ssh/app_ssh.dart';

import '../models/vnc_exceptions.dart';
import '../models/vnc_models.dart';

abstract interface class VncTransport {
  Stream<Uint8List> get stream;
  void add(Uint8List data);
  Future<void> flush();
  Future<void> close();
  Future<void> get done;
}

class TcpVncTransport implements VncTransport {
  TcpVncTransport._(this._socket);

  final Socket _socket;

  static Future<TcpVncTransport> connect({
    required String host,
    required int port,
    Duration timeout = const Duration(seconds: 15),
  }) async {
    try {
      final socket = await Socket.connect(host, port, timeout: timeout);
      socket.setOption(SocketOption.tcpNoDelay, true);
      return TcpVncTransport._(socket);
    } on SocketException catch (e) {
      throw VncConnectionException('Failed to connect to $host:$port', e);
    } on TimeoutException catch (e) {
      throw VncConnectionException('Connection to $host:$port timed out', e);
    }
  }

  @override
  Stream<Uint8List> get stream => _socket;

  @override
  void add(Uint8List data) => _socket.add(data);

  @override
  Future<void> flush() => _socket.flush();

  @override
  Future<void> close() async {
    try {
      await _socket.close();
    } catch (_) {
      _socket.destroy();
    }
  }

  @override
  Future<void> get done => _socket.done;
}

class SshTunnelVncTransport implements VncTransport {
  SshTunnelVncTransport._(this._client, this._channel);

  final SSHClient _client;
  final SSHForwardChannel _channel;

  static Future<SshTunnelVncTransport> connect({
    required VncSshTunnelConfig tunnel,
    required String remoteHost,
    required int remotePort,
    Duration timeout = const Duration(seconds: 15),
  }) async {
    SSHClient? client;
    try {
      final socket = await SSHSocket.connect(
        tunnel.host,
        tunnel.port,
        timeout: timeout,
      );
      List<SSHKeyPair>? identities;
      if (tunnel.privateKeyPem != null && tunnel.privateKeyPem!.isNotEmpty) {
        identities = SSHKeyPair.fromPem(
          tunnel.privateKeyPem!,
          tunnel.privateKeyPassphrase,
        );
      }
      client = SSHClient(
        socket,
        username: tunnel.username,
        identities: identities,
        onPasswordRequest: tunnel.password != null ? () => tunnel.password : null,
      );
      await client.authenticated.timeout(timeout);
      final channel = await client
          .forwardLocal(remoteHost, remotePort)
          .timeout(timeout);
      return SshTunnelVncTransport._(client, channel);
    } catch (e) {
      client?.close();
      throw VncSshTunnelException(
        'SSH tunnel via ${tunnel.host}:${tunnel.port} to $remoteHost:$remotePort failed',
        e,
      );
    }
  }

  @override
  Stream<Uint8List> get stream => _channel.stream;

  @override
  void add(Uint8List data) => _channel.sink.add(data);

  @override
  Future<void> flush() async {}

  @override
  Future<void> close() async {
    try {
      await _channel.close();
    } catch (_) {
      _channel.destroy();
    } finally {
      _client.close();
    }
  }

  @override
  Future<void> get done => _channel.done;
}
```

Export `src/transport/vnc_transport.dart` in `app_lib/vnc/lib/app_vnc.dart`.

- [ ] **Step 4: Run tests and commit**

Run: `dart test app_lib/vnc/test/transport_test.dart`
Expected: PASS.

```bash
git add app_lib/vnc/
git commit -m "feat(vnc): add VncTransport for direct TCP and app_ssh tunneling"
```

---

### Task 4: RFB Handshake & Authentication State Machine (including `RFB 003.889` & ARD Type 30)

**Files:**
- Create: `app_lib/vnc/lib/src/protocol/rfb_handshake.dart`
- Modify: `app_lib/vnc/lib/app_vnc.dart`
- Test: `app_lib/vnc/test/rfb_handshake_test.dart`

- [ ] **Step 1: Write failing handshake tests (`app_lib/vnc/test/rfb_handshake_test.dart`)**

Build an in-memory `MockVncTransport` helper in the test that simulates:
1. macOS server sending `RFB 003.889\n`, offering security types `[30, 33, 35, 36]`, completing ARD DH/AES handshake, returning `SecurityResult = 0`, and sending `ServerInit` (`2560×1600`, `"MacBook Pro"`).
2. Standard RFB 3.8 server offering `[2]` (VNC Auth), verifying 16B DES challenge-response.
3. RFB 3.8 server offering `[30]` when credentials were not pre-supplied, verifying `onCredentialsRequired` callback is invoked with `requiresUsername: true`.
4. Unsupported security types `[35, 36]` throwing `VncUnsupportedSecurityTypeException([35, 36])`.
5. Bad credentials returning `SecurityResult = 1` + reason string throwing `VncAuthenticationException`.

```dart
import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:app_vnc/app_vnc.dart';
import 'package:crypto/crypto.dart';
import 'package:pointycastle/export.dart';
import 'package:test/test.dart';

class _PairTransport {
  _PairTransport() {
    client = _MemoryTransport(_s2c.stream, _c2s);
    server = _MemoryTransport(_c2s.stream, _s2c);
  }
  final _c2s = StreamController<Uint8List>();
  final _s2c = StreamController<Uint8List>();
  late final VncTransport client;
  late final VncTransport server;
}

class _MemoryTransport implements VncTransport {
  _MemoryTransport(this.stream, this._out);
  @override
  final Stream<Uint8List> stream;
  final StreamController<Uint8List> _out;
  final _done = Completer<void>();

  @override
  void add(Uint8List data) => _out.add(Uint8List.fromList(data));
  @override
  Future<void> flush() async {}
  @override
  Future<void> close() async {
    if (!_out.isClosed) await _out.close();
    if (!_done.isCompleted) _done.complete();
  }
  @override
  Future<void> get done => _done.future;
}

Uint8List _serverInitBytes(int w, int h, String name) {
  final nameBytes = utf8.encode(name);
  final bd = ByteData(24 + nameBytes.length)
    ..setUint16(0, w, Endian.big)
    ..setUint16(2, h, Endian.big);
  final buf = bd.buffer.asUint8List();
  buf.setRange(4, 20, VncPixelFormat.rgba8888.toBytes());
  bd.setUint32(20, nameBytes.length, Endian.big);
  buf.setRange(24, 24 + nameBytes.length, nameBytes);
  return buf;
}

void main() {
  test('negotiates RFB 003.889 + Apple ARD Type 30 with macOS server', () async {
    final pair = _PairTransport();
    final serverReader = BufferedByteReader(pair.server.stream);

    final serverFuture = () async {
      pair.server.add(Uint8List.fromList(ascii.encode('RFB 003.889\n')));
      final clientVer = ascii.decode(await serverReader.readBytes(12));
      expect(clientVer, 'RFB 003.008\n');

      // Offer macOS security types [30, 33, 35, 36]
      pair.server.add(Uint8List.fromList([4, 30, 33, 35, 36]));
      expect(await serverReader.readUint8(), 30);

      // Send ARD DH parameters
      const generator = 5;
      const keyLength = 4;
      final prime = BigInt.parse('FFFFFFFB', radix: 16);
      final serverPriv = BigInt.from(0x334455);
      final serverPub = BigInt.from(generator).modPow(serverPriv, prime);
      final dhPacket = BytesBuilder()
        ..add([0, generator, 0, keyLength])
        ..add(ArdAuthCrypto.bigIntToFixedBytes(prime, keyLength))
        ..add(ArdAuthCrypto.bigIntToFixedBytes(serverPub, keyLength));
      pair.server.add(dhPacket.toBytes());

      final cipher = await serverReader.readBytes(128);
      final clientPubBytes = await serverReader.readBytes(keyLength);

      // Decrypt and validate credentials
      final shared = ArdAuthCrypto.bytesToBigInt(clientPubBytes).modPow(serverPriv, prime);
      final key = Uint8List.fromList(
        md5.convert(ArdAuthCrypto.bigIntToFixedBytes(shared, keyLength)).bytes,
      );
      final aes = AESEngine()..init(false, KeyParameter(key));
      final plain = Uint8List(128);
      for (var i = 0; i < 128; i += 16) {
        aes.processBlock(cipher, i, plain, i);
      }
      expect(utf8.decode(plain.sublist(0, 3)), 'gao');
      expect(utf8.decode(plain.sublist(64, 70)), 'secret');

      // SecurityResult = OK
      pair.server.add(Uint8List.fromList([0, 0, 0, 0]));
      expect(await serverReader.readUint8(), 1); // ClientInit shared=1
      pair.server.add(_serverInitBytes(2560, 1600, 'MacBook Pro'));
    }();

    final reader = BufferedByteReader(pair.client.stream);
    final info = await RfbHandshake.perform(
      transport: pair.client,
      reader: reader,
      config: const VncConnectionConfig(
        host: 'mac.local',
        credentials: VncCredentials(username: 'gao', password: 'secret'),
      ),
    );
    await serverFuture;

    expect(info.width, 2560);
    expect(info.height, 1600);
    expect(info.name, 'MacBook Pro');
    expect(info.securityType, 30);
    await reader.dispose();
    await serverReader.dispose();
  });

  test('throws VncUnsupportedSecurityTypeException when no common type exists', () async {
    final pair = _PairTransport();
    final serverReader = BufferedByteReader(pair.server.stream);
    unawaited(() async {
      pair.server.add(Uint8List.fromList(ascii.encode('RFB 003.889\n')));
      await serverReader.readBytes(12);
      pair.server.add(Uint8List.fromList([2, 35, 36]));
    }());

    final reader = BufferedByteReader(pair.client.stream);
    await expectLater(
      RfbHandshake.perform(
        transport: pair.client,
        reader: reader,
        config: const VncConnectionConfig(host: 'mac.local'),
      ),
      throwsA(
        isA<VncUnsupportedSecurityTypeException>()
            .having((e) => e.offeredTypes, 'offeredTypes', [35, 36]),
      ),
    );
    await reader.dispose();
    await serverReader.dispose();
  });
}
```

- [ ] **Step 2: Run test to verify it fails**

Run: `dart test app_lib/vnc/test/rfb_handshake_test.dart`
Expected: FAIL.

- [ ] **Step 3: Implement `app_lib/vnc/lib/src/protocol/rfb_handshake.dart`**

Implement `RfbHandshake.perform`:
- Parse 12-byte `RFB MMM.mmm\n` (accepts `3.3`, `3.7`, `3.8`, `3.889`, or any `major == 3 && minor >= 8` by negotiating `RFB 003.008\n`).
- Security type negotiation:
  - RFB 3.3: read 4-byte security type directly (`0` = failed + reason, `1` = None, `2` = VNC Auth).
  - RFB 3.7/3.8: read `count` (`uint8`); if `0`, read 4-byte length + UTF-8 reason and throw `VncConnectionException`. Otherwise read `count` types and select based on `config.authPreference` (`auto` prefers `30 -> 2 -> 1`). Write selected 1-byte security type.
- Auth handlers:
  - `1 (None)`: read `SecurityResult` if negotiated `>= 3.8`.
  - `2 (VNC Auth)`: read 16-byte challenge; if password is empty/null, invoke `onCredentialsRequired(securityType: 2, requiresUsername: false)`; encrypt with `VncDes.encryptChallenge` and send 16 bytes; read `SecurityResult`.
  - `30 (Apple ARD)`: read `generator (2B)`, `keyLength (2B)`, `prime (keyLength B)`, `serverPubKey (keyLength B)`; if username or password missing, invoke `onCredentialsRequired(securityType: 30, requiresUsername: true)`; run `ArdAuthCrypto.buildResponse`, send `128B ciphertext + clientPubKey`; read `SecurityResult`.
- `ClientInit`: send `Uint8List.fromList([config.sharedDesktop ? 1 : 0])`.
- `ServerInit`: read `width (2B)`, `height (2B)`, `pixelFormat (16B)`, `nameLen (4B)`, `name (UTF-8)`.
- Immediately send `SetPixelFormat (0)` with `VncPixelFormat.rgba8888` and `SetEncodings (2)` with `[16 (ZRLE), 1 (CopyRect), 5 (Hextile), 0 (Raw), -223 (DesktopSize), -308 (ExtendedDesktopSize), -239 (Cursor), -224 (LastRect)]`.

Export `src/protocol/rfb_handshake.dart` from `app_lib/vnc/lib/app_vnc.dart`.

- [ ] **Step 4: Run tests and commit**

Run: `dart test app_lib/vnc/test/rfb_handshake_test.dart`
Expected: PASS.

```bash
git add app_lib/vnc/
git commit -m "feat(vnc): implement RFB handshake with 003.889 and macOS ARD Type 30 auth"
```

---

### Task 5: RGBA Framebuffer & Encodings (`Raw`, `CopyRect`, `Hextile`, `ZRLE`, `DesktopSize`, `Cursor`)

**Files:**
- Create: `app_lib/vnc/lib/src/protocol/framebuffer.dart`
- Modify: `app_lib/vnc/lib/app_vnc.dart`
- Test: `app_lib/vnc/test/framebuffer_decoder_test.dart`

- [ ] **Step 1: Write failing decoder tests (`app_lib/vnc/test/framebuffer_decoder_test.dart`)**

Test every encoding explicitly:
- `Raw (0)`: decodes 2×2 RGBA pixels with alpha forced to `0xFF`.
- `CopyRect (1)`: copies a 2×2 region including overlapping source/dest (shifting right/down without corruption).
- `Hextile (5)`: solid background tile + `AnySubrects` + `SubrectsColoured` subrect.
- `ZRLE (16)`: persistent zlib stream across two separate updates covering all 5 tile sub-encodings:
  1. `subencoding == 0` (Raw CPIXEL 3 bytes/pixel)
  2. `subencoding == 1` (Solid 1 CPIXEL fill)
  3. `subencoding 2..16` (Packed Palette 1/2/4-bit indices)
  4. `subencoding == 128` (Plain RLE)
  5. `subencoding 130..255` (Palette RLE)
- `DesktopSize (-223)`: resizes framebuffer dimensions cleanly.
- `Cursor (-239)`: builds `VncCursorData` applying the 1-bit transparency bitmask to RGBA alpha channel.

```dart
import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:app_vnc/app_vnc.dart';
import 'package:test/test.dart';

Future<void> _feedAndDecode(
  VncFramebuffer fb,
  RfbRectDecoder decoder,
  List<int> bytes, {
  required int x,
  required int y,
  required int w,
  required int h,
  required int encoding,
}) async {
  final ctrl = StreamController<Uint8List>();
  final reader = BufferedByteReader(ctrl.stream);
  ctrl.add(Uint8List.fromList(bytes));
  await ctrl.close();
  await decoder.decodeRectangle(
    reader: reader,
    framebuffer: fb,
    x: x,
    y: y,
    width: w,
    height: h,
    encoding: encoding,
  );
  await reader.dispose();
}

void main() {
  test('Raw encoding sets RGBA pixels with alpha=255', () async {
    final fb = VncFramebuffer(2, 1);
    final decoder = RfbRectDecoder();
    await _feedAndDecode(
      fb,
      decoder,
      [10, 20, 30, 0, 40, 50, 60, 0],
      x: 0,
      y: 0,
      w: 2,
      h: 1,
      encoding: RfbEncoding.raw,
    );
    expect(fb.pixels, Uint8List.fromList([10, 20, 30, 255, 40, 50, 60, 255]));
  });

  test('CopyRect handles overlapping right-shift safely', () async {
    final fb = VncFramebuffer(3, 1);
    fb.setPixel(0, 0, 1, 2, 3);
    fb.setPixel(1, 0, 4, 5, 6);
    final decoder = RfbRectDecoder();
    await _feedAndDecode(
      fb,
      decoder,
      [0, 0, 0, 0], // srcX=0, srcY=0
      x: 1,
      y: 0,
      w: 2,
      h: 1,
      encoding: RfbEncoding.copyRect,
    );
    expect(fb.pixels, Uint8List.fromList([1, 2, 3, 255, 1, 2, 3, 255, 4, 5, 6, 255]));
  });

  test('ZRLE decodes Solid, Packed Palette, Plain RLE, and Palette RLE across persistent zlib stream', () async {
    final fb = VncFramebuffer(4, 2);
    final decoder = RfbRectDecoder();
    final deflater = RawZLibFilter.deflateFilter();

    Uint8List compressTile(List<int> tilePayload) {
      deflater.process(tilePayload, 0, tilePayload.length);
      final out = BytesBuilder();
      List<int>? chunk;
      while ((chunk = deflater.processed(flush: true)) != null) {
        out.add(chunk!);
      }
      final compressed = out.toBytes();
      final header = ByteData(4)..setUint32(0, compressed.length, Endian.big);
      return Uint8List.fromList([...header.buffer.asUint8List(), ...compressed]);
    }

    // Update 1: Solid fill RGB(11, 22, 33)
    await _feedAndDecode(
      fb,
      decoder,
      compressTile([1, 11, 22, 33]),
      x: 0,
      y: 0,
      w: 4,
      h: 2,
      encoding: RfbEncoding.zrle,
    );
    expect(fb.pixels.sublist(0, 4), [11, 22, 33, 255]);

    // Update 2 (same persistent zlib stream): Plain RLE (128)
    // 3 pixels of (90,80,70) [len byte 2 => run=3], 5 pixels of (1,2,3) [len byte 4 => run=5]
    await _feedAndDecode(
      fb,
      decoder,
      compressTile([128, 90, 80, 70, 2, 1, 2, 3, 4]),
      x: 0,
      y: 0,
      w: 4,
      h: 2,
      encoding: RfbEncoding.zrle,
    );
    expect(fb.pixels.sublist(0, 4), [90, 80, 70, 255]);
    expect(fb.pixels.sublist(12, 16), [1, 2, 3, 255]);
  });

  test('DesktopSize resizes framebuffer', () async {
    final fb = VncFramebuffer(10, 10);
    final decoder = RfbRectDecoder();
    await _feedAndDecode(
      fb,
      decoder,
      const [],
      x: 0,
      y: 0,
      w: 1920,
      h: 1080,
      encoding: RfbEncoding.desktopSize,
    );
    expect(fb.width, 1920);
    expect(fb.height, 1080);
    expect(fb.pixels.length, 1920 * 1080 * 4);
  });
}
```

- [ ] **Step 2: Run test to verify it fails**

Run: `dart test app_lib/vnc/test/framebuffer_decoder_test.dart`
Expected: FAIL.

- [ ] **Step 3: Implement `app_lib/vnc/lib/src/protocol/framebuffer.dart`**

Implement:
- `RfbEncoding` constants (`raw = 0`, `copyRect = 1`, `hextile = 5`, `zrle = 16`, `desktopSize = -223`, `lastRect = -224`, `cursor = -239`, `extendedDesktopSize = -308`).
- `VncFramebuffer`: `width`, `height`, `Uint8List pixels`, `resize(w, h)`, `setPixel(x, y, r, g, b)`, `fillRect(x, y, w, h, r, g, b)`, `copyRect(srcX, srcY, dstX, dstY, w, h)` (iterating bottom-to-top when `dstY > srcY`, right-to-left when `dstY == srcY && dstX > srcX`), `snapshot()` returning a fresh `Uint8List.fromList(pixels)`.
- `RfbRectDecoder` maintaining a single `RawZLibFilter.inflateFilter()` for the session lifetime (reset only on new session):
  - Decodes `Raw` (4 bytes/pixel RGBA → sets alpha `0xFF`).
  - Decodes `CopyRect` (reads `srcX`, `srcY`).
  - Decodes `Hextile` (iterates 16×16 tiles, reads mask, handles `Raw(1)`, `BackgroundSpecified(2)`, `ForegroundSpecified(4)`, `AnySubrects(8)`, `SubrectsColoured(16)`).
  - Decodes `ZRLE` (reads 4B `compressedLength`, inflates through persistent `RawZLibFilter`, decodes 64×64 tiles with 3-byte CPIXEL `(r, g, b)` for subencodings `0`, `1`, `2..16`, `128`, `130..255`).
  - Handles `DesktopSize` & `ExtendedDesktopSize` (skips screen list payload of `1 + 3 + numScreens * 16` bytes, resizes framebuffer).
  - Handles `Cursor` (reads `w * h * 4` pixel bytes + `((w + 7) ~/ 8) * h` bitmask bytes, builds `VncCursorData` with alpha `0xFF` where mask bit = 1 else `0x00`).

Export `src/protocol/framebuffer.dart` in `app_lib/vnc/lib/app_vnc.dart`.

- [ ] **Step 4: Run tests and commit**

Run: `dart test app_lib/vnc/test/framebuffer_decoder_test.dart`
Expected: PASS.

```bash
git add app_lib/vnc/
git commit -m "feat(vnc): implement RGBA framebuffer and Raw/CopyRect/Hextile/ZRLE decoders"
```

---

### Task 6: `RfbSession`, `VncIsolateClient`, and `VncMdnsDiscovery`

**Files:**
- Create: `app_lib/vnc/lib/src/protocol/rfb_session.dart`
- Create: `app_lib/vnc/lib/src/isolate/vnc_isolate_client.dart`
- Create: `app_lib/vnc/lib/src/discovery/vnc_mdns_discovery.dart`
- Modify: `app_lib/vnc/lib/app_vnc.dart`
- Test: `app_lib/vnc/test/rfb_session_test.dart`
- Test: `app_lib/vnc/test/vnc_isolate_client_test.dart`

- [ ] **Step 1: Write failing tests for `RfbSession` & `VncIsolateClient`**

`app_lib/vnc/test/rfb_session_test.dart`:
- Tests end-to-end `FramebufferUpdate (0)` → callback fires with updated RGBA bytes and triggers next incremental `FramebufferUpdateRequest (3)`.
- Tests `ServerCutText (3)` emits clipboard text.
- Tests `sendPointerEvent(x, y, buttonMask)` writes exact 6-byte message `[5, mask, xHi, xLo, yHi, yLo]`.
- Tests `sendKeyEvent(keysym, down: true)` writes exact 8-byte message `[4, 1, 0, 0, ks3, ks2, ks1, ks0]`.
- Tests `sendClientCutText('hello€')` encodes Latin-1 safely (`'hello?'`) into `[6, 0, 0, 0, len4..., bytes...]`.

`app_lib/vnc/test/vnc_isolate_client_test.dart`:
- Spins up a real loopback `ServerSocket` mocking an RFB 003.889 + None (Type 1) server serving a 4×4 `Raw` frame; connects via `VncIsolateClient`, verifies `VncConnectedEvent`, receives a `VncFrameEvent` with exact RGBA bytes, sends a pointer event and verifies server receives it, then calls `disconnect()` and confirms clean shutdown.

- [ ] **Step 2: Run tests to verify they fail**

Run: `dart test app_lib/vnc/test/rfb_session_test.dart app_lib/vnc/test/vnc_isolate_client_test.dart`
Expected: FAIL.

- [ ] **Step 3: Implement `RfbSession`, `VncIsolateClient`, and `VncMdnsDiscovery`**

- `RfbSession`:
  - Methods: `requestFramebufferUpdate({required bool incremental})`, `sendPointerEvent(int x, int y, int buttonMask)`, `sendKeyEvent(int keysym, {required bool down})`, `sendClientCutText(String text)`, `runMessageLoop(...)`.
  - Handles server messages `0 (FramebufferUpdate)`, `1 (SetColourMapEntries — skip)`, `2 (Bell)`, `3 (ServerCutText)`.
- `VncIsolateClient`:
  - Defines sealed `VncClientEvent` types: `VncConnectingEvent`, `VncAuthRequiredEvent(securityType, requiresUsername)`, `VncConnectedEvent(VncDesktopInfo)`, `VncFrameEvent(VncFrameData)`, `VncResizedEvent(width, height)`, `VncCursorEvent(VncCursorData)`, `VncClipboardEvent(String text)`, `VncDisconnectedEvent(String? reason)`, `VncErrorEvent(VncException error)`.
  - Worker isolate entry point creates `TcpVncTransport` or `SshTunnelVncTransport`, runs `RfbHandshake.perform` (pausing on `Completer<VncCredentials>` if UI prompt is required), runs `RfbSession.runMessageLoop`, throttles frame delivery (~30 ms minimum interval) using `TransferableTypedData.fromList([fb.snapshot()])`, and responds to `submitCredentials`, `pointer`, `key`, `clipboard`, `refresh`, `disconnect`.
  - `disconnect()` requests graceful shutdown and falls back to `Isolate.kill(priority: Isolate.immediate)` after 1s.
- `VncMdnsDiscovery`:
  - `Stream<VncDiscoveredHost> discover({Duration timeout = const Duration(seconds: 5)})`: queries `ResourceRecordQuery.serverPointer('_rfb._tcp.local')`, resolves `SRV` + `IPv4`/`IPv6`, deduplicates by `id`, stops `MDnsClient` deterministically in `finally` or on timeout.

Export all three from `app_lib/vnc/lib/app_vnc.dart`.

- [ ] **Step 4: Run full `app_vnc` test suite and commit**

Run: `dart test app_lib/vnc/test/`
Expected: PASS (all `app_vnc` tests pass).

```bash
git add app_lib/vnc/
git commit -m "feat(vnc): add RfbSession, background VncIsolateClient, and mDNS discovery"
```

---

## Phase 2: Persistence & BLoC Layer

### Task 7: Add `VncHosts` Table to `app_database` (Schema v22 → v23)

**Files:**
- Create: `app_lib/database/lib/src/tables/vnc_hosts.dart`
- Modify: `app_lib/database/lib/src/database.dart` (import/export `vnc_hosts.dart`, add `VncHosts` to `@DriftDatabase`, bump `schemaVersion => 23`, add `if (from < 23) { await m.createTable(vncHosts); }`)
- Regenerate: `app_lib/database/lib/src/database.g.dart`
- Test: `app_lib/database/test/vnc_hosts_table_test.dart`

- [ ] **Step 1: Create `app_lib/database/lib/src/tables/vnc_hosts.dart`**

```dart
import 'package:drift/drift.dart';

import 'ssh_hosts.dart';

/// Authentication mode for a saved VNC host.
enum VncHostAuthType {
  auto(0),
  none(1),
  vncPassword(2),
  appleArd(30);

  const VncHostAuthType(this.value);
  final int value;

  static VncHostAuthType fromValue(int value) =>
      VncHostAuthType.values.firstWhere(
        (e) => e.value == value,
        orElse: () => VncHostAuthType.auto,
      );
}

/// Table for storing saved VNC host profiles (secrets live in VaultRepository).
@DataClassName('VncHost')
class VncHosts extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text()();
  TextColumn get host => text()();
  IntColumn get port => integer().withDefault(const Constant(5900))();
  IntColumn get authType => integer().withDefault(const Constant(0))();
  TextColumn get username => text().nullable()();
  TextColumn get passwordRef => text().nullable()();
  IntColumn get sshHostId => integer()
      .nullable()
      .references(SshHosts, #id, onDelete: KeyAction.setNull)();
  BoolColumn get viewOnly => boolean().withDefault(const Constant(false))();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get lastConnectedAt => dateTime().nullable()();
}
```

- [ ] **Step 2: Register `VncHosts` in `app_lib/database/lib/src/database.dart` and run `build_runner`**

Update `app_lib/database/lib/src/database.dart`:
- Import & export `tables/vnc_hosts.dart` (`show VncHostAuthType`).
- Add `VncHosts` to `@DriftDatabase(tables: [...])`.
- Change `int get schemaVersion => 23;`.
- Append `if (from < 23) { await m.createTable(vncHosts); }` to `onUpgrade`.

Run:
```bash
cd app_lib/database && dart run build_runner build --delete-conflicting-outputs
```
Expected: `database.g.dart` regenerated with `VncHost`, `VncHostsCompanion`, `vncHosts`.

- [ ] **Step 3: Write and run `app_lib/database/test/vnc_hosts_table_test.dart`**

```dart
import 'package:app_database/app_database.dart';
import 'package:drift/drift.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('inserts, queries, updates, and deletes VncHost rows', () async {
    final db = AppDatabase.forTesting();
    addTearDown(db.close);

    final id = await db.into(db.vncHosts).insert(
      VncHostsCompanion.insert(
        name: 'Studio Mac',
        host: 'studio.local',
        authType: Value(VncHostAuthType.appleArd.value),
        username: const Value('gao'),
        passwordRef: const Value('vnc_host:1:password'),
      ),
    );

    final rows = await db.select(db.vncHosts).get();
    expect(rows, hasLength(1));
    expect(rows.single.id, id);
    expect(rows.single.port, 5900);
    expect(rows.single.authType, 30);

    await (db.delete(db.vncHosts)..where((t) => t.id.equals(id))).go();
    expect(await db.select(db.vncHosts).get(), isEmpty);
  });
}
```

Run: `flutter test app_lib/database/test/vnc_hosts_table_test.dart`
Expected: PASS.

- [ ] **Step 4: Commit**

```bash
git add app_lib/database/
git commit -m "feat(database): add VncHosts table in schema v23"
```

---

### Task 8: Create `app_bloc/vnc_host` (`VncHostBloc`)

**Files:**
- Modify: `pubspec.yaml` (add `app_bloc/vnc_host` & `vnc_host_bloc: any`)
- Create: `app_bloc/vnc_host/pubspec.yaml`
- Create: `app_bloc/vnc_host/analysis_options.yaml`
- Create: `app_bloc/vnc_host/lib/vnc_host_bloc.dart`
- Create: `app_bloc/vnc_host/lib/src/repository.dart`
- Create: `app_bloc/vnc_host/lib/src/bloc.dart`
- Create: `app_bloc/vnc_host/lib/src/event.dart`
- Create: `app_bloc/vnc_host/lib/src/state.dart`
- Test: `app_bloc/vnc_host/test/vnc_host_bloc_test.dart`

- [ ] **Step 1: Scaffold `app_bloc/vnc_host/pubspec.yaml` and bootstrap**

Dependencies: `app_database: any`, `app_secure_storage: any`, `app_vnc: any`, `bloc: ^9.2.1`, `drift: ^2.35.2`, `equatable: ^3.0.0`, `meta: ^1.19.0`, `flutter`. Dev deps: `bloc_test`, `flutter_test`, `flutter_lints`. Run `melos bootstrap`.

- [ ] **Step 2: Write failing BLoC test (`app_bloc/vnc_host/test/vnc_host_bloc_test.dart`)**

Test with `AppDatabase.forTesting()` + an in-memory `FakeVaultRepository` + fake mDNS discovery stream:
1. `VncHostAdd` inserts row into `VncHosts`, writes password to `VaultRepository` under `vnc_host:<id>:password`, emits updated `VncHostState` with `hosts.length == 1`, and `readPassword(host)` returns the saved password.
2. `VncHostUpdate` updates metadata and replaces password only when non-empty (preserves existing password when `password == null`).
3. `VncHostDelete` deletes row AND deletes `passwordRef` from `VaultRepository`.
4. `VncHostDiscoverLan` populates `discoveredHosts` and clears `isDiscovering` when stream completes.

- [ ] **Step 3: Run test to verify it fails**

Run: `flutter test app_bloc/vnc_host/test/vnc_host_bloc_test.dart`
Expected: FAIL.

- [ ] **Step 4: Implement `VncHostRepository` and `VncHostBloc`**

- `VncHostRepository(this.database, this.vault)`:
  - `loadHosts()`, `addHost({...})`, `updateHost(id, {...})`, `deleteHost(VncHost)`, `markConnected(int id)`, `readPassword(VncHost)`.
  - Uses `passwordKey(int id) => 'vnc_host:$id:password'`.
- `VncHostBloc`:
  - Events: `VncHostLoad`, `VncHostAdd`, `VncHostUpdate`, `VncHostDelete`, `VncHostMarkConnected`, `VncHostDiscoverLan`.
  - State: `VncHostState(hosts, discoveredHosts, isLoading, isDiscovering, error)` extending `Equatable`.

- [ ] **Step 5: Run tests and commit**

Run: `flutter test app_bloc/vnc_host/test/vnc_host_bloc_test.dart`
Expected: PASS.

```bash
git add pubspec.yaml app_bloc/vnc_host/
git commit -m "feat(vnc): add vnc_host_bloc with Drift persistence, VaultRepository secrets, and LAN discovery"
```

---

### Task 9: Create `app_bloc/vnc_session` (`VncSessionBloc`)

**Files:**
- Modify: `pubspec.yaml` (add `app_bloc/vnc_session` & `vnc_session_bloc: any`)
- Create: `app_bloc/vnc_session/pubspec.yaml`
- Create: `app_bloc/vnc_session/analysis_options.yaml`
- Create: `app_bloc/vnc_session/lib/vnc_session_bloc.dart`
- Create: `app_bloc/vnc_session/lib/src/bloc.dart`
- Create: `app_bloc/vnc_session/lib/src/event.dart`
- Create: `app_bloc/vnc_session/lib/src/state.dart`
- Test: `app_bloc/vnc_session/test/vnc_session_bloc_test.dart`

- [ ] **Step 1: Scaffold `app_bloc/vnc_session/pubspec.yaml` and bootstrap**

Dependencies: `app_vnc: any`, `bloc: ^9.2.1`, `equatable: ^3.0.0`, `meta: ^1.19.0`, `flutter`. Run `melos bootstrap`.

- [ ] **Step 2: Write failing `VncSessionBloc` test (`app_bloc/vnc_session/test/vnc_session_bloc_test.dart`)**

Inject a `VncClientFactory` (`VncSessionClient Function()` interface implemented by `VncIsolateClient`) so tests drive a `FakeVncClient` synchronously:
1. `VncSessionConnect` → emits `connecting` → `authRequired` (on `VncAuthRequiredEvent`) → `VncSessionSubmitCredentials` → `connected` with desktop info.
2. Receiving `VncFrameEvent` updates `latestFrame` without dropping desktop metadata; `VncResizedEvent` updates `width`/`height`.
3. `VncSessionToggleViewOnly` blocks `VncSessionSendPointer` and `VncSessionSendKey` from forwarding to client.
4. `VncErrorEvent(VncAuthenticationException)` transitions to `authFailed` state preserving config so user can retry credentials immediately.
5. `bloc.close()` calls `client.disconnect()`.

- [ ] **Step 3: Run test to verify it fails**

Run: `flutter test app_bloc/vnc_session/test/vnc_session_bloc_test.dart`
Expected: FAIL.

- [ ] **Step 4: Implement `VncSessionBloc`, events, and states**

- `VncSessionStatus`: `idle`, `connecting`, `authRequired`, `connected`, `disconnected`, `error`.
- Events: `VncSessionConnect(VncConnectionConfig)`, `VncSessionSubmitCredentials(VncCredentials)`, `VncSessionCancelAuth`, `VncSessionReconnect`, `VncSessionDisconnect`, `VncSessionSendPointer(x, y, buttonMask)`, `VncSessionSendKey(keysym, {required down})`, `VncSessionSendClipboard(String text)`, `VncSessionToggleViewOnly`, `VncSessionRequestRefresh`.
- Expose a separate `Stream<VncFrameData> get frames` (or `ValueNotifier<VncFrameData?>`) in addition to BLoC state so high-frequency 30–60fps frame updates bypass full-screen `BlocBuilder` rebuilds and only repaint `VncViewerCanvas`!

- [ ] **Step 5: Run tests and commit**

Run: `flutter test app_bloc/vnc_session/test/vnc_session_bloc_test.dart`
Expected: PASS.

```bash
git add pubspec.yaml app_bloc/vnc_session/
git commit -m "feat(vnc): add vnc_session_bloc for remote desktop session lifecycle"
```

---

## Phase 3: Viewer Widgets (`app_widget/vnc_viewer`)

### Task 10: Create `app_widget/vnc_viewer` (`KeysymMapper`, `VncViewerCanvas`, `VncShortcutBar`)

**Files:**
- Modify: `pubspec.yaml` (add `app_widget/vnc_viewer` & `vnc_viewer_widgets: any`)
- Create: `app_widget/vnc_viewer/pubspec.yaml`
- Create: `app_widget/vnc_viewer/analysis_options.yaml`
- Create: `app_widget/vnc_viewer/lib/vnc_viewer_widgets.dart`
- Create: `app_widget/vnc_viewer/lib/src/keysym_mapper.dart`
- Create: `app_widget/vnc_viewer/lib/src/vnc_viewer_canvas.dart`
- Create: `app_widget/vnc_viewer/lib/src/vnc_shortcut_bar.dart`
- Test: `app_widget/vnc_viewer/test/keysym_mapper_test.dart`
- Test: `app_widget/vnc_viewer/test/vnc_viewer_canvas_test.dart`

- [ ] **Step 1: Scaffold `app_widget/vnc_viewer/pubspec.yaml` and bootstrap**

Dependencies: `app_vnc: any`, `duskmoon_ui: ^2.2.10`, `flutter`. Run `melos bootstrap`.

- [ ] **Step 2: Write failing tests (`keysym_mapper_test.dart` & `vnc_viewer_canvas_test.dart`)**

`keysym_mapper_test.dart`:
- Maps `LogicalKeyboardKey.metaLeft` → `X11Keysym.superL` (`0xFFEB`, macOS Command ⌘).
- Maps `LogicalKeyboardKey.altLeft` → `X11Keysym.altL` (`0xFFE9`, macOS Option ⌥).
- Maps `LogicalKeyboardKey.controlLeft` → `X11Keysym.controlL` (`0xFFE3`).
- Maps `LogicalKeyboardKey.enter`, `backspace`, `delete`, `escape`, `arrowUp`, `f12`.
- Maps printable characters (shifted `'A'` → `0x41`, `'!'` → `0x21`, Unicode `'中'` → `0x01004E2D`).

`vnc_viewer_canvas_test.dart`:
- Tests `VncCoordinateMapper.localToRemote(...)` accurately maps tapped canvas coordinates to framebuffer `(x, y)` under both fit-to-screen letterboxing and 2× zoom/pan transforms, clamped to `[0, fbWidth-1] × [0, fbHeight-1]`.
- Tests `VncViewerCanvas` decodes an incoming `VncFrameData` into a `ui.Image`, renders via `CustomPaint`, and disposes previous `ui.Image` on replacement and widget `dispose`.

- [ ] **Step 3: Run tests to verify they fail**

Run: `flutter test app_widget/vnc_viewer/test/`
Expected: FAIL.

- [ ] **Step 4: Implement `KeysymMapper`, `VncViewerCanvas`, and `VncShortcutBar`**

- `KeysymMapper.fromKeyEvent(KeyEvent event)`: handles special keys first, then `event.character` via `unicodeToKeysym`, falling back to `logicalKey.keyLabel` when character is null (e.g. `KeyUpEvent` or `Cmd+C` combos where macOS suppresses `event.character`!).
- `VncViewerCanvas`:
  - Listens to `Stream<VncFrameData>`, converts RGBA bytes via `ui.decodeImageFromPixels`, guards stale frames with `frameId`, disposes superseded `ui.Image` immediately.
  - Wraps `CustomPaint` inside `InteractiveViewer` with `TransformationController` supporting `VncScaleMode.fit` and `VncScaleMode.actualSize`.
  - Desktop `Listener`: handles mouse hover, left/middle/right press & release, and `PointerScrollEvent` (scroll wheel bits `1<<3` / `1<<4`).
  - Mobile gesture layer: supports `VncTouchMode.trackpad` (relative 1-finger cursor drag + tap=left click + 2-finger tap=right click) and `VncTouchMode.direct` (tap at remote coordinate).
  - Keyboard `Focus` node forwarding `KeyDownEvent`/`KeyUpEvent` through `KeysymMapper`.
- `VncShortcutBar`:
  - DuskMoon-styled horizontal bar with sticky modifier chips (`⌘`, `⌥`, `⌃`, `⇧` — sends key-down on toggle-on, key-up on next key or toggle-off), one-tap special keys (`Esc`, `Tab`, `←`, `↑`, `↓`, `→`, `Del`, `Ctrl+Alt+Del`), and a hidden `TextField` trigger for mobile soft-keyboard input.

- [ ] **Step 5: Run tests and commit**

Run: `flutter test app_widget/vnc_viewer/test/`
Expected: PASS.

```bash
git add pubspec.yaml app_widget/vnc_viewer/
git commit -m "feat(vnc): add vnc_viewer_widgets with KeysymMapper, canvas, and shortcut bar"
```

---

## Phase 4: App Integration, Routing, Localization & Permissions

### Task 11: Provider Wiring, Localization & Platform Permissions

**Files:**
- Modify: `app_lib/provider/pubspec.yaml` (add `vnc_host_bloc: any`, `app_vnc: any`)
- Create: `app_lib/provider/lib/src/vnc_dependencies_stub.dart`
- Create: `app_lib/provider/lib/src/vnc_dependencies_native.dart`
- Modify: `app_lib/provider/lib/src/main.dart` (spread `...vncBlocs(database, vault)` in `MultiBlocProvider`)
- Modify: `app_lib/locale/lib/arb/app_en.arb`, `app_zh.arb`, `app_zh_Hans.arb`, `app_zh_Hant.arb`
- Modify: `ios/Runner/Info.plist` (append `_rfb._tcp` to `NSBonjourServices` and update `NSLocalNetworkUsageDescription`)
- Modify: `macos/Runner/Info.plist` (add `NSBonjourServices` with `_rfb._tcp` and `NSLocalNetworkUsageDescription`)

- [ ] **Step 1: Add conditional VNC BLoC provider registration (Web-safe)**

Create `app_lib/provider/lib/src/vnc_dependencies_stub.dart`:
```dart
import 'package:app_database/app_database.dart';
import 'package:app_secure_storage/app_secure_storage.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

List<BlocProvider<dynamic>> vncBlocs(
  AppDatabase database,
  VaultRepository vault,
) => const [];
```

Create `app_lib/provider/lib/src/vnc_dependencies_native.dart`:
```dart
import 'package:app_database/app_database.dart';
import 'package:app_secure_storage/app_secure_storage.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vnc_host_bloc/vnc_host_bloc.dart';

List<BlocProvider<dynamic>> vncBlocs(
  AppDatabase database,
  VaultRepository vault,
) => [
  BlocProvider<VncHostBloc>(
    create: (context) => VncHostBloc(
      repository: VncHostRepository(database: database, vault: vault),
    )..add(const VncHostLoad()),
  ),
];
```

Import conditionally in `app_lib/provider/lib/src/main.dart` and spread `...vncBlocs(database, vault)` inside `MultiBlocProvider`.

- [ ] **Step 2: Add VNC l10n keys and run `melos run gen-l10n`**

Add keys (`vncTitle`, `vncBrowserUnsupported`, `vncQuickConnect`, `vncAddHost`, `vncEditHost`, `vncSavedHosts`, `vncLanDiscovery`, `vncScanningLan`, `vncNoSavedHosts`, `vncNoDiscoveredHosts`, `vncHostLabel`, `vncPortLabel`, `vncAuthTypeLabel`, `vncAuthAuto`, `vncAuthAppleArd`, `vncAuthPassword`, `vncAuthNone`, `vncUsernameLabel`, `vncPasswordLabel`, `vncSshTunnelLabel`, `vncSshTunnelNone`, `vncViewOnlyLabel`, `vncConnect`, `vncDisconnect`, `vncReconnect`, `vncFitScreen`, `vncActualSize`, `vncSyncClipboard`, `vncTrackpadMode`, `vncDirectTouchMode`, `vncAuthPromptTitle`, `vncMacosSharingHint`) to `app_en.arb`, `app_zh.arb`, `app_zh_Hans.arb`, `app_zh_Hant.arb`.

Run: `melos bootstrap && melos run gen-l10n`
Expected: `AppLocalizations` regenerated with zero errors.

- [ ] **Step 3: Update `ios/Runner/Info.plist` and `macos/Runner/Info.plist`**

Add `<string>_rfb._tcp</string>` to `NSBonjourServices` in `ios/Runner/Info.plist`, and add `NSBonjourServices` (`_rfb._tcp`) + `NSLocalNetworkUsageDescription` to `macos/Runner/Info.plist`.

- [ ] **Step 4: Run `app_provider` tests and commit**

Run: `flutter test app_lib/provider/test/`
Expected: PASS.

```bash
git add app_lib/provider/ app_lib/locale/ ios/Runner/Info.plist macos/Runner/Info.plist
git commit -m "feat(vnc): wire VncHostBloc in MainProvider, add l10n strings and Bonjour permissions"
```

---

### Task 12: Toolbox Screens (`VncHostsScreen`, `VncSessionScreen`), Dialogs & Routes

**Files:**
- Create: `lib/screens/toolbox/vnc/vnc_screen.dart` (conditional export: stub vs native)
- Create: `lib/screens/toolbox/vnc/vnc_unsupported_screen.dart`
- Create: `lib/screens/toolbox/vnc/vnc_hosts_screen.dart`
- Create: `lib/screens/toolbox/vnc/vnc_session_screen.dart`
- Create: `lib/screens/toolbox/vnc/vnc_launch_config.dart`
- Create: `lib/screens/toolbox/vnc/widgets/vnc_host_form_dialog.dart`
- Create: `lib/screens/toolbox/vnc/widgets/vnc_auth_dialog.dart`
- Modify: `lib/screens/toolbox/toolbox_screen.dart` (add `if (!kIsWeb)` `VNC` `AppGridTile`)
- Modify: `lib/screens/toolbox/toolbox_routes.dart` (register `VncHostsScreen` & nested `VncSessionScreen`)
- Test: `test/screens/toolbox/vnc/vnc_hosts_screen_test.dart`

- [ ] **Step 1: Write failing screen test (`test/screens/toolbox/vnc/vnc_hosts_screen_test.dart`)**

Test:
- Renders `VncHostsScreen` inside `DmTheme` + `AppLocalizations` + `VncHostBloc` + `SshHostBloc`.
- Displays saved VNC host cards with auth badge (`ARD`) and SSH tunnel badge.
- Displays LAN-discovered macOS hosts with Connect & Save buttons.
- Tapping "Quick Connect" opens `VncHostFormDialog` in quick-connect mode.

- [ ] **Step 2: Run test to verify it fails**

Run: `flutter test test/screens/toolbox/vnc/vnc_hosts_screen_test.dart`
Expected: FAIL.

- [ ] **Step 3: Implement screens, dialogs, and Toolbox integration**

- `vnc_screen.dart` conditionally exports `vnc_unsupported_screen.dart` (`if (dart.library.io) 'vnc_hosts_screen.dart'`), both defining `class VncScreen` (`static const name = 'Vnc'`, `static const path = 'vnc'`).
- `vnc_launch_config.dart`: holds `title`, `VncConnectionConfig`, optional `savedHostId` (for updating `lastConnectedAt` on connect).
- `vnc_host_form_dialog.dart`: supports **Quick Connect**, **Add Host**, and **Edit Host** modes; reads `SshHostBloc` state to populate optional SSH tunnel dropdown (`None` + saved SSH hosts).
- `vnc_hosts_screen.dart` (`class VncScreen`):
  - Uses `AppAdaptiveScaffold` (`navigationRestoreInHeader: true`, `selectedIndex: Destinations.indexOf(const Key(ToolboxScreen.name), context)`).
  - Auto-triggers `VncHostDiscoverLan` on `initState` (5s finite scan).
  - On connect: resolves saved VNC password via `VncHostRepository.readPassword(host)`; if `sshHostId != null`, resolves `SshHost` + password / PEM key + passphrase via `context.read<SshCredentialRepository>()` and `SshKeyBloc`; navigates to `VncSessionScreen` passing `VncLaunchConfig`.
- `vnc_session_screen.dart`:
  - Creates a local `BlocProvider<VncSessionBloc>` dispatching `VncSessionConnect(launch.config)`.
  - Collapsible HUD top bar: connection badge + desktop name + resolution, Fit/1:1 toggle, Trackpad/Direct toggle (mobile), View-Only toggle, Sync Clipboard button, Fullscreen + `WakelockPlus` toggle, Disconnect button.
  - `BlocListener` handles `authRequired` / `authFailed` by presenting `VncAuthDialog` (showing username field when `requiresUsername == true`, e.g. macOS ARD Type 30), and displays `vncMacosSharingHint` when `VncUnsupportedSecurityTypeException` occurs.
  - `dispose()` disables `WakelockPlus` and closes `VncSessionBloc` (closing socket/SSH tunnel/Isolate).
- Wire `toolbox_screen.dart` (`if (!kIsWeb) AppGridTile(onTap: () => context.menuGoNamed(VncScreen.name), child: Text(context.l10n.vncTitle))`) and `toolbox_routes.dart`.

- [ ] **Step 4: Run screen tests and commit**

Run: `flutter test test/screens/toolbox/vnc/vnc_hosts_screen_test.dart`
Expected: PASS.

```bash
git add lib/screens/toolbox/ test/screens/toolbox/vnc/
git commit -m "feat(vnc): add VNC hosts and remote session screens to Toolbox"
```

---

### Task 13: Full Workspace Verification & macOS Screen Sharing Acceptance Check

**Files:**
- Verify all modified/created packages across the workspace.

- [ ] **Step 1: Run formatting, static analysis, dependency validation, and full tests**

```bash
melos run format
melos run format-check
melos run analyze
melos run test:dart
flutter test app_lib/database/test/vnc_hosts_table_test.dart app_bloc/vnc_host/test/ app_bloc/vnc_session/test/ app_widget/vnc_viewer/test/ test/screens/toolbox/vnc/
```
Expected: All commands exit 0 with zero warnings and all tests passing.

- [ ] **Step 2: Real macOS Screen Sharing manual verification checklist**

On a macOS host with **System Settings → General → Sharing → Screen Sharing** enabled:
1. Launch GSMLG (`flutter run -d macos`), open **Toolbox → VNC**.
2. Confirm the Mac appears under **LAN Discovery** (`_rfb._tcp`).
3. Connect using the Mac's **username + login password** (ARD Type 30, without enabling legacy VNC password).
4. Verify smooth `ZRLE` rendering, fit-to-screen & 1:1 zoom/pan, mouse clicks/scroll, `⌘+Space` / `⌘+C` / `⌘+V` shortcuts, and clipboard sync.
5. Save the host with an existing `SshHost` selected as SSH tunnel and verify tunneled connection to `127.0.0.1:5900`.
6. Disconnect and confirm zero lingering sockets/isolates and clean re-entry.
