//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of openapi.api;

class CreateVpcRequest {
  /// Returns a new [CreateVpcRequest] instance.
  CreateVpcRequest({
    required this.region,
    this.description,
    this.v4Subnet,
    this.v4SubnetMask,
  });

  /// Create the VPC in this [Region id](#operation/list-regions).
  String region;

  /// A description of the VPC.
  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  String? description;

  /// The IPv4 VPC address. For example: 10.99.0.0<br><span style=\"color: red\">If v4_subnet_mask is specified then v4_subnet is a required field.</span>
  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  String? v4Subnet;

  /// The number of bits for the netmask in CIDR notation. Example: 24<br><span style=\"color: red\">If v4_subnet is specified then v4_subnet_mask is a required field.</span>
  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  int? v4SubnetMask;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CreateVpcRequest &&
          other.region == region &&
          other.description == description &&
          other.v4Subnet == v4Subnet &&
          other.v4SubnetMask == v4SubnetMask;

  @override
  int get hashCode =>
      // ignore: unnecessary_parenthesis
      (region.hashCode) +
      (description == null ? 0 : description!.hashCode) +
      (v4Subnet == null ? 0 : v4Subnet!.hashCode) +
      (v4SubnetMask == null ? 0 : v4SubnetMask!.hashCode);

  @override
  String toString() =>
      'CreateVpcRequest[region=$region, description=$description, v4Subnet=$v4Subnet, v4SubnetMask=$v4SubnetMask]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
    json[r'region'] = this.region;
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

  /// Returns a new [CreateVpcRequest] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static CreateVpcRequest? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      assert(() {
        requiredKeys.forEach((key) {
          assert(json.containsKey(key),
              'Required key "CreateVpcRequest[$key]" is missing from JSON.');
          assert(json[key] != null,
              'Required key "CreateVpcRequest[$key]" has a null value in JSON.');
        });
        return true;
      }());

      return CreateVpcRequest(
        region: mapValueOfType<String>(json, r'region')!,
        description: mapValueOfType<String>(json, r'description'),
        v4Subnet: mapValueOfType<String>(json, r'v4_subnet'),
        v4SubnetMask: mapValueOfType<int>(json, r'v4_subnet_mask'),
      );
    }
    return null;
  }

  static List<CreateVpcRequest> listFromJson(
    dynamic json, {
    bool growable = false,
  }) {
    final result = <CreateVpcRequest>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = CreateVpcRequest.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, CreateVpcRequest> mapFromJson(dynamic json) {
    final map = <String, CreateVpcRequest>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = CreateVpcRequest.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of CreateVpcRequest-objects as value to a dart map
  static Map<String, List<CreateVpcRequest>> mapListFromJson(
    dynamic json, {
    bool growable = false,
  }) {
    final map = <String, List<CreateVpcRequest>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = CreateVpcRequest.listFromJson(
          entry.value,
          growable: growable,
        );
      }
    }
    return map;
  }

  /// The list of required keys that must be present in a JSON.
  static const requiredKeys = <String>{
    'region',
  };
}
