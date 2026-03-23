//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of openapi.api;

class RestoreInstanceRequest {
  /// Returns a new [RestoreInstanceRequest] instance.
  RestoreInstanceRequest({
    this.backupId,
    this.snapshotId,
  });

  /// The [Backup id](#operation/list-backups) used to restore this instance.
  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  String? backupId;

  /// The [Snapshot id](#operation/list-snapshots) used to restore this instance.
  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  String? snapshotId;

  @override
  bool operator ==(Object other) => identical(this, other) || other is RestoreInstanceRequest &&
    other.backupId == backupId &&
    other.snapshotId == snapshotId;

  @override
  int get hashCode =>
    // ignore: unnecessary_parenthesis
    (backupId == null ? 0 : backupId!.hashCode) +
    (snapshotId == null ? 0 : snapshotId!.hashCode);

  @override
  String toString() => 'RestoreInstanceRequest[backupId=$backupId, snapshotId=$snapshotId]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
    if (this.backupId != null) {
      json[r'backup_id'] = this.backupId;
    } else {
      json[r'backup_id'] = null;
    }
    if (this.snapshotId != null) {
      json[r'snapshot_id'] = this.snapshotId;
    } else {
      json[r'snapshot_id'] = null;
    }
    return json;
  }

  /// Returns a new [RestoreInstanceRequest] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static RestoreInstanceRequest? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      assert(() {
        requiredKeys.forEach((key) {
          assert(json.containsKey(key), 'Required key "RestoreInstanceRequest[$key]" is missing from JSON.');
          assert(json[key] != null, 'Required key "RestoreInstanceRequest[$key]" has a null value in JSON.');
        });
        return true;
      }());

      return RestoreInstanceRequest(
        backupId: mapValueOfType<String>(json, r'backup_id'),
        snapshotId: mapValueOfType<String>(json, r'snapshot_id'),
      );
    }
    return null;
  }

  static List<RestoreInstanceRequest> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <RestoreInstanceRequest>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = RestoreInstanceRequest.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, RestoreInstanceRequest> mapFromJson(dynamic json) {
    final map = <String, RestoreInstanceRequest>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = RestoreInstanceRequest.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of RestoreInstanceRequest-objects as value to a dart map
  static Map<String, List<RestoreInstanceRequest>> mapListFromJson(dynamic json, {bool growable = false,}) {
    final map = <String, List<RestoreInstanceRequest>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = RestoreInstanceRequest.listFromJson(entry.value, growable: growable,);
      }
    }
    return map;
  }

  /// The list of required keys that must be present in a JSON.
  static const requiredKeys = <String>{
  };
}

