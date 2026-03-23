//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of openapi.api;

class AddUserIpWhitelistRequest {
  /// Returns a new [AddUserIpWhitelistRequest] instance.
  AddUserIpWhitelistRequest({
    required this.subnet,
    required this.subnetSize,
  });

  /// The IP address or subnet to whitelist.
  String subnet;

  /// The subnet size. For IPv4: 0 (allow all) or 8-32. For IPv6: 0 (allow all) or 20-128.
  int subnetSize;

  @override
  bool operator ==(Object other) => identical(this, other) || other is AddUserIpWhitelistRequest &&
    other.subnet == subnet &&
    other.subnetSize == subnetSize;

  @override
  int get hashCode =>
    // ignore: unnecessary_parenthesis
    (subnet.hashCode) +
    (subnetSize.hashCode);

  @override
  String toString() => 'AddUserIpWhitelistRequest[subnet=$subnet, subnetSize=$subnetSize]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
      json[r'subnet'] = this.subnet;
      json[r'subnet_size'] = this.subnetSize;
    return json;
  }

  /// Returns a new [AddUserIpWhitelistRequest] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static AddUserIpWhitelistRequest? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      assert(() {
        requiredKeys.forEach((key) {
          assert(json.containsKey(key), 'Required key "AddUserIpWhitelistRequest[$key]" is missing from JSON.');
          assert(json[key] != null, 'Required key "AddUserIpWhitelistRequest[$key]" has a null value in JSON.');
        });
        return true;
      }());

      return AddUserIpWhitelistRequest(
        subnet: mapValueOfType<String>(json, r'subnet')!,
        subnetSize: mapValueOfType<int>(json, r'subnet_size')!,
      );
    }
    return null;
  }

  static List<AddUserIpWhitelistRequest> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <AddUserIpWhitelistRequest>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = AddUserIpWhitelistRequest.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, AddUserIpWhitelistRequest> mapFromJson(dynamic json) {
    final map = <String, AddUserIpWhitelistRequest>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = AddUserIpWhitelistRequest.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of AddUserIpWhitelistRequest-objects as value to a dart map
  static Map<String, List<AddUserIpWhitelistRequest>> mapListFromJson(dynamic json, {bool growable = false,}) {
    final map = <String, List<AddUserIpWhitelistRequest>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = AddUserIpWhitelistRequest.listFromJson(entry.value, growable: growable,);
      }
    }
    return map;
  }

  /// The list of required keys that must be present in a JSON.
  static const requiredKeys = <String>{
    'subnet',
    'subnet_size',
  };
}

