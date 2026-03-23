//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of openapi.api;

class GetInstanceBackupSchedule200Response {
  /// Returns a new [GetInstanceBackupSchedule200Response] instance.
  GetInstanceBackupSchedule200Response({
    this.backupSchedule,
  });

  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  BackupSchedule? backupSchedule;

  @override
  bool operator ==(Object other) => identical(this, other) || other is GetInstanceBackupSchedule200Response &&
    other.backupSchedule == backupSchedule;

  @override
  int get hashCode =>
    // ignore: unnecessary_parenthesis
    (backupSchedule == null ? 0 : backupSchedule!.hashCode);

  @override
  String toString() => 'GetInstanceBackupSchedule200Response[backupSchedule=$backupSchedule]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
    if (this.backupSchedule != null) {
      json[r'backup_schedule'] = this.backupSchedule;
    } else {
      json[r'backup_schedule'] = null;
    }
    return json;
  }

  /// Returns a new [GetInstanceBackupSchedule200Response] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static GetInstanceBackupSchedule200Response? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      assert(() {
        requiredKeys.forEach((key) {
          assert(json.containsKey(key), 'Required key "GetInstanceBackupSchedule200Response[$key]" is missing from JSON.');
          assert(json[key] != null, 'Required key "GetInstanceBackupSchedule200Response[$key]" has a null value in JSON.');
        });
        return true;
      }());

      return GetInstanceBackupSchedule200Response(
        backupSchedule: BackupSchedule.fromJson(json[r'backup_schedule']),
      );
    }
    return null;
  }

  static List<GetInstanceBackupSchedule200Response> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <GetInstanceBackupSchedule200Response>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = GetInstanceBackupSchedule200Response.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, GetInstanceBackupSchedule200Response> mapFromJson(dynamic json) {
    final map = <String, GetInstanceBackupSchedule200Response>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = GetInstanceBackupSchedule200Response.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of GetInstanceBackupSchedule200Response-objects as value to a dart map
  static Map<String, List<GetInstanceBackupSchedule200Response>> mapListFromJson(dynamic json, {bool growable = false,}) {
    final map = <String, List<GetInstanceBackupSchedule200Response>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = GetInstanceBackupSchedule200Response.listFromJson(entry.value, growable: growable,);
      }
    }
    return map;
  }

  /// The list of required keys that must be present in a JSON.
  static const requiredKeys = <String>{
  };
}

