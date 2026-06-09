import 'package:app_system_metrics_platform_interface/app_system_metrics_platform_interface.dart';

/// The Linux implementation of [SystemMetricsPlatform].
class SystemMetricsLinux extends SystemMetricsPlatform {
  /// Registers this class as the default instance of [SystemMetricsPlatform].
  static void registerWith() {
    SystemMetricsPlatform.instance = SystemMetricsLinux();
  }
}
