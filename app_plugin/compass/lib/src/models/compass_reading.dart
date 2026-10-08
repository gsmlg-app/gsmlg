enum CompassStatus { ready, calibrating, unavailable }

enum CompassSensorAccuracy { unknown, unreliable, low, medium, high }

enum CompassUnavailableReason { sensorNotFound, sensorFailure }

final class CompassReading {
  const CompassReading({
    required this.status,
    this.magneticHeadingDegrees,
    this.accuracyDegrees,
    this.sensorAccuracy,
    this.unavailableReason,
  });

  final CompassStatus status;
  final double? magneticHeadingDegrees;
  final double? accuracyDegrees;
  final CompassSensorAccuracy? sensorAccuracy;
  final CompassUnavailableReason? unavailableReason;

  factory CompassReading.fromMap(Map<String, Object?> map) {
    T? readEnum<T extends Enum>(String key, List<T> values) {
      final value = map[key];
      if (value == null) return null;
      for (final candidate in values) {
        if (candidate.name == value) return candidate;
      }
      throw FormatException('Invalid $key');
    }

    double? readNumber(String key) {
      final value = map[key];
      if (value == null) return null;
      if (value is! num || !value.toDouble().isFinite) {
        throw FormatException('Invalid $key');
      }
      return value.toDouble();
    }

    final status = readEnum('status', CompassStatus.values);
    final heading = readNumber('magneticHeadingDegrees');
    final accuracy = readNumber('accuracyDegrees');
    final quality = readEnum('sensorAccuracy', CompassSensorAccuracy.values);
    final reason = readEnum(
      'unavailableReason',
      CompassUnavailableReason.values,
    );
    if (status == null ||
        (heading != null && (heading < 0 || heading >= 360)) ||
        (accuracy != null && accuracy < 0) ||
        (status == CompassStatus.ready && heading == null) ||
        (status == CompassStatus.unavailable &&
            (heading != null || reason == null)) ||
        (status != CompassStatus.unavailable && reason != null)) {
      throw const FormatException('Invalid compass reading');
    }
    return CompassReading(
      status: status,
      magneticHeadingDegrees: heading,
      accuracyDegrees: accuracy,
      sensorAccuracy: quality,
      unavailableReason: reason,
    );
  }
}
