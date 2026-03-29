# Monitor Module — Technical Design

## 1. Package Decomposition

```
gsmlg/
├── monitor_models/                    # Shared models + protocol (pure Dart)
│   ├── pubspec.yaml
│   └── lib/
│       ├── monitor_models.dart        # barrel export
│       └── src/
│           ├── host_info.dart
│           ├── cpu_metrics.dart
│           ├── memory_metrics.dart
│           ├── gpu_metrics.dart
│           ├── network_metrics.dart
│           ├── disk_metrics.dart
│           ├── monitor_message.dart    # Envelope: type + payload
│           └── protocol.dart          # Message type constants, serialization helpers
│
├── monitor_agent/                     # Dart CLI daemon
│   ├── pubspec.yaml
│   ├── bin/
│   │   └── monitor_agent.dart         # CLI entry point
│   └── lib/
│       ├── monitor_agent.dart         # barrel export
│       └── src/
│           ├── agent.dart             # Orchestrator
│           ├── config.dart            # CLI args → AgentConfig
│           ├── collectors/
│           │   ├── collector.dart     # MetricsCollector interface
│           │   ├── cpu_collector.dart
│           │   ├── memory_collector.dart
│           │   ├── gpu_collector.dart
│           │   ├── network_collector.dart
│           │   ├── disk_collector.dart
│           │   └── platform/
│           │       ├── linux/          # Linux-specific implementations
│           │       │   ├── linux_cpu.dart
│           │       │   ├── linux_memory.dart
│           │       │   ├── linux_gpu.dart
│           │       │   ├── linux_network.dart
│           │       │   └── linux_disk.dart
│           │       ├── macos/          # macOS-specific implementations
│           │       │   ├── macos_cpu.dart
│           │       │   ├── macos_memory.dart
│           │       │   ├── macos_gpu.dart         # IOKit FFI + fallback chain
│           │       │   ├── macos_gpu_iokit.dart   # IOKit FFI bindings
│           │       │   ├── macos_network.dart
│           │       │   └── macos_disk.dart
│           │       └── windows/        # Windows-specific implementations
│           │           ├── windows_cpu.dart
│           │           ├── windows_memory.dart
│           │           ├── windows_gpu.dart
│           │           ├── windows_network.dart
│           │           └── windows_disk.dart
│           ├── server/
│           │   ├── ws_server.dart      # WebSocket server (shelf), TLS-aware
│           │   ├── mdns_service.dart   # mDNS registration
│           │   └── cert_manager.dart   # Self-signed cert generation + storage
│           └── utils/
│               ├── process_runner.dart # Isolate-based Process.run wrapper
│               └── delta_tracker.dart  # Tracks previous sample for rate computation
│
├── app_bloc/monitor/                  # Client BLoC
│   ├── pubspec.yaml
│   └── lib/
│       ├── monitor_bloc.dart          # barrel export
│       └── src/
│           ├── bloc.dart
│           ├── event.dart
│           ├── state.dart
│           ├── monitor_repository.dart
│           └── trust_store.dart       # TOFU cert pinning persistence
│
├── lib/screens/toolbox/monitor/       # Client UI
│   ├── monitor_screen.dart
│   ├── monitor_routes.dart
│   └── widgets/
│       ├── host_list_tile.dart
│       ├── metrics_dashboard.dart
│       ├── cpu_gauge.dart
│       ├── cpu_per_core_chart.dart
│       ├── memory_gauge.dart
│       ├── gpu_card.dart
│       ├── network_chart.dart
│       ├── disk_chart.dart
│       ├── add_host_dialog.dart
│       ├── connection_indicator.dart
│       ├── trust_dialog.dart          # TOFU fingerprint confirmation dialog
│       ├── cert_mismatch_dialog.dart  # Security warning when cert changes
│       └── version_badge.dart         # Amber badge for outdated agent
```

### Workspace Registration

Add to root `pubspec.yaml`:

```yaml
workspace:
  # ... existing entries
  - monitor_models
  - monitor_agent
  - app_bloc/monitor

dependencies:
  # ... existing entries
  monitor_models: any
  monitor_agent: any
  monitor_bloc: any
```

## 2. Data Models (`monitor_models`)

### 2.1 HostInfo

```dart
@immutable
class HostInfo extends Equatable {
  final String hostname;
  final String os;           // 'linux' | 'macos' | 'windows'
  final String arch;         // 'x86_64' | 'arm64' etc.
  final String agentVersion;
  final int cpuCount;
  final int totalMemoryBytes;
  final List<GpuInfo> gpus;

  const HostInfo({...});

  factory HostInfo.fromJson(Map<String, dynamic> json);
  Map<String, dynamic> toJson();
}

@immutable
class GpuInfo extends Equatable {
  final String name;
  final int memoryBytes;

  const GpuInfo({...});
}
```

### 2.2 Metrics Models

