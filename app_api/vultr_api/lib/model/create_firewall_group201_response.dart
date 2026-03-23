//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of openapi.api;

class CreateFirewallGroup201Response {
  /// Returns a new [CreateFirewallGroup201Response] instance.
  CreateFirewallGroup201Response({
    this.firewallGroup,
  });

  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  FirewallGroup? firewallGroup;

  @override
  bool operator ==(Object other) => identical(this, other) || other is CreateFirewallGroup201Response &&
    other.firewallGroup == firewallGroup;

  @override
  int get hashCode =>
    // ignore: unnecessary_parenthesis
    (firewallGroup == null ? 0 : firewallGroup!.hashCode);

  @override
  String toString() => 'CreateFirewallGroup201Response[firewallGroup=$firewallGroup]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
    if (this.firewallGroup != null) {
      json[r'firewall_group'] = this.firewallGroup;
    } else {
      json[r'firewall_group'] = null;
    }
    return json;
  }

  /// Returns a new [CreateFirewallGroup201Response] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static CreateFirewallGroup201Response? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      assert(() {
        requiredKeys.forEach((key) {
          assert(json.containsKey(key), 'Required key "CreateFirewallGroup201Response[$key]" is missing from JSON.');
          assert(json[key] != null, 'Required key "CreateFirewallGroup201Response[$key]" has a null value in JSON.');
        });
        return true;
      }());

      return CreateFirewallGroup201Response(
        firewallGroup: FirewallGroup.fromJson(json[r'firewall_group']),
      );
    }
    return null;
  }

  static List<CreateFirewallGroup201Response> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <CreateFirewallGroup201Response>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = CreateFirewallGroup201Response.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, CreateFirewallGroup201Response> mapFromJson(dynamic json) {
    final map = <String, CreateFirewallGroup201Response>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = CreateFirewallGroup201Response.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of CreateFirewallGroup201Response-objects as value to a dart map
  static Map<String, List<CreateFirewallGroup201Response>> mapListFromJson(dynamic json, {bool growable = false,}) {
    final map = <String, List<CreateFirewallGroup201Response>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = CreateFirewallGroup201Response.listFromJson(entry.value, growable: growable,);
      }
    }
    return map;
  }

  /// The list of required keys that must be present in a JSON.
  static const requiredKeys = <String>{
  };
}

