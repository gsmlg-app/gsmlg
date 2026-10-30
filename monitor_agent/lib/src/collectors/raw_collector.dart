import 'dart:io';

import 'package:monitor_agent/src/collectors/platform/linux/linux_raw_collector.dart';
import 'package:monitor_agent/src/collectors/platform/macos/macos_raw_collector.dart';
import 'package:monitor_agent/src/collectors/platform/windows/windows_raw_collector.dart';

abstract class RawCollector {
  Future<Map<String, dynamic>> collectRaw();
}

RawCollector createRawCollector() {
  if (Platform.isLinux) return LinuxRawCollector();
  if (Platform.isMacOS) return MacosRawCollector();
  if (Platform.isWindows) return WindowsRawCollector();
  throw UnsupportedError(
    'Raw collector not available for ${Platform.operatingSystem}',
  );
}
