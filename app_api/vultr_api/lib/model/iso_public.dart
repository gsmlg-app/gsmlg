//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of openapi.api;

class IsoPublic {
  /// Returns a new [IsoPublic] instance.
  IsoPublic({
    this.id,
    this.name,
    this.description,
    this.md5sum,
  });

  /// A unique ID for the Vultr Public ISO.
  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  String? id;

  /// The short name of the Public ISO.
  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  String? name;

  /// The long description of the Public ISO.
  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  String? description;

  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  String? md5sum;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is IsoPublic &&
          other.id == id &&
          other.name == name &&
          other.description == description &&
          other.md5sum == md5sum;

  @override
  int get hashCode =>
      // ignore: unnecessary_parenthesis
      (id == null ? 0 : id!.hashCode) +
      (name == null ? 0 : name!.hashCode) +
      (description == null ? 0 : description!.hashCode) +
      (md5sum == null ? 0 : md5sum!.hashCode);

  @override
  String toString() =>
      'IsoPublic[id=$id, name=$name, description=$description, md5sum=$md5sum]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
    if (this.id != null) {
      json[r'id'] = this.id;
    } else {
      json[r'id'] = null;
    }
    if (this.name != null) {
      json[r'name'] = this.name;
    } else {
      json[r'name'] = null;
    }
    if (this.description != null) {
      json[r'description'] = this.description;
    } else {
      json[r'description'] = null;
    }
    if (this.md5sum != null) {
      json[r'md5sum'] = this.md5sum;
    } else {
      json[r'md5sum'] = null;
    }
    return json;
  }

  /// Returns a new [IsoPublic] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static IsoPublic? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      assert(() {
        requiredKeys.forEach((key) {
          assert(json.containsKey(key),
              'Required key "IsoPublic[$key]" is missing from JSON.');
          assert(json[key] != null,
              'Required key "IsoPublic[$key]" has a null value in JSON.');
        });
        return true;
      }());

      return IsoPublic(
        id: mapValueOfType<String>(json, r'id'),
        name: mapValueOfType<String>(json, r'name'),
        description: mapValueOfType<String>(json, r'description'),
        md5sum: mapValueOfType<String>(json, r'md5sum'),
      );
    }
    return null;
  }

  static List<IsoPublic> listFromJson(
    dynamic json, {
    bool growable = false,
  }) {
    final result = <IsoPublic>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = IsoPublic.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, IsoPublic> mapFromJson(dynamic json) {
    final map = <String, IsoPublic>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = IsoPublic.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of IsoPublic-objects as value to a dart map
  static Map<String, List<IsoPublic>> mapListFromJson(
    dynamic json, {
    bool growable = false,
  }) {
    final map = <String, List<IsoPublic>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = IsoPublic.listFromJson(
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
