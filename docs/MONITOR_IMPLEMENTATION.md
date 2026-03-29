# Monitor Module — Implementation Guide

This document provides step-by-step instructions for implementing the Monitor module across its four milestones. It is designed to be used as a prompt for Claude Code or as a developer checklist.

Reference documents:

- [MONITOR_PRD.md](./MONITOR_PRD.md) — Requirements and user stories
- [MONITOR_DESIGN.md](./MONITOR_DESIGN.md) — Architecture and technical design

---

## Prerequisites

Before starting, verify the development environment:

```bash
melos bootstrap
mason get
flutter --version   # Dart >=3.8.0
```

---

## Milestone 1: Core Agent + Basic Client

### Step 1: Create `monitor_models` package

1. Create directory `monitor_models/` at repo root.
2. Create `pubspec.yaml`:

```yaml
name: monitor_models
description: Shared data models for GSMLG Monitor
publish_to: none
resolution: workspace

environment:
  sdk: ^3.8.0

dependencies:
  equatable: any
  meta: any
```

3. Create barrel export `lib/monitor_models.dart`.
4. Implement models in `lib/src/`:
   - `host_info.dart` — `HostInfo`, `GpuInfo`
   - `cpu_metrics.dart` — `CpuMetrics`
   - `memory_metrics.dart` — `MemoryMetrics`
   - `gpu_metrics.dart` — `GpuMetrics`
   - `network_metrics.dart` — `NetworkMetrics`
   - `disk_metrics.dart` — `DiskMetrics`
   - `monitor_message.dart` — `MonitorMessageType`, `MonitorMessage`, `SystemMetrics`
   - `protocol.dart` — JSON key constants

All models: `@immutable`, extend `Equatable`, manual `fromJson`/`toJson`.

5. Write unit tests in `monitor_models/test/` for serialization round-trips.

### Step 2: Create `monitor_agent` package

1. Create directory `monitor_agent/` at repo root.
2. Create `pubspec.yaml`:

```yaml
name: monitor_agent
description: System metrics agent daemon for GSMLG Monitor
publish_to: none
resolution: workspace

environment:
  sdk: ^3.8.0

dependencies:
  args: any
  monitor_models: any
  shelf: any
  shelf_web_socket: any
```

3. Implement in `lib/src/`:
   - `config.dart` — `AgentConfig` from CLI args
   - `utils/process_runner.dart` — isolate-based `Process.run`
   - `utils/delta_tracker.dart` — delta computation helper
   - `collectors/collector.dart` — abstract `MetricsCollector<T>`
   - `collectors/platform/linux/linux_cpu.dart` — parse `/proc/stat`
   - `collectors/platform/linux/linux_memory.dart` — parse `/proc/meminfo`
   - `collectors/cpu_collector.dart` — factory function
   - `collectors/memory_collector.dart` — factory function
   - `server/ws_server.dart` — shelf WebSocket server
   - `agent.dart` — orchestrator

4. Create CLI entry point `bin/monitor_agent.dart`:

```dart
import 'dart:io';
import 'package:args/args.dart';
import 'package:monitor_agent/monitor_agent.dart';

Future<void> main(List<String> args) async {
  final parser = ArgParser()
    ..addOption('port', defaultsTo: '9723')
    ..addOption('interval', defaultsTo: '3')
    ..addOption('bind', defaultsTo: '0.0.0.0');

  final results = parser.parse(args);
  final config = AgentConfig.fromArgs(results);
  final agent = MonitorAgent(config);

  // Graceful shutdown
  ProcessSignal.sigint.watch().listen((_) async {
    await agent.stop();
    exit(0);
  });

  await agent.start();
}
```

5. Write tests for Linux collectors (mock file reads).

### Step 3: Create `app_bloc/monitor` package

1. Use Mason if the `simple_bloc` brick supports it, otherwise create manually.

```bash
mason make simple_bloc -o app_bloc/monitor --name=monitor
```

