//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of openapi.api;

class CreateKubernetesClusterRequest {
  /// Returns a new [CreateKubernetesClusterRequest] instance.
  CreateKubernetesClusterRequest({
    this.label,
    required this.region,
    required this.version,
    this.vpcId,
    this.haControlplanes,
    this.enableFirewall,
    this.oidc,
    this.nodePools = const [],
  });

  /// The label for your Kubernetes cluster.
  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  String? label;

  /// Region you want to deploy VKE in. See [Regions](#tag/region) for more information.
  String region;

  /// Version of Kubernetes you want to deploy.
  String version;

  /// The [VPC id](#operation/list-vpcs) to use when deploying this VKE. Omitting or leaving this empty will configure a new VPC network with this deployment.
  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  String? vpcId;

  /// Whether a highly available control planes configuration should be deployed * true * false (default)
  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  bool? haControlplanes;

  /// Whether a [Firewall Group](#tag/firewall) should be deployed and managed by this cluster * true * false (default)
  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  bool? enableFirewall;

  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  CreateKubernetesClusterRequestOidc? oidc;

  List<CreateKubernetesClusterRequestNodePoolsInner> nodePools;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CreateKubernetesClusterRequest &&
          other.label == label &&
          other.region == region &&
          other.version == version &&
          other.vpcId == vpcId &&
          other.haControlplanes == haControlplanes &&
          other.enableFirewall == enableFirewall &&
          other.oidc == oidc &&
          _deepEquality.equals(other.nodePools, nodePools);

  @override
  int get hashCode =>
      // ignore: unnecessary_parenthesis
      (label == null ? 0 : label!.hashCode) +
      (region.hashCode) +
      (version.hashCode) +
      (vpcId == null ? 0 : vpcId!.hashCode) +
      (haControlplanes == null ? 0 : haControlplanes!.hashCode) +
      (enableFirewall == null ? 0 : enableFirewall!.hashCode) +
      (oidc == null ? 0 : oidc!.hashCode) +
      (nodePools.hashCode);

  @override
  String toString() =>
      'CreateKubernetesClusterRequest[label=$label, region=$region, version=$version, vpcId=$vpcId, haControlplanes=$haControlplanes, enableFirewall=$enableFirewall, oidc=$oidc, nodePools=$nodePools]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
    if (this.label != null) {
      json[r'label'] = this.label;
    } else {
      json[r'label'] = null;
    }
    json[r'region'] = this.region;
    json[r'version'] = this.version;
    if (this.vpcId != null) {
      json[r'vpc_id'] = this.vpcId;
    } else {
      json[r'vpc_id'] = null;
    }
    if (this.haControlplanes != null) {
      json[r'ha_controlplanes'] = this.haControlplanes;
    } else {
      json[r'ha_controlplanes'] = null;
    }
    if (this.enableFirewall != null) {
      json[r'enable_firewall'] = this.enableFirewall;
    } else {
      json[r'enable_firewall'] = null;
    }
    if (this.oidc != null) {
      json[r'oidc'] = this.oidc;
    } else {
      json[r'oidc'] = null;
    }
    json[r'node_pools'] = this.nodePools;
    return json;
  }

  /// Returns a new [CreateKubernetesClusterRequest] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static CreateKubernetesClusterRequest? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      assert(() {
        requiredKeys.forEach((key) {
          assert(json.containsKey(key),
              'Required key "CreateKubernetesClusterRequest[$key]" is missing from JSON.');
          assert(json[key] != null,
              'Required key "CreateKubernetesClusterRequest[$key]" has a null value in JSON.');
        });
        return true;
      }());

      return CreateKubernetesClusterRequest(
        label: mapValueOfType<String>(json, r'label'),
        region: mapValueOfType<String>(json, r'region')!,
        version: mapValueOfType<String>(json, r'version')!,
        vpcId: mapValueOfType<String>(json, r'vpc_id'),
        haControlplanes: mapValueOfType<bool>(json, r'ha_controlplanes'),
        enableFirewall: mapValueOfType<bool>(json, r'enable_firewall'),
        oidc: CreateKubernetesClusterRequestOidc.fromJson(json[r'oidc']),
        nodePools: CreateKubernetesClusterRequestNodePoolsInner.listFromJson(
            json[r'node_pools']),
      );
    }
    return null;
  }

  static List<CreateKubernetesClusterRequest> listFromJson(
    dynamic json, {
    bool growable = false,
  }) {
    final result = <CreateKubernetesClusterRequest>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = CreateKubernetesClusterRequest.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, CreateKubernetesClusterRequest> mapFromJson(dynamic json) {
    final map = <String, CreateKubernetesClusterRequest>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = CreateKubernetesClusterRequest.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of CreateKubernetesClusterRequest-objects as value to a dart map
  static Map<String, List<CreateKubernetesClusterRequest>> mapListFromJson(
    dynamic json, {
    bool growable = false,
  }) {
    final map = <String, List<CreateKubernetesClusterRequest>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = CreateKubernetesClusterRequest.listFromJson(
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
    'version',
  };
}
