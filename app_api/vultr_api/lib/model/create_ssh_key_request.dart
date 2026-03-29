//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of openapi.api;

class CreateSshKeyRequest {
  /// Returns a new [CreateSshKeyRequest] instance.
  CreateSshKeyRequest({
    required this.name,
    required this.sshKey,
  });

  /// The user-supplied name for this SSH Key.
  String name;

  /// The SSH Key.
  String sshKey;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CreateSshKeyRequest &&
          other.name == name &&
          other.sshKey == sshKey;

  @override
  int get hashCode =>
      // ignore: unnecessary_parenthesis
      (name.hashCode) + (sshKey.hashCode);

  @override
  String toString() => 'CreateSshKeyRequest[name=$name, sshKey=$sshKey]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
    json[r'name'] = this.name;
    json[r'ssh_key'] = this.sshKey;
    return json;
  }

  /// Returns a new [CreateSshKeyRequest] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static CreateSshKeyRequest? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      assert(() {
        requiredKeys.forEach((key) {
          assert(json.containsKey(key),
              'Required key "CreateSshKeyRequest[$key]" is missing from JSON.');
          assert(json[key] != null,
              'Required key "CreateSshKeyRequest[$key]" has a null value in JSON.');
        });
        return true;
      }());

      return CreateSshKeyRequest(
        name: mapValueOfType<String>(json, r'name')!,
        sshKey: mapValueOfType<String>(json, r'ssh_key')!,
      );
    }
    return null;
  }

  static List<CreateSshKeyRequest> listFromJson(
    dynamic json, {
    bool growable = false,
  }) {
    final result = <CreateSshKeyRequest>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = CreateSshKeyRequest.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, CreateSshKeyRequest> mapFromJson(dynamic json) {
    final map = <String, CreateSshKeyRequest>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = CreateSshKeyRequest.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of CreateSshKeyRequest-objects as value to a dart map
  static Map<String, List<CreateSshKeyRequest>> mapListFromJson(
    dynamic json, {
    bool growable = false,
  }) {
    final map = <String, List<CreateSshKeyRequest>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = CreateSshKeyRequest.listFromJson(
          entry.value,
          growable: growable,
        );
      }
    }
    return map;
  }

  /// The list of required keys that must be present in a JSON.
  static const requiredKeys = <String>{
    'name',
    'ssh_key',
  };
}
