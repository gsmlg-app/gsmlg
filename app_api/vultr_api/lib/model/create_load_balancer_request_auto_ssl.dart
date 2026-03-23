//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of openapi.api;

class CreateLoadBalancerRequestAutoSsl {
  /// Returns a new [CreateLoadBalancerRequestAutoSsl] instance.
  CreateLoadBalancerRequestAutoSsl({
    this.domainZone,
    this.domainSub,
  });

  /// The domain zone. (example.com)
  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  String? domainZone;

  /// (optional) Subdomain to append to the domain zone.
  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  String? domainSub;

  @override
  bool operator ==(Object other) => identical(this, other) || other is CreateLoadBalancerRequestAutoSsl &&
    other.domainZone == domainZone &&
    other.domainSub == domainSub;

  @override
  int get hashCode =>
    // ignore: unnecessary_parenthesis
    (domainZone == null ? 0 : domainZone!.hashCode) +
    (domainSub == null ? 0 : domainSub!.hashCode);

  @override
  String toString() => 'CreateLoadBalancerRequestAutoSsl[domainZone=$domainZone, domainSub=$domainSub]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
    if (this.domainZone != null) {
      json[r'domain_zone'] = this.domainZone;
    } else {
      json[r'domain_zone'] = null;
    }
    if (this.domainSub != null) {
      json[r'domain_sub'] = this.domainSub;
    } else {
      json[r'domain_sub'] = null;
    }
    return json;
  }

  /// Returns a new [CreateLoadBalancerRequestAutoSsl] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static CreateLoadBalancerRequestAutoSsl? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      assert(() {
        requiredKeys.forEach((key) {
          assert(json.containsKey(key), 'Required key "CreateLoadBalancerRequestAutoSsl[$key]" is missing from JSON.');
          assert(json[key] != null, 'Required key "CreateLoadBalancerRequestAutoSsl[$key]" has a null value in JSON.');
        });
        return true;
      }());

      return CreateLoadBalancerRequestAutoSsl(
        domainZone: mapValueOfType<String>(json, r'domain_zone'),
        domainSub: mapValueOfType<String>(json, r'domain_sub'),
      );
    }
    return null;
  }

  static List<CreateLoadBalancerRequestAutoSsl> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <CreateLoadBalancerRequestAutoSsl>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = CreateLoadBalancerRequestAutoSsl.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, CreateLoadBalancerRequestAutoSsl> mapFromJson(dynamic json) {
    final map = <String, CreateLoadBalancerRequestAutoSsl>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = CreateLoadBalancerRequestAutoSsl.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of CreateLoadBalancerRequestAutoSsl-objects as value to a dart map
  static Map<String, List<CreateLoadBalancerRequestAutoSsl>> mapListFromJson(dynamic json, {bool growable = false,}) {
    final map = <String, List<CreateLoadBalancerRequestAutoSsl>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = CreateLoadBalancerRequestAutoSsl.listFromJson(entry.value, growable: growable,);
      }
    }
    return map;
  }

  /// The list of required keys that must be present in a JSON.
  static const requiredKeys = <String>{
  };
}

