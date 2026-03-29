//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of openapi.api;

class PrivateNetworks {
  /// Returns a new [PrivateNetworks] instance.
  PrivateNetworks({
    this.id,
    this.macAddress,
    this.ipAddress,
  });

  /// A unique ID for the Private Network.
  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  String? id;

  /// The assigned MAC address.
  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  String? macAddress;

  /// The assigned IP address.
  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  String? ipAddress;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PrivateNetworks &&
          other.id == id &&
          other.macAddress == macAddress &&
          other.ipAddress == ipAddress;

  @override
  int get hashCode =>
      // ignore: unnecessary_parenthesis
      (id == null ? 0 : id!.hashCode) +
      (macAddress == null ? 0 : macAddress!.hashCode) +
      (ipAddress == null ? 0 : ipAddress!.hashCode);

  @override
  String toString() =>
      'PrivateNetworks[id=$id, macAddress=$macAddress, ipAddress=$ipAddress]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
    if (this.id != null) {
      json[r'id'] = this.id;
    } else {
      json[r'id'] = null;
    }
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

  /// Returns a new [PrivateNetworks] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static PrivateNetworks? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      assert(() {
        requiredKeys.forEach((key) {
          assert(json.containsKey(key),
              'Required key "PrivateNetworks[$key]" is missing from JSON.');
          assert(json[key] != null,
              'Required key "PrivateNetworks[$key]" has a null value in JSON.');
        });
        return true;
      }());

      return PrivateNetworks(
        id: mapValueOfType<String>(json, r'id'),
        macAddress: mapValueOfType<String>(json, r'mac_address'),
        ipAddress: mapValueOfType<String>(json, r'ip_address'),
      );
    }
    return null;
  }

  static List<PrivateNetworks> listFromJson(
    dynamic json, {
    bool growable = false,
  }) {
    final result = <PrivateNetworks>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = PrivateNetworks.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, PrivateNetworks> mapFromJson(dynamic json) {
    final map = <String, PrivateNetworks>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = PrivateNetworks.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of PrivateNetworks-objects as value to a dart map
  static Map<String, List<PrivateNetworks>> mapListFromJson(
    dynamic json, {
    bool growable = false,
  }) {
    final map = <String, List<PrivateNetworks>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = PrivateNetworks.listFromJson(
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
