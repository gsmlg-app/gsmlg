//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of openapi.api;

class GetBareMetalUserdata200Response {
  /// Returns a new [GetBareMetalUserdata200Response] instance.
  GetBareMetalUserdata200Response({
    this.userData,
  });

  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  GetBareMetalUserdata200ResponseUserData? userData;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is GetBareMetalUserdata200Response && other.userData == userData;

  @override
  int get hashCode =>
      // ignore: unnecessary_parenthesis
      (userData == null ? 0 : userData!.hashCode);

  @override
  String toString() => 'GetBareMetalUserdata200Response[userData=$userData]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
    if (this.userData != null) {
      json[r'user_data'] = this.userData;
    } else {
      json[r'user_data'] = null;
    }
    return json;
  }

  /// Returns a new [GetBareMetalUserdata200Response] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static GetBareMetalUserdata200Response? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      assert(() {
        requiredKeys.forEach((key) {
          assert(json.containsKey(key),
              'Required key "GetBareMetalUserdata200Response[$key]" is missing from JSON.');
          assert(json[key] != null,
              'Required key "GetBareMetalUserdata200Response[$key]" has a null value in JSON.');
        });
        return true;
      }());

      return GetBareMetalUserdata200Response(
        userData: GetBareMetalUserdata200ResponseUserData.fromJson(
            json[r'user_data']),
      );
    }
    return null;
  }

  static List<GetBareMetalUserdata200Response> listFromJson(
    dynamic json, {
    bool growable = false,
  }) {
    final result = <GetBareMetalUserdata200Response>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = GetBareMetalUserdata200Response.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, GetBareMetalUserdata200Response> mapFromJson(
      dynamic json) {
    final map = <String, GetBareMetalUserdata200Response>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = GetBareMetalUserdata200Response.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of GetBareMetalUserdata200Response-objects as value to a dart map
  static Map<String, List<GetBareMetalUserdata200Response>> mapListFromJson(
    dynamic json, {
    bool growable = false,
  }) {
    final map = <String, List<GetBareMetalUserdata200Response>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = GetBareMetalUserdata200Response.listFromJson(
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
