//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of openapi.api;

class LoadbalancerFirewallRule {
  /// Returns a new [LoadbalancerFirewallRule] instance.
  LoadbalancerFirewallRule({
    this.id,
    this.port,
    this.source_,
    this.ipType,
  });

  /// The unique ID for the firewall rule
  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  String? id;

  /// Port for this rule. 
  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  int? port;

  /// If the source string is given a value of \"cloudflare\" then cloudflare IPs will be supplied. Otherwise enter a IP address with subnet size that you wish to permit through the firewall.  Possible values:  |   | Value | Description | | - | ------ | ------------- | |   | \"192.168.1.1/16\" | Ip address with a subnet size. | |   | cloudflare | Allow all of Cloudflare's IP space through the firewall |
  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  String? source_;

  /// The type of IP rule.  * v4 * v6 
  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  String? ipType;

  @override
  bool operator ==(Object other) => identical(this, other) || other is LoadbalancerFirewallRule &&
    other.id == id &&
    other.port == port &&
    other.source_ == source_ &&
    other.ipType == ipType;

  @override
  int get hashCode =>
    // ignore: unnecessary_parenthesis
    (id == null ? 0 : id!.hashCode) +
    (port == null ? 0 : port!.hashCode) +
    (source_ == null ? 0 : source_!.hashCode) +
    (ipType == null ? 0 : ipType!.hashCode);

  @override
  String toString() => 'LoadbalancerFirewallRule[id=$id, port=$port, source_=$source_, ipType=$ipType]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
    if (this.id != null) {
      json[r'id'] = this.id;
    } else {
      json[r'id'] = null;
    }
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
    if (this.ipType != null) {
      json[r'ip_type'] = this.ipType;
    } else {
      json[r'ip_type'] = null;
    }
    return json;
  }

  /// Returns a new [LoadbalancerFirewallRule] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static LoadbalancerFirewallRule? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      assert(() {
        requiredKeys.forEach((key) {
          assert(json.containsKey(key), 'Required key "LoadbalancerFirewallRule[$key]" is missing from JSON.');
          assert(json[key] != null, 'Required key "LoadbalancerFirewallRule[$key]" has a null value in JSON.');
        });
        return true;
      }());

      return LoadbalancerFirewallRule(
        id: mapValueOfType<String>(json, r'id'),
        port: mapValueOfType<int>(json, r'port'),
        source_: mapValueOfType<String>(json, r'source'),
        ipType: mapValueOfType<String>(json, r'ip_type'),
      );
    }
    return null;
  }

  static List<LoadbalancerFirewallRule> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <LoadbalancerFirewallRule>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = LoadbalancerFirewallRule.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, LoadbalancerFirewallRule> mapFromJson(dynamic json) {
    final map = <String, LoadbalancerFirewallRule>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = LoadbalancerFirewallRule.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of LoadbalancerFirewallRule-objects as value to a dart map
  static Map<String, List<LoadbalancerFirewallRule>> mapListFromJson(dynamic json, {bool growable = false,}) {
    final map = <String, List<LoadbalancerFirewallRule>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = LoadbalancerFirewallRule.listFromJson(entry.value, growable: growable,);
      }
    }
    return map;
  }

  /// The list of required keys that must be present in a JSON.
  static const requiredKeys = <String>{
  };
}