```dart
@immutable
class CpuMetrics extends Equatable {
  final double usagePercent;
  final List<double> perCore;
  final List<double> loadAvg;   // [1m, 5m, 15m], empty on Windows

  const CpuMetrics({...});
}

@immutable
class MemoryMetrics extends Equatable {
  final int usedBytes;
  final int totalBytes;
  final int swapUsedBytes;
  final int swapTotalBytes;

  double get usagePercent => totalBytes > 0 ? usedBytes / totalBytes * 100 : 0;
  double get swapPercent => swapTotalBytes > 0 ? swapUsedBytes / swapTotalBytes * 100 : 0;

  const MemoryMetrics({...});
}

@immutable
class GpuMetrics extends Equatable {
  final int index;
  final String name;
  final double usagePercent;
  final int memoryUsedBytes;
  final int memoryTotalBytes;
  final double? temperatureCelsius;

  const GpuMetrics({...});
}

@immutable
class NetworkMetrics extends Equatable {
  final String interface_;
  final int txBytesPerSec;
  final int rxBytesPerSec;

  const NetworkMetrics({...});
}

@immutable
class DiskMetrics extends Equatable {
  final String device;
  final int readBytesPerSec;
  final int writeBytesPerSec;
  final int usedBytes;
  final int totalBytes;

  double get usagePercent => totalBytes > 0 ? usedBytes / totalBytes * 100 : 0;

  const DiskMetrics({...});
}
```

### 2.3 MonitorMessage

```dart
enum MonitorMessageType { hostInfo, metrics, ping, pong }

@immutable
class MonitorMessage extends Equatable {
  final MonitorMessageType type;
  final DateTime timestamp;
  final HostInfo? hostInfo;
  final SystemMetrics? metrics;

  const MonitorMessage({...});

  factory MonitorMessage.fromJson(Map<String, dynamic> json);
  Map<String, dynamic> toJson();
}

@immutable
class SystemMetrics extends Equatable {
  final CpuMetrics cpu;
  final MemoryMetrics memory;
  final List<GpuMetrics> gpus;
  final List<NetworkMetrics> network;
  final List<DiskMetrics> disks;

  const SystemMetrics({...});
}
```

All models use `Equatable`, `@immutable`, and provide `fromJson`/`toJson`. No code generation — manual serialization for a lean shared package with no build_runner dependency.

## 3. WebSocket Protocol

### 3.1 Message Envelope

Every message is a JSON object with `type` and `payload`:

```json
{
  "type": "host_info",
  "payload": { ... }
}
```

### 3.2 `host_info` (agent → client, once on connect)

```json
{
  "type": "host_info",
  "payload": {
    "hostname": "dev-workstation",
    "os": "linux",
    "arch": "x86_64",
    "agentVersion": "1.0.0",
    "cpuCount": 16,
    "totalMemoryBytes": 34359738368,
    "gpus": [
      { "name": "NVIDIA RTX 4090", "memoryBytes": 25769803776 }
    ]
  }
}
```

### 3.3 `metrics` (agent → client, every N seconds)

```json
{
  "type": "metrics",
  "payload": {
    "timestamp": "2026-03-28T12:00:00.000Z",
    "cpu": {
      "usagePercent": 23.5,
      "perCore": [12.0, 45.2, 8.1, 30.7, 15.3, 22.8, 55.1, 10.4,
                  18.9, 33.2, 7.5, 41.0, 19.8, 26.3, 48.7, 11.2],
      "loadAvg": [1.23, 0.87, 0.62]
    },
    "memory": {
      "usedBytes": 17179869184,
      "totalBytes": 34359738368,
      "swapUsedBytes": 0,
      "swapTotalBytes": 8589934592
    },
    "gpus": [
      {
        "index": 0,
        "name": "NVIDIA RTX 4090",
        "usagePercent": 67.0,
        "memoryUsedBytes": 12884901888,
        "memoryTotalBytes": 25769803776,
        "temperatureCelsius": 72.0
      }
    ],
    "network": [
      {
        "interface": "eth0",
        "txBytesPerSec": 1048576,
        "rxBytesPerSec": 5242880
      },
      {
        "interface": "wlan0",
        "txBytesPerSec": 262144,
        "rxBytesPerSec": 1048576
      }
    ],
    "disks": [
      {
        "device": "nvme0n1",
        "readBytesPerSec": 10485760,
        "writeBytesPerSec": 2097152,
        "usedBytes": 500000000000,
        "totalBytes": 1000000000000
      }
    ]
  }
}
```

### 3.4 `ping` / `pong` (keepalive)

```json
{ "type": "ping", "payload": {} }
{ "type": "pong", "payload": {} }
```

Client sends `ping` every 15 seconds when connected. If no `pong` received within 5 seconds, connection is considered dead → trigger reconnection.

## 4. Agent Architecture

### 4.1 Collector Interface

```dart
abstract class MetricsCollector<T> {
  /// Collect a single sample. May throw on unsupported platforms.
  Future<T> collect();

  /// Whether this collector is available on the current platform.
  bool get isSupported;
}
```

