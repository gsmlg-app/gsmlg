//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of openapi.api;

class PostFirewallsFirewallGroupIdRules201Response {
  /// Returns a new [PostFirewallsFirewallGroupIdRules201Response] instance.
  PostFirewallsFirewallGroupIdRules201Response({
    this.firewallRule,
  });

  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  FirewallRule? firewallRule;

  @override
  bool operator ==(Object other) => identical(this, other) || other is PostFirewallsFirewallGroupIdRules201Response &&
    other.firewallRule == firewallRule;

  @override
  int get hashCode =>
    // ignore: unnecessary_parenthesis
    (firewallRule == null ? 0 : firewallRule!.hashCode);

  @override
  String toString() => 'PostFirewallsFirewallGroupIdRules201Response[firewallRule=$firewallRule]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
    if (this.firewallRule != null) {
      json[r'firewall_rule'] = this.firewallRule;
    } else {
      json[r'firewall_rule'] = null;
    }
    return json;
  }

  /// Returns a new [PostFirewallsFirewallGroupIdRules201Response] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static PostFirewallsFirewallGroupIdRules201Response? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      assert(() {
        requiredKeys.forEach((key) {
          assert(json.containsKey(key), 'Required key "PostFirewallsFirewallGroupIdRules201Response[$key]" is missing from JSON.');
          assert(json[key] != null, 'Required key "PostFirewallsFirewallGroupIdRules201Response[$key]" has a null value in JSON.');
        });
        return true;
      }());

      return PostFirewallsFirewallGroupIdRules201Response(
        firewallRule: FirewallRule.fromJson(json[r'firewall_rule']),
      );
    }
    return null;
  }

  static List<PostFirewallsFirewallGroupIdRules201Response> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <PostFirewallsFirewallGroupIdRules201Response>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = PostFirewallsFirewallGroupIdRules201Response.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, PostFirewallsFirewallGroupIdRules201Response> mapFromJson(dynamic json) {
    final map = <String, PostFirewallsFirewallGroupIdRules201Response>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = PostFirewallsFirewallGroupIdRules201Response.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of PostFirewallsFirewallGroupIdRules201Response-objects as value to a dart map
  static Map<String, List<PostFirewallsFirewallGroupIdRules201Response>> mapListFromJson(dynamic json, {bool growable = false,}) {
    final map = <String, List<PostFirewallsFirewallGroupIdRules201Response>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = PostFirewallsFirewallGroupIdRules201Response.listFromJson(entry.value, growable: growable,);
      }
    }
    return map;
  }

  /// The list of required keys that must be present in a JSON.
  static const requiredKeys = <String>{
  };
}