2. Implement:
   - `lib/src/monitor_repository.dart` — WebSocket client wrapper (no mDNS yet)
   - `lib/src/event.dart` — `ConnectHost`, `DisconnectHost`, `AddManualHost`, `_MetricsReceived`, `_ConnectionStatusChanged`
   - `lib/src/state.dart` — `MonitorInitial`, `MonitorLoaded` with `Map<String, MonitorHost>`
   - `lib/src/bloc.dart` — event handlers, stream subscriptions per host

3. Write BLoC tests with mock repository.

### Step 4: Create Monitor screen

1. Use Mason screen brick:

```bash
mason make screen --name MonitorScreen --folder toolbox/monitor
```

2. Implement `lib/screens/toolbox/monitor/`:
   - `monitor_screen.dart` — split layout: host list + text metrics
   - `monitor_routes.dart` — `GoRoute` definition
   - `widgets/host_list_tile.dart` — basic tile with status
   - `widgets/add_host_dialog.dart` — IP + port text fields

3. Display metrics as formatted text for M1 (no gauges).

### Step 5: Wire into app

1. Add packages to root `pubspec.yaml` workspace + dependencies.
2. Add `MonitorBloc` to `MainProvider`.
3. Add `monitorRoute()` to `toolbox_routes.dart`.
4. Add Monitor entry to toolbox screen grid.
5. Run `melos bootstrap`.

### Step 6: Verify M1

```bash
# Terminal 1: Run agent on a Linux machine
cd monitor_agent && dart run bin/monitor_agent.dart

# Terminal 2: Run app
flutter run -d macos
# Navigate to Toolbox → Monitor → Add Host → enter agent IP:9723
# Verify: CPU % and memory values appear and update every 3 seconds
```

---

## Milestone 2: Full Collectors + Visual Dashboard

### Step 7: Implement remaining Linux collectors

- `linux_gpu.dart` — `nvidia-smi --query-gpu=...` CSV parsing
- `linux_network.dart` — `/proc/net/dev` delta parsing
- `linux_disk.dart` — `/proc/diskstats` delta + `df` for capacity

### Step 8: Implement macOS collectors

- `macos_cpu.dart` — `top -l 2 -n 0 -s 0` parsing
- `macos_memory.dart` — `vm_stat` + `sysctl hw.memsize`
- `macos_gpu.dart` — IOKit `IOAccelerator` via `dart:ffi` for GPU utilization (see MONITOR_DESIGN.md §10.8)
  - `macos_gpu_iokit.dart` — FFI bindings to `IOServiceGetMatchingServices` + `IORegistryEntryCreateCFProperties`
  - Fallback chain: IOKit → `ioreg -rc IOAccelerator` shell parse → `system_profiler` (name only) → empty
  - Must degrade gracefully — wrap all FFI calls in try/catch
- `macos_network.dart` — `netstat -ibnd` delta
- `macos_disk.dart` — `iostat -d` + `df`

### Step 9: Implement Windows collectors

- `windows_cpu.dart` — `wmic cpu get LoadPercentage`
- `windows_memory.dart` — `wmic os get FreePhysicalMemory,TotalVisibleMemorySize`
- `windows_gpu.dart` — `nvidia-smi` (NVIDIA) or PowerShell fallback
- `windows_network.dart` — PowerShell `Get-NetAdapterStatistics`
- `windows_disk.dart` — `wmic logicaldisk` + PowerShell counters

### Step 10: Implement RingBuffer

Add `ring_buffer.dart` to `monitor_models` (or `app_bloc/monitor`). Capacity 60. Used in `MonitorHost` state to track sparkline history.

### Step 11: Build dashboard widgets

Use the `data_visualization` package suite (already in the gsmlg-app ecosystem). Key packages for the monitor dashboard:

- `dv_scale` — `scaleLinear` for mapping metric values to pixel coordinates, `scaleBand` for per-core bars
- `dv_shape` — `ArcGenerator` for radial gauges, `LineGenerator`/`AreaGenerator` for sparklines
- `dv_curve` — `curveMonotoneX()` for smooth sparkline interpolation
- `dv_tooltip` — tap-to-inspect data points on sparklines

Widgets to implement (all use `CustomPainter` with data_visualization primitives):

