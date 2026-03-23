//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of openapi.api;

class Network {
  /// Returns a new [Network] instance.
  Network({
    required this.id,
    this.region,
    this.dateCreated,
    this.description,
    this.v4Subnet,
    this.v4SubnetMask,
  });

  /// A unique ID for the Private Network.
  String id;

  /// The [Region id](#operation/list-regions) where the network is located.
  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  String? region;

  /// Date the network was created.
  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  String? dateCreated;

  /// A description of the private network.
  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  String? description;

  /// The IPv4 network address. For example: 10.99.0.0
  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  String? v4Subnet;

  /// The number of bits for the netmask in CIDR notation. Example: 24
  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  int? v4SubnetMask;

  @override
  bool operator ==(Object other) => identical(this, other) || other is Network &&
    other.id == id &&
    other.region == region &&
    other.dateCreated == dateCreated &&
    other.description == description &&
    other.v4Subnet == v4Subnet &&
    other.v4SubnetMask == v4SubnetMask;

  @override
  int get hashCode =>
    // ignore: unnecessary_parenthesis
    (id.hashCode) +
    (region == null ? 0 : region!.hashCode) +
    (dateCreated == null ? 0 : dateCreated!.hashCode) +
    (description == null ? 0 : description!.hashCode) +
    (v4Subnet == null ? 0 : v4Subnet!.hashCode) +
    (v4SubnetMask == null ? 0 : v4SubnetMask!.hashCode);

  @override
  String toString() => 'Network[id=$id, region=$region, dateCreated=$dateCreated, description=$description, v4Subnet=$v4Subnet, v4SubnetMask=$v4SubnetMask]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
      json[r'id'] = this.id;
    if (this.region != null) {
      json[r'region'] = this.region;
    } else {
      json[r'region'] = null;
    }
    if (this.dateCreated != null) {
      json[r'date_created'] = this.dateCreated;
    } else {
      json[r'date_created'] = null;
    }
    if (this.description != null) {
      json[r'description'] = this.description;
    } else {
      json[r'description'] = null;
    }
    if (this.v4Subnet != null) {
      json[r'v4_subnet'] = this.v4Subnet;
    } else {
      json[r'v4_subnet'] = null;
    }
    if (this.v4SubnetMask != null) {
      json[r'v4_subnet_mask'] = this.v4SubnetMask;
    } else {
      json[r'v4_subnet_mask'] = null;
    }
    return json;
  }

  /// Returns a new [Network] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static Network? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      assert(() {
        requiredKeys.forEach((key) {
          assert(json.containsKey(key), 'Required key "Network[$key]" is missing from JSON.');
          assert(json[key] != null, 'Required key "Network[$key]" has a null value in JSON.');
        });
        return true;
      }());

      return Network(
        id: mapValueOfType<String>(json, r'id')!,
        region: mapValueOfType<String>(json, r'region'),
        dateCreated: mapValueOfType<String>(json, r'date_created'),
        description: mapValueOfType<String>(json, r'description'),
        v4Subnet: mapValueOfType<String>(json, r'v4_subnet'),
        v4SubnetMask: mapValueOfType<int>(json, r'v4_subnet_mask'),
      );
    }
    return null;
  }

  static List<Network> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <Network>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = Network.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, Network> mapFromJson(dynamic json) {
    final map = <String, Network>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = Network.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of Network-objects as value to a dart map
  static Map<String, List<Network>> mapListFromJson(dynamic json, {bool growable = false,}) {
    final map = <String, List<Network>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = Network.listFromJson(entry.value, growable: growable,);
      }
    }
    return map;
  }

  /// The list of required keys that must be present in a JSON.
  static const requiredKeys = <String>{
    'id',
  };
}

