//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of openapi.api;

class PostFirewallsFirewallGroupIdRulesRequest {
  /// Returns a new [PostFirewallsFirewallGroupIdRulesRequest] instance.
  PostFirewallsFirewallGroupIdRulesRequest({
    required this.ipType,
    required this.protocol,
    required this.subnet,
    required this.subnetSize,
    this.port,
    this.source_,
    this.notes,
  });

  /// The type of IP rule.  * v4 * v6
  String ipType;

  /// The protocol for this rule.  * ICMP * TCP * UDP * GRE * ESP * AH
  String protocol;

  /// IP address representing a subnet. The IP address format must match with the \"ip_type\" parameter value.
  String subnet;

  /// The number of bits for the netmask in CIDR notation. Example: 32
  int subnetSize;

  /// TCP/UDP only. This field can be a specific port or a colon separated port range.
  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  String? port;

  /// If the source string is given a value of \"cloudflare\" subnet and subnet_size will both be ignored. Possible values:  |   | Value | Description | | - | ------ | ------------- | |   | \"\" | Use the value from `subnet` and `subnet_size`. | |   | cloudflare | Allow all of Cloudflare's IP space through the firewall | |   | [Load Balancer id](#operation/list-load-balancers) | Provide a load balancer ID to use its IPs |
  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  String? source_;

  /// User-supplied notes for this rule.
  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  String? notes;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PostFirewallsFirewallGroupIdRulesRequest &&
          other.ipType == ipType &&
          other.protocol == protocol &&
          other.subnet == subnet &&
          other.subnetSize == subnetSize &&
          other.port == port &&
          other.source_ == source_ &&
          other.notes == notes;

  @override
  int get hashCode =>
      // ignore: unnecessary_parenthesis
      (ipType.hashCode) +
      (protocol.hashCode) +
      (subnet.hashCode) +
      (subnetSize.hashCode) +
      (port == null ? 0 : port!.hashCode) +
      (source_ == null ? 0 : source_!.hashCode) +
      (notes == null ? 0 : notes!.hashCode);

  @override
  String toString() =>
      'PostFirewallsFirewallGroupIdRulesRequest[ipType=$ipType, protocol=$protocol, subnet=$subnet, subnetSize=$subnetSize, port=$port, source_=$source_, notes=$notes]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
    json[r'ip_type'] = this.ipType;
    json[r'protocol'] = this.protocol;
    json[r'subnet'] = this.subnet;
    json[r'subnet_size'] = this.subnetSize;
    if (this.port != null) {
      json[r'port'] = this.port;
    } else {
      json[r'port'] = null;
    }
    if (this.source_ != null) {
      json[r'source'] = this.source_;
    } else {
      json[r'source'] = null;
    }
    if (this.notes != null) {
      json[r'notes'] = this.notes;
    } else {
      json[r'notes'] = null;
    }
    return json;
  }

  /// Returns a new [PostFirewallsFirewallGroupIdRulesRequest] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static PostFirewallsFirewallGroupIdRulesRequest? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      assert(() {
        requiredKeys.forEach((key) {
          assert(json.containsKey(key),
              'Required key "PostFirewallsFirewallGroupIdRulesRequest[$key]" is missing from JSON.');
          assert(json[key] != null,
              'Required key "PostFirewallsFirewallGroupIdRulesRequest[$key]" has a null value in JSON.');
        });
        return true;
      }());

      return PostFirewallsFirewallGroupIdRulesRequest(
        ipType: mapValueOfType<String>(json, r'ip_type')!,
        protocol: mapValueOfType<String>(json, r'protocol')!,
        subnet: mapValueOfType<String>(json, r'subnet')!,
        subnetSize: mapValueOfType<int>(json, r'subnet_size')!,
        port: mapValueOfType<String>(json, r'port'),
        source_: mapValueOfType<String>(json, r'source'),
        notes: mapValueOfType<String>(json, r'notes'),
      );
    }
    return null;
  }

  static List<PostFirewallsFirewallGroupIdRulesRequest> listFromJson(
    dynamic json, {
    bool growable = false,
  }) {
    final result = <PostFirewallsFirewallGroupIdRulesRequest>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = PostFirewallsFirewallGroupIdRulesRequest.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, PostFirewallsFirewallGroupIdRulesRequest> mapFromJson(
      dynamic json) {
    final map = <String, PostFirewallsFirewallGroupIdRulesRequest>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value =
            PostFirewallsFirewallGroupIdRulesRequest.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of PostFirewallsFirewallGroupIdRulesRequest-objects as value to a dart map
  static Map<String, List<PostFirewallsFirewallGroupIdRulesRequest>>
      mapListFromJson(
    dynamic json, {
    bool growable = false,
  }) {
    final map = <String, List<PostFirewallsFirewallGroupIdRulesRequest>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = PostFirewallsFirewallGroupIdRulesRequest.listFromJson(
          entry.value,
          growable: growable,
        );
      }
    }
    return map;
  }

  /// The list of required keys that must be present in a JSON.
  static const requiredKeys = <String>{
    'ip_type',
    'protocol',
    'subnet',
    'subnet_size',
  };
}
