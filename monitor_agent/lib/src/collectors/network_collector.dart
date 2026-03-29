import 'dart:io';

import 'package:monitor_models/monitor_models.dart';
import 'package:monitor_agent/src/collectors/collector.dart';
import 'package:monitor_agent/src/collectors/platform/linux/linux_network.dart';
import 'package:monitor_agent/src/collectors/platform/macos/macos_network.dart';
import 'package:monitor_agent/src/collectors/platform/windows/windows_network.dart';

MetricsCollector<List<NetworkMetrics>> createNetworkCollector() {
  if (Platform.isLinux) return LinuxNetworkCollector();
  if (Platform.isMacOS) return MacosNetworkCollector();
  if (Platform.isWindows) return WindowsNetworkCollector();
  throw UnsupportedError(
    'Network collector not available for ${Platform.operatingSystem}',
  );
}