- `widgets/cpu_gauge.dart` — `ArcGenerator`-based radial gauge with animated percentage
- `widgets/cpu_per_core_chart.dart` — `scaleBand` horizontal bar chart
- `widgets/memory_gauge.dart` — `ArcGenerator`-based radial gauge
- `widgets/gpu_card.dart` — gauge + VRAM bar + temp badge
- `widgets/network_chart.dart` — dual `LineGenerator` + `AreaGenerator` sparkline from ring buffer
- `widgets/disk_chart.dart` — dual sparkline + capacity bar
- `widgets/metrics_dashboard.dart` — composes all sections with responsive layout

Color scale shared across all gauges:

```dart
// Green (0–60%) → Yellow (60–80%) → Red (80–100%)
Color gaugeColor(double percent) {
  if (percent < 60) return Color.lerp(Colors.green, Colors.yellow, percent / 60)!;
  if (percent < 80) return Color.lerp(Colors.yellow, Colors.orange, (percent - 60) / 20)!;
  return Color.lerp(Colors.orange, Colors.red, (percent - 80) / 20)!;
}
```

### Step 12: Responsive layout

Use `LayoutBuilder` in `MonitorScreen`:
- Width ≥ 900: `Row` with host list (fixed 280dp) + dashboard (expanded)
- Width < 900: `Navigator` push from list to detail

### Step 13: Verify M2

Test all platforms. Verify:
- All 5 metric types populate on Linux agent
- Gauges animate smoothly
- Sparklines scroll with new data
- Per-core breakdown renders correctly for 4, 8, 16+ cores
- GPU section hidden when no GPU detected

---

## Milestone 3: mDNS Discovery + mTLS TOFU

### Step 14: Agent certificate management

1. Add `pointycastle` dependency to `monitor_agent/pubspec.yaml`.
2. Implement `server/cert_manager.dart`:
   - On first run: generate RSA-2048 key pair + self-signed X.509 cert
   - Store to `~/.gsmlg-monitor/cert.pem` and `key.pem`
   - Certificate CN = machine hostname, SANs = all local non-loopback IPs
   - Validity: 365 days
   - Provide `SecurityContext` for `HttpServer.bindSecure`
   - Compute and expose SHA-256 fingerprint
   - Support `--regen-cert` flag to force new cert
3. Print fingerprint on agent startup:
   ```
   Agent fingerprint: SHA256:ab:cd:ef:12:34:...
   ```

### Step 15: Upgrade agent to WSS

1. Update `server/ws_server.dart`:
   - Accept `CertManager` dependency
   - Use `HttpServer.bindSecure` with the generated `SecurityContext`
   - Keep `useTls` parameter (default `true`) for backward compat during dev
   - Add `GET /cert-fingerprint` endpoint returning plain text fingerprint
2. Update `bin/monitor_agent.dart` to wire `CertManager` → `WsServer`.

### Step 16: Agent mDNS registration

1. Add `multicast_dns` dependency to `monitor_agent/pubspec.yaml`.
2. Implement `server/mdns_service.dart`:
   - Register `_gsmlg-monitor._tcp` with TXT records including `version`, `hostname`, and `fingerprint`
   - Deregister on agent shutdown
3. Wire into `MonitorAgent.start()` / `stop()`.
4. Add `--no-mdns` flag to `AgentConfig`.

### Step 17: Client TOFU trust store

1. Implement `app_bloc/monitor/lib/src/trust_store.dart`:
   - Interface for storing/loading pinned cert fingerprints
   - In-memory implementation for M3 (DB-backed in M4)

```dart
abstract class TrustStore {
  Future<String?> getPinnedFingerprint(String hostId);
  Future<void> pinFingerprint(String hostId, String fingerprint);
  Future<void> removePinnedFingerprint(String hostId);
}
```

2. Update `MonitorRepository.connect()`:
   - Configure `SecurityContext` to accept self-signed certs
   - On TLS handshake, extract server cert fingerprint
   - If `pinnedFingerprint` is null → emit `_CertificateReceived` (first connect)
   - If `pinnedFingerprint` matches → proceed normally
   - If mismatch → emit error with `TrustStatus.mismatch`

### Step 18: Client mDNS browsing

