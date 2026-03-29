import 'dart:io';

import 'package:monitor_models/monitor_models.dart';
import 'package:monitor_agent/src/collectors/collector.dart';
import 'package:monitor_agent/src/collectors/platform/linux/linux_memory.dart';
import 'package:monitor_agent/src/collectors/platform/macos/macos_memory.dart';
import 'package:monitor_agent/src/collectors/platform/windows/windows_memory.dart';

MetricsCollector<MemoryMetrics> createMemoryCollector() {
  if (Platform.isLinux) return LinuxMemoryCollector();
  if (Platform.isMacOS) return MacosMemoryCollector();
  if (Platform.isWindows) return WindowsMemoryCollector();
  throw UnsupportedError(
    'Memory collector not available for ${Platform.operatingSystem}',
  );
}
