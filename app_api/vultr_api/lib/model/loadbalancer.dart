//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of openapi.api;

class Loadbalancer {
  /// Returns a new [Loadbalancer] instance.
  Loadbalancer({
    this.id,
    this.dateCreated,
    this.region,
    this.label,
    this.status,
    this.ipv4,
    this.ipv6,
    this.genericInfo,
    this.healthCheck,
    this.hasSsl,
    this.http2,
    this.http3,
    this.nodes,
    this.forwardRules = const [],
    this.instances = const [],
    this.firewallRules = const [],
    this.nodeIps,
    this.autoSsl,
    this.globalParentId,
    this.globalRegions = const [],
    this.globalChildrenIds = const [],
    this.globalCname,
    this.sslCertB64,
    this.pendingCharges,
    this.cname,
  });

  /// A unique ID for the Load Balancer.
  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  String? id;

  /// Date this Load Balancer was created.
  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  String? dateCreated;

  /// The [Region id](#operation/list-regions) where the Load Balancer is located.
  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  String? region;

  /// The user-supplied label for this load-balancer.
  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  String? label;

  /// The current status.  * active
  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  String? status;

  /// The IPv4 address of this Load Balancer.
  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  String? ipv4;

  /// The IPv6 address of this Load Balancer.
  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  String? ipv6;

  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  LoadbalancerGenericInfo? genericInfo;

  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  LoadbalancerHealthCheck? healthCheck;

  /// Indicates if this Load Balancer has an SSL certificate installed.
  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  bool? hasSsl;

  /// Indicates if this Load Balancer has HTTP2 enabled.
  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  bool? http2;

  /// Indicates if this Load Balancer has HTTP3 enabled.
  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  bool? http3;

  /// The number of nodes to add to the load balancer (1-99), must be an odd number. This defaults to 1.
  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  int? nodes;

  /// An array of forwarding rule objects.
  List<LoadbalancerForwardRulesInner> forwardRules;

  /// Array of [Instance ids](#operation/list-instances) attached to this Load Balancer.
  List<String> instances;

  /// An array of firewall rule objects.
  List<LoadbalancerFirewallRulesInner> firewallRules;

  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  LoadbalancerNodeIps? nodeIps;

  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  LoadbalancerAutoSsl? autoSsl;

  /// If this load balancer is a child of a global load balancer, this field will display the ID of the parent load balancer.
  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  String? globalParentId;

  /// Array of [Region ids](#operation/list-regions) to deploy child Load Balancers to.
  List<String> globalRegions;

  /// If this load balancer is the parent of a global load balancer, this filed will display an array of children load balancer ids
  List<String> globalChildrenIds;

  /// The Canonical Name (CNAME) record value
  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  String? globalCname;

  /// Base64 encoded ssl certificate, private key, and chain
  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  String? sslCertB64;

  /// Pending charges for the current billing period
  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  int? pendingCharges;

  /// The Canonical Name (CNAME) record value
  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  String? cname;

  @override
  bool operator ==(Object other) => identical(this, other) || other is Loadbalancer &&
    other.id == id &&
    other.dateCreated == dateCreated &&
    other.region == region &&
    other.label == label &&
    other.status == status &&
    other.ipv4 == ipv4 &&
    other.ipv6 == ipv6 &&
    other.genericInfo == genericInfo &&
    other.healthCheck == healthCheck &&
    other.hasSsl == hasSsl &&
    other.http2 == http2 &&
    other.http3 == http3 &&
    other.nodes == nodes &&
    _deepEquality.equals(other.forwardRules, forwardRules) &&
    _deepEquality.equals(other.instances, instances) &&
    _deepEquality.equals(other.firewallRules, firewallRules) &&
    other.nodeIps == nodeIps &&
    other.autoSsl == autoSsl &&
    other.globalParentId == globalParentId &&
    _deepEquality.equals(other.globalRegions, globalRegions) &&
    _deepEquality.equals(other.globalChildrenIds, globalChildrenIds) &&
    other.globalCname == globalCname &&
    other.sslCertB64 == sslCertB64 &&
    other.pendingCharges == pendingCharges &&
    other.cname == cname;

