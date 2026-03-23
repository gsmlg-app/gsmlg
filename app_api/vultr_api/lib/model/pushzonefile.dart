//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of openapi.api;

class Pushzonefile {
  /// Returns a new [Pushzonefile] instance.
  Pushzonefile({
    this.name,
    this.mime,
    this.size,
    this.content,
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

  /// The mime type of the file.
  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  String? mime;

  /// The size of the file.
  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  String? size;

  /// Base64 encoded string of the file's binary content.
  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  String? content;

  /// The date the file was last modified.
  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  String? lastModified;

  @override
  bool operator ==(Object other) => identical(this, other) || other is Pushzonefile &&
    other.name == name &&
    other.mime == mime &&
    other.size == size &&
    other.content == content &&
    other.lastModified == lastModified;

  @override
  int get hashCode =>
    // ignore: unnecessary_parenthesis
    (name == null ? 0 : name!.hashCode) +
    (mime == null ? 0 : mime!.hashCode) +
    (size == null ? 0 : size!.hashCode) +
    (content == null ? 0 : content!.hashCode) +
    (lastModified == null ? 0 : lastModified!.hashCode);

  @override
  String toString() => 'Pushzonefile[name=$name, mime=$mime, size=$size, content=$content, lastModified=$lastModified]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
    if (this.name != null) {
      json[r'name'] = this.name;
    } else {
      json[r'name'] = null;
    }
    if (this.mime != null) {
      json[r'mime'] = this.mime;
    } else {
      json[r'mime'] = null;
    }
    if (this.size != null) {
      json[r'size'] = this.size;
    } else {
      json[r'size'] = null;
    }
    if (this.content != null) {
      json[r'content'] = this.content;
    } else {
      json[r'content'] = null;
    }
    if (this.lastModified != null) {
      json[r'last_modified'] = this.lastModified;
    } else {
      json[r'last_modified'] = null;
    }
    return json;
  }

  /// Returns a new [Pushzonefile] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static Pushzonefile? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      assert(() {
        requiredKeys.forEach((key) {
          assert(json.containsKey(key), 'Required key "Pushzonefile[$key]" is missing from JSON.');
          assert(json[key] != null, 'Required key "Pushzonefile[$key]" has a null value in JSON.');
        });
        return true;
      }());

      return Pushzonefile(
        name: mapValueOfType<String>(json, r'name'),
        mime: mapValueOfType<String>(json, r'mime'),
        size: mapValueOfType<String>(json, r'size'),
        content: mapValueOfType<String>(json, r'content'),
        lastModified: mapValueOfType<String>(json, r'last_modified'),
      );
    }
    return null;
  }

  static List<Pushzonefile> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <Pushzonefile>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = Pushzonefile.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, Pushzonefile> mapFromJson(dynamic json) {
    final map = <String, Pushzonefile>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = Pushzonefile.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of Pushzonefile-objects as value to a dart map
  static Map<String, List<Pushzonefile>> mapListFromJson(dynamic json, {bool growable = false,}) {
    final map = <String, List<Pushzonefile>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = Pushzonefile.listFromJson(entry.value, growable: growable,);
      }
    }
    return map;
  }

  /// The list of required keys that must be present in a JSON.
  static const requiredKeys = <String>{
  };
}

