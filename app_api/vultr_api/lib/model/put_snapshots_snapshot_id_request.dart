//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of openapi.api;

class PutSnapshotsSnapshotIdRequest {
  /// Returns a new [PutSnapshotsSnapshotIdRequest] instance.
  PutSnapshotsSnapshotIdRequest({
    required this.description,
  });

  /// The user-supplied description for the Snapshot.
  String description;

  @override
  bool operator ==(Object other) => identical(this, other) || other is PutSnapshotsSnapshotIdRequest &&
    other.description == description;

  @override
  int get hashCode =>
    // ignore: unnecessary_parenthesis
    (description.hashCode);

  @override
  String toString() => 'PutSnapshotsSnapshotIdRequest[description=$description]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
      json[r'description'] = this.description;
    return json;
  }

  /// Returns a new [PutSnapshotsSnapshotIdRequest] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static PutSnapshotsSnapshotIdRequest? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      assert(() {
        requiredKeys.forEach((key) {
          assert(json.containsKey(key), 'Required key "PutSnapshotsSnapshotIdRequest[$key]" is missing from JSON.');
          assert(json[key] != null, 'Required key "PutSnapshotsSnapshotIdRequest[$key]" has a null value in JSON.');
        });
        return true;
      }());

      return PutSnapshotsSnapshotIdRequest(
        description: mapValueOfType<String>(json, r'description')!,
      );
    }
    return null;
  }

  static List<PutSnapshotsSnapshotIdRequest> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <PutSnapshotsSnapshotIdRequest>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = PutSnapshotsSnapshotIdRequest.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, PutSnapshotsSnapshotIdRequest> mapFromJson(dynamic json) {
    final map = <String, PutSnapshotsSnapshotIdRequest>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = PutSnapshotsSnapshotIdRequest.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of PutSnapshotsSnapshotIdRequest-objects as value to a dart map
  static Map<String, List<PutSnapshotsSnapshotIdRequest>> mapListFromJson(dynamic json, {bool growable = false,}) {
    final map = <String, List<PutSnapshotsSnapshotIdRequest>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = PutSnapshotsSnapshotIdRequest.listFromJson(entry.value, growable: growable,);
      }
    }
    return map;
  }

  /// The list of required keys that must be present in a JSON.
  static const requiredKeys = <String>{
    'description',
  };
}

