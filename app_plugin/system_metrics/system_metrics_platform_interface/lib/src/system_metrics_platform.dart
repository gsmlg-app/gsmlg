import 'package:plugin_platform_interface/plugin_platform_interface.dart';
import 'method_channel_system_metrics.dart';

/// The interface that platform-specific implementations of
/// `app_system_metrics` must extend.
abstract class SystemMetricsPlatform extends PlatformInterface {
  /// Constructs a SystemMetricsPlatform.
  SystemMetricsPlatform() : super(token: _token);

  static final Object _token = Object();

  static SystemMetricsPlatform _instance = MethodChannelSystemMetrics();

  /// The default instance of [SystemMetricsPlatform] to use.
  ///
  /// Defaults to [MethodChannelSystemMetrics].
  static SystemMetricsPlatform get instance => _instance;

  /// Platform-specific plugins should set this with their own
  /// platform-specific class that extends [SystemMetricsPlatform] when
  /// they register themselves.
  static set instance(SystemMetricsPlatform instance) {
    PlatformInterface.verify(instance, _token);
    _instance = instance;
  }

  /// Get system_metrics data from the platform.
  ///
  /// Returns a map containing platform-specific system_metrics data.
  Future<Map<String, dynamic>> getData() {
    throw UnimplementedError('getData() has not been implemented.');
  }

  /// Refresh the cached system_metrics data.
  Future<void> refresh() {
    throw UnimplementedError('refresh() has not been implemented.');
  }
}
