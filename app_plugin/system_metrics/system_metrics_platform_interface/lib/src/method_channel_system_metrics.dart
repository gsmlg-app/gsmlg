import 'package:flutter/services.dart';
import 'system_metrics_platform.dart';

/// An implementation of [SystemMetricsPlatform] that uses method channels.
class MethodChannelSystemMetrics extends SystemMetricsPlatform {
  /// The method channel used to interact with the native platform.
  final methodChannel = const MethodChannel('app_system_metrics');

  @override
  Future<Map<String, dynamic>> getData() async {
    final result = await methodChannel.invokeMethod<Map<Object?, Object?>>('getData');
    if (result == null) {
      throw PlatformException(
        code: 'NULL_RESULT',
        message: 'Platform returned null result',
      );
    }
    return Map<String, dynamic>.from(result);
  }

  @override
  Future<void> refresh() async {
    await methodChannel.invokeMethod<void>('refresh');
  }
}