Each metric type has one abstract collector and three platform implementations. A factory function returns the correct implementation based on `Platform.operatingSystem`:

```dart
MetricsCollector<CpuMetrics> createCpuCollector() {
  return switch (Platform.operatingSystem) {
    'linux'   => LinuxCpuCollector(),
    'macos'   => MacosCpuCollector(),
    'windows' => WindowsCpuCollector(),
    _         => throw UnsupportedError('Unsupported OS'),
  };
}
```

### 4.2 Delta-Based Metrics

CPU usage, network I/O, and disk I/O are computed as deltas between consecutive samples. The `DeltaTracker<T>` utility handles this:

```dart
class DeltaTracker<T> {
  T? _previous;

  /// Returns null on first call (no delta available).
  /// On subsequent calls, passes previous and current to the delta function.
  R? track<R>(T current, R Function(T previous, T current) computeDelta) {
    final prev = _previous;
    _previous = current;
    if (prev == null) return null;
    return computeDelta(prev, current);
  }
}
```

First sample after agent startup produces no output. Metrics push begins from the second sample.

### 4.3 Isolate-Based Collection

Shell commands (`Process.run`) are executed in a separate isolate to prevent blocking the WebSocket server:

```dart
class IsolateProcessRunner {
  /// Run a command in an isolate, return stdout as String.
  static Future<String> run(String executable, List<String> args);
}
```

This is critical for the agent to remain responsive to WebSocket clients while potentially slow shell commands execute (e.g., `nvidia-smi` can take 100–500ms).

### 4.4 Agent Orchestrator

```dart
class MonitorAgent {
  final AgentConfig config;
  final List<MetricsCollector> collectors;
  final WsServer server;
  final MdnsService? mdns;

  /// Start the agent:
  /// 1. Initialize collectors (first sample for delta tracking)
  /// 2. Start WebSocket server
  /// 3. Register mDNS service
  /// 4. Start periodic collection timer
  Future<void> start();

  /// Graceful shutdown:
  /// 1. Cancel collection timer
  /// 2. Deregister mDNS
  /// 3. Close all WebSocket connections
  /// 4. Stop HTTP server
  Future<void> stop();
}
```

Collection loop pseudocode:

```
every config.interval seconds:
  samples = await Future.wait([
    cpuCollector.collect(),
    memoryCollector.collect(),
    gpuCollector.collect(),     // may return empty if unsupported
    networkCollector.collect(),
    diskCollector.collect(),
  ])
  message = MonitorMessage(type: metrics, payload: SystemMetrics(...))
  server.broadcast(message.toJson())
```

### 4.5 WebSocket Server

Built on `shelf` + `shelf_web_socket`, with TLS via `dart:io` `HttpServer.bindSecure`:

```dart
class WsServer {
  final Set<WebSocketChannel> _clients = {};
  final CertManager certManager;

  /// Start HTTPS server with TLS (or plain HTTP in dev mode).
  /// In TLS mode, uses cert/key from CertManager.
  Future<void> start(String bind, int port, {bool useTls = true});

  /// Send message to all connected clients.
  void broadcast(Map<String, dynamic> json);

  /// Build HostInfo for the current machine.
  Future<HostInfo> collectHostInfo();
}
```

Route: `GET /ws` → WebSocket upgrade. `GET /cert-fingerprint` → returns SHA-256 fingerprint as plain text (for programmatic TOFU). Any other path returns 404. The server sends `host_info` immediately on each new client connection.

M1 uses plain WS (`useTls: false`) for development convenience. M3 switches to WSS by default.

### 4.6 mDNS Service Registration

```dart
class MdnsService {
  static const serviceType = '_gsmlg-monitor._tcp';

  /// Register the service on the local network.
  Future<void> register({
    required String hostname,
    required int port,
    required String agentVersion,
    required String certFingerprint,  // included in TXT record for pre-verification
  });

  /// Deregister (called on shutdown).
  Future<void> deregister();
}
```

Uses `multicast_dns` package. Falls back gracefully if mDNS registration fails (e.g., no multicast support). The `certFingerprint` TXT record allows clients to display the fingerprint before connecting, enabling out-of-band verification.

### 4.7 TLS Certificate Management

```dart
class CertManager {
  static const certDir = '.gsmlg-monitor';
  static const certFile = 'cert.pem';
  static const keyFile = 'key.pem';

  /// Path: ~/.gsmlg-monitor/
  final String storePath;

  /// Load existing cert/key or generate new self-signed pair.
  /// Certificate properties:
  ///   - Subject CN: machine hostname
  ///   - SANs: all non-loopback local IP addresses
  ///   - Validity: 365 days
  ///   - Key: RSA 2048 or EC P-256
  Future<SecurityContext> getOrCreateSecurityContext();

  /// Force regenerate certificate (--regen-cert flag).
  Future<SecurityContext> regenerate();

  /// SHA-256 fingerprint of the current certificate.
  Future<String> get fingerprint;

  /// Print fingerprint to stdout for out-of-band verification.
  void printFingerprint();
}
```

