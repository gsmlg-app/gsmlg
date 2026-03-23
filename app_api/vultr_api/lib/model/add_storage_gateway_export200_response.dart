//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of openapi.api;

class AddStorageGatewayExport200Response {
  /// Returns a new [AddStorageGatewayExport200Response] instance.
  AddStorageGatewayExport200Response({
    this.vpc,
  });

  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  StorageGatewayExport? vpc;

  @override
  bool operator ==(Object other) => identical(this, other) || other is AddStorageGatewayExport200Response &&
    other.vpc == vpc;

  @override
  int get hashCode =>
    // ignore: unnecessary_parenthesis
    (vpc == null ? 0 : vpc!.hashCode);

  @override
  String toString() => 'AddStorageGatewayExport200Response[vpc=$vpc]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
    if (this.vpc != null) {
      json[r'vpc'] = this.vpc;
    } else {
      json[r'vpc'] = null;
    }
    return json;
  }

  /// Returns a new [AddStorageGatewayExport200Response] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static AddStorageGatewayExport200Response? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      assert(() {
        requiredKeys.forEach((key) {
          assert(json.containsKey(key), 'Required key "AddStorageGatewayExport200Response[$key]" is missing from JSON.');
          assert(json[key] != null, 'Required key "AddStorageGatewayExport200Response[$key]" has a null value in JSON.');
        });
        return true;
      }());

      return AddStorageGatewayExport200Response(
        vpc: StorageGatewayExport.fromJson(json[r'vpc']),
      );
    }
    return null;
  }

  static List<AddStorageGatewayExport200Response> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <AddStorageGatewayExport200Response>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = AddStorageGatewayExport200Response.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, AddStorageGatewayExport200Response> mapFromJson(dynamic json) {
    final map = <String, AddStorageGatewayExport200Response>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = AddStorageGatewayExport200Response.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of AddStorageGatewayExport200Response-objects as value to a dart map
  static Map<String, List<AddStorageGatewayExport200Response>> mapListFromJson(dynamic json, {bool growable = false,}) {
    final map = <String, List<AddStorageGatewayExport200Response>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = AddStorageGatewayExport200Response.listFromJson(entry.value, growable: growable,);
      }
    }
    return map;
  }

  /// The list of required keys that must be present in a JSON.
  static const requiredKeys = <String>{
  };
}

