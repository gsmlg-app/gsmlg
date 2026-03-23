//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of openapi.api;

class AttachedVpcs {
  /// Returns a new [AttachedVpcs] instance.
  AttachedVpcs({
    this.id,
    this.version,
    this.subnet,
  });

  /// The ID of the VPC Network.
  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  String? id;

  /// The version of VPC (1 or 2).
  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  int? version;

  /// The IP subnet used for the instance on the VPC Network.
  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  String? subnet;

  @override
  bool operator ==(Object other) => identical(this, other) || other is AttachedVpcs &&
    other.id == id &&
    other.version == version &&
    other.subnet == subnet;

  @override
  int get hashCode =>
    // ignore: unnecessary_parenthesis
    (id == null ? 0 : id!.hashCode) +
    (version == null ? 0 : version!.hashCode) +
    (subnet == null ? 0 : subnet!.hashCode);

  @override
  String toString() => 'AttachedVpcs[id=$id, version=$version, subnet=$subnet]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
    if (this.id != null) {
      json[r'id'] = this.id;
    } else {
      json[r'id'] = null;
    }
    if (this.version != null) {
      json[r'version'] = this.version;
    } else {
      json[r'version'] = null;
    }
    if (this.subnet != null) {
      json[r'subnet'] = this.subnet;
    } else {
      json[r'subnet'] = null;
    }
    return json;
  }

  /// Returns a new [AttachedVpcs] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static AttachedVpcs? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      assert(() {
        requiredKeys.forEach((key) {
          assert(json.containsKey(key), 'Required key "AttachedVpcs[$key]" is missing from JSON.');
          assert(json[key] != null, 'Required key "AttachedVpcs[$key]" has a null value in JSON.');
        });
        return true;
      }());

      return AttachedVpcs(
        id: mapValueOfType<String>(json, r'id'),
        version: mapValueOfType<int>(json, r'version'),
        subnet: mapValueOfType<String>(json, r'subnet'),
      );
    }
    return null;
  }

  static List<AttachedVpcs> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <AttachedVpcs>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = AttachedVpcs.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, AttachedVpcs> mapFromJson(dynamic json) {
    final map = <String, AttachedVpcs>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = AttachedVpcs.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of AttachedVpcs-objects as value to a dart map
  static Map<String, List<AttachedVpcs>> mapListFromJson(dynamic json, {bool growable = false,}) {
    final map = <String, List<AttachedVpcs>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = AttachedVpcs.listFromJson(entry.value, growable: growable,);
      }
    }
    return map;
  }

  /// The list of required keys that must be present in a JSON.
  static const requiredKeys = <String>{
  };
}