Implementation uses `pointycastle` for key generation and self-signed cert creation. The certificate is stored as PEM files in `~/.gsmlg-monitor/` and reused across agent restarts.

Certificate lifecycle:

```
First launch:
  1. Check ~/.gsmlg-monitor/cert.pem exists
  2. If not → generate RSA-2048 key pair + self-signed X.509 cert
  3. Write cert.pem + key.pem
  4. Print fingerprint: "Agent fingerprint: SHA256:ab:cd:ef:..."

Subsequent launches:
  1. Load existing cert.pem + key.pem
  2. If expired → regenerate automatically
  3. Print fingerprint

--regen-cert flag:
  1. Delete existing cert.pem + key.pem
  2. Generate new pair
  3. Print new fingerprint
  4. Warning: "Clients will need to re-trust this agent"
```

### 4.8 Version Reporting

The `host_info` message includes `agentVersion` (semver string). The client compares this against a hardcoded `minAgentVersion` constant in `monitor_models`:

```dart
/// Minimum agent version the client is compatible with.
/// Bump this when protocol-breaking changes are made.
const String minAgentVersion = '1.0.0';

/// Returns true if the agent version is older than the minimum.
bool isAgentOutdated(String agentVersion) {
  // semver comparison
}
```

When `isAgentOutdated` returns true, the BLoC sets a `versionWarning` flag on the `MonitorHost`, and the UI shows an amber warning badge on the host tile with tooltip "Agent update available".

## 5. Client BLoC Architecture

### 5.1 State

```dart
enum HostConnectionStatus {
  discovered,    // Found via mDNS, not yet connected
  connecting,    // WS handshake in progress
  connected,     // WS open, receiving metrics
  disconnected,  // WS closed, will retry
  error,         // Retry timeout exceeded
}

enum TrustStatus {
  unknown,       // Never connected (no fingerprint yet)
  pending,       // First connect — awaiting user confirmation
  trusted,       // User confirmed fingerprint, pinned in DB
  mismatch,      // Fingerprint changed since last trust — security warning
}

@immutable
class MonitorHost extends Equatable {
  final String id;               // unique: "$ip:$port"
  final String ip;
  final int port;
  final bool isManual;
  final HostConnectionStatus status;
  final HostInfo? hostInfo;
  final RingBuffer<SystemMetrics> metricsHistory;  // last 60 samples
  final SystemMetrics? latestMetrics;
  final TrustStatus trustStatus;     // TOFU state
  final String? certFingerprint;     // agent's cert SHA-256
  final bool versionWarning;         // true if agent version < minAgentVersion
}

@immutable
sealed class MonitorState extends Equatable {}

class MonitorInitial extends MonitorState {}

class MonitorLoaded extends MonitorState {
  final Map<String, MonitorHost> hosts;
  final String? selectedHostId;
  final bool isScanning;
}
```

### 5.2 Events

```dart
@immutable
sealed class MonitorEvent extends Equatable {}

class DiscoverHosts extends MonitorEvent {}

class ConnectHost extends MonitorEvent {
  final String hostId;
}

class DisconnectHost extends MonitorEvent {
  final String hostId;
}

class AddManualHost extends MonitorEvent {
  final String ip;
  final int port;
}

class RemoveHost extends MonitorEvent {
  final String hostId;
}

class SelectHost extends MonitorEvent {
  final String hostId;
}

// Internal events (from streams)
class _HostDiscovered extends MonitorEvent {
  final String ip;
  final int port;
  final String hostname;
}

class _MetricsReceived extends MonitorEvent {
  final String hostId;
  final MonitorMessage message;
}

class _ConnectionStatusChanged extends MonitorEvent {
  final String hostId;
  final HostConnectionStatus status;
}

// TOFU certificate events
class _CertificateReceived extends MonitorEvent {
  final String hostId;
  final String fingerprint;
}

class TrustHost extends MonitorEvent {
  final String hostId;   // User confirms fingerprint → pin in DB
}

class RejectHost extends MonitorEvent {
  final String hostId;   // User rejects fingerprint → disconnect
}

class ReTrustHost extends MonitorEvent {
  final String hostId;   // User re-trusts after cert mismatch
}
```

### 5.3 MonitorRepository

```dart
class MonitorRepository {
  /// Start mDNS discovery. Returns a stream of discovered hosts.
  Stream<DiscoveredHost> discoverHosts();

  /// Connect to a host via WSS. Returns a stream of MonitorMessages.
  /// On first connect, emits a CertificateEvent with the agent's fingerprint.
  /// If pinnedFingerprint is provided, verifies against it (mismatch → error).
  /// Handles reconnection internally with exponential backoff.
  Stream<MonitorMessage> connect(
    String ip,
    int port, {
    String? pinnedFingerprint,
  });

  /// Retrieve agent cert fingerprint without establishing full connection.
  /// Used for pre-verification via the /cert-fingerprint HTTP endpoint.
  Future<String> fetchFingerprint(String ip, int port);

  /// Disconnect from a host.
  Future<void> disconnect(String hostId);

  /// Dispose all connections and stop discovery.
  Future<void> dispose();
}
```