  @override
  int get hashCode =>
    // ignore: unnecessary_parenthesis
    (id == null ? 0 : id!.hashCode) +
    (dateCreated == null ? 0 : dateCreated!.hashCode) +
    (region == null ? 0 : region!.hashCode) +
    (label == null ? 0 : label!.hashCode) +
    (status == null ? 0 : status!.hashCode) +
    (ipv4 == null ? 0 : ipv4!.hashCode) +
    (ipv6 == null ? 0 : ipv6!.hashCode) +
    (genericInfo == null ? 0 : genericInfo!.hashCode) +
    (healthCheck == null ? 0 : healthCheck!.hashCode) +
    (hasSsl == null ? 0 : hasSsl!.hashCode) +
    (http2 == null ? 0 : http2!.hashCode) +
    (http3 == null ? 0 : http3!.hashCode) +
    (nodes == null ? 0 : nodes!.hashCode) +
    (forwardRules.hashCode) +
    (instances.hashCode) +
    (firewallRules.hashCode) +
    (nodeIps == null ? 0 : nodeIps!.hashCode) +
    (autoSsl == null ? 0 : autoSsl!.hashCode) +
    (globalParentId == null ? 0 : globalParentId!.hashCode) +
    (globalRegions.hashCode) +
    (globalChildrenIds.hashCode) +
    (globalCname == null ? 0 : globalCname!.hashCode) +
    (sslCertB64 == null ? 0 : sslCertB64!.hashCode) +
    (pendingCharges == null ? 0 : pendingCharges!.hashCode) +
    (cname == null ? 0 : cname!.hashCode);

