//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of openapi.api;

class CreateBaremetal202Response {
  /// Returns a new [CreateBaremetal202Response] instance.
  CreateBaremetal202Response({
    this.baremetal,
  });

  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  Baremetal? baremetal;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CreateBaremetal202Response && other.baremetal == baremetal;

  @override
  int get hashCode =>
      // ignore: unnecessary_parenthesis
      (baremetal == null ? 0 : baremetal!.hashCode);

  @override
  String toString() => 'CreateBaremetal202Response[baremetal=$baremetal]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
    if (this.baremetal != null) {
      json[r'baremetal'] = this.baremetal;
    } else {
      json[r'baremetal'] = null;
    }
    return json;
  }

  /// Returns a new [CreateBaremetal202Response] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static CreateBaremetal202Response? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      assert(() {
        requiredKeys.forEach((key) {
          assert(json.containsKey(key),
              'Required key "CreateBaremetal202Response[$key]" is missing from JSON.');
          assert(json[key] != null,
              'Required key "CreateBaremetal202Response[$key]" has a null value in JSON.');
        });
        return true;
      }());

      return CreateBaremetal202Response(
        baremetal: Baremetal.fromJson(json[r'baremetal']),
      );
    }
    return null;
  }

  static List<CreateBaremetal202Response> listFromJson(
    dynamic json, {
    bool growable = false,
  }) {
    final result = <CreateBaremetal202Response>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = CreateBaremetal202Response.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, CreateBaremetal202Response> mapFromJson(dynamic json) {
    final map = <String, CreateBaremetal202Response>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = CreateBaremetal202Response.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of CreateBaremetal202Response-objects as value to a dart map
  static Map<String, List<CreateBaremetal202Response>> mapListFromJson(
    dynamic json, {
    bool growable = false,
  }) {
    final map = <String, List<CreateBaremetal202Response>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = CreateBaremetal202Response.listFromJson(
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
