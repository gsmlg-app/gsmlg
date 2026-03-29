//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of openapi.api;

class CreatePullzone201Response {
  /// Returns a new [CreatePullzone201Response] instance.
  CreatePullzone201Response({
    this.pullZone,
  });

  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  Pullzone? pullZone;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CreatePullzone201Response && other.pullZone == pullZone;

  @override
  int get hashCode =>
      // ignore: unnecessary_parenthesis
      (pullZone == null ? 0 : pullZone!.hashCode);

  @override
  String toString() => 'CreatePullzone201Response[pullZone=$pullZone]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
    if (this.pullZone != null) {
      json[r'pull_zone'] = this.pullZone;
    } else {
      json[r'pull_zone'] = null;
    }
    return json;
  }

  /// Returns a new [CreatePullzone201Response] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static CreatePullzone201Response? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      assert(() {
        requiredKeys.forEach((key) {
          assert(json.containsKey(key),
              'Required key "CreatePullzone201Response[$key]" is missing from JSON.');
          assert(json[key] != null,
              'Required key "CreatePullzone201Response[$key]" has a null value in JSON.');
        });
        return true;
      }());

      return CreatePullzone201Response(
        pullZone: Pullzone.fromJson(json[r'pull_zone']),
      );
    }
    return null;
  }

  static List<CreatePullzone201Response> listFromJson(
    dynamic json, {
    bool growable = false,
  }) {
    final result = <CreatePullzone201Response>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = CreatePullzone201Response.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, CreatePullzone201Response> mapFromJson(dynamic json) {
    final map = <String, CreatePullzone201Response>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = CreatePullzone201Response.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of CreatePullzone201Response-objects as value to a dart map
  static Map<String, List<CreatePullzone201Response>> mapListFromJson(
    dynamic json, {
    bool growable = false,
  }) {
    final map = <String, List<CreatePullzone201Response>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = CreatePullzone201Response.listFromJson(
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
