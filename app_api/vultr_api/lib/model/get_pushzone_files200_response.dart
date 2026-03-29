//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of openapi.api;

class GetPushzoneFiles200Response {
  /// Returns a new [GetPushzoneFiles200Response] instance.
  GetPushzoneFiles200Response({
    this.files = const [],
    this.count,
    this.totalSize,
  });

  List<Pushzonefilemeta> files;

  /// number of files.
  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  int? count;

  /// total size of all files.
  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  int? totalSize;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is GetPushzoneFiles200Response &&
          _deepEquality.equals(other.files, files) &&
          other.count == count &&
          other.totalSize == totalSize;

  @override
  int get hashCode =>
      // ignore: unnecessary_parenthesis
      (files.hashCode) +
      (count == null ? 0 : count!.hashCode) +
      (totalSize == null ? 0 : totalSize!.hashCode);

  @override
  String toString() =>
      'GetPushzoneFiles200Response[files=$files, count=$count, totalSize=$totalSize]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
    json[r'files'] = this.files;
    if (this.count != null) {
      json[r'count'] = this.count;
    } else {
      json[r'count'] = null;
    }
    if (this.totalSize != null) {
      json[r'total_size'] = this.totalSize;
    } else {
      json[r'total_size'] = null;
    }
    return json;
  }

  /// Returns a new [GetPushzoneFiles200Response] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static GetPushzoneFiles200Response? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      assert(() {
        requiredKeys.forEach((key) {
          assert(json.containsKey(key),
              'Required key "GetPushzoneFiles200Response[$key]" is missing from JSON.');
          assert(json[key] != null,
              'Required key "GetPushzoneFiles200Response[$key]" has a null value in JSON.');
        });
        return true;
      }());

      return GetPushzoneFiles200Response(
        files: Pushzonefilemeta.listFromJson(json[r'files']),
        count: mapValueOfType<int>(json, r'count'),
        totalSize: mapValueOfType<int>(json, r'total_size'),
      );
    }
    return null;
  }

  static List<GetPushzoneFiles200Response> listFromJson(
    dynamic json, {
    bool growable = false,
  }) {
    final result = <GetPushzoneFiles200Response>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = GetPushzoneFiles200Response.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, GetPushzoneFiles200Response> mapFromJson(dynamic json) {
    final map = <String, GetPushzoneFiles200Response>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = GetPushzoneFiles200Response.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of GetPushzoneFiles200Response-objects as value to a dart map
  static Map<String, List<GetPushzoneFiles200Response>> mapListFromJson(
    dynamic json, {
    bool growable = false,
  }) {
    final map = <String, List<GetPushzoneFiles200Response>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = GetPushzoneFiles200Response.listFromJson(
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
