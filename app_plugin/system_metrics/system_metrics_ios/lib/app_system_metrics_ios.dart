import 'package:app_system_metrics_platform_interface/app_system_metrics_platform_interface.dart';

/// The iOS implementation of [SystemMetricsPlatform].
class SystemMetricsIOS extends SystemMetricsPlatform {
  /// Registers this class as the default instance of [SystemMetricsPlatform].
  static void registerWith() {
    SystemMetricsPlatform.instance = SystemMetricsIOS();
  }
}
