import 'dart:io';

import 'package:monitor_models/monitor_models.dart';
import 'package:monitor_agent/src/collectors/collector.dart';
import 'package:monitor_agent/src/collectors/platform/linux/linux_gpu.dart';
import 'package:monitor_agent/src/collectors/platform/macos/macos_gpu.dart';
import 'package:monitor_agent/src/collectors/platform/windows/windows_gpu.dart';

MetricsCollector<List<GpuMetrics>> createGpuCollector() {
  if (Platform.isLinux) return LinuxGpuCollector();
  if (Platform.isMacOS) return MacosGpuCollector();
  if (Platform.isWindows) return WindowsGpuCollector();
  throw UnsupportedError(
    'GPU collector not available for ${Platform.operatingSystem}',
  );
}
