//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of openapi.api;

class Uploadendpoint {
  /// Returns a new [Uploadendpoint] instance.
  Uploadendpoint({
    this.URL,
    this.inputs = const [],
  });

  /// The URL used to upload the file.
  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  String? URL;

  List<NodepoolInstances> inputs;

  @override
  bool operator ==(Object other) => identical(this, other) || other is Uploadendpoint &&
    other.URL == URL &&
    _deepEquality.equals(other.inputs, inputs);

  @override
  int get hashCode =>
    // ignore: unnecessary_parenthesis
    (URL == null ? 0 : URL!.hashCode) +
    (inputs.hashCode);

  @override
  String toString() => 'Uploadendpoint[URL=$URL, inputs=$inputs]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
    if (this.URL != null) {
      json[r'URL'] = this.URL;
    } else {
      json[r'URL'] = null;
    }
      json[r'inputs'] = this.inputs;
    return json;
  }

  /// Returns a new [Uploadendpoint] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static Uploadendpoint? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      assert(() {
        requiredKeys.forEach((key) {
          assert(json.containsKey(key), 'Required key "Uploadendpoint[$key]" is missing from JSON.');
          assert(json[key] != null, 'Required key "Uploadendpoint[$key]" has a null value in JSON.');
        });
        return true;
      }());

      return Uploadendpoint(
        URL: mapValueOfType<String>(json, r'URL'),
        inputs: NodepoolInstances.listFromJson(json[r'inputs']),
      );
    }
    return null;
  }

  static List<Uploadendpoint> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <Uploadendpoint>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = Uploadendpoint.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, Uploadendpoint> mapFromJson(dynamic json) {
    final map = <String, Uploadendpoint>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = Uploadendpoint.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of Uploadendpoint-objects as value to a dart map
  static Map<String, List<Uploadendpoint>> mapListFromJson(dynamic json, {bool growable = false,}) {
    final map = <String, List<Uploadendpoint>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = Uploadendpoint.listFromJson(entry.value, growable: growable,);
      }
    }
    return map;
  }

  /// The list of required keys that must be present in a JSON.
  static const requiredKeys = <String>{
  };
}

