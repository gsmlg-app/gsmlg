import 'package:app_compass/app_compass.dart';
import 'package:flutter_test/flutter_test.dart';

Map<String, Object?> reading({
  String status = 'ready',
  Object? heading = 128.0,
  Object? accuracy,
  Object? quality,
  Object? reason,
}) => {
  'status': status,
  'magneticHeadingDegrees': heading,
  'accuracyDegrees': accuracy,
  'sensorAccuracy': quality,
  'unavailableReason': reason,
};

void main() {
  test('preserves actual heading and unknown degree accuracy on Android', () {
    final value = CompassReading.fromMap(reading(quality: 'high'));
    expect(value.status, CompassStatus.ready);
    expect(value.magneticHeadingDegrees, 128);
    expect(value.accuracyDegrees, isNull);
    expect(value.sensorAccuracy, CompassSensorAccuracy.high);
  });

  test('iOS zero degree error is valid', () {
    final value = CompassReading.fromMap(reading(heading: 0, accuracy: 0));
    expect(value.magneticHeadingDegrees, 0);
    expect(value.accuracyDegrees, 0);
    expect(value.sensorAccuracy, isNull);
  });

  test('unreliable values stay unknown instead of pointing north', () {
    final value = CompassReading.fromMap(
      reading(status: 'calibrating', heading: null, quality: 'unreliable'),
    );
    expect(value.magneticHeadingDegrees, isNull);
    expect(value.accuracyDegrees, isNull);
  });

  test('low accuracy estimate preserves its warning state and real error', () {
    final value = CompassReading.fromMap(
      reading(status: 'calibrating', heading: 90.5, accuracy: 25.0),
    );
    expect(value.status, CompassStatus.calibrating);
    expect(value.magneticHeadingDegrees, 90.5);
    expect(value.accuracyDegrees, 25);
  });

  for (final reason in CompassUnavailableReason.values) {
    test('unavailable preserves ${reason.name}', () {
      final value = CompassReading.fromMap(
        reading(status: 'unavailable', heading: null, reason: reason.name),
      );
      expect(value.unavailableReason, reason);
      expect(value.magneticHeadingDegrees, isNull);
    });
  }

  final invalid = <Map<String, Object?>>[
    reading(status: 'invalid'),
    reading(heading: null),
    reading(heading: -1),
    reading(heading: 360),
    reading(heading: double.nan),
    reading(heading: double.infinity),
    reading(heading: '128'),
    reading(accuracy: -1),
    reading(accuracy: double.nan),
    reading(quality: 'accurate'),
    reading(reason: 'sensorFailure'),
    reading(status: 'unavailable', heading: null),
    reading(status: 'unavailable', reason: 'sensorNotFound'),
    {},
  ];
  for (var index = 0; index < invalid.length; index++) {
    test('rejects invalid event $index without inventing data', () {
      expect(
        () => CompassReading.fromMap(invalid[index]),
        throwsFormatException,
      );
    });
  }
}