The `connect` method configures a custom `SecurityContext` that accepts self-signed certificates. On TLS handshake, it extracts the server certificate's SHA-256 fingerprint and compares it against `pinnedFingerprint` (if present). Mismatch causes the stream to emit an error event rather than silently connecting.

The BLoC subscribes to the repository's streams and maps them to internal events. Each host connection is an independent stream subscription managed by the BLoC.

### 5.4 RingBuffer

```dart
class RingBuffer<T> {
  final int capacity;
  final List<T> _buffer;

  RingBuffer(this.capacity);

  void add(T item);
  List<T> toList();  // oldest → newest
  T? get latest;
  int get length;
  bool get isFull;
}
```

Capacity: 60 samples. At 3-second intervals, this gives ~3 minutes of sparkline history. Immutable snapshots are created for state emission via `toList()`.

## 6. Client UI Design

### 6.1 Screen Layout

**Desktop (width ≥ 900dp):**

```
┌──────────────────────────────────────────────────┐
│ Monitor                              [+ Add Host] │
├─────────────┬────────────────────────────────────┤
│ Host List   │ Metrics Dashboard                  │
│             │                                    │
│ ● workst..  │ ┌─CPU────────┐ ┌─Memory──────┐   │
│   23% · 16G │ │  ◐ 23.5%   │ │  ◐ 50.0%    │   │
│             │ │  per-core   │ │  16/32 GB    │   │
│ ○ nas-01    │ │  ████░░░░   │ │  swap: 0%    │   │
│   discovered│ └────────────┘ └──────────────┘   │
│             │ ┌─GPU─────────────────────────┐   │
│             │ │ RTX 4090  ◐ 67%  72°C       │   │
│             │ │ VRAM: 12/24 GB              │   │
│             │ └─────────────────────────────┘   │
│             │ ┌─Network────┐ ┌─Disk─────────┐   │
│             │ │ eth0       │ │ nvme0n1       │   │
│             │ │ ↑1MB ↓5MB  │ │ R:10MB W:2MB │   │
│             │ │ ~~~~~~~~   │ │ ~~~~~~~~     │   │
│             │ └────────────┘ └──────────────┘   │
└─────────────┴────────────────────────────────────┘
```

**Mobile (width < 900dp):**

- Host list is full-screen
- Tapping a host pushes a detail screen with the metrics dashboard
- Back button returns to host list

### 6.2 Widget Hierarchy

```
MonitorScreen
├── HostListPanel
│   ├── ScanningIndicator (when isScanning)
│   ├── HostListTile × N
│   │   ├── ConnectionIndicator (colored dot)
│   │   ├── hostname + OS icon
│   │   └── summary: CPU % + memory %
│   └── AddHostButton → AddHostDialog
│
└── MetricsDashboard (for selected host)
    ├── CpuSection
    │   ├── CpuGauge (radial, aggregate %)
    │   ├── CpuPerCoreChart (horizontal bar chart)
    │   └── LoadAvgText
    ├── MemorySection
    │   ├── MemoryGauge (radial, used/total %)
    │   └── SwapIndicator
    ├── GpuSection (per GPU)
    │   └── GpuCard
    │       ├── utilization gauge
    │       ├── VRAM bar
    │       └── temperature badge
    ├── NetworkSection (per interface)
    │   └── NetworkChart (dual sparkline: tx + rx)
    └── DiskSection (per device)
        ├── DiskChart (dual sparkline: read + write)
        └── DiskCapacityBar
```

### 6.3 Radial Gauge Widget

Used for CPU, memory, GPU utilization. Built with `dv_shape` `ArcGenerator` and `dv_scale` `scaleLinear`:

```dart
class GaugeChartPainter extends CustomPainter {
  final double percent; // 0–100

  @override
  void paint(Canvas canvas, Size size) {
    final radius = math.min(size.width, size.height) / 2 - 10;
    final center = Offset(size.width / 2, size.height / 2);

    // Color scale: green → yellow → red
    final colorScale = scaleLinear(domain: [0, 60, 80, 100], range: [...]);

    // Background arc (grey track)
    final bgArc = ArcGenerator(
      innerRadius: radius * 0.75, outerRadius: radius,
      startAngle: -math.pi * 0.75, endAngle: math.pi * 0.75,
    );

    // Value arc
    final valueAngle = scaleLinear(
      domain: [0, 100],
      range: [-math.pi * 0.75, math.pi * 0.75],
    );
    final fgArc = ArcGenerator(
      innerRadius: radius * 0.75, outerRadius: radius,
      startAngle: -math.pi * 0.75, endAngle: valueAngle(percent),
    );

    // Draw arcs + center text
  }
}
```

