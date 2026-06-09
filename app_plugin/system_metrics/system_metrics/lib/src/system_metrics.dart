import 'package:flutter/foundation.dart';
import 'package:app_system_metrics_platform_interface/app_system_metrics_platform_interface.dart';
import 'models/models.dart';

/// Main class for SystemMetrics plugin.
///
/// Provides a unified API for accessing system_metrics information
/// across all supported platforms.
class SystemMetrics {
  SystemMetrics._();

  static SystemMetrics? _instance;

  /// Get the singleton instance of SystemMetrics.
  static SystemMetrics get instance {
    _instance ??= SystemMetrics._();
    return _instance!;
  }

  /// The platform interface instance.
  static SystemMetricsPlatform get _platform {
    return SystemMetricsPlatform.instance;
  }

  /// Get system_metrics data.
  ///
  /// Returns a [SystemMetricsData] object containing all available
  /// system_metrics information for the current platform.
  ///
  /// Example:
  /// ```dart
  /// final systemMetrics = SystemMetrics.instance;
  /// final data = await systemMetrics.getData();
  /// print('Data: ${data}');
  /// ```
  Future<SystemMetricsData> getData() async {
    final platformData = await _platform.getData();
    return SystemMetricsData.fromMap(platformData);
  }

  /// Refresh system_metrics data.
  ///
  /// Forces a refresh of the cached data from the platform.
  Future<void> refresh() async {
    await _platform.refresh();
  }

  /// For testing purposes only.
  @visibleForTesting
  static void setMockPlatform(SystemMetricsPlatform platform) {
    SystemMetricsPlatform.instance = platform;
  }

  /// Reset the singleton instance.
  @visibleForTesting
  static void reset() {
    _instance = null;
  }
}
