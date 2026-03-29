//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of openapi.api;

class CreateStorageGateway202Response {
  /// Returns a new [CreateStorageGateway202Response] instance.
  CreateStorageGateway202Response({
    this.storageGateway,
  });

  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  StorageGateway? storageGateway;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CreateStorageGateway202Response &&
          other.storageGateway == storageGateway;

  @override
  int get hashCode =>
      // ignore: unnecessary_parenthesis
      (storageGateway == null ? 0 : storageGateway!.hashCode);

  @override
  String toString() =>
      'CreateStorageGateway202Response[storageGateway=$storageGateway]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
    if (this.storageGateway != null) {
      json[r'storage_gateway'] = this.storageGateway;
    } else {
      json[r'storage_gateway'] = null;
    }
    return json;
  }

  /// Returns a new [CreateStorageGateway202Response] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static CreateStorageGateway202Response? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      assert(() {
        requiredKeys.forEach((key) {
          assert(json.containsKey(key),
              'Required key "CreateStorageGateway202Response[$key]" is missing from JSON.');
          assert(json[key] != null,
              'Required key "CreateStorageGateway202Response[$key]" has a null value in JSON.');
        });
        return true;
      }());

      return CreateStorageGateway202Response(
        storageGateway: StorageGateway.fromJson(json[r'storage_gateway']),
      );
    }
    return null;
  }

  static List<CreateStorageGateway202Response> listFromJson(
    dynamic json, {
    bool growable = false,
  }) {
    final result = <CreateStorageGateway202Response>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = CreateStorageGateway202Response.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, CreateStorageGateway202Response> mapFromJson(
      dynamic json) {
    final map = <String, CreateStorageGateway202Response>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = CreateStorageGateway202Response.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of CreateStorageGateway202Response-objects as value to a dart map
  static Map<String, List<CreateStorageGateway202Response>> mapListFromJson(
    dynamic json, {
    bool growable = false,
  }) {
    final map = <String, List<CreateStorageGateway202Response>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = CreateStorageGateway202Response.listFromJson(
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