- Smooth animation between values using `AnimatedBuilder` + `Tween`
- Center text: percentage value + label

### 6.4 Sparkline Widget

Used for network and disk I/O. Built with `dv_scale`, `dv_curve`, and `dv_shape` `LineGenerator`/`AreaGenerator`:

```dart
class SparklinePainter extends CustomPainter {
  final List<double> txData;  // ring buffer snapshot
  final List<double> rxData;

  @override
  void paint(Canvas canvas, Size size) {
    final xScale = scaleLinear(
      domain: [0, txData.length - 1],
      range: [0, size.width],
    );
    final maxVal = [txData.max, rxData.max].reduce(math.max);
    final yScale = scaleLinear(
      domain: [0, maxVal],
      range: [size.height, 0],
    );

    // Area fill under each line
    final txArea = AreaGenerator<int>(
      x: (i, _) => xScale(i.toDouble()),
      y0: (_, __) => size.height,
      y1: (i, _) => yScale(txData[i]),
      curve: curveMonotoneX(),
    );

    // Line on top
    final txLine = LineGenerator<int>(
      x: (i, _) => xScale(i.toDouble()),
      y: (i, _) => yScale(txData[i]),
      curve: curveMonotoneX(),
    );

    // Draw area (semi-transparent) then line for tx and rx
  }
}
```

- 60 data points from ring buffer
- Two series per chart (tx/rx or read/write) in distinct colors
- Auto-scaling Y-axis using `scaleLinear` domain from data max
- Human-readable labels via helper (bytes/s → KB/s, MB/s, GB/s)
- `curveMonotoneX()` for smooth monotone interpolation
- Semi-transparent `AreaGenerator` fill under each `LineGenerator` line
- Optional: `dv_tooltip` for tap-to-inspect individual data points

### 6.4.1 Per-Core CPU Bar Chart

Built with `dv_scale` `scaleBand` for core labels and `scaleLinear` for usage:

```dart
final coreScale = scaleBand(
  domain: List.generate(cpuCount, (i) => 'Core $i'),
  range: [0, size.width],
  padding: 0.15,
);
final usageScale = scaleLinear(domain: [0, 100], range: [size.height, 0]);
```

Horizontal bars, color-coded by utilization level using the same green → yellow → red scale as gauges.

### 6.5 Connection Indicator Colors

| Status | Color | Icon |
|--------|-------|------|
| `discovered` | Blue | `Icons.wifi` |
| `connecting` | Amber | `CircularProgressIndicator` (small) |
| `connected` | Green | `Icons.check_circle` |
| `disconnected` | Grey | `Icons.cloud_off` |
| `error` | Red | `Icons.error` |

### 6.6 TOFU Trust Dialog

On first connection to any agent, the client displays a modal dialog before allowing data flow:

```
┌─────────────────────────────────────────┐
│  Trust this agent?                      │
│                                         │
│  Host: workstation.local                │
│  IP:   192.168.1.42:9723               │
│                                         │
│  Certificate fingerprint:               │
│  SHA256:ab:cd:ef:12:34:56:78:9a:bc:de  │
│         :f0:12:34:56:78:9a:bc:de:f0:12 │
│                                         │
│  Verify this matches the fingerprint    │
│  shown when the agent started.          │
│                                         │
│          [Reject]    [Trust]            │
└─────────────────────────────────────────┘
```

If the certificate fingerprint changes on a previously-trusted host, a security warning dialog is shown instead:

```
┌─────────────────────────────────────────┐
│  ⚠ Certificate Changed                  │
│                                         │
│  Host: workstation.local                │
│                                         │
│  The agent's certificate has changed    │
│  since you last connected. This could   │
│  mean the agent was reinstalled, or     │
│  someone is intercepting the connection.│
│                                         │
│  Previous: SHA256:ab:cd:ef:...          │
│  Current:  SHA256:01:23:45:...          │
│                                         │
│      [Disconnect]    [Trust New Cert]   │
└─────────────────────────────────────────┘
```

### 6.7 Version Warning Badge

When `hostInfo.agentVersion` is older than `minAgentVersion`, the host tile shows an amber badge:

- Icon: `Icons.update` in amber
- Tooltip: "Agent v{version} — update available"
- Tapping the badge shows a dialog with instructions to update the agent

### 6.8 Trusted Certificates Database

Stored in `AppDatabase` (M3+):

```sql
CREATE TABLE monitor_trusted_certs (
  host_id TEXT PRIMARY KEY,          -- "ip:port"
  fingerprint TEXT NOT NULL,         -- SHA-256 hex string
  hostname TEXT,                     -- hostname from HostInfo
  trusted_at TEXT NOT NULL,          -- ISO 8601 timestamp
  last_connected_at TEXT NOT NULL    -- updated on each successful connect
);
```

