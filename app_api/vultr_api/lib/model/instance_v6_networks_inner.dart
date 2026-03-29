//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of openapi.api;

class InstanceV6NetworksInner {
  /// Returns a new [InstanceV6NetworksInner] instance.
  InstanceV6NetworksInner({
    this.network,
    this.mainIp,
    this.networkSize,
  });

  /// The IPv6 subnet.
  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  String? network;

  /// The main IPv6 network address.
  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  String? mainIp;

  /// The IPv6 network size in bits.
  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  int? networkSize;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is InstanceV6NetworksInner &&
          other.network == network &&
          other.mainIp == mainIp &&
          other.networkSize == networkSize;

  @override
  int get hashCode =>
      // ignore: unnecessary_parenthesis
      (network == null ? 0 : network!.hashCode) +
      (mainIp == null ? 0 : mainIp!.hashCode) +
      (networkSize == null ? 0 : networkSize!.hashCode);

  @override
  String toString() =>
      'InstanceV6NetworksInner[network=$network, mainIp=$mainIp, networkSize=$networkSize]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
    if (this.network != null) {
      json[r'network'] = this.network;
    } else {
      json[r'network'] = null;
    }
    if (this.mainIp != null) {
      json[r'main_ip'] = this.mainIp;
    } else {
      json[r'main_ip'] = null;
    }
    if (this.networkSize != null) {
      json[r'network_size'] = this.networkSize;
    } else {
      json[r'network_size'] = null;
    }
    return json;
  }

  /// Returns a new [InstanceV6NetworksInner] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static InstanceV6NetworksInner? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      assert(() {
        requiredKeys.forEach((key) {
          assert(json.containsKey(key),
              'Required key "InstanceV6NetworksInner[$key]" is missing from JSON.');
          assert(json[key] != null,
              'Required key "InstanceV6NetworksInner[$key]" has a null value in JSON.');
        });
        return true;
      }());

      return InstanceV6NetworksInner(
        network: mapValueOfType<String>(json, r'network'),
        mainIp: mapValueOfType<String>(json, r'main_ip'),
        networkSize: mapValueOfType<int>(json, r'network_size'),
      );
    }
    return null;
  }

  static List<InstanceV6NetworksInner> listFromJson(
    dynamic json, {
    bool growable = false,
  }) {
    final result = <InstanceV6NetworksInner>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = InstanceV6NetworksInner.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, InstanceV6NetworksInner> mapFromJson(dynamic json) {
    final map = <String, InstanceV6NetworksInner>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = InstanceV6NetworksInner.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of InstanceV6NetworksInner-objects as value to a dart map
  static Map<String, List<InstanceV6NetworksInner>> mapListFromJson(
    dynamic json, {
    bool growable = false,
  }) {
    final map = <String, List<InstanceV6NetworksInner>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = InstanceV6NetworksInner.listFromJson(
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
