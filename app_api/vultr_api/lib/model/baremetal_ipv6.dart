//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of openapi.api;

class BaremetalIpv6 {
  /// Returns a new [BaremetalIpv6] instance.
  BaremetalIpv6({
    this.ip,
    this.network,
    this.networkSize,
    this.type,
  });

  /// A unique ID for the IPv6 address.
  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  String? ip;

  /// The IPv6 subnet.
  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  String? network;

  /// The IPv6 network size in bits.
  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  int? networkSize;

  /// The type of IP address.  * main_ip
  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  String? type;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BaremetalIpv6 &&
          other.ip == ip &&
          other.network == network &&
          other.networkSize == networkSize &&
          other.type == type;

  @override
  int get hashCode =>
      // ignore: unnecessary_parenthesis
      (ip == null ? 0 : ip!.hashCode) +
      (network == null ? 0 : network!.hashCode) +
      (networkSize == null ? 0 : networkSize!.hashCode) +
      (type == null ? 0 : type!.hashCode);

  @override
  String toString() =>
      'BaremetalIpv6[ip=$ip, network=$network, networkSize=$networkSize, type=$type]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
    if (this.ip != null) {
      json[r'ip'] = this.ip;
    } else {
      json[r'ip'] = null;
    }
    if (this.network != null) {
      json[r'network'] = this.network;
    } else {
      json[r'network'] = null;
    }
    if (this.networkSize != null) {
      json[r'network_size'] = this.networkSize;
    } else {
      json[r'network_size'] = null;
    }
    if (this.type != null) {
      json[r'type'] = this.type;
    } else {
      json[r'type'] = null;
    }
    return json;
  }

  /// Returns a new [BaremetalIpv6] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static BaremetalIpv6? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      assert(() {
        requiredKeys.forEach((key) {
          assert(json.containsKey(key),
              'Required key "BaremetalIpv6[$key]" is missing from JSON.');
          assert(json[key] != null,
              'Required key "BaremetalIpv6[$key]" has a null value in JSON.');
        });
        return true;
      }());

      return BaremetalIpv6(
        ip: mapValueOfType<String>(json, r'ip'),
        network: mapValueOfType<String>(json, r'network'),
        networkSize: mapValueOfType<int>(json, r'network_size'),
        type: mapValueOfType<String>(json, r'type'),
      );
    }
    return null;
  }

  static List<BaremetalIpv6> listFromJson(
    dynamic json, {
    bool growable = false,
  }) {
    final result = <BaremetalIpv6>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = BaremetalIpv6.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, BaremetalIpv6> mapFromJson(dynamic json) {
    final map = <String, BaremetalIpv6>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = BaremetalIpv6.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of BaremetalIpv6-objects as value to a dart map
  static Map<String, List<BaremetalIpv6>> mapListFromJson(
    dynamic json, {
    bool growable = false,
  }) {
    final map = <String, List<BaremetalIpv6>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = BaremetalIpv6.listFromJson(
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