  @override
  String toString() => 'Loadbalancer[id=$id, dateCreated=$dateCreated, region=$region, label=$label, status=$status, ipv4=$ipv4, ipv6=$ipv6, genericInfo=$genericInfo, healthCheck=$healthCheck, hasSsl=$hasSsl, http2=$http2, http3=$http3, nodes=$nodes, forwardRules=$forwardRules, instances=$instances, firewallRules=$firewallRules, nodeIps=$nodeIps, autoSsl=$autoSsl, globalParentId=$globalParentId, globalRegions=$globalRegions, globalChildrenIds=$globalChildrenIds, globalCname=$globalCname, sslCertB64=$sslCertB64, pendingCharges=$pendingCharges, cname=$cname]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
    if (this.id != null) {
      json[r'id'] = this.id;
    } else {
      json[r'id'] = null;
    }
    if (this.dateCreated != null) {
      json[r'date_created'] = this.dateCreated;
    } else {
      json[r'date_created'] = null;
    }
    if (this.region != null) {
      json[r'region'] = this.region;
    } else {
      json[r'region'] = null;
    }
    if (this.label != null) {
      json[r'label'] = this.label;
    } else {
      json[r'label'] = null;
    }
    if (this.status != null) {
      json[r'status'] = this.status;
    } else {
      json[r'status'] = null;
    }
    if (this.ipv4 != null) {
      json[r'ipv4'] = this.ipv4;
    } else {
      json[r'ipv4'] = null;
    }
    if (this.ipv6 != null) {
      json[r'ipv6'] = this.ipv6;
    } else {
      json[r'ipv6'] = null;
    }
    if (this.genericInfo != null) {
      json[r'generic_info'] = this.genericInfo;
    } else {
      json[r'generic_info'] = null;
    }
    if (this.healthCheck != null) {
      json[r'health_check'] = this.healthCheck;
    } else {
      json[r'health_check'] = null;
    }
    if (this.hasSsl != null) {
      json[r'has_ssl'] = this.hasSsl;
    } else {
      json[r'has_ssl'] = null;
    }
    if (this.http2 != null) {
      json[r'http2'] = this.http2;
    } else {
      json[r'http2'] = null;
    }
    if (this.http3 != null) {
      json[r'http3'] = this.http3;
    } else {
      json[r'http3'] = null;
    }
    if (this.nodes != null) {
      json[r'nodes'] = this.nodes;
    } else {
      json[r'nodes'] = null;
    }
      json[r'forward_rules'] = this.forwardRules;
      json[r'instances'] = this.instances;
      json[r'firewall_rules'] = this.firewallRules;
    if (this.nodeIps != null) {
      json[r'node_ips'] = this.nodeIps;
    } else {
      json[r'node_ips'] = null;
    }
    if (this.autoSsl != null) {
      json[r'auto_ssl'] = this.autoSsl;
    } else {
      json[r'auto_ssl'] = null;
    }
    if (this.globalParentId != null) {
      json[r'global_parent_id'] = this.globalParentId;
    } else {
      json[r'global_parent_id'] = null;
    }
      json[r'global_regions'] = this.globalRegions;
      json[r'global_children_ids'] = this.globalChildrenIds;
    if (this.globalCname != null) {
      json[r'global_cname'] = this.globalCname;
    } else {
      json[r'global_cname'] = null;
    }
    if (this.sslCertB64 != null) {
      json[r'ssl_cert_b64'] = this.sslCertB64;
    } else {
      json[r'ssl_cert_b64'] = null;
    }
    if (this.pendingCharges != null) {
      json[r'pending_charges'] = this.pendingCharges;
    } else {
      json[r'pending_charges'] = null;
    }
    if (this.cname != null) {
      json[r'cname'] = this.cname;
    } else {
      json[r'cname'] = null;
    }
    return json;
  }

  /// Returns a new [Loadbalancer] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static Loadbalancer? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      assert(() {
        requiredKeys.forEach((key) {
          assert(json.containsKey(key), 'Required key "Loadbalancer[$key]" is missing from JSON.');
          assert(json[key] != null, 'Required key "Loadbalancer[$key]" has a null value in JSON.');
        });
        return true;
      }());

      return Loadbalancer(
        id: mapValueOfType<String>(json, r'id'),
        dateCreated: mapValueOfType<String>(json, r'date_created'),
        region: mapValueOfType<String>(json, r'region'),
        label: mapValueOfType<String>(json, r'label'),
        status: mapValueOfType<String>(json, r'status'),
        ipv4: mapValueOfType<String>(json, r'ipv4'),
        ipv6: mapValueOfType<String>(json, r'ipv6'),
        genericInfo: LoadbalancerGenericInfo.fromJson(json[r'generic_info']),
        healthCheck: LoadbalancerHealthCheck.fromJson(json[r'health_check']),
        hasSsl: mapValueOfType<bool>(json, r'has_ssl'),
        http2: mapValueOfType<bool>(json, r'http2'),
        http3: mapValueOfType<bool>(json, r'http3'),
        nodes: mapValueOfType<int>(json, r'nodes'),
        forwardRules: LoadbalancerForwardRulesInner.listFromJson(json[r'forward_rules']),
        instances: json[r'instances'] is Iterable
            ? (json[r'instances'] as Iterable).cast<String>().toList(growable: false)
            : const [],
        firewallRules: LoadbalancerFirewallRulesInner.listFromJson(json[r'firewall_rules']),
        nodeIps: LoadbalancerNodeIps.fromJson(json[r'node_ips']),
        autoSsl: LoadbalancerAutoSsl.fromJson(json[r'auto_ssl']),
        globalParentId: mapValueOfType<String>(json, r'global_parent_id'),
        globalRegions: json[r'global_regions'] is Iterable
            ? (json[r'global_regions'] as Iterable).cast<String>().toList(growable: false)
            : const [],
        globalChildrenIds: json[r'global_children_ids'] is Iterable
            ? (json[r'global_children_ids'] as Iterable).cast<String>().toList(growable: false)
            : const [],
        globalCname: mapValueOfType<String>(json, r'global_cname'),
        sslCertB64: mapValueOfType<String>(json, r'ssl_cert_b64'),
        pendingCharges: mapValueOfType<int>(json, r'pending_charges'),
        cname: mapValueOfType<String>(json, r'cname'),
      );
    }
    return null;
  }

  static List<Loadbalancer> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <Loadbalancer>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = Loadbalancer.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, Loadbalancer> mapFromJson(dynamic json) {
    final map = <String, Loadbalancer>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = Loadbalancer.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of Loadbalancer-objects as value to a dart map
  static Map<String, List<Loadbalancer>> mapListFromJson(dynamic json, {bool growable = false,}) {
    final map = <String, List<Loadbalancer>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = Loadbalancer.listFromJson(entry.value, growable: growable,);
      }
    }
    return map;
  }

  /// The list of required keys that must be present in a JSON.
  static const requiredKeys = <String>{
  };
}

