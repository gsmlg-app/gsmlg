//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of openapi.api;

class UpdateFirewallGroupRequest {
  /// Returns a new [UpdateFirewallGroupRequest] instance.
  UpdateFirewallGroupRequest({
    required this.description,
  });

  /// User-supplied description of this Firewall Group.
  String description;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UpdateFirewallGroupRequest && other.description == description;

  @override
  int get hashCode =>
      // ignore: unnecessary_parenthesis
      (description.hashCode);

  @override
  String toString() => 'UpdateFirewallGroupRequest[description=$description]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
    json[r'description'] = this.description;
    return json;
  }

  /// Returns a new [UpdateFirewallGroupRequest] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static UpdateFirewallGroupRequest? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      assert(() {
        requiredKeys.forEach((key) {
          assert(json.containsKey(key),
              'Required key "UpdateFirewallGroupRequest[$key]" is missing from JSON.');
          assert(json[key] != null,
              'Required key "UpdateFirewallGroupRequest[$key]" has a null value in JSON.');
        });
        return true;
      }());

      return UpdateFirewallGroupRequest(
        description: mapValueOfType<String>(json, r'description')!,
      );
    }
    return null;
  }

  static List<UpdateFirewallGroupRequest> listFromJson(
    dynamic json, {
    bool growable = false,
  }) {
    final result = <UpdateFirewallGroupRequest>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = UpdateFirewallGroupRequest.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, UpdateFirewallGroupRequest> mapFromJson(dynamic json) {
    final map = <String, UpdateFirewallGroupRequest>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = UpdateFirewallGroupRequest.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of UpdateFirewallGroupRequest-objects as value to a dart map
  static Map<String, List<UpdateFirewallGroupRequest>> mapListFromJson(
    dynamic json, {
    bool growable = false,
  }) {
    final map = <String, List<UpdateFirewallGroupRequest>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = UpdateFirewallGroupRequest.listFromJson(
          entry.value,
          growable: growable,
        );
      }
    }
    return map;
  }

  /// The list of required keys that must be present in a JSON.
  static const requiredKeys = <String>{
    'description',
  };
}
