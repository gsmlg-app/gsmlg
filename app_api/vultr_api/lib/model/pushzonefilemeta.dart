//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of openapi.api;

class Pushzonefilemeta {
  /// Returns a new [Pushzonefilemeta] instance.
  Pushzonefilemeta({
    this.name,
    this.size,
    this.lastModified,
  });

  /// The name of the file.
  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  String? name;

  /// the size of the file.
  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  String? size;

  /// The date the file was last modified.
  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  String? lastModified;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Pushzonefilemeta &&
          other.name == name &&
          other.size == size &&
          other.lastModified == lastModified;

  @override
  int get hashCode =>
      // ignore: unnecessary_parenthesis
      (name == null ? 0 : name!.hashCode) +
      (size == null ? 0 : size!.hashCode) +
      (lastModified == null ? 0 : lastModified!.hashCode);

  @override
  String toString() =>
      'Pushzonefilemeta[name=$name, size=$size, lastModified=$lastModified]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
    if (this.name != null) {
      json[r'name'] = this.name;
    } else {
      json[r'name'] = null;
    }
    if (this.size != null) {
      json[r'size'] = this.size;
    } else {
      json[r'size'] = null;
    }
    if (this.lastModified != null) {
      json[r'last_modified'] = this.lastModified;
    } else {
      json[r'last_modified'] = null;
    }
    return json;
  }

  /// Returns a new [Pushzonefilemeta] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static Pushzonefilemeta? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      assert(() {
        requiredKeys.forEach((key) {
          assert(json.containsKey(key),
              'Required key "Pushzonefilemeta[$key]" is missing from JSON.');
          assert(json[key] != null,
              'Required key "Pushzonefilemeta[$key]" has a null value in JSON.');
        });
        return true;
      }());

      return Pushzonefilemeta(
        name: mapValueOfType<String>(json, r'name'),
        size: mapValueOfType<String>(json, r'size'),
        lastModified: mapValueOfType<String>(json, r'last_modified'),
      );
    }
    return null;
  }

  static List<Pushzonefilemeta> listFromJson(
    dynamic json, {
    bool growable = false,
  }) {
    final result = <Pushzonefilemeta>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = Pushzonefilemeta.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, Pushzonefilemeta> mapFromJson(dynamic json) {
    final map = <String, Pushzonefilemeta>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = Pushzonefilemeta.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of Pushzonefilemeta-objects as value to a dart map
  static Map<String, List<Pushzonefilemeta>> mapListFromJson(
    dynamic json, {
    bool growable = false,
  }) {
    final map = <String, List<Pushzonefilemeta>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = Pushzonefilemeta.listFromJson(
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