1. Add `multicast_dns` dependency to `app_bloc/monitor/pubspec.yaml`.
2. Update `MonitorRepository.discoverHosts()`:
   - Browse for `_gsmlg-monitor._tcp`
   - Resolve service instances to IP + port
   - Read `fingerprint` from TXT record for pre-verification display
   - Emit `DiscoveredHost` objects on stream
3. Update `MonitorBloc`:
   - `DiscoverHosts` event starts mDNS browse
   - `_HostDiscovered` events add hosts with `discovered` status
   - `_CertificateReceived` → set `trustStatus = pending`, pause data flow
   - `TrustHost` → pin fingerprint, set `trustStatus = trusted`, resume
   - `RejectHost` → disconnect, remove from list
   - `ReTrustHost` → update pinned fingerprint after mismatch
4. Note: mDNS on iOS requires `NSBonjourServices` in `Info.plist`:

```xml
<key>NSBonjourServices</key>
<array>
  <string>_gsmlg-monitor._tcp</string>
</array>
```

And `NSLocalNetworkUsageDescription`:

```xml
<key>NSLocalNetworkUsageDescription</key>
<string>GSMLG needs local network access to discover monitor agents.</string>
```

### Step 19: TOFU UI

1. Implement `widgets/trust_dialog.dart`:

```
┌─────────────────────────────────────┐
│  Trust this agent?                  │
│                                     │
│  Host: workstation.local            │
│  Fingerprint:                       │
│  SHA256:ab:cd:ef:12:34:56:78:...   │
│                                     │
│  Verify this matches the agent's    │
│  terminal output.                   │
│                                     │
│  [Cancel]              [Trust]      │
└─────────────────────────────────────┘
```

2. Implement `widgets/cert_mismatch_dialog.dart`:

```
┌─────────────────────────────────────┐
│  ⚠ Certificate changed!            │
│                                     │
│  The agent's certificate has        │
│  changed since you last connected.  │
│  This could indicate a security     │
│  issue.                             │
│                                     │
│  Previous: SHA256:ab:cd:ef:...      │
│  Current:  SHA256:99:88:77:...      │
│                                     │
│  [Disconnect]      [Trust Anyway]   │
└─────────────────────────────────────┘
```

### Step 20: Update discovery UI

- Auto-trigger `DiscoverHosts` on screen open.
- Show scanning indicator during browse.
- Differentiate discovered vs manual hosts visually (icon badge).
- Pull-to-refresh re-triggers discovery.

### Step 21: Verify M3

1. Run agent on machine A — note fingerprint from stdout.
2. Open Monitor on machine B (same network).
3. Verify: machine A appears in host list automatically.
4. Tap → trust dialog shows fingerprint → confirm → dashboard shows.
5. Restart agent with `--regen-cert` → reconnect → cert mismatch dialog shows.
6. Verify all connections use WSS (no plain WS).

---

## Milestone 4: Polish, Persistence & Distribution

### Step 22: Reconnection with backoff

Implement in `MonitorRepository`:

```dart
Stream<MonitorMessage> connect(String ip, int port, {String? pinnedFingerprint}) async* {
  var delay = Duration(seconds: 1);
  const maxDelay = Duration(seconds: 30);
  const maxRetryDuration = Duration(minutes: 5);
  final deadline = DateTime.now().add(maxRetryDuration);

  while (DateTime.now().isBefore(deadline)) {
    try {
      // WSS with TOFU cert verification
      final channel = WebSocketChannel.connect(
        Uri.parse('wss://$ip:$port/ws'),
        // Custom SecurityContext accepting self-signed certs
      );
      await channel.ready;
      yield* channel.stream.map((data) =>
        MonitorMessage.fromJson(jsonDecode(data as String)));
    } catch (e) {
      await Future.delayed(delay);
      delay = Duration(
        milliseconds: (delay.inMilliseconds * 2).clamp(0, maxDelay.inMilliseconds),
      );
    }
  }
  // Exceeded retry duration → emit error status
}
```

### Step 23: Host + trust persistence

Add to `AppDatabase` (in `app_lib/database`):

