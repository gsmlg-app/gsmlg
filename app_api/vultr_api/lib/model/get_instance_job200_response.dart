//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of openapi.api;

class GetInstanceJob200Response {
  /// Returns a new [GetInstanceJob200Response] instance.
  GetInstanceJob200Response({
    this.job,
  });

  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  GetInstanceJob200ResponseJob? job;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is GetInstanceJob200Response && other.job == job;

  @override
  int get hashCode =>
      // ignore: unnecessary_parenthesis
      (job == null ? 0 : job!.hashCode);

  @override
  String toString() => 'GetInstanceJob200Response[job=$job]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
    if (this.job != null) {
      json[r'job'] = this.job;
    } else {
      json[r'job'] = null;
    }
    return json;
  }

  /// Returns a new [GetInstanceJob200Response] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static GetInstanceJob200Response? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      assert(() {
        requiredKeys.forEach((key) {
          assert(json.containsKey(key),
              'Required key "GetInstanceJob200Response[$key]" is missing from JSON.');
          assert(json[key] != null,
              'Required key "GetInstanceJob200Response[$key]" has a null value in JSON.');
        });
        return true;
      }());

      return GetInstanceJob200Response(
        job: GetInstanceJob200ResponseJob.fromJson(json[r'job']),
      );
    }
    return null;
  }

  static List<GetInstanceJob200Response> listFromJson(
    dynamic json, {
    bool growable = false,
  }) {
    final result = <GetInstanceJob200Response>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = GetInstanceJob200Response.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, GetInstanceJob200Response> mapFromJson(dynamic json) {
    final map = <String, GetInstanceJob200Response>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = GetInstanceJob200Response.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of GetInstanceJob200Response-objects as value to a dart map
  static Map<String, List<GetInstanceJob200Response>> mapListFromJson(
    dynamic json, {
    bool growable = false,
  }) {
    final map = <String, List<GetInstanceJob200Response>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = GetInstanceJob200Response.listFromJson(
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
