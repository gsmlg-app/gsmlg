//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of openapi.api;

class FirewallRule {
  /// Returns a new [FirewallRule] instance.
  FirewallRule({
    this.id,
    this.type,
    this.ipType,
    this.action,
    this.protocol,
    this.port,
    this.subnet,
    this.subnetSize,
    this.source_,
    this.notes,
  });

  /// A unique ID for the Firewall Rule.
  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  int? id;

  /// This field is deprecated. Use `ip_type` instead.  The type of IP rule.  * v4 * v6
  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  String? type;

  /// The type of IP rule.  * v4 * v6
  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  String? ipType;

  /// Action to take when this rule is met.  * accept
  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  String? action;

  /// The protocol for this rule.  * ICMP * TCP * UDP * GRE 
  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  String? protocol;

  /// Port or port range for this rule.
  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  String? port;

  /// IP address representing a subnet. The IP address format must match with the \"ip_type\" parameter value.
  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  String? subnet;

  /// The number of bits for the netmask in CIDR notation. Example: 24
  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  int? subnetSize;

  /// If the source string is given a value of \"cloudflare\" subnet and subnet_size will both be ignored. Possible values:  |   | Value | Description | | - | ------ | ------------- | |   | \"\" | Use the value from `subnet` and `subnet_size`. | |   | cloudflare | Allow all of Cloudflare's IP space through the firewall |
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
  bool operator ==(Object other) => identical(this, other) || other is FirewallRule &&
    other.id == id &&
    other.type == type &&
    other.ipType == ipType &&
    other.action == action &&
    other.protocol == protocol &&
    other.port == port &&
    other.subnet == subnet &&
    other.subnetSize == subnetSize &&
    other.source_ == source_ &&
    other.notes == notes;

  @override
  int get hashCode =>
    // ignore: unnecessary_parenthesis
    (id == null ? 0 : id!.hashCode) +
    (type == null ? 0 : type!.hashCode) +
    (ipType == null ? 0 : ipType!.hashCode) +
    (action == null ? 0 : action!.hashCode) +
    (protocol == null ? 0 : protocol!.hashCode) +
    (port == null ? 0 : port!.hashCode) +
    (subnet == null ? 0 : subnet!.hashCode) +
    (subnetSize == null ? 0 : subnetSize!.hashCode) +
    (source_ == null ? 0 : source_!.hashCode) +
    (notes == null ? 0 : notes!.hashCode);

  @override
  String toString() => 'FirewallRule[id=$id, type=$type, ipType=$ipType, action=$action, protocol=$protocol, port=$port, subnet=$subnet, subnetSize=$subnetSize, source_=$source_, notes=$notes]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
    if (this.id != null) {
      json[r'id'] = this.id;
    } else {
      json[r'id'] = null;
    }
    if (this.type != null) {
      json[r'type'] = this.type;
    } else {
      json[r'type'] = null;
    }
    if (this.ipType != null) {
      json[r'ip_type'] = this.ipType;
    } else {
      json[r'ip_type'] = null;
    }
    if (this.action != null) {
      json[r'action'] = this.action;
    } else {
      json[r'action'] = null;
    }
    if (this.protocol != null) {
      json[r'protocol'] = this.protocol;
    } else {
      json[r'protocol'] = null;
    }
    if (this.port != null) {
      json[r'port'] = this.port;
    } else {
      json[r'port'] = null;
    }
    if (this.subnet != null) {
      json[r'subnet'] = this.subnet;
    } else {
      json[r'subnet'] = null;
    }
    if (this.subnetSize != null) {
      json[r'subnet_size'] = this.subnetSize;
    } else {
      json[r'subnet_size'] = null;
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

  /// Returns a new [FirewallRule] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static FirewallRule? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      assert(() {
        requiredKeys.forEach((key) {
          assert(json.containsKey(key), 'Required key "FirewallRule[$key]" is missing from JSON.');
          assert(json[key] != null, 'Required key "FirewallRule[$key]" has a null value in JSON.');
        });
        return true;
      }());

      return FirewallRule(
        id: mapValueOfType<int>(json, r'id'),
        type: mapValueOfType<String>(json, r'type'),
        ipType: mapValueOfType<String>(json, r'ip_type'),
        action: mapValueOfType<String>(json, r'action'),
        protocol: mapValueOfType<String>(json, r'protocol'),
        port: mapValueOfType<String>(json, r'port'),
        subnet: mapValueOfType<String>(json, r'subnet'),
        subnetSize: mapValueOfType<int>(json, r'subnet_size'),
        source_: mapValueOfType<String>(json, r'source'),
        notes: mapValueOfType<String>(json, r'notes'),
      );
    }
    return null;
  }

  static List<FirewallRule> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <FirewallRule>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = FirewallRule.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, FirewallRule> mapFromJson(dynamic json) {
    final map = <String, FirewallRule>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = FirewallRule.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of FirewallRule-objects as value to a dart map
  static Map<String, List<FirewallRule>> mapListFromJson(dynamic json, {bool growable = false,}) {
    final map = <String, List<FirewallRule>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = FirewallRule.listFromJson(entry.value, growable: growable,);
      }
    }
    return map;
  }

  /// The list of required keys that must be present in a JSON.
  static const requiredKeys = <String>{
  };
}

