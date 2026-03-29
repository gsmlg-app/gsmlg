//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of openapi.api;

class CreateObjectStorage202Response {
  /// Returns a new [CreateObjectStorage202Response] instance.
  CreateObjectStorage202Response({
    this.objectStorage,
  });

  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  ObjectStorage? objectStorage;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CreateObjectStorage202Response &&
          other.objectStorage == objectStorage;

  @override
  int get hashCode =>
      // ignore: unnecessary_parenthesis
      (objectStorage == null ? 0 : objectStorage!.hashCode);

  @override
  String toString() =>
      'CreateObjectStorage202Response[objectStorage=$objectStorage]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
    if (this.objectStorage != null) {
      json[r'object_storage'] = this.objectStorage;
    } else {
      json[r'object_storage'] = null;
    }
    return json;
  }

  /// Returns a new [CreateObjectStorage202Response] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static CreateObjectStorage202Response? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      assert(() {
        requiredKeys.forEach((key) {
          assert(json.containsKey(key),
              'Required key "CreateObjectStorage202Response[$key]" is missing from JSON.');
          assert(json[key] != null,
              'Required key "CreateObjectStorage202Response[$key]" has a null value in JSON.');
        });
        return true;
      }());

      return CreateObjectStorage202Response(
        objectStorage: ObjectStorage.fromJson(json[r'object_storage']),
      );
    }
    return null;
  }

  static List<CreateObjectStorage202Response> listFromJson(
    dynamic json, {
    bool growable = false,
  }) {
    final result = <CreateObjectStorage202Response>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = CreateObjectStorage202Response.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, CreateObjectStorage202Response> mapFromJson(dynamic json) {
    final map = <String, CreateObjectStorage202Response>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = CreateObjectStorage202Response.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of CreateObjectStorage202Response-objects as value to a dart map
  static Map<String, List<CreateObjectStorage202Response>> mapListFromJson(
    dynamic json, {
    bool growable = false,
  }) {
    final map = <String, List<CreateObjectStorage202Response>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = CreateObjectStorage202Response.listFromJson(
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
