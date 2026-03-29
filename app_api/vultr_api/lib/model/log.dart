//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of openapi.api;

class Log {
  /// Returns a new [Log] instance.
  Log({
    required this.resourceId,
    required this.resourceType,
    required this.logLevel,
    required this.message,
    required this.timestamp,
    required this.metadata,
  });

  /// The UUID for the resource that was interacted with.  Only set if the logged interaction relates to a specific resource with a UUID.
  String resourceId;

  /// The type of resource that was interacted with.
  String resourceType;

  /// The type of the configuration option. * `info` * `debug` * `warning` * `error` * `critical`
  String logLevel;

  /// A message relating to the event that is being logged.
  String message;

  /// the UTC timestamp of the time at which the log was generated.
  String timestamp;

  LogMetadata metadata;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Log &&
          other.resourceId == resourceId &&
          other.resourceType == resourceType &&
          other.logLevel == logLevel &&
          other.message == message &&
          other.timestamp == timestamp &&
          other.metadata == metadata;

  @override
  int get hashCode =>
      // ignore: unnecessary_parenthesis
      (resourceId.hashCode) +
      (resourceType.hashCode) +
      (logLevel.hashCode) +
      (message.hashCode) +
      (timestamp.hashCode) +
      (metadata.hashCode);

  @override
  String toString() =>
      'Log[resourceId=$resourceId, resourceType=$resourceType, logLevel=$logLevel, message=$message, timestamp=$timestamp, metadata=$metadata]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
    json[r'resource_id'] = this.resourceId;
    json[r'resource_type'] = this.resourceType;
    json[r'log_level'] = this.logLevel;
    json[r'message'] = this.message;
    json[r'timestamp'] = this.timestamp;
    json[r'metadata'] = this.metadata;
    return json;
  }

  /// Returns a new [Log] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static Log? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      assert(() {
        requiredKeys.forEach((key) {
          assert(json.containsKey(key),
              'Required key "Log[$key]" is missing from JSON.');
          assert(json[key] != null,
              'Required key "Log[$key]" has a null value in JSON.');
        });
        return true;
      }());

      return Log(
        resourceId: mapValueOfType<String>(json, r'resource_id')!,
        resourceType: mapValueOfType<String>(json, r'resource_type')!,
        logLevel: mapValueOfType<String>(json, r'log_level')!,
        message: mapValueOfType<String>(json, r'message')!,
        timestamp: mapValueOfType<String>(json, r'timestamp')!,
        metadata: LogMetadata.fromJson(json[r'metadata'])!,
      );
    }
    return null;
  }

  static List<Log> listFromJson(
    dynamic json, {
    bool growable = false,
  }) {
    final result = <Log>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = Log.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, Log> mapFromJson(dynamic json) {
    final map = <String, Log>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = Log.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of Log-objects as value to a dart map
  static Map<String, List<Log>> mapListFromJson(
    dynamic json, {
    bool growable = false,
  }) {
    final map = <String, List<Log>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = Log.listFromJson(
          entry.value,
          growable: growable,
        );
      }
    }
    return map;
  }

  /// The list of required keys that must be present in a JSON.
  static const requiredKeys = <String>{
    'resource_id',
    'resource_type',
    'log_level',
    'message',
    'timestamp',
    'metadata',
  };
}
