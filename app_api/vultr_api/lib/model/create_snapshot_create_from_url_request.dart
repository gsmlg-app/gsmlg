//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of openapi.api;

class CreateSnapshotCreateFromUrlRequest {
  /// Returns a new [CreateSnapshotCreateFromUrlRequest] instance.
  CreateSnapshotCreateFromUrlRequest({
    required this.url,
    this.description,
    this.uefi,
  });

  /// The public URL containing a RAW image.
  String url;

  /// The user-supplied description of the Snapshot.
  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  String? description;

  /// Whether or not the snapshot uses UEFI.
  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  bool? uefi;

  @override
  bool operator ==(Object other) => identical(this, other) || other is CreateSnapshotCreateFromUrlRequest &&
    other.url == url &&
    other.description == description &&
    other.uefi == uefi;

  @override
  int get hashCode =>
    // ignore: unnecessary_parenthesis
    (url.hashCode) +
    (description == null ? 0 : description!.hashCode) +
    (uefi == null ? 0 : uefi!.hashCode);

  @override
  String toString() => 'CreateSnapshotCreateFromUrlRequest[url=$url, description=$description, uefi=$uefi]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
      json[r'url'] = this.url;
    if (this.description != null) {
      json[r'description'] = this.description;
    } else {
      json[r'description'] = null;
    }
    if (this.uefi != null) {
      json[r'uefi'] = this.uefi;
    } else {
      json[r'uefi'] = null;
    }
    return json;
  }

  /// Returns a new [CreateSnapshotCreateFromUrlRequest] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static CreateSnapshotCreateFromUrlRequest? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      assert(() {
        requiredKeys.forEach((key) {
          assert(json.containsKey(key), 'Required key "CreateSnapshotCreateFromUrlRequest[$key]" is missing from JSON.');
          assert(json[key] != null, 'Required key "CreateSnapshotCreateFromUrlRequest[$key]" has a null value in JSON.');
        });
        return true;
      }());

      return CreateSnapshotCreateFromUrlRequest(
        url: mapValueOfType<String>(json, r'url')!,
        description: mapValueOfType<String>(json, r'description'),
        uefi: mapValueOfType<bool>(json, r'uefi'),
      );
    }
    return null;
  }

  static List<CreateSnapshotCreateFromUrlRequest> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <CreateSnapshotCreateFromUrlRequest>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = CreateSnapshotCreateFromUrlRequest.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, CreateSnapshotCreateFromUrlRequest> mapFromJson(dynamic json) {
    final map = <String, CreateSnapshotCreateFromUrlRequest>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = CreateSnapshotCreateFromUrlRequest.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of CreateSnapshotCreateFromUrlRequest-objects as value to a dart map
  static Map<String, List<CreateSnapshotCreateFromUrlRequest>> mapListFromJson(dynamic json, {bool growable = false,}) {
    final map = <String, List<CreateSnapshotCreateFromUrlRequest>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = CreateSnapshotCreateFromUrlRequest.listFromJson(entry.value, growable: growable,);
      }
    }
    return map;
  }

  /// The list of required keys that must be present in a JSON.
  static const requiredKeys = <String>{
    'url',
  };
}

