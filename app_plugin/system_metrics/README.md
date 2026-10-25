# System Metrics

Retrieve CPU, GPU, NPU, and memory metrics

## Features

- ✅ Cross-platform support (Android, iOS, Linux, macOS, Windows)
- ✅ Native platform integration
- ✅ Method channel communication
- ✅ Built-in caching
- ✅ Type-safe API

## Activity Monitor (macOS)

`ActivityMonitor` provides an independent sampling session for macOS Intel and
Apple Silicon. It reads native Mach, sysctl, IOKit, and network counters through
the plugin; it does not launch command-line programs or require administrator
access. Other platforms do not implement this activity API yet.

```dart
final monitor = ActivityMonitor();
final baseline = await monitor.sample();
// Call again after the application's sampling interval (for example, one second).
final snapshot = await monitor.sample();
print(snapshot.cpuUsage);
print(snapshot.disk.readBytesPerSecond);
print(snapshot.network.receivedBytesPerSecond);

// Clear the baseline when a page is hidden, paused, or resumed.
monitor.reset();
```

The session owns no timer. Its caller controls polling and stops requesting
samples when the page is hidden or disposed. Concurrent requests share one
pending sample. Each session keeps its own baseline, separate from the legacy
`SystemMetrics.getData()` sampler.

Snapshots include aggregate and per-core CPU usage, memory and swap bytes, memory
pressure, aggregate physical-disk I/O, network interfaces and I/O, GPU utilization
when published by the driver, and process/thread counts. Apple Silicon
P/E core labels come from the device tree mapped to Mach CPU slots; unavailable
topology and Intel CPUs retain generic labels. Thread totals can be partial when
the OS denies access to some processes; check `threadCountComplete`.

CPU percentages and I/O rates use differences between cumulative counters and a
monotonic clock. The first sample and samples after `reset()` contain no interval
rates. Missing measurements, counter resets, non-advancing clocks, and incompatible
CPU/disk topology produce `null`, not zero. Network rates compare interfaces by
name so a newly connected interface cannot introduce a cumulative-counter spike.
Memory used follows the reference monitor's accounting:
`max(anonymous - purgeable, 0) + wired + compressor` bytes. Missing terms make
the result unavailable. Active pages can include file-backed cache and are not
substituted for anonymous memory. Memory pressure is 1 (normal), 2 (warning), or
4 (critical). The legacy `getData()` memory formula remains unchanged.

GPU utilization remains `null` when the driver does not expose it. The activity
API does not report NPU utilization. The legacy numeric `getData()` API remains
unchanged for existing callers.

### App integration and verification

Settings → Device → Activity Monitor opens `/settings/activity-monitor`. The
screen requests one snapshot per second while its route is current and the app
is resumed, with at most one request pending. Leaving, covering, or pausing the
page stops polling. Resuming resets the baseline and the bounded 60-sample
history. Errors stop polling and expose Retry. Trend lines restart after missing
intervals instead of connecting across gaps. No activity history is persisted.

The data path is:

```text
ActivityMonitorScreen → ActivityMonitor session → platform method channel
  → serial macOS collection queue → Mach / sysctl / IOKit / interface MIB
  → raw cumulative snapshot → Dart interval calculation → dashboard
```

The CocoaPods and Swift Package Manager source layouts are kept identical. Run
`bash app_plugin/system_metrics/system_metrics_macos/test/macos_metrics_smoke_test.sh`
from the repository root to exercise both native channel implementations on the
current host and cross-compile both for Intel. This uses a Flutter channel stub;
it does not replace testing the built Flutter application. Unit and widget tests
cover interval math, unavailable counters, topology changes, request ownership,
page lifecycle, retry, routing, and responsive layouts.

Apple M1 Max live sampling was also checked with App Sandbox enabled. macOS
denies per-process detail reads in that sandbox, while the collector can still
report complete global Mach process/thread totals. Intel compilation is verified;
Intel hardware runtime requires a separate device check.

## Supported Platforms

- ✅ Android
- ✅ iOS
- ✅ Linux
- ✅ macOS
- ✅ Windows


## Installation

Add this plugin to your project's `pubspec.yaml`:

```yaml
dependencies:
  app_system_metrics: any
```

Then run:

```bash
melos bootstrap
```

## Usage

```dart
import 'package:app_system_metrics/app_system_metrics.dart';

// Get system_metrics instance
final systemMetrics = SystemMetrics.instance;

// Get data
final data = await systemMetrics. getData();
print('Platform: ${data.platform}');
print('Timestamp: ${data.timestamp}');
print('Additional Data: ${data.additionalData}');

// Refresh cached data
await systemMetrics.refresh();
```

## Architecture

This plugin uses a federated plugin architecture:

- **app_system_metrics**: Main package (app-facing API)
- **app_system_metrics_platform_interface**: Platform interface definition
- **app_system_metrics_android**: Android implementation
- **app_system_metrics_ios**: iOS implementation
- **app_system_metrics_linux**: Linux implementation
- **app_system_metrics_macos**: macOS implementation
- **app_system_metrics_windows**: Windows implementation


## Development

### Running Tests

```bash
# Test all packages
melos run test

# Test specific package
cd system_metrics && flutter test
```

### Adding New Features

1. Update the platform interface in `system_metrics_platform_interface`
2. Implement the feature in each platform-specific package
3. Update the main API in `system_metrics`
4. Add tests

## License

MIT License - see LICENSE file for details.

## Author

GSMLG Team
