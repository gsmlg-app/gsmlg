import 'dart:io';

import 'package:monitor_models/monitor_models.dart';
import 'package:monitor_agent/src/collectors/collector.dart';
import 'package:monitor_agent/src/collectors/platform/linux/linux_disk.dart';
import 'package:monitor_agent/src/collectors/platform/macos/macos_disk.dart';
import 'package:monitor_agent/src/collectors/platform/windows/windows_disk.dart';

MetricsCollector<List<DiskMetrics>> createDiskCollector() {
  if (Platform.isLinux) return LinuxDiskCollector();
  if (Platform.isMacOS) return MacosDiskCollector();
  if (Platform.isWindows) return WindowsDiskCollector();
  throw UnsupportedError(
      'Disk collector not available for ${Platform.operatingSystem}');
}
