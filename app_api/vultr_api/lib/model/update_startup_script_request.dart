//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of openapi.api;

class UpdateStartupScriptRequest {
  /// Returns a new [UpdateStartupScriptRequest] instance.
  UpdateStartupScriptRequest({
    this.name,
    this.script,
    this.type,
  });

  /// The name of the Startup Script.
  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  String? name;

  /// The base-64 encoded Startup Script.
  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  String? script;

  /// The Startup Script type.  boot (default) pxe
  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  String? type;

  @override
  bool operator ==(Object other) => identical(this, other) || other is UpdateStartupScriptRequest &&
    other.name == name &&
    other.script == script &&
    other.type == type;

  @override
  int get hashCode =>
    // ignore: unnecessary_parenthesis
    (name == null ? 0 : name!.hashCode) +
    (script == null ? 0 : script!.hashCode) +
    (type == null ? 0 : type!.hashCode);

  @override
  String toString() => 'UpdateStartupScriptRequest[name=$name, script=$script, type=$type]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
    if (this.name != null) {
      json[r'name'] = this.name;
    } else {
      json[r'name'] = null;
    }
    if (this.script != null) {
      json[r'script'] = this.script;
    } else {
      json[r'script'] = null;
    }
    if (this.type != null) {
      json[r'type'] = this.type;
    } else {
      json[r'type'] = null;
    }
    return json;
  }

  /// Returns a new [UpdateStartupScriptRequest] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static UpdateStartupScriptRequest? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      assert(() {
        requiredKeys.forEach((key) {
          assert(json.containsKey(key), 'Required key "UpdateStartupScriptRequest[$key]" is missing from JSON.');
          assert(json[key] != null, 'Required key "UpdateStartupScriptRequest[$key]" has a null value in JSON.');
        });
        return true;
      }());

      return UpdateStartupScriptRequest(
        name: mapValueOfType<String>(json, r'name'),
        script: mapValueOfType<String>(json, r'script'),
        type: mapValueOfType<String>(json, r'type'),
      );
    }
    return null;
  }

  static List<UpdateStartupScriptRequest> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <UpdateStartupScriptRequest>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = UpdateStartupScriptRequest.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, UpdateStartupScriptRequest> mapFromJson(dynamic json) {
    final map = <String, UpdateStartupScriptRequest>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = UpdateStartupScriptRequest.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of UpdateStartupScriptRequest-objects as value to a dart map
  static Map<String, List<UpdateStartupScriptRequest>> mapListFromJson(dynamic json, {bool growable = false,}) {
    final map = <String, List<UpdateStartupScriptRequest>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = UpdateStartupScriptRequest.listFromJson(entry.value, growable: growable,);
      }
    }
    return map;
  }

  /// The list of required keys that must be present in a JSON.
  static const requiredKeys = <String>{
  };
}

