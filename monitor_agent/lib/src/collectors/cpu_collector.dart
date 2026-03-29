import 'dart:io';

import 'package:monitor_models/monitor_models.dart';
import 'package:monitor_agent/src/collectors/collector.dart';
import 'package:monitor_agent/src/collectors/platform/linux/linux_cpu.dart';
import 'package:monitor_agent/src/collectors/platform/macos/macos_cpu.dart';
import 'package:monitor_agent/src/collectors/platform/windows/windows_cpu.dart';

MetricsCollector<CpuMetrics> createCpuCollector() {
  if (Platform.isLinux) return LinuxCpuCollector();
  if (Platform.isMacOS) return MacosCpuCollector();
  if (Platform.isWindows) return WindowsCpuCollector();
  throw UnsupportedError(
      'CPU collector not available for ${Platform.operatingSystem}');
}
