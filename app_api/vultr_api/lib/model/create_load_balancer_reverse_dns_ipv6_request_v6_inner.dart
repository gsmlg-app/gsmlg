//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of openapi.api;

class CreateLoadBalancerReverseDnsIpv6RequestV6Inner {
  /// Returns a new [CreateLoadBalancerReverseDnsIpv6RequestV6Inner] instance.
  CreateLoadBalancerReverseDnsIpv6RequestV6Inner({
    this.domain,
    this.ip,
  });

  /// The Domain for the Reverse DNS Entry.
  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  String? domain;

  /// The IPV6 IP for the Reverse DNS Entry.
  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  String? ip;

  @override
  bool operator ==(Object other) => identical(this, other) || other is CreateLoadBalancerReverseDnsIpv6RequestV6Inner &&
    other.domain == domain &&
    other.ip == ip;

  @override
  int get hashCode =>
    // ignore: unnecessary_parenthesis
    (domain == null ? 0 : domain!.hashCode) +
    (ip == null ? 0 : ip!.hashCode);

  @override
  String toString() => 'CreateLoadBalancerReverseDnsIpv6RequestV6Inner[domain=$domain, ip=$ip]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
    if (this.domain != null) {
      json[r'domain'] = this.domain;
    } else {
      json[r'domain'] = null;
    }
    if (this.ip != null) {
      json[r'ip'] = this.ip;
    } else {
      json[r'ip'] = null;
    }
    return json;
  }

  /// Returns a new [CreateLoadBalancerReverseDnsIpv6RequestV6Inner] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static CreateLoadBalancerReverseDnsIpv6RequestV6Inner? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      assert(() {
        requiredKeys.forEach((key) {
          assert(json.containsKey(key), 'Required key "CreateLoadBalancerReverseDnsIpv6RequestV6Inner[$key]" is missing from JSON.');
          assert(json[key] != null, 'Required key "CreateLoadBalancerReverseDnsIpv6RequestV6Inner[$key]" has a null value in JSON.');
        });
        return true;
      }());

      return CreateLoadBalancerReverseDnsIpv6RequestV6Inner(
        domain: mapValueOfType<String>(json, r'domain'),
        ip: mapValueOfType<String>(json, r'ip'),
      );
    }
    return null;
  }

  static List<CreateLoadBalancerReverseDnsIpv6RequestV6Inner> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <CreateLoadBalancerReverseDnsIpv6RequestV6Inner>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = CreateLoadBalancerReverseDnsIpv6RequestV6Inner.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, CreateLoadBalancerReverseDnsIpv6RequestV6Inner> mapFromJson(dynamic json) {
    final map = <String, CreateLoadBalancerReverseDnsIpv6RequestV6Inner>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = CreateLoadBalancerReverseDnsIpv6RequestV6Inner.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of CreateLoadBalancerReverseDnsIpv6RequestV6Inner-objects as value to a dart map
  static Map<String, List<CreateLoadBalancerReverseDnsIpv6RequestV6Inner>> mapListFromJson(dynamic json, {bool growable = false,}) {
    final map = <String, List<CreateLoadBalancerReverseDnsIpv6RequestV6Inner>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = CreateLoadBalancerReverseDnsIpv6RequestV6Inner.listFromJson(entry.value, growable: growable,);
      }
    }
    return map;
  }

  /// The list of required keys that must be present in a JSON.
  static const requiredKeys = <String>{
  };
}

