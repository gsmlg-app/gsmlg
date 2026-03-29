//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of openapi.api;

class VfsBilling {
  /// Returns a new [VfsBilling] instance.
  VfsBilling({
    this.charges,
    this.monthly,
  });

  /// Current billing charges
  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  double? charges;

  /// Monthly billing amount
  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  double? monthly;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is VfsBilling &&
          other.charges == charges &&
          other.monthly == monthly;

  @override
  int get hashCode =>
      // ignore: unnecessary_parenthesis
      (charges == null ? 0 : charges!.hashCode) +
      (monthly == null ? 0 : monthly!.hashCode);

  @override
  String toString() => 'VfsBilling[charges=$charges, monthly=$monthly]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
    if (this.charges != null) {
      json[r'charges'] = this.charges;
    } else {
      json[r'charges'] = null;
    }
    if (this.monthly != null) {
      json[r'monthly'] = this.monthly;
    } else {
      json[r'monthly'] = null;
    }
    return json;
  }

  /// Returns a new [VfsBilling] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static VfsBilling? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      assert(() {
        requiredKeys.forEach((key) {
          assert(json.containsKey(key),
              'Required key "VfsBilling[$key]" is missing from JSON.');
          assert(json[key] != null,
              'Required key "VfsBilling[$key]" has a null value in JSON.');
        });
        return true;
      }());

      return VfsBilling(
        charges: mapValueOfType<double>(json, r'charges'),
        monthly: mapValueOfType<double>(json, r'monthly'),
      );
    }
    return null;
  }

  static List<VfsBilling> listFromJson(
    dynamic json, {
    bool growable = false,
  }) {
    final result = <VfsBilling>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = VfsBilling.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, VfsBilling> mapFromJson(dynamic json) {
    final map = <String, VfsBilling>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = VfsBilling.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of VfsBilling-objects as value to a dart map
  static Map<String, List<VfsBilling>> mapListFromJson(
    dynamic json, {
    bool growable = false,
  }) {
    final map = <String, List<VfsBilling>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = VfsBilling.listFromJson(
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