```sql
CREATE TABLE monitor_hosts (
  id TEXT PRIMARY KEY,    -- "ip:port"
  ip TEXT NOT NULL,
  port INTEGER NOT NULL,
  label TEXT,             -- user-assigned name
  is_manual INTEGER NOT NULL DEFAULT 1,
  created_at TEXT NOT NULL
);

CREATE TABLE monitor_trusted_certs (
  host_id TEXT PRIMARY KEY,
  fingerprint TEXT NOT NULL,     -- SHA-256 hex
  first_trusted_at TEXT NOT NULL,
  last_verified_at TEXT NOT NULL,
  FOREIGN KEY (host_id) REFERENCES monitor_hosts(id) ON DELETE CASCADE
);
```

- Implement `DbTrustStore` (replaces in-memory `TrustStore` from M3)
- Load saved hosts + pinned certs on `MonitorBloc` init
- Save manual hosts on `AddManualHost`
- Pin fingerprint on `TrustHost`
- Delete on `RemoveHost` (cascades to trusted_certs)

Update `MainProvider` to pass `AppDatabase` to `MonitorBloc`.

### Step 24: Agent version warning

1. Add `minAgentVersion` constant to `monitor_models/lib/src/protocol.dart`:

```dart
const String minAgentVersion = '1.0.0';
```

2. In `MonitorBloc`, when `host_info` is received:
   - Parse `agentVersion` from `HostInfo`
   - Compare against `minAgentVersion` (semver comparison)
   - Set `versionWarning = true` on `MonitorHost` if agent is older
3. Implement `widgets/version_badge.dart`:
   - Amber `Tooltip` badge on `HostListTile`
   - Text: "Agent v{version} — update available"

### Step 25: Configurable interval

- Add per-host interval setting in `MonitorHost` state.
- Send a control message to agent (extend protocol):

```json
{ "type": "set_interval", "payload": { "seconds": 5 } }
```

- Agent-side: handle `set_interval` message, adjust timer for that client.

### Step 26: GPU temperature color coding

In `GpuCard` widget:

| Temperature | Color |
|-------------|-------|
| < 60°C | Green |
| 60–80°C | Yellow |
| > 80°C | Red |

### Step 27: Binary distribution

1. Add `dart compile exe` targets to agent build:

```bash
dart compile exe bin/monitor_agent.dart -o gsmlg-monitor-agent-linux-x64
```

2. Create `.github/workflows/release-agent.yml`:
   - Trigger on tag push (`v*`)
   - Matrix: linux-x64, linux-arm64, macos-x64, macos-arm64, windows-x64
   - `dart compile exe` on each platform runner
   - Upload binaries as GitHub Release assets
3. Document installation in agent README:
   - Download binary from GitHub Releases
   - `chmod +x` on Linux/macOS
   - Run directly — no Dart SDK needed

### Step 28: Localization

Add strings to `app_lib/locale/lib/l10n/app_en.arb`:

```json
{
  "monitorTitle": "Monitor",
  "monitorAddHost": "Add Host",
  "monitorDiscovering": "Scanning network...",
  "monitorNoHosts": "No hosts found. Add one manually or start an agent on your network.",
  "monitorCpu": "CPU",
  "monitorMemory": "Memory",
  "monitorGpu": "GPU",
  "monitorNetwork": "Network",
  "monitorDisk": "Disk",
  "monitorConnecting": "Connecting...",
  "monitorConnected": "Connected",
  "monitorDisconnected": "Disconnected",
  "monitorError": "Unreachable",
  "monitorLoadAvg": "Load: {one}, {five}, {fifteen}",
  "monitorSwap": "Swap: {percent}%",
  "monitorGpuTemp": "{temp}°C",
  "monitorHostIp": "IP Address",
  "monitorHostPort": "Port",
  "monitorHostPortDefault": "Default: 9723",
  "monitorRemoveHost": "Remove Host",
  "monitorRemoveHostConfirm": "Remove {hostname} from the list?",
  "monitorTrustTitle": "Trust this agent?",
  "monitorTrustBody": "Verify this fingerprint matches the agent's terminal output.",
  "monitorTrustAction": "Trust",
  "monitorCertMismatchTitle": "Certificate changed!",
  "monitorCertMismatchBody": "The agent's certificate has changed since you last connected. This could indicate a security issue.",
  "monitorReTrust": "Trust Anyway",
  "monitorVersionWarning": "Agent v{version} — update available"
}
```

