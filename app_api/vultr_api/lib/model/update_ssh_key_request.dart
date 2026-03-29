//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of openapi.api;

class UpdateSshKeyRequest {
  /// Returns a new [UpdateSshKeyRequest] instance.
  UpdateSshKeyRequest({
    this.name,
    this.sshKey,
  });

  /// The user-supplied name for this SSH Key.
  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  String? name;

  /// The SSH Key.
  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  String? sshKey;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UpdateSshKeyRequest &&
          other.name == name &&
          other.sshKey == sshKey;

  @override
  int get hashCode =>
      // ignore: unnecessary_parenthesis
      (name == null ? 0 : name!.hashCode) +
      (sshKey == null ? 0 : sshKey!.hashCode);

  @override
  String toString() => 'UpdateSshKeyRequest[name=$name, sshKey=$sshKey]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
    if (this.name != null) {
      json[r'name'] = this.name;
    } else {
      json[r'name'] = null;
    }
    if (this.sshKey != null) {
      json[r'ssh_key'] = this.sshKey;
    } else {
      json[r'ssh_key'] = null;
    }
    return json;
  }

  /// Returns a new [UpdateSshKeyRequest] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static UpdateSshKeyRequest? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      assert(() {
        requiredKeys.forEach((key) {
          assert(json.containsKey(key),
              'Required key "UpdateSshKeyRequest[$key]" is missing from JSON.');
          assert(json[key] != null,
              'Required key "UpdateSshKeyRequest[$key]" has a null value in JSON.');
        });
        return true;
      }());

      return UpdateSshKeyRequest(
        name: mapValueOfType<String>(json, r'name'),
        sshKey: mapValueOfType<String>(json, r'ssh_key'),
      );
    }
    return null;
  }

  static List<UpdateSshKeyRequest> listFromJson(
    dynamic json, {
    bool growable = false,
  }) {
    final result = <UpdateSshKeyRequest>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = UpdateSshKeyRequest.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, UpdateSshKeyRequest> mapFromJson(dynamic json) {
    final map = <String, UpdateSshKeyRequest>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = UpdateSshKeyRequest.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of UpdateSshKeyRequest-objects as value to a dart map
  static Map<String, List<UpdateSshKeyRequest>> mapListFromJson(
    dynamic json, {
    bool growable = false,
  }) {
    final map = <String, List<UpdateSshKeyRequest>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = UpdateSshKeyRequest.listFromJson(
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
