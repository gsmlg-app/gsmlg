import 'package:app_system_metrics_platform_interface/app_system_metrics_platform_interface.dart';

/// The Windows implementation of [SystemMetricsPlatform].
class SystemMetricsWindows extends SystemMetricsPlatform {
  /// Registers this class as the default instance of [SystemMetricsPlatform].
  static void registerWith() {
    SystemMetricsPlatform.instance = SystemMetricsWindows();
  }
}
