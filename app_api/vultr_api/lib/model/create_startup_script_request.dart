//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of openapi.api;

class CreateStartupScriptRequest {
  /// Returns a new [CreateStartupScriptRequest] instance.
  CreateStartupScriptRequest({
    required this.name,
    this.type,
    required this.script,
  });

  /// The name of the Startup Script.
  String name;

  /// The Startup Script type.  * boot (default) * pxe
  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  String? type;

  /// The base-64 encoded Startup Script.
  String script;

  @override
  bool operator ==(Object other) => identical(this, other) || other is CreateStartupScriptRequest &&
    other.name == name &&
    other.type == type &&
    other.script == script;

  @override
  int get hashCode =>
    // ignore: unnecessary_parenthesis
    (name.hashCode) +
    (type == null ? 0 : type!.hashCode) +
    (script.hashCode);

  @override
  String toString() => 'CreateStartupScriptRequest[name=$name, type=$type, script=$script]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
      json[r'name'] = this.name;
    if (this.type != null) {
      json[r'type'] = this.type;
    } else {
      json[r'type'] = null;
    }
      json[r'script'] = this.script;
    return json;
  }

  /// Returns a new [CreateStartupScriptRequest] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static CreateStartupScriptRequest? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      assert(() {
        requiredKeys.forEach((key) {
          assert(json.containsKey(key), 'Required key "CreateStartupScriptRequest[$key]" is missing from JSON.');
          assert(json[key] != null, 'Required key "CreateStartupScriptRequest[$key]" has a null value in JSON.');
        });
        return true;
      }());

      return CreateStartupScriptRequest(
        name: mapValueOfType<String>(json, r'name')!,
        type: mapValueOfType<String>(json, r'type'),
        script: mapValueOfType<String>(json, r'script')!,
      );
    }
    return null;
  }

  static List<CreateStartupScriptRequest> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <CreateStartupScriptRequest>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = CreateStartupScriptRequest.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, CreateStartupScriptRequest> mapFromJson(dynamic json) {
    final map = <String, CreateStartupScriptRequest>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = CreateStartupScriptRequest.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of CreateStartupScriptRequest-objects as value to a dart map
  static Map<String, List<CreateStartupScriptRequest>> mapListFromJson(dynamic json, {bool growable = false,}) {
    final map = <String, List<CreateStartupScriptRequest>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = CreateStartupScriptRequest.listFromJson(entry.value, growable: growable,);
      }
    }
    return map;
  }

  /// The list of required keys that must be present in a JSON.
  static const requiredKeys = <String>{
    'name',
    'script',
  };
}

