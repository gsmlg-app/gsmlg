import 'package:app_client_info_platform_interface/app_client_info_platform_interface.dart';
import 'package:flutter/services.dart';

/// The Windows implementation of [ClientInfoPlatform].
class ClientInfoWindows extends ClientInfoPlatform {
  /// The method channel used to interact with the native platform.
  final _methodChannel = const MethodChannel('app_client_info');

  /// Registers this class as the default instance of [ClientInfoPlatform].
  static void registerWith() {
    ClientInfoPlatform.instance = ClientInfoWindows();
  }

  @override
  Future<Map<String, dynamic>> getData() async {
    final result =
        await _methodChannel.invokeMethod<Map<Object?, Object?>>('getData');
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
    await _methodChannel.invokeMethod<void>('refresh');
  }
}
