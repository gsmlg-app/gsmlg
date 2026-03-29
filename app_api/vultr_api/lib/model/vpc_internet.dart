//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of openapi.api;

class VpcInternet {
  /// Returns a new [VpcInternet] instance.
  VpcInternet({
    this.connectivity,
    this.types = const [],
  });

  /// If this VPC has connectivity to the public internet or not.
  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  bool? connectivity;

  /// The mechanism providing connectivity to the public internet.
  List<String> types;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is VpcInternet &&
          other.connectivity == connectivity &&
          _deepEquality.equals(other.types, types);

  @override
  int get hashCode =>
      // ignore: unnecessary_parenthesis
      (connectivity == null ? 0 : connectivity!.hashCode) + (types.hashCode);

  @override
  String toString() => 'VpcInternet[connectivity=$connectivity, types=$types]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
    if (this.connectivity != null) {
      json[r'connectivity'] = this.connectivity;
    } else {
      json[r'connectivity'] = null;
    }
    json[r'types'] = this.types;
    return json;
  }

  /// Returns a new [VpcInternet] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static VpcInternet? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      assert(() {
        requiredKeys.forEach((key) {
          assert(json.containsKey(key),
              'Required key "VpcInternet[$key]" is missing from JSON.');
          assert(json[key] != null,
              'Required key "VpcInternet[$key]" has a null value in JSON.');
        });
        return true;
      }());

      return VpcInternet(
        connectivity: mapValueOfType<bool>(json, r'connectivity'),
        types: json[r'types'] is Iterable
            ? (json[r'types'] as Iterable)
                .cast<String>()
                .toList(growable: false)
            : const [],
      );
    }
    return null;
  }

  static List<VpcInternet> listFromJson(
    dynamic json, {
    bool growable = false,
  }) {
    final result = <VpcInternet>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = VpcInternet.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, VpcInternet> mapFromJson(dynamic json) {
    final map = <String, VpcInternet>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = VpcInternet.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of VpcInternet-objects as value to a dart map
  static Map<String, List<VpcInternet>> mapListFromJson(
    dynamic json, {
    bool growable = false,
  }) {
    final map = <String, List<VpcInternet>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = VpcInternet.listFromJson(
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
