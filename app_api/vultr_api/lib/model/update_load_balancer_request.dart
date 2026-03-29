//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of openapi.api;

class UpdateLoadBalancerRequest {
  /// Returns a new [UpdateLoadBalancerRequest] instance.
  UpdateLoadBalancerRequest({
    this.ssl,
    this.stickySession,
    this.forwardingRules = const [],
    this.healthCheck,
    this.proxyProtocol,
    this.timeout,
    this.sslRedirect,
    this.http2,
    this.http3,
    this.nodes,
    this.balancingAlgorithm,
    this.instances = const [],
    this.label,
    this.privateNetwork,
    this.vpc,
    this.firewallRules = const [],
    this.autoSsl,
    this.globalRegions = const [],
  });

  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  CreateLoadBalancerRequestSsl? ssl;

  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  CreateLoadBalancerRequestStickySession? stickySession;

  /// An array of forwarding rule objects.
  List<CreateLoadBalancerRequestForwardingRulesInner> forwardingRules;

  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  UpdateLoadBalancerRequestHealthCheck? healthCheck;

  /// If `true`, you must configure backend nodes to accept Proxy protocol.  * true * false (Default)
  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  bool? proxyProtocol;

  /// The maximum time allowed for the connection to remain inactive before timing out in seconds. This defaults to 600.
  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  int? timeout;

  /// If `true`, this will redirect all HTTP traffic to HTTPS. You must have an HTTPS rule and SSL certificate installed on the load balancer to enable this option.  * true * false
  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  bool? sslRedirect;

  /// If `true`, this will enable HTTP2 traffic. You must have an HTTPS forwarding rule combo (HTTPS -> HTTPS) to enable this option.  * true * false
  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  bool? http2;

  /// If `true`, this will enable HTTP3/QUIC traffic. You must have HTTP2 enabled.  * true * false
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

  /// The balancing algorithm.  * roundrobin (default) * leastconn
  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  String? balancingAlgorithm;

  /// Send the complete array of Instances IDs that should be attached to this Load Balancer. Instances will be attached or detached to match your array. For example, if Instances **X**, **Y**, and **Z** are currently attached, and you send [A,B,Z], then Instance **A** and **B** will be attached,  **X** and **Y** will be detached, and **Z** will remain attached.
  List<String> instances;

  /// The label for your Load Balancer
  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  String? label;

  /// Use `vpc` instead. ID of the private network you wish to use. If private_network is omitted it will default to the public network.
  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  String? privateNetwork;

  /// ID of the VPC you wish to use. If a VPC ID is omitted it will default to the public network.
  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  String? vpc;

  /// An array of firewall rule objects.
  List<CreateLoadBalancerRequestFirewallRulesInner> firewallRules;

  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  CreateLoadBalancerRequestAutoSsl? autoSsl;

  /// Array of [Region ids](#operation/list-regions) to deploy child Load Balancers to.
  List<String> globalRegions;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UpdateLoadBalancerRequest &&
          other.ssl == ssl &&
          other.stickySession == stickySession &&
          _deepEquality.equals(other.forwardingRules, forwardingRules) &&
          other.healthCheck == healthCheck &&
          other.proxyProtocol == proxyProtocol &&
          other.timeout == timeout &&
          other.sslRedirect == sslRedirect &&
          other.http2 == http2 &&
          other.http3 == http3 &&
          other.nodes == nodes &&
          other.balancingAlgorithm == balancingAlgorithm &&
          _deepEquality.equals(other.instances, instances) &&
          other.label == label &&
          other.privateNetwork == privateNetwork &&
          other.vpc == vpc &&
          _deepEquality.equals(other.firewallRules, firewallRules) &&
          other.autoSsl == autoSsl &&
          _deepEquality.equals(other.globalRegions, globalRegions);

  @override
  int get hashCode =>
      // ignore: unnecessary_parenthesis
      (ssl == null ? 0 : ssl!.hashCode) +
      (stickySession == null ? 0 : stickySession!.hashCode) +
      (forwardingRules.hashCode) +
      (healthCheck == null ? 0 : healthCheck!.hashCode) +
      (proxyProtocol == null ? 0 : proxyProtocol!.hashCode) +
      (timeout == null ? 0 : timeout!.hashCode) +
      (sslRedirect == null ? 0 : sslRedirect!.hashCode) +
      (http2 == null ? 0 : http2!.hashCode) +
      (http3 == null ? 0 : http3!.hashCode) +
      (nodes == null ? 0 : nodes!.hashCode) +
      (balancingAlgorithm == null ? 0 : balancingAlgorithm!.hashCode) +
      (instances.hashCode) +
      (label == null ? 0 : label!.hashCode) +
      (privateNetwork == null ? 0 : privateNetwork!.hashCode) +
      (vpc == null ? 0 : vpc!.hashCode) +
      (firewallRules.hashCode) +
      (autoSsl == null ? 0 : autoSsl!.hashCode) +
      (globalRegions.hashCode);

