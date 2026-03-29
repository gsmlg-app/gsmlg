//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of openapi.api;

class Vpc2nodes {
  /// Returns a new [Vpc2nodes] instance.
  Vpc2nodes({
    this.id,
    this.ipAddress,
    this.macAddress,
    this.description,
    this.type,
    this.nodeStatus,
  });

  /// A unique ID for the attached instance.
  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  String? id;

  /// The IP address to use for the attached instance.
  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  String? ipAddress;

  /// The MAC address to use for the attached instance.
  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  String? macAddress;

  /// The user-supplied label for the attached instance.
  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  String? description;

  /// The type of the attached instance.
  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  String? type;

  /// The status of the attached instance.
  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  String? nodeStatus;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Vpc2nodes &&
          other.id == id &&
          other.ipAddress == ipAddress &&
          other.macAddress == macAddress &&
          other.description == description &&
          other.type == type &&
          other.nodeStatus == nodeStatus;

  @override
  int get hashCode =>
      // ignore: unnecessary_parenthesis
      (id == null ? 0 : id!.hashCode) +
      (ipAddress == null ? 0 : ipAddress!.hashCode) +
      (macAddress == null ? 0 : macAddress!.hashCode) +
      (description == null ? 0 : description!.hashCode) +
      (type == null ? 0 : type!.hashCode) +
      (nodeStatus == null ? 0 : nodeStatus!.hashCode);

  @override
  String toString() =>
      'Vpc2nodes[id=$id, ipAddress=$ipAddress, macAddress=$macAddress, description=$description, type=$type, nodeStatus=$nodeStatus]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
    if (this.id != null) {
      json[r'id'] = this.id;
    } else {
      json[r'id'] = null;
    }
    if (this.ipAddress != null) {
      json[r'ip_address'] = this.ipAddress;
    } else {
      json[r'ip_address'] = null;
    }
    if (this.macAddress != null) {
      json[r'mac_address'] = this.macAddress;
    } else {
      json[r'mac_address'] = null;
    }
    if (this.description != null) {
      json[r'description'] = this.description;
    } else {
      json[r'description'] = null;
    }
    if (this.type != null) {
      json[r'type'] = this.type;
    } else {
      json[r'type'] = null;
    }
    if (this.nodeStatus != null) {
      json[r'node_status'] = this.nodeStatus;
    } else {
      json[r'node_status'] = null;
    }
    return json;
  }

  /// Returns a new [Vpc2nodes] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static Vpc2nodes? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      assert(() {
        requiredKeys.forEach((key) {
          assert(json.containsKey(key),
              'Required key "Vpc2nodes[$key]" is missing from JSON.');
          assert(json[key] != null,
              'Required key "Vpc2nodes[$key]" has a null value in JSON.');
        });
        return true;
      }());

      return Vpc2nodes(
        id: mapValueOfType<String>(json, r'id'),
        ipAddress: mapValueOfType<String>(json, r'ip_address'),
        macAddress: mapValueOfType<String>(json, r'mac_address'),
        description: mapValueOfType<String>(json, r'description'),
        type: mapValueOfType<String>(json, r'type'),
        nodeStatus: mapValueOfType<String>(json, r'node_status'),
      );
    }
    return null;
  }

  static List<Vpc2nodes> listFromJson(
    dynamic json, {
    bool growable = false,
  }) {
    final result = <Vpc2nodes>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = Vpc2nodes.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, Vpc2nodes> mapFromJson(dynamic json) {
    final map = <String, Vpc2nodes>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = Vpc2nodes.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of Vpc2nodes-objects as value to a dart map
  static Map<String, List<Vpc2nodes>> mapListFromJson(
    dynamic json, {
    bool growable = false,
  }) {
    final map = <String, List<Vpc2nodes>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = Vpc2nodes.listFromJson(
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
