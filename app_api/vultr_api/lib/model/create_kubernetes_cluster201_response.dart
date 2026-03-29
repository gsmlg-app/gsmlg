//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of openapi.api;

class CreateKubernetesCluster201Response {
  /// Returns a new [CreateKubernetesCluster201Response] instance.
  CreateKubernetesCluster201Response({
    this.vkeCluster,
  });

  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  VkeCluster? vkeCluster;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CreateKubernetesCluster201Response &&
          other.vkeCluster == vkeCluster;

  @override
  int get hashCode =>
      // ignore: unnecessary_parenthesis
      (vkeCluster == null ? 0 : vkeCluster!.hashCode);

  @override
  String toString() =>
      'CreateKubernetesCluster201Response[vkeCluster=$vkeCluster]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
    if (this.vkeCluster != null) {
      json[r'vke_cluster'] = this.vkeCluster;
    } else {
      json[r'vke_cluster'] = null;
    }
    return json;
  }

  /// Returns a new [CreateKubernetesCluster201Response] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static CreateKubernetesCluster201Response? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      assert(() {
        requiredKeys.forEach((key) {
          assert(json.containsKey(key),
              'Required key "CreateKubernetesCluster201Response[$key]" is missing from JSON.');
          assert(json[key] != null,
              'Required key "CreateKubernetesCluster201Response[$key]" has a null value in JSON.');
        });
        return true;
      }());

      return CreateKubernetesCluster201Response(
        vkeCluster: VkeCluster.fromJson(json[r'vke_cluster']),
      );
    }
    return null;
  }

  static List<CreateKubernetesCluster201Response> listFromJson(
    dynamic json, {
    bool growable = false,
  }) {
    final result = <CreateKubernetesCluster201Response>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = CreateKubernetesCluster201Response.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, CreateKubernetesCluster201Response> mapFromJson(
      dynamic json) {
    final map = <String, CreateKubernetesCluster201Response>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = CreateKubernetesCluster201Response.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of CreateKubernetesCluster201Response-objects as value to a dart map
  static Map<String, List<CreateKubernetesCluster201Response>> mapListFromJson(
    dynamic json, {
    bool growable = false,
  }) {
    final map = <String, List<CreateKubernetesCluster201Response>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = CreateKubernetesCluster201Response.listFromJson(
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