The `TrustStore` class in `app_bloc/monitor` wraps this table:

```dart
class TrustStore {
  final AppDatabase db;

  /// Returns the pinned fingerprint for a host, or null if not yet trusted.
  Future<String?> getPinnedFingerprint(String hostId);

  /// Pin a new fingerprint (first trust or re-trust).
  Future<void> pin(String hostId, String fingerprint, String? hostname);

  /// Remove trust (on host removal).
  Future<void> remove(String hostId);

  /// Update last_connected_at timestamp.
  Future<void> touch(String hostId);
}
```

## 7. Routing Integration

### 7.1 Route Definition

`lib/screens/toolbox/monitor/monitor_routes.dart`:

```dart
GoRoute monitorRoute() => GoRoute(
  path: MonitorScreen.path,
  name: MonitorScreen.name,
  pageBuilder: (context, state) =>
    const NoTransitionPage(child: MonitorScreen()),
);
```

### 7.2 Screen Constants

```dart
class MonitorScreen extends StatefulWidget {
  static const name = 'Monitor';
  static const path = 'monitor';

  const MonitorScreen({super.key});
}
```

### 7.3 Registration

Add `monitorRoute()` to the children list in `toolbox_routes.dart`, following the pattern of `camera`, `ip_geo`, `whois`, `bluetooth`.

### 7.4 Navigation Destination

Add Monitor to the toolbox grid/list in the toolbox screen with icon `Icons.monitor_heart` or `Icons.desktop_windows`.

## 8. MainProvider Integration

Register `MonitorBloc` in `MainProvider` after `BluetoothBloc`:

```dart
BlocProvider<MonitorBloc>(
  create: (context) => MonitorBloc(
    monitorRepository: MonitorRepository(),
  ),
),
```

No repository provider needed — `MonitorRepository` is created inline by the BLoC (it has no external dependencies for v1). In M4, when host persistence is added, it will accept `AppDatabase`.

## 9. Agent pubspec.yaml

```yaml
name: monitor_agent
description: System metrics agent for GSMLG Monitor
publish_to: none
resolution: workspace

environment:
  sdk: ^3.8.0

dependencies:
  args: any
  monitor_models: any
  shelf: any
  shelf_web_socket: any
  multicast_dns: any
  pointycastle: any      # Self-signed cert generation (M3)
```

Entry point `bin/monitor_agent.dart` uses `ArgParser` for CLI flags, instantiates the `MonitorAgent`, and wires up SIGINT/SIGTERM for graceful shutdown.

## 10. Platform-Specific Collection Details

### 10.1 Linux CPU (`/proc/stat`)

Read `/proc/stat`, parse `cpu` and `cpuN` lines. Each line has columns: `user nice system idle iowait irq softirq steal`. Compute usage as:

```
total = sum of all fields
idle_total = idle + iowait
usage% = (1 - (idle_delta / total_delta)) * 100
```

Delta between two reads at the push interval.

### 10.2 Linux Memory (`/proc/meminfo`)

Parse key-value pairs. Relevant fields:

```
MemTotal → totalBytes (kB → bytes)
MemAvailable → available (kB → bytes)
used = total - available
SwapTotal → swapTotalBytes
SwapFree → swapFreeBytes
swapUsed = swapTotal - swapFree
```

### 10.3 Linux GPU (`nvidia-smi`)

```bash
nvidia-smi --query-gpu=index,name,utilization.gpu,memory.used,memory.total,temperature.gpu \
           --format=csv,noheader,nounits
```

Parse CSV output. If `nvidia-smi` is not found, return empty GPU list.

### 10.4 Linux Network (`/proc/net/dev`)

Parse lines after header. Each line: `iface: rx_bytes rx_packets ... tx_bytes tx_packets ...`. Delta between reads to get bytes/sec. Exclude `lo`.

### 10.5 Linux Disk (`/proc/diskstats`)

Fields 6 and 10 are sectors read/written. Sector size is typically 512 bytes. Delta between reads. Filter to real block devices (exclude partitions, loop devices).

