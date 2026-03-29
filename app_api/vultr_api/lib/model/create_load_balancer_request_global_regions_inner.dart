//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of openapi.api;

class CreateLoadBalancerRequestGlobalRegionsInner {
  /// Returns a new [CreateLoadBalancerRequestGlobalRegionsInner] instance.
  CreateLoadBalancerRequestGlobalRegionsInner({
    required this.regionId,
    this.vpcId,
  });

  /// A [Region id](#operation/list-regions) to deploy child Load Balancers to.
  String regionId;

  /// ID of the VPC you wish to use. If a VPC ID is omitted it will default to the public network.
  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  String? vpcId;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CreateLoadBalancerRequestGlobalRegionsInner &&
          other.regionId == regionId &&
          other.vpcId == vpcId;

  @override
  int get hashCode =>
      // ignore: unnecessary_parenthesis
      (regionId.hashCode) + (vpcId == null ? 0 : vpcId!.hashCode);

  @override
  String toString() =>
      'CreateLoadBalancerRequestGlobalRegionsInner[regionId=$regionId, vpcId=$vpcId]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
    json[r'region_id'] = this.regionId;
    if (this.vpcId != null) {
      json[r'vpc_id'] = this.vpcId;
    } else {
      json[r'vpc_id'] = null;
    }
    return json;
  }

  /// Returns a new [CreateLoadBalancerRequestGlobalRegionsInner] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static CreateLoadBalancerRequestGlobalRegionsInner? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      assert(() {
        requiredKeys.forEach((key) {
          assert(json.containsKey(key),
              'Required key "CreateLoadBalancerRequestGlobalRegionsInner[$key]" is missing from JSON.');
          assert(json[key] != null,
              'Required key "CreateLoadBalancerRequestGlobalRegionsInner[$key]" has a null value in JSON.');
        });
        return true;
      }());

      return CreateLoadBalancerRequestGlobalRegionsInner(
        regionId: mapValueOfType<String>(json, r'region_id')!,
        vpcId: mapValueOfType<String>(json, r'vpc_id'),
      );
    }
    return null;
  }

  static List<CreateLoadBalancerRequestGlobalRegionsInner> listFromJson(
    dynamic json, {
    bool growable = false,
  }) {
    final result = <CreateLoadBalancerRequestGlobalRegionsInner>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = CreateLoadBalancerRequestGlobalRegionsInner.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, CreateLoadBalancerRequestGlobalRegionsInner> mapFromJson(
      dynamic json) {
    final map = <String, CreateLoadBalancerRequestGlobalRegionsInner>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value =
            CreateLoadBalancerRequestGlobalRegionsInner.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of CreateLoadBalancerRequestGlobalRegionsInner-objects as value to a dart map
  static Map<String, List<CreateLoadBalancerRequestGlobalRegionsInner>>
      mapListFromJson(
    dynamic json, {
    bool growable = false,
  }) {
    final map = <String, List<CreateLoadBalancerRequestGlobalRegionsInner>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] =
            CreateLoadBalancerRequestGlobalRegionsInner.listFromJson(
          entry.value,
          growable: growable,
        );
      }
    }
    return map;
  }

  /// The list of required keys that must be present in a JSON.
  static const requiredKeys = <String>{
    'region_id',
  };
}
