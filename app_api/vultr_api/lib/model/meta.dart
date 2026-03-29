//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of openapi.api;

class Meta {
  /// Returns a new [Meta] instance.
  Meta({
    this.total,
    this.links,
  });

  /// Total objects available in the list. This value may be greater than the number of objects returned if `per_page` is set.
  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  int? total;

  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  MetaLinks? links;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Meta && other.total == total && other.links == links;

  @override
  int get hashCode =>
      // ignore: unnecessary_parenthesis
      (total == null ? 0 : total!.hashCode) +
      (links == null ? 0 : links!.hashCode);

  @override
  String toString() => 'Meta[total=$total, links=$links]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
    if (this.total != null) {
      json[r'total'] = this.total;
    } else {
      json[r'total'] = null;
    }
    if (this.links != null) {
      json[r'links'] = this.links;
    } else {
      json[r'links'] = null;
    }
    return json;
  }

  /// Returns a new [Meta] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static Meta? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      assert(() {
        requiredKeys.forEach((key) {
          assert(json.containsKey(key),
              'Required key "Meta[$key]" is missing from JSON.');
          assert(json[key] != null,
              'Required key "Meta[$key]" has a null value in JSON.');
        });
        return true;
      }());

      return Meta(
        total: mapValueOfType<int>(json, r'total'),
        links: MetaLinks.fromJson(json[r'links']),
      );
    }
    return null;
  }

  static List<Meta> listFromJson(
    dynamic json, {
    bool growable = false,
  }) {
    final result = <Meta>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = Meta.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, Meta> mapFromJson(dynamic json) {
    final map = <String, Meta>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = Meta.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of Meta-objects as value to a dart map
  static Map<String, List<Meta>> mapListFromJson(
    dynamic json, {
    bool growable = false,
  }) {
    final map = <String, List<Meta>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = Meta.listFromJson(
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
