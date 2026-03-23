//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of openapi.api;

class StorageGatewayNetworkPrimary {
  /// Returns a new [StorageGatewayNetworkPrimary] instance.
  StorageGatewayNetworkPrimary({
    this.ipv4PublicEnabled,
    this.ipv6PublicEnabled,
    this.vpc,
  });

  /// Should the storage gateway have a public ipv4 address?
  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  bool? ipv4PublicEnabled;

  /// Should the storage gateway have a public ipv6 address?
  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  bool? ipv6PublicEnabled;

  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  StorageGatewayNetworkPrimaryVpc? vpc;

  @override
  bool operator ==(Object other) => identical(this, other) || other is StorageGatewayNetworkPrimary &&
    other.ipv4PublicEnabled == ipv4PublicEnabled &&
    other.ipv6PublicEnabled == ipv6PublicEnabled &&
    other.vpc == vpc;

  @override
  int get hashCode =>
    // ignore: unnecessary_parenthesis
    (ipv4PublicEnabled == null ? 0 : ipv4PublicEnabled!.hashCode) +
    (ipv6PublicEnabled == null ? 0 : ipv6PublicEnabled!.hashCode) +
    (vpc == null ? 0 : vpc!.hashCode);

  @override
  String toString() => 'StorageGatewayNetworkPrimary[ipv4PublicEnabled=$ipv4PublicEnabled, ipv6PublicEnabled=$ipv6PublicEnabled, vpc=$vpc]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
    if (this.ipv4PublicEnabled != null) {
      json[r'ipv4_public_enabled'] = this.ipv4PublicEnabled;
    } else {
      json[r'ipv4_public_enabled'] = null;
    }
    if (this.ipv6PublicEnabled != null) {
      json[r'ipv6_public_enabled'] = this.ipv6PublicEnabled;
    } else {
      json[r'ipv6_public_enabled'] = null;
    }
    if (this.vpc != null) {
      json[r'vpc'] = this.vpc;
    } else {
      json[r'vpc'] = null;
    }
    return json;
  }

  /// Returns a new [StorageGatewayNetworkPrimary] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static StorageGatewayNetworkPrimary? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      assert(() {
        requiredKeys.forEach((key) {
          assert(json.containsKey(key), 'Required key "StorageGatewayNetworkPrimary[$key]" is missing from JSON.');
          assert(json[key] != null, 'Required key "StorageGatewayNetworkPrimary[$key]" has a null value in JSON.');
        });
        return true;
      }());

      return StorageGatewayNetworkPrimary(
        ipv4PublicEnabled: mapValueOfType<bool>(json, r'ipv4_public_enabled'),
        ipv6PublicEnabled: mapValueOfType<bool>(json, r'ipv6_public_enabled'),
        vpc: StorageGatewayNetworkPrimaryVpc.fromJson(json[r'vpc']),
      );
    }
    return null;
  }

  static List<StorageGatewayNetworkPrimary> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <StorageGatewayNetworkPrimary>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = StorageGatewayNetworkPrimary.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, StorageGatewayNetworkPrimary> mapFromJson(dynamic json) {
    final map = <String, StorageGatewayNetworkPrimary>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = StorageGatewayNetworkPrimary.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of StorageGatewayNetworkPrimary-objects as value to a dart map
  static Map<String, List<StorageGatewayNetworkPrimary>> mapListFromJson(dynamic json, {bool growable = false,}) {
    final map = <String, List<StorageGatewayNetworkPrimary>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = StorageGatewayNetworkPrimary.listFromJson(entry.value, growable: growable,);
      }
    }
    return map;
  }

  /// The list of required keys that must be present in a JSON.
  static const requiredKeys = <String>{
  };
}

