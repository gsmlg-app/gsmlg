import 'package:app_system_metrics_platform_interface/app_system_metrics_platform_interface.dart';

/// The Android implementation of [SystemMetricsPlatform].
class SystemMetricsAndroid extends SystemMetricsPlatform {
  /// Registers this class as the default instance of [SystemMetricsPlatform].
  static void registerWith() {
    SystemMetricsPlatform.instance = SystemMetricsAndroid();
  }
}
