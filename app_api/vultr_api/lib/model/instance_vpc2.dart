//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of openapi.api;

class InstanceVpc2 {
  /// Returns a new [InstanceVpc2] instance.
  InstanceVpc2({
    required this.id,
    this.macAddress,
    this.ipAddress,
  });

  /// A unique ID for the VPC.
  String id;

  /// The MAC address to use for this instance on the attached VPC 2.0 network.
  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  String? macAddress;

  /// The IP address to use for this instance on the attached VPC 2.0 network.
  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  String? ipAddress;

  @override
  bool operator ==(Object other) => identical(this, other) || other is InstanceVpc2 &&
    other.id == id &&
    other.macAddress == macAddress &&
    other.ipAddress == ipAddress;

  @override
  int get hashCode =>
    // ignore: unnecessary_parenthesis
    (id.hashCode) +
    (macAddress == null ? 0 : macAddress!.hashCode) +
    (ipAddress == null ? 0 : ipAddress!.hashCode);

  @override
  String toString() => 'InstanceVpc2[id=$id, macAddress=$macAddress, ipAddress=$ipAddress]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
      json[r'id'] = this.id;
    if (this.macAddress != null) {
      json[r'mac_address'] = this.macAddress;
    } else {
      json[r'mac_address'] = null;
    }
    if (this.ipAddress != null) {
      json[r'ip_address'] = this.ipAddress;
    } else {
      json[r'ip_address'] = null;
    }
    return json;
  }

  /// Returns a new [InstanceVpc2] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static InstanceVpc2? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      assert(() {
        requiredKeys.forEach((key) {
          assert(json.containsKey(key), 'Required key "InstanceVpc2[$key]" is missing from JSON.');
          assert(json[key] != null, 'Required key "InstanceVpc2[$key]" has a null value in JSON.');
        });
        return true;
      }());

      return InstanceVpc2(
        id: mapValueOfType<String>(json, r'id')!,
        macAddress: mapValueOfType<String>(json, r'mac_address'),
        ipAddress: mapValueOfType<String>(json, r'ip_address'),
      );
    }
    return null;
  }

  static List<InstanceVpc2> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <InstanceVpc2>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = InstanceVpc2.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, InstanceVpc2> mapFromJson(dynamic json) {
    final map = <String, InstanceVpc2>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = InstanceVpc2.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of InstanceVpc2-objects as value to a dart map
  static Map<String, List<InstanceVpc2>> mapListFromJson(dynamic json, {bool growable = false,}) {
    final map = <String, List<InstanceVpc2>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = InstanceVpc2.listFromJson(entry.value, growable: growable,);
      }
    }
    return map;
  }

  /// The list of required keys that must be present in a JSON.
  static const requiredKeys = <String>{
    'id',
  };
}

