//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of openapi.api;

class CreateInstanceBackupScheduleRequest {
  /// Returns a new [CreateInstanceBackupScheduleRequest] instance.
  CreateInstanceBackupScheduleRequest({
    required this.type,
    this.hour,
    this.dow,
    this.dom,
  });

  /// Type of backup schedule:  |   | Value | Description | | - | ------ | ------------- | |   | daily | Back up once per day at `hour`. | |   | weekly | Back up once per week on `dow` at `hour`. | |   | monthly | Back up each month at `dom` at `hour`. | |   | daily\\_alt\\_even | Back up on even dates at `hour`. | |   | daily\\_alt\\_odd | Back up on odd dates at `hour`. |
  String type;

  /// Hour of day to run in UTC.
  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  int? hour;

  /// Day of week to run.  |   | Value | Description | | - | ------ | ------------- | |   | 1 | Sunday | |   | 2 | Monday | |   | 3 | Tuesday | |   | 4 | Wednesday | |   | 5 | Thursday | |   | 6 | Friday | |   | 7 | Saturday |
  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  int? dow;

  /// Day of month to run. Use values between 1 and 28.
  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  int? dom;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CreateInstanceBackupScheduleRequest &&
          other.type == type &&
          other.hour == hour &&
          other.dow == dow &&
          other.dom == dom;

  @override
  int get hashCode =>
      // ignore: unnecessary_parenthesis
      (type.hashCode) +
      (hour == null ? 0 : hour!.hashCode) +
      (dow == null ? 0 : dow!.hashCode) +
      (dom == null ? 0 : dom!.hashCode);

  @override
  String toString() =>
      'CreateInstanceBackupScheduleRequest[type=$type, hour=$hour, dow=$dow, dom=$dom]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
    json[r'type'] = this.type;
    if (this.hour != null) {
      json[r'hour'] = this.hour;
    } else {
      json[r'hour'] = null;
    }
    if (this.dow != null) {
      json[r'dow'] = this.dow;
    } else {
      json[r'dow'] = null;
    }
    if (this.dom != null) {
      json[r'dom'] = this.dom;
    } else {
      json[r'dom'] = null;
    }
    return json;
  }

  /// Returns a new [CreateInstanceBackupScheduleRequest] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static CreateInstanceBackupScheduleRequest? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      assert(() {
        requiredKeys.forEach((key) {
          assert(json.containsKey(key),
              'Required key "CreateInstanceBackupScheduleRequest[$key]" is missing from JSON.');
          assert(json[key] != null,
              'Required key "CreateInstanceBackupScheduleRequest[$key]" has a null value in JSON.');
        });
        return true;
      }());

      return CreateInstanceBackupScheduleRequest(
        type: mapValueOfType<String>(json, r'type')!,
        hour: mapValueOfType<int>(json, r'hour'),
        dow: mapValueOfType<int>(json, r'dow'),
        dom: mapValueOfType<int>(json, r'dom'),
      );
    }
    return null;
  }

  static List<CreateInstanceBackupScheduleRequest> listFromJson(
    dynamic json, {
    bool growable = false,
  }) {
    final result = <CreateInstanceBackupScheduleRequest>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = CreateInstanceBackupScheduleRequest.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, CreateInstanceBackupScheduleRequest> mapFromJson(
      dynamic json) {
    final map = <String, CreateInstanceBackupScheduleRequest>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = CreateInstanceBackupScheduleRequest.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of CreateInstanceBackupScheduleRequest-objects as value to a dart map
  static Map<String, List<CreateInstanceBackupScheduleRequest>> mapListFromJson(
    dynamic json, {
    bool growable = false,
  }) {
    final map = <String, List<CreateInstanceBackupScheduleRequest>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = CreateInstanceBackupScheduleRequest.listFromJson(
          entry.value,
          growable: growable,
        );
      }
    }
    return map;
  }

  /// The list of required keys that must be present in a JSON.
  static const requiredKeys = <String>{
    'type',
  };
}