Disk usage via `statvfs` syscall (available through `dart:io`'s `FileStat` or shell `df`).

### 10.6 macOS CPU

```bash
top -l 2 -n 0 -s 0
```

Two samples, parse the second `CPU usage:` line for `user%`, `sys%`, `idle%`. Per-core requires `processor_info` via `sysctl` or parsing `top` differently.

### 10.7 macOS Memory

```bash
vm_stat
sysctl hw.memsize
```

Parse `vm_stat` for `Pages active`, `Pages wired down`, etc. Multiply by page size (typically 16384 on ARM, 4096 on Intel). `hw.memsize` gives total.

### 10.8 macOS GPU (IOKit + Metal)

Apple Silicon and Intel Macs do not expose GPU utilization via standard CLI tools. The collector uses IOKit framework via `dart:ffi` to query the `IOAccelerator` service.

**Collection approach:**

1. Use `IOServiceGetMatchingServices` with `IOServiceMatching("IOAccelerator")` to find GPU services.
2. Call `IORegistryEntryCreateCFProperties` on each service to read the performance statistics dictionary.
3. Extract `"Device Utilization %"` (or `"GPU Core Utilization"` on some models) from the properties dictionary.
4. GPU name comes from the `"model"` property or `system_profiler SPDisplaysDataType`.
5. GPU memory total/used: Apple Silicon uses unified memory — report as the GPU's allocated share from `"VRAM,totalMB"` in IORegistry, or fall back to reporting unified memory stats.

**FFI bindings required:**

```dart
// Minimal IOKit FFI surface
@Native<Int32 Function(Pointer<Void>, Pointer<Pointer<Void>>)>()
external int IOServiceGetMatchingServices(...);

@Native<Int32 Function(Pointer<Void>, Pointer<Void>, Pointer<Pointer<Void>>, Int32)>()
external int IORegistryEntryCreateCFProperties(...);
```

**Fragility considerations:**

- IOKit property keys vary across macOS versions and GPU generations.
- The collector wraps all IOKit calls in try/catch and returns empty `GpuMetrics` on any failure.
- A version-to-property-key mapping table may be needed for different macOS releases.
- Integration tests should run on both Apple Silicon and Intel Macs.
- Consider falling back to `powermetrics -s gpu_power` (requires root) or `ioreg -l -w 0` parsing as alternatives if IOKit FFI proves too fragile.

**Fallback chain:**

```
1. IOKit IOAccelerator properties → full metrics
2. `ioreg -rc IOAccelerator` shell parse → partial metrics (name + utilization)
3. `system_profiler SPDisplaysDataType` → name only, no utilization
4. Empty GPU list → GPU section hidden in UI
```

### 10.9 Windows CPU

```bash
wmic cpu get LoadPercentage /value
```

Returns `LoadPercentage=XX`. For per-core, use PowerShell:

```powershell
Get-Counter '\Processor(*)\% Processor Time' -SampleInterval 1 -MaxSamples 1
```

### 10.10 Windows Memory

```bash
wmic os get FreePhysicalMemory,TotalVisibleMemorySize /value
```

Values in KB. `used = total - free`.

### 10.11 Windows GPU

Same `nvidia-smi` command as Linux (NVIDIA installs it to PATH on Windows). For non-NVIDIA GPUs, fall back to:

```powershell
Get-Counter '\GPU Engine(*engtype_3D)\Utilization Percentage'
```

## 11. Error Handling

### 11.1 Agent Errors

| Error | Handling |
|-------|----------|
| Collector throws | Log warning, send partial metrics (null out failed metric type) |
| `Process.run` timeout | 5-second timeout per command, return empty/null on timeout |
| Port in use | Exit with clear error message, suggest `--port` |
| mDNS registration fails | Log warning, continue without mDNS |

### 11.2 Client Errors

| Error | Handling |
|-------|----------|
| WS connection refused | Status → `disconnected`, start backoff retry |
| WS unexpected close | Same as above |
| Invalid JSON from agent | Log, ignore message, continue listening |
| mDNS browse fails | Log, disable auto-discovery, show "manual only" hint |
| All retries exhausted | Status → `error`, show "unreachable" in UI |

## 12. Testing Strategy

### 12.1 Unit Tests

- **monitor_models**: Serialization round-trip for all models
- **monitor_agent/collectors**: Mock `Process.run`, verify parsing for each platform
- **monitor_agent/delta_tracker**: Verify delta computation, first-sample null behavior
- **app_bloc/monitor**: BLoC test with mock `MonitorRepository`

### 12.2 Integration Tests

- Agent WS server: Start server, connect client, verify `host_info` sent, then `metrics` stream
- mDNS: Register service, browse from client, verify discovery (requires network; CI-skip)

### 12.3 Widget Tests

- `MetricsDashboard`: Pump with mock state, verify all gauge/chart widgets render
- `HostListTile`: Verify status icon colors for each `HostConnectionStatus`
- `AddHostDialog`: Verify IP validation, port validation

## 13. Future Considerations

These are deliberately out of scope for the initial milestones but inform the architecture:

- **Historical storage**: Metrics could be persisted to SQLite on the agent side, with a REST endpoint for range queries. Client could show historical charts with `dv_scale` `scaleTime` and `dv_brush` for time-range selection.
- **Alerts**: Threshold-based alerts (CPU > 90% for 5 minutes) could be a BLoC-level feature with local notifications.
- **Container metrics**: Docker/Podman socket integration for per-container resource usage.
- **Agent auto-update**: Currently the client warns on version mismatch. A future enhancement could check GitHub Releases API and offer one-click binary update.
- **Multi-user trust**: Current TOFU model is per-device. A shared trust store (e.g., via a team config file or central authority) could simplify fleet management.
- **Process list**: Show top-N processes by CPU/memory on each host, similar to `htop`.
