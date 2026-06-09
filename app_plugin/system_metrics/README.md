# System Metrics

Retrieve CPU, GPU, NPU, and memory metrics

## Features

- ✅ Cross-platform support (Android, iOS, Linux, macOS, Windows)
- ✅ Native platform integration
- ✅ Method channel communication
- ✅ Built-in caching
- ✅ Type-safe API

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
