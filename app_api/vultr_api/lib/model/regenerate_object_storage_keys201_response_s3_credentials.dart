//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of openapi.api;

class RegenerateObjectStorageKeys201ResponseS3Credentials {
  /// Returns a new [RegenerateObjectStorageKeys201ResponseS3Credentials] instance.
  RegenerateObjectStorageKeys201ResponseS3Credentials({
    this.s3Hostname,
    this.s3AccessKey,
    this.s3SecretKey,
  });

  /// The [Cluster hostname](#operation/list-object-storage-clusters) for this Object Storage.
  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  String? s3Hostname;

  /// The new Object Storage access key.
  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  String? s3AccessKey;

  /// The new Object Storage secret key.
  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  String? s3SecretKey;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is RegenerateObjectStorageKeys201ResponseS3Credentials &&
          other.s3Hostname == s3Hostname &&
          other.s3AccessKey == s3AccessKey &&
          other.s3SecretKey == s3SecretKey;

  @override
  int get hashCode =>
      // ignore: unnecessary_parenthesis
      (s3Hostname == null ? 0 : s3Hostname!.hashCode) +
      (s3AccessKey == null ? 0 : s3AccessKey!.hashCode) +
      (s3SecretKey == null ? 0 : s3SecretKey!.hashCode);

  @override
  String toString() =>
      'RegenerateObjectStorageKeys201ResponseS3Credentials[s3Hostname=$s3Hostname, s3AccessKey=$s3AccessKey, s3SecretKey=$s3SecretKey]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
    if (this.s3Hostname != null) {
      json[r's3_hostname'] = this.s3Hostname;
    } else {
      json[r's3_hostname'] = null;
    }
    if (this.s3AccessKey != null) {
      json[r's3_access_key'] = this.s3AccessKey;
    } else {
      json[r's3_access_key'] = null;
    }
    if (this.s3SecretKey != null) {
      json[r's3_secret_key'] = this.s3SecretKey;
    } else {
      json[r's3_secret_key'] = null;
    }
    return json;
  }

  /// Returns a new [RegenerateObjectStorageKeys201ResponseS3Credentials] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static RegenerateObjectStorageKeys201ResponseS3Credentials? fromJson(
      dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      assert(() {
        requiredKeys.forEach((key) {
          assert(json.containsKey(key),
              'Required key "RegenerateObjectStorageKeys201ResponseS3Credentials[$key]" is missing from JSON.');
          assert(json[key] != null,
              'Required key "RegenerateObjectStorageKeys201ResponseS3Credentials[$key]" has a null value in JSON.');
        });
        return true;
      }());

      return RegenerateObjectStorageKeys201ResponseS3Credentials(
        s3Hostname: mapValueOfType<String>(json, r's3_hostname'),
        s3AccessKey: mapValueOfType<String>(json, r's3_access_key'),
        s3SecretKey: mapValueOfType<String>(json, r's3_secret_key'),
      );
    }
    return null;
  }

  static List<RegenerateObjectStorageKeys201ResponseS3Credentials> listFromJson(
    dynamic json, {
    bool growable = false,
  }) {
    final result = <RegenerateObjectStorageKeys201ResponseS3Credentials>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value =
            RegenerateObjectStorageKeys201ResponseS3Credentials.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, RegenerateObjectStorageKeys201ResponseS3Credentials>
      mapFromJson(dynamic json) {
    final map = <String, RegenerateObjectStorageKeys201ResponseS3Credentials>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value =
            RegenerateObjectStorageKeys201ResponseS3Credentials.fromJson(
                entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of RegenerateObjectStorageKeys201ResponseS3Credentials-objects as value to a dart map
  static Map<String, List<RegenerateObjectStorageKeys201ResponseS3Credentials>>
      mapListFromJson(
    dynamic json, {
    bool growable = false,
  }) {
    final map =
        <String, List<RegenerateObjectStorageKeys201ResponseS3Credentials>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] =
            RegenerateObjectStorageKeys201ResponseS3Credentials.listFromJson(
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
