//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of openapi.api;

class Vpc2 {
  /// Returns a new [Vpc2] instance.
  Vpc2({
    required this.id,
    this.region,
    this.dateCreated,
    this.description,
    this.ipBlock,
    this.prefixLength,
  });

  /// A unique ID for the VPC.
  String id;

  /// The [Region id](#operation/list-regions) where the VPC is located.
  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  String? region;

  /// Date the VPC was created.
  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  String? dateCreated;

  /// A description of the VPC.
  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  String? description;

  /// The VPC subnet IP address. For example: 10.99.0.0
  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  String? ipBlock;

  /// The number of bits for the netmask in CIDR notation. Example: 24
  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  int? prefixLength;

  @override
  bool operator ==(Object other) => identical(this, other) || other is Vpc2 &&
    other.id == id &&
    other.region == region &&
    other.dateCreated == dateCreated &&
    other.description == description &&
    other.ipBlock == ipBlock &&
    other.prefixLength == prefixLength;

  @override
  int get hashCode =>
    // ignore: unnecessary_parenthesis
    (id.hashCode) +
    (region == null ? 0 : region!.hashCode) +
    (dateCreated == null ? 0 : dateCreated!.hashCode) +
    (description == null ? 0 : description!.hashCode) +
    (ipBlock == null ? 0 : ipBlock!.hashCode) +
    (prefixLength == null ? 0 : prefixLength!.hashCode);

  @override
  String toString() => 'Vpc2[id=$id, region=$region, dateCreated=$dateCreated, description=$description, ipBlock=$ipBlock, prefixLength=$prefixLength]';

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
    if (this.ipBlock != null) {
      json[r'ip_block'] = this.ipBlock;
    } else {
      json[r'ip_block'] = null;
    }
    if (this.prefixLength != null) {
      json[r'prefix_length'] = this.prefixLength;
    } else {
      json[r'prefix_length'] = null;
    }
    return json;
  }

  /// Returns a new [Vpc2] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static Vpc2? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      assert(() {
        requiredKeys.forEach((key) {
          assert(json.containsKey(key), 'Required key "Vpc2[$key]" is missing from JSON.');
          assert(json[key] != null, 'Required key "Vpc2[$key]" has a null value in JSON.');
        });
        return true;
      }());

      return Vpc2(
        id: mapValueOfType<String>(json, r'id')!,
        region: mapValueOfType<String>(json, r'region'),
        dateCreated: mapValueOfType<String>(json, r'date_created'),
        description: mapValueOfType<String>(json, r'description'),
        ipBlock: mapValueOfType<String>(json, r'ip_block'),
        prefixLength: mapValueOfType<int>(json, r'prefix_length'),
      );
    }
    return null;
  }

  static List<Vpc2> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <Vpc2>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = Vpc2.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, Vpc2> mapFromJson(dynamic json) {
    final map = <String, Vpc2>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = Vpc2.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of Vpc2-objects as value to a dart map
  static Map<String, List<Vpc2>> mapListFromJson(dynamic json, {bool growable = false,}) {
    final map = <String, List<Vpc2>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = Vpc2.listFromJson(entry.value, growable: growable,);
      }
    }
    return map;
  }

  /// The list of required keys that must be present in a JSON.
  static const requiredKeys = <String>{
    'id',
  };
}