  @override
  String toString() =>
      'UpdateLoadBalancerRequest[ssl=$ssl, stickySession=$stickySession, forwardingRules=$forwardingRules, healthCheck=$healthCheck, proxyProtocol=$proxyProtocol, timeout=$timeout, sslRedirect=$sslRedirect, http2=$http2, http3=$http3, nodes=$nodes, balancingAlgorithm=$balancingAlgorithm, instances=$instances, label=$label, privateNetwork=$privateNetwork, vpc=$vpc, firewallRules=$firewallRules, autoSsl=$autoSsl, globalRegions=$globalRegions]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
    if (this.ssl != null) {
      json[r'ssl'] = this.ssl;
    } else {
      json[r'ssl'] = null;
    }
    if (this.stickySession != null) {
      json[r'sticky_session'] = this.stickySession;
    } else {
      json[r'sticky_session'] = null;
    }
    json[r'forwarding_rules'] = this.forwardingRules;
    if (this.healthCheck != null) {
      json[r'health_check'] = this.healthCheck;
    } else {
      json[r'health_check'] = null;
    }
    if (this.proxyProtocol != null) {
      json[r'proxy_protocol'] = this.proxyProtocol;
    } else {
      json[r'proxy_protocol'] = null;
    }
    if (this.timeout != null) {
      json[r'timeout'] = this.timeout;
    } else {
      json[r'timeout'] = null;
    }
    if (this.sslRedirect != null) {
      json[r'ssl_redirect'] = this.sslRedirect;
    } else {
      json[r'ssl_redirect'] = null;
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
    if (this.balancingAlgorithm != null) {
      json[r'balancing_algorithm'] = this.balancingAlgorithm;
    } else {
      json[r'balancing_algorithm'] = null;
    }
    json[r'instances'] = this.instances;
    if (this.label != null) {
      json[r'label'] = this.label;
    } else {
      json[r'label'] = null;
    }
    if (this.privateNetwork != null) {
      json[r'private_network'] = this.privateNetwork;
    } else {
      json[r'private_network'] = null;
    }
    if (this.vpc != null) {
      json[r'vpc'] = this.vpc;
    } else {
      json[r'vpc'] = null;
    }
    json[r'firewall_rules'] = this.firewallRules;
    if (this.autoSsl != null) {
      json[r'auto_ssl'] = this.autoSsl;
    } else {
      json[r'auto_ssl'] = null;
    }
    json[r'global_regions'] = this.globalRegions;
    return json;
  }

  /// Returns a new [UpdateLoadBalancerRequest] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static UpdateLoadBalancerRequest? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      assert(() {
        requiredKeys.forEach((key) {
          assert(json.containsKey(key),
              'Required key "UpdateLoadBalancerRequest[$key]" is missing from JSON.');
          assert(json[key] != null,
              'Required key "UpdateLoadBalancerRequest[$key]" has a null value in JSON.');
        });
        return true;
      }());

      return UpdateLoadBalancerRequest(
        ssl: CreateLoadBalancerRequestSsl.fromJson(json[r'ssl']),
        stickySession: CreateLoadBalancerRequestStickySession.fromJson(
            json[r'sticky_session']),
        forwardingRules:
            CreateLoadBalancerRequestForwardingRulesInner.listFromJson(
                json[r'forwarding_rules']),
        healthCheck: UpdateLoadBalancerRequestHealthCheck.fromJson(
            json[r'health_check']),
        proxyProtocol: mapValueOfType<bool>(json, r'proxy_protocol'),
        timeout: mapValueOfType<int>(json, r'timeout'),
        sslRedirect: mapValueOfType<bool>(json, r'ssl_redirect'),
        http2: mapValueOfType<bool>(json, r'http2'),
        http3: mapValueOfType<bool>(json, r'http3'),
        nodes: mapValueOfType<int>(json, r'nodes'),
        balancingAlgorithm:
            mapValueOfType<String>(json, r'balancing_algorithm'),
        instances: json[r'instances'] is Iterable
            ? (json[r'instances'] as Iterable)
                .cast<String>()
                .toList(growable: false)
            : const [],
        label: mapValueOfType<String>(json, r'label'),
        privateNetwork: mapValueOfType<String>(json, r'private_network'),
        vpc: mapValueOfType<String>(json, r'vpc'),
        firewallRules: CreateLoadBalancerRequestFirewallRulesInner.listFromJson(
            json[r'firewall_rules']),
        autoSsl: CreateLoadBalancerRequestAutoSsl.fromJson(json[r'auto_ssl']),
        globalRegions: json[r'global_regions'] is Iterable
            ? (json[r'global_regions'] as Iterable)
                .cast<String>()
                .toList(growable: false)
            : const [],
      );
    }
    return null;
  }

  static List<UpdateLoadBalancerRequest> listFromJson(
    dynamic json, {
    bool growable = false,
  }) {
    final result = <UpdateLoadBalancerRequest>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = UpdateLoadBalancerRequest.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, UpdateLoadBalancerRequest> mapFromJson(dynamic json) {
    final map = <String, UpdateLoadBalancerRequest>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = UpdateLoadBalancerRequest.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of UpdateLoadBalancerRequest-objects as value to a dart map
  static Map<String, List<UpdateLoadBalancerRequest>> mapListFromJson(
    dynamic json, {
    bool growable = false,
  }) {
    final map = <String, List<UpdateLoadBalancerRequest>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = UpdateLoadBalancerRequest.listFromJson(
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
