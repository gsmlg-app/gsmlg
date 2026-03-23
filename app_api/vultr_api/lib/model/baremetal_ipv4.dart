//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of openapi.api;

class BaremetalIpv4 {
  /// Returns a new [BaremetalIpv4] instance.
  BaremetalIpv4({
    this.ip,
    this.netmask,
    this.gateway,
    this.type,
    this.reverse,
    this.macAddress,
  });

  /// The IPv4 address.
  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  String? ip;

  /// The IPv4 netmask in dot-decimal notation.
  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  String? netmask;

  /// The gateway IP address.
  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  String? gateway;

  /// The type of IP address.  * main_ip
  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  String? type;

  /// The reverse DNS information for this IP address.
  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  String? reverse;

  /// The MAC address associated with this IP address.
  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  String? macAddress;

  @override
  bool operator ==(Object other) => identical(this, other) || other is BaremetalIpv4 &&
    other.ip == ip &&
    other.netmask == netmask &&
    other.gateway == gateway &&
    other.type == type &&
    other.reverse == reverse &&
    other.macAddress == macAddress;

  @override
  int get hashCode =>
    // ignore: unnecessary_parenthesis
    (ip == null ? 0 : ip!.hashCode) +
    (netmask == null ? 0 : netmask!.hashCode) +
    (gateway == null ? 0 : gateway!.hashCode) +
    (type == null ? 0 : type!.hashCode) +
    (reverse == null ? 0 : reverse!.hashCode) +
    (macAddress == null ? 0 : macAddress!.hashCode);

  @override
  String toString() => 'BaremetalIpv4[ip=$ip, netmask=$netmask, gateway=$gateway, type=$type, reverse=$reverse, macAddress=$macAddress]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
    if (this.ip != null) {
      json[r'ip'] = this.ip;
    } else {
      json[r'ip'] = null;
    }
    if (this.netmask != null) {
      json[r'netmask'] = this.netmask;
    } else {
      json[r'netmask'] = null;
    }
    if (this.gateway != null) {
      json[r'gateway'] = this.gateway;
    } else {
      json[r'gateway'] = null;
    }
    if (this.type != null) {
      json[r'type'] = this.type;
    } else {
      json[r'type'] = null;
    }
    if (this.reverse != null) {
      json[r'reverse'] = this.reverse;
    } else {
      json[r'reverse'] = null;
    }
    if (this.macAddress != null) {
      json[r'mac_address'] = this.macAddress;
    } else {
      json[r'mac_address'] = null;
    }
    return json;
  }

  /// Returns a new [BaremetalIpv4] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static BaremetalIpv4? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      assert(() {
        requiredKeys.forEach((key) {
          assert(json.containsKey(key), 'Required key "BaremetalIpv4[$key]" is missing from JSON.');
          assert(json[key] != null, 'Required key "BaremetalIpv4[$key]" has a null value in JSON.');
        });
        return true;
      }());

      return BaremetalIpv4(
        ip: mapValueOfType<String>(json, r'ip'),
        netmask: mapValueOfType<String>(json, r'netmask'),
        gateway: mapValueOfType<String>(json, r'gateway'),
        type: mapValueOfType<String>(json, r'type'),
        reverse: mapValueOfType<String>(json, r'reverse'),
        macAddress: mapValueOfType<String>(json, r'mac_address'),
      );
    }
    return null;
  }

  static List<BaremetalIpv4> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <BaremetalIpv4>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = BaremetalIpv4.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, BaremetalIpv4> mapFromJson(dynamic json) {
    final map = <String, BaremetalIpv4>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = BaremetalIpv4.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of BaremetalIpv4-objects as value to a dart map
  static Map<String, List<BaremetalIpv4>> mapListFromJson(dynamic json, {bool growable = false,}) {
    final map = <String, List<BaremetalIpv4>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = BaremetalIpv4.listFromJson(entry.value, growable: growable,);
      }
    }
    return map;
  }

  /// The list of required keys that must be present in a JSON.
  static const requiredKeys = <String>{
  };
}

