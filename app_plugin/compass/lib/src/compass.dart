import 'package:flutter/services.dart';

import 'models/compass_reading.dart';

abstract interface class CompassSource {
  Stream<CompassReading> get readings;
  Future<void> refreshOrientation();
}

final class AppCompass implements CompassSource {
  AppCompass({
    this._events = const EventChannel('app_compass/events'),
    this._methods = const MethodChannel('app_compass'),
  });

  final EventChannel _events;
  final MethodChannel _methods;
  late final Stream<CompassReading> _readings = _events
      .receiveBroadcastStream()
      .map(
        (event) =>
            CompassReading.fromMap(Map<String, Object?>.from(event as Map)),
      );

  @override
  Stream<CompassReading> get readings => _readings;

  @override
  Future<void> refreshOrientation() async {
    await _methods.invokeMethod<void>('refreshOrientation');
  }
}
