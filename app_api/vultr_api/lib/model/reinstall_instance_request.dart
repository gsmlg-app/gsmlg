//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of openapi.api;

class ReinstallInstanceRequest {
  /// Returns a new [ReinstallInstanceRequest] instance.
  ReinstallInstanceRequest({
    this.hostname,
  });

  /// The hostname to use when reinstalling this instance.
  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  String? hostname;

  @override
  bool operator ==(Object other) => identical(this, other) || other is ReinstallInstanceRequest &&
    other.hostname == hostname;

  @override
  int get hashCode =>
    // ignore: unnecessary_parenthesis
    (hostname == null ? 0 : hostname!.hashCode);

  @override
  String toString() => 'ReinstallInstanceRequest[hostname=$hostname]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
    if (this.hostname != null) {
      json[r'hostname'] = this.hostname;
    } else {
      json[r'hostname'] = null;
    }
    return json;
  }

  /// Returns a new [ReinstallInstanceRequest] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static ReinstallInstanceRequest? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      assert(() {
        requiredKeys.forEach((key) {
          assert(json.containsKey(key), 'Required key "ReinstallInstanceRequest[$key]" is missing from JSON.');
          assert(json[key] != null, 'Required key "ReinstallInstanceRequest[$key]" has a null value in JSON.');
        });
        return true;
      }());

      return ReinstallInstanceRequest(
        hostname: mapValueOfType<String>(json, r'hostname'),
      );
    }
    return null;
  }

  static List<ReinstallInstanceRequest> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <ReinstallInstanceRequest>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = ReinstallInstanceRequest.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, ReinstallInstanceRequest> mapFromJson(dynamic json) {
    final map = <String, ReinstallInstanceRequest>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = ReinstallInstanceRequest.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of ReinstallInstanceRequest-objects as value to a dart map
  static Map<String, List<ReinstallInstanceRequest>> mapListFromJson(dynamic json, {bool growable = false,}) {
    final map = <String, List<ReinstallInstanceRequest>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = ReinstallInstanceRequest.listFromJson(entry.value, growable: growable,);
      }
    }
    return map;
  }

  /// The list of required keys that must be present in a JSON.
  static const requiredKeys = <String>{
  };
}

