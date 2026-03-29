//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of openapi.api;

class BackupSchedule {
  /// Returns a new [BackupSchedule] instance.
  BackupSchedule({
    this.enabled,
    this.type,
    this.nextScheduledTimeUtc,
    this.hour,
    this.dow,
    this.dom,
  });

  /// Indicates if backup is enabled:  * true * false
  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  bool? enabled;

  /// Type of backup schedule:  |   | Value | Description | | - | ------ | ------------- | |   | daily | Back up once per day at `hour`. | |   | weekly | Back up once per week on `dow` at `hour`. | |   | monthly | Back up each month at `dom` at `hour`. | |   | daily\\_alt\\_even | Back up on even dates at `hour`. | |   | daily\\_alt\\_odd | Back up on odd dates at `hour`. |
  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  String? type;

  /// Time of next backup run in UTC.
  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  String? nextScheduledTimeUtc;

  /// Scheduled hour of day in UTC.
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
      other is BackupSchedule &&
          other.enabled == enabled &&
          other.type == type &&
          other.nextScheduledTimeUtc == nextScheduledTimeUtc &&
          other.hour == hour &&
          other.dow == dow &&
          other.dom == dom;

  @override
  int get hashCode =>
      // ignore: unnecessary_parenthesis
      (enabled == null ? 0 : enabled!.hashCode) +
      (type == null ? 0 : type!.hashCode) +
      (nextScheduledTimeUtc == null ? 0 : nextScheduledTimeUtc!.hashCode) +
      (hour == null ? 0 : hour!.hashCode) +
      (dow == null ? 0 : dow!.hashCode) +
      (dom == null ? 0 : dom!.hashCode);

  @override
  String toString() =>
      'BackupSchedule[enabled=$enabled, type=$type, nextScheduledTimeUtc=$nextScheduledTimeUtc, hour=$hour, dow=$dow, dom=$dom]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
    if (this.enabled != null) {
      json[r'enabled'] = this.enabled;
    } else {
      json[r'enabled'] = null;
    }
    if (this.type != null) {
      json[r'type'] = this.type;
    } else {
      json[r'type'] = null;
    }
    if (this.nextScheduledTimeUtc != null) {
      json[r'next_scheduled_time_utc'] = this.nextScheduledTimeUtc;
    } else {
      json[r'next_scheduled_time_utc'] = null;
    }
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

  /// Returns a new [BackupSchedule] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static BackupSchedule? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      assert(() {
        requiredKeys.forEach((key) {
          assert(json.containsKey(key),
              'Required key "BackupSchedule[$key]" is missing from JSON.');
          assert(json[key] != null,
              'Required key "BackupSchedule[$key]" has a null value in JSON.');
        });
        return true;
      }());

      return BackupSchedule(
        enabled: mapValueOfType<bool>(json, r'enabled'),
        type: mapValueOfType<String>(json, r'type'),
        nextScheduledTimeUtc:
            mapValueOfType<String>(json, r'next_scheduled_time_utc'),
        hour: mapValueOfType<int>(json, r'hour'),
        dow: mapValueOfType<int>(json, r'dow'),
        dom: mapValueOfType<int>(json, r'dom'),
      );
    }
    return null;
  }

  static List<BackupSchedule> listFromJson(
    dynamic json, {
    bool growable = false,
  }) {
    final result = <BackupSchedule>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = BackupSchedule.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, BackupSchedule> mapFromJson(dynamic json) {
    final map = <String, BackupSchedule>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = BackupSchedule.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of BackupSchedule-objects as value to a dart map
  static Map<String, List<BackupSchedule>> mapListFromJson(
    dynamic json, {
    bool growable = false,
  }) {
    final map = <String, List<BackupSchedule>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = BackupSchedule.listFromJson(
          entry.value,
          growable: growable,
        );
      }
    }
    return map;
  }

  /// The list of required keys that must be present in a JSON.
  static const requiredKeys = <String>{};
}
