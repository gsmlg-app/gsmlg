//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of openapi.api;

class CreateSnapshotRequest {
  /// Returns a new [CreateSnapshotRequest] instance.
  CreateSnapshotRequest({
    required this.instanceId,
    this.description,
  });

  /// Create a Snapshot for this [Instance id](#operation/list-instances).
  String instanceId;

  /// The user-supplied description of the Snapshot.
  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  String? description;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CreateSnapshotRequest &&
          other.instanceId == instanceId &&
          other.description == description;

  @override
  int get hashCode =>
      // ignore: unnecessary_parenthesis
      (instanceId.hashCode) + (description == null ? 0 : description!.hashCode);

  @override
  String toString() =>
      'CreateSnapshotRequest[instanceId=$instanceId, description=$description]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
    json[r'instance_id'] = this.instanceId;
    if (this.description != null) {
      json[r'description'] = this.description;
    } else {
      json[r'description'] = null;
    }
    return json;
  }

  /// Returns a new [CreateSnapshotRequest] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static CreateSnapshotRequest? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      assert(() {
        requiredKeys.forEach((key) {
          assert(json.containsKey(key),
              'Required key "CreateSnapshotRequest[$key]" is missing from JSON.');
          assert(json[key] != null,
              'Required key "CreateSnapshotRequest[$key]" has a null value in JSON.');
        });
        return true;
      }());

      return CreateSnapshotRequest(
        instanceId: mapValueOfType<String>(json, r'instance_id')!,
        description: mapValueOfType<String>(json, r'description'),
      );
    }
    return null;
  }

  static List<CreateSnapshotRequest> listFromJson(
    dynamic json, {
    bool growable = false,
  }) {
    final result = <CreateSnapshotRequest>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = CreateSnapshotRequest.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, CreateSnapshotRequest> mapFromJson(dynamic json) {
    final map = <String, CreateSnapshotRequest>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = CreateSnapshotRequest.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of CreateSnapshotRequest-objects as value to a dart map
  static Map<String, List<CreateSnapshotRequest>> mapListFromJson(
    dynamic json, {
    bool growable = false,
  }) {
    final map = <String, List<CreateSnapshotRequest>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = CreateSnapshotRequest.listFromJson(
          entry.value,
          growable: growable,
        );
      }
    }
    return map;
  }

  /// The list of required keys that must be present in a JSON.
  static const requiredKeys = <String>{
    'instance_id',
  };
}
