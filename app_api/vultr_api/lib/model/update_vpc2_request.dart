//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of openapi.api;

class UpdateVpc2Request {
  /// Returns a new [UpdateVpc2Request] instance.
  UpdateVpc2Request({
    required this.description,
  });

  /// The VPC description. </br> Must be no longer than 255 characters and may include only letters, numbers, spaces, underscores and hyphens.
  String description;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UpdateVpc2Request && other.description == description;

  @override
  int get hashCode =>
      // ignore: unnecessary_parenthesis
      (description.hashCode);

  @override
  String toString() => 'UpdateVpc2Request[description=$description]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
    json[r'description'] = this.description;
    return json;
  }

  /// Returns a new [UpdateVpc2Request] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static UpdateVpc2Request? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      assert(() {
        requiredKeys.forEach((key) {
          assert(json.containsKey(key),
              'Required key "UpdateVpc2Request[$key]" is missing from JSON.');
          assert(json[key] != null,
              'Required key "UpdateVpc2Request[$key]" has a null value in JSON.');
        });
        return true;
      }());

      return UpdateVpc2Request(
        description: mapValueOfType<String>(json, r'description')!,
      );
    }
    return null;
  }

  static List<UpdateVpc2Request> listFromJson(
    dynamic json, {
    bool growable = false,
  }) {
    final result = <UpdateVpc2Request>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = UpdateVpc2Request.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, UpdateVpc2Request> mapFromJson(dynamic json) {
    final map = <String, UpdateVpc2Request>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = UpdateVpc2Request.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of UpdateVpc2Request-objects as value to a dart map
  static Map<String, List<UpdateVpc2Request>> mapListFromJson(
    dynamic json, {
    bool growable = false,
  }) {
    final map = <String, List<UpdateVpc2Request>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = UpdateVpc2Request.listFromJson(
          entry.value,
          growable: growable,
        );
      }
    }
    return map;
  }

  /// The list of required keys that must be present in a JSON.
  static const requiredKeys = <String>{
    'description',
  };
}
