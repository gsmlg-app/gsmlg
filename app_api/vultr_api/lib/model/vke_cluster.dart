//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of openapi.api;

class VkeCluster {
  /// Returns a new [VkeCluster] instance.
  VkeCluster({
    this.id,
    this.firewallGroupId,
    this.label,
    this.dateCreated,
    this.clusterSubnet,
    this.serviceSubnet,
    this.ip,
    this.endpoint,
    this.version,
    this.region,
    this.status,
    this.haControlplanes,
    this.oidc,
    this.nodePools = const [],
    this.vpcs = const [],
  });

  /// ID for the VKE cluster
  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  String? id;

  /// The [Firewall Group id](#operation/list-firewall-groups) linked to this cluster.
  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  String? firewallGroupId;

  /// Label for your cluster
  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  String? label;

  /// Date of creation
  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  String? dateCreated;

  /// IP range that your pods will run on in this cluster
  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  String? clusterSubnet;

  /// IP range that services will run on this cluster
  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  String? serviceSubnet;

  /// IP for your Kubernetes Clusters Control Plane
  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  String? ip;

  /// Domain for your Kubernetes Clusters Control Plane
  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  String? endpoint;

  /// Version of Kubernetes this cluster is running on
  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  String? version;

  /// Region this Kubernetes Cluster is running in
  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  String? region;

  /// Status for VKE cluster
  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  String? status;

  /// Whether a highly available control planes configuration has been deployed * true * false (default)
  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  bool? haControlplanes;

  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  VkeClusterOidc? oidc;

  /// NodePools in this cluster
  List<Nodepools> nodePools;

  /// List of VPC Networks to which the instance is attached.
  List<AttachedVpcs> vpcs;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is VkeCluster &&
          other.id == id &&
          other.firewallGroupId == firewallGroupId &&
          other.label == label &&
          other.dateCreated == dateCreated &&
          other.clusterSubnet == clusterSubnet &&
          other.serviceSubnet == serviceSubnet &&
          other.ip == ip &&
          other.endpoint == endpoint &&
          other.version == version &&
          other.region == region &&
          other.status == status &&
          other.haControlplanes == haControlplanes &&
          other.oidc == oidc &&
          _deepEquality.equals(other.nodePools, nodePools) &&
          _deepEquality.equals(other.vpcs, vpcs);

  @override
  int get hashCode =>
      // ignore: unnecessary_parenthesis
      (id == null ? 0 : id!.hashCode) +
      (firewallGroupId == null ? 0 : firewallGroupId!.hashCode) +
      (label == null ? 0 : label!.hashCode) +
      (dateCreated == null ? 0 : dateCreated!.hashCode) +
      (clusterSubnet == null ? 0 : clusterSubnet!.hashCode) +
      (serviceSubnet == null ? 0 : serviceSubnet!.hashCode) +
      (ip == null ? 0 : ip!.hashCode) +
      (endpoint == null ? 0 : endpoint!.hashCode) +
      (version == null ? 0 : version!.hashCode) +
      (region == null ? 0 : region!.hashCode) +
      (status == null ? 0 : status!.hashCode) +
      (haControlplanes == null ? 0 : haControlplanes!.hashCode) +
      (oidc == null ? 0 : oidc!.hashCode) +
      (nodePools.hashCode) +
      (vpcs.hashCode);

  @override
  String toString() =>
      'VkeCluster[id=$id, firewallGroupId=$firewallGroupId, label=$label, dateCreated=$dateCreated, clusterSubnet=$clusterSubnet, serviceSubnet=$serviceSubnet, ip=$ip, endpoint=$endpoint, version=$version, region=$region, status=$status, haControlplanes=$haControlplanes, oidc=$oidc, nodePools=$nodePools, vpcs=$vpcs]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
    if (this.id != null) {
      json[r'id'] = this.id;
    } else {
      json[r'id'] = null;
    }
    if (this.firewallGroupId != null) {
      json[r'firewall_group_id'] = this.firewallGroupId;
    } else {
      json[r'firewall_group_id'] = null;
    }
    if (this.label != null) {
      json[r'label'] = this.label;
    } else {
      json[r'label'] = null;
    }
    if (this.dateCreated != null) {
      json[r'date_created'] = this.dateCreated;
    } else {
      json[r'date_created'] = null;
    }
    if (this.clusterSubnet != null) {
      json[r'cluster_subnet'] = this.clusterSubnet;
    } else {
      json[r'cluster_subnet'] = null;
    }
    if (this.serviceSubnet != null) {
      json[r'service_subnet'] = this.serviceSubnet;
    } else {
      json[r'service_subnet'] = null;
    }
    if (this.ip != null) {
      json[r'ip'] = this.ip;
    } else {
      json[r'ip'] = null;
    }
    if (this.endpoint != null) {
      json[r'endpoint'] = this.endpoint;
    } else {
      json[r'endpoint'] = null;
    }
    if (this.version != null) {
      json[r'version'] = this.version;
    } else {
      json[r'version'] = null;
    }
    if (this.region != null) {
      json[r'region'] = this.region;
    } else {
      json[r'region'] = null;
    }
    if (this.status != null) {
      json[r'status'] = this.status;
    } else {
      json[r'status'] = null;
    }
    if (this.haControlplanes != null) {
      json[r'ha_controlplanes'] = this.haControlplanes;
    } else {
      json[r'ha_controlplanes'] = null;
    }
    if (this.oidc != null) {
      json[r'oidc'] = this.oidc;
    } else {
      json[r'oidc'] = null;
    }
    json[r'node_pools'] = this.nodePools;
    json[r'vpcs'] = this.vpcs;
    return json;
  }

  /// Returns a new [VkeCluster] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static VkeCluster? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      assert(() {
        requiredKeys.forEach((key) {
          assert(json.containsKey(key),
              'Required key "VkeCluster[$key]" is missing from JSON.');
          assert(json[key] != null,
              'Required key "VkeCluster[$key]" has a null value in JSON.');
        });
        return true;
      }());

      return VkeCluster(
        id: mapValueOfType<String>(json, r'id'),
        firewallGroupId: mapValueOfType<String>(json, r'firewall_group_id'),
        label: mapValueOfType<String>(json, r'label'),
        dateCreated: mapValueOfType<String>(json, r'date_created'),
        clusterSubnet: mapValueOfType<String>(json, r'cluster_subnet'),
        serviceSubnet: mapValueOfType<String>(json, r'service_subnet'),
        ip: mapValueOfType<String>(json, r'ip'),
        endpoint: mapValueOfType<String>(json, r'endpoint'),
        version: mapValueOfType<String>(json, r'version'),
        region: mapValueOfType<String>(json, r'region'),
        status: mapValueOfType<String>(json, r'status'),
        haControlplanes: mapValueOfType<bool>(json, r'ha_controlplanes'),
        oidc: VkeClusterOidc.fromJson(json[r'oidc']),
        nodePools: Nodepools.listFromJson(json[r'node_pools']),
        vpcs: AttachedVpcs.listFromJson(json[r'vpcs']),
      );
    }
    return null;
  }

  static List<VkeCluster> listFromJson(
    dynamic json, {
    bool growable = false,
  }) {
    final result = <VkeCluster>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = VkeCluster.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, VkeCluster> mapFromJson(dynamic json) {
    final map = <String, VkeCluster>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = VkeCluster.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of VkeCluster-objects as value to a dart map
  static Map<String, List<VkeCluster>> mapListFromJson(
    dynamic json, {
    bool growable = false,
  }) {
    final map = <String, List<VkeCluster>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = VkeCluster.listFromJson(
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