Run `melos run gen-l10n`.

### Step 29: Empty and error states

- No hosts: illustration + "No hosts found" message + prominent "Add Host" button.
- Host error: error icon in host tile + "Unreachable — tap to retry" hint.
- Agent not responding: after 5 min backoff, show error state with "Remove" and "Retry" actions.
- Trust pending: host tile shows lock icon + "Tap to verify" hint.

### Step 30: Connection status animations

- `discovered` → `connecting`: pulse animation on indicator dot.
- `connecting` → `connected`: dot scales up briefly, color transition.
- `connected` → `disconnected`: dot fades to grey.
- `mismatch`: red pulsing lock icon.

Use `AnimatedSwitcher` or explicit `AnimationController`.

### Step 31: Final verification

Run full test suite:

```bash
melos run analyze
melos run test
```

Manual testing matrix:

| Agent OS | Client Platform | Expected Result |
|----------|----------------|-----------------|
| Linux | macOS | All 5 metrics, WSS |
| Linux | Android | All 5 metrics, mobile layout, WSS |
| macOS | macOS | All metrics (GPU via IOKit, best-effort), WSS |
| Windows | macOS | All 5 metrics, WSS |
| Linux (no GPU) | any | 4 metrics, GPU section hidden |
| Any | any | TOFU dialog on first connect |
| Any (regen cert) | any | Cert mismatch dialog |
| Old agent | any | Version warning badge |
| Binary agent | any | Same as dart-run agent |

---

## File Checklist

### New packages to add to workspace

- [ ] `monitor_models/`
- [ ] `monitor_agent/`
- [ ] `app_bloc/monitor/`

### New files in main app

- [ ] `lib/screens/toolbox/monitor/monitor_screen.dart`
- [ ] `lib/screens/toolbox/monitor/monitor_routes.dart`
- [ ] `lib/screens/toolbox/monitor/widgets/host_list_tile.dart`
- [ ] `lib/screens/toolbox/monitor/widgets/metrics_dashboard.dart`
- [ ] `lib/screens/toolbox/monitor/widgets/cpu_gauge.dart`
- [ ] `lib/screens/toolbox/monitor/widgets/cpu_per_core_chart.dart`
- [ ] `lib/screens/toolbox/monitor/widgets/memory_gauge.dart`
- [ ] `lib/screens/toolbox/monitor/widgets/gpu_card.dart`
- [ ] `lib/screens/toolbox/monitor/widgets/network_chart.dart`
- [ ] `lib/screens/toolbox/monitor/widgets/disk_chart.dart`
- [ ] `lib/screens/toolbox/monitor/widgets/add_host_dialog.dart`
- [ ] `lib/screens/toolbox/monitor/widgets/connection_indicator.dart`
- [ ] `lib/screens/toolbox/monitor/widgets/trust_dialog.dart`
- [ ] `lib/screens/toolbox/monitor/widgets/cert_mismatch_dialog.dart`
- [ ] `lib/screens/toolbox/monitor/widgets/version_badge.dart`

### New files in monitor_agent

- [ ] `monitor_agent/lib/src/server/cert_manager.dart`
- [ ] `monitor_agent/lib/src/collectors/platform/macos/macos_gpu_iokit.dart`

### Modified files

- [ ] Root `pubspec.yaml` — workspace + dependencies
- [ ] `app_lib/provider/lib/src/main.dart` — register `MonitorBloc`
- [ ] `lib/screens/toolbox/toolbox_routes.dart` — add `monitorRoute()`
- [ ] Toolbox screen — add Monitor grid entry
- [ ] `ios/Runner/Info.plist` — mDNS Bonjour services (M3)
- [ ] `app_lib/locale/lib/l10n/app_en.arb` — localization strings (M4)
- [ ] `app_lib/database/` — `monitor_hosts` + `monitor_trusted_certs` table migration (M4)

### New CI workflows

- [ ] `.github/workflows/release-agent.yml` — compile + publish agent binaries (M4)
