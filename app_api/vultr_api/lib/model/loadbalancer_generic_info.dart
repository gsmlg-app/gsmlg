//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of openapi.api;

class LoadbalancerGenericInfo {
  /// Returns a new [LoadbalancerGenericInfo] instance.
  LoadbalancerGenericInfo({
    this.balancingAlgorithm,
    this.sslRedirect,
    this.stickySessions,
    this.proxyProtocol,
    this.timeout,
    this.privateNetwork,
    this.vpc,
  });

  /// The balancing algorithm.  * roundrobin (default) * leastconn
  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  String? balancingAlgorithm;

  /// If `true`, this will redirect all HTTP traffic to HTTPS. You must have an HTTPS rule and SSL certificate installed on the load balancer to enable this option.  * true * false
  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  bool? sslRedirect;

  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  LoadbalancerGenericInfoStickySessions? stickySessions;

  /// \"If `true`, you must configure backend nodes to accept Proxy protocol. \\n\\n* true\\n* false (Default)\"
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

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is LoadbalancerGenericInfo &&
          other.balancingAlgorithm == balancingAlgorithm &&
          other.sslRedirect == sslRedirect &&
          other.stickySessions == stickySessions &&
          other.proxyProtocol == proxyProtocol &&
          other.timeout == timeout &&
          other.privateNetwork == privateNetwork &&
          other.vpc == vpc;

  @override
  int get hashCode =>
      // ignore: unnecessary_parenthesis
      (balancingAlgorithm == null ? 0 : balancingAlgorithm!.hashCode) +
      (sslRedirect == null ? 0 : sslRedirect!.hashCode) +
      (stickySessions == null ? 0 : stickySessions!.hashCode) +
      (proxyProtocol == null ? 0 : proxyProtocol!.hashCode) +
      (timeout == null ? 0 : timeout!.hashCode) +
      (privateNetwork == null ? 0 : privateNetwork!.hashCode) +
      (vpc == null ? 0 : vpc!.hashCode);

  @override
  String toString() =>
      'LoadbalancerGenericInfo[balancingAlgorithm=$balancingAlgorithm, sslRedirect=$sslRedirect, stickySessions=$stickySessions, proxyProtocol=$proxyProtocol, timeout=$timeout, privateNetwork=$privateNetwork, vpc=$vpc]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
    if (this.balancingAlgorithm != null) {
      json[r'balancing_algorithm'] = this.balancingAlgorithm;
    } else {
      json[r'balancing_algorithm'] = null;
    }
    if (this.sslRedirect != null) {
      json[r'ssl_redirect'] = this.sslRedirect;
    } else {
      json[r'ssl_redirect'] = null;
    }
    if (this.stickySessions != null) {
      json[r'sticky_sessions'] = this.stickySessions;
    } else {
      json[r'sticky_sessions'] = null;
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
    return json;
  }

  /// Returns a new [LoadbalancerGenericInfo] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static LoadbalancerGenericInfo? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      assert(() {
        requiredKeys.forEach((key) {
          assert(json.containsKey(key),
              'Required key "LoadbalancerGenericInfo[$key]" is missing from JSON.');
          assert(json[key] != null,
              'Required key "LoadbalancerGenericInfo[$key]" has a null value in JSON.');
        });
        return true;
      }());

      return LoadbalancerGenericInfo(
        balancingAlgorithm:
            mapValueOfType<String>(json, r'balancing_algorithm'),
        sslRedirect: mapValueOfType<bool>(json, r'ssl_redirect'),
        stickySessions: LoadbalancerGenericInfoStickySessions.fromJson(
            json[r'sticky_sessions']),
        proxyProtocol: mapValueOfType<bool>(json, r'proxy_protocol'),
        timeout: mapValueOfType<int>(json, r'timeout'),
        privateNetwork: mapValueOfType<String>(json, r'private_network'),
        vpc: mapValueOfType<String>(json, r'vpc'),
      );
    }
    return null;
  }

  static List<LoadbalancerGenericInfo> listFromJson(
    dynamic json, {
    bool growable = false,
  }) {
    final result = <LoadbalancerGenericInfo>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = LoadbalancerGenericInfo.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, LoadbalancerGenericInfo> mapFromJson(dynamic json) {
    final map = <String, LoadbalancerGenericInfo>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = LoadbalancerGenericInfo.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of LoadbalancerGenericInfo-objects as value to a dart map
  static Map<String, List<LoadbalancerGenericInfo>> mapListFromJson(
    dynamic json, {
    bool growable = false,
  }) {
    final map = <String, List<LoadbalancerGenericInfo>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = LoadbalancerGenericInfo.listFromJson(
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
