//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of openapi.api;

class Iso {
  /// Returns a new [Iso] instance.
  Iso({
    this.id,
    this.dateCreated,
    this.filename,
    this.size,
    this.md5sum,
    this.sha512sum,
    this.status,
  });

  /// A unique ID for the ISO.
  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  String? id;

  /// Date the ISO was created.
  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  String? dateCreated;

  /// The ISO filename.
  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  String? filename;

  /// The ISO size in KB.
  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  int? size;

  /// The calculated md5sum of the ISO.
  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  String? md5sum;

  /// The calculated sha512sum of the ISO.
  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  String? sha512sum;

  /// The current status of the ISO.  * complete * pending
  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  String? status;

  @override
  bool operator ==(Object other) => identical(this, other) || other is Iso &&
    other.id == id &&
    other.dateCreated == dateCreated &&
    other.filename == filename &&
    other.size == size &&
    other.md5sum == md5sum &&
    other.sha512sum == sha512sum &&
    other.status == status;

  @override
  int get hashCode =>
    // ignore: unnecessary_parenthesis
    (id == null ? 0 : id!.hashCode) +
    (dateCreated == null ? 0 : dateCreated!.hashCode) +
    (filename == null ? 0 : filename!.hashCode) +
    (size == null ? 0 : size!.hashCode) +
    (md5sum == null ? 0 : md5sum!.hashCode) +
    (sha512sum == null ? 0 : sha512sum!.hashCode) +
    (status == null ? 0 : status!.hashCode);

  @override
  String toString() => 'Iso[id=$id, dateCreated=$dateCreated, filename=$filename, size=$size, md5sum=$md5sum, sha512sum=$sha512sum, status=$status]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
    if (this.id != null) {
      json[r'id'] = this.id;
    } else {
      json[r'id'] = null;
    }
    if (this.dateCreated != null) {
      json[r'date_created'] = this.dateCreated;
    } else {
      json[r'date_created'] = null;
    }
    if (this.filename != null) {
      json[r'filename'] = this.filename;
    } else {
      json[r'filename'] = null;
    }
    if (this.size != null) {
      json[r'size'] = this.size;
    } else {
      json[r'size'] = null;
    }
    if (this.md5sum != null) {
      json[r'md5sum'] = this.md5sum;
    } else {
      json[r'md5sum'] = null;
    }
    if (this.sha512sum != null) {
      json[r'sha512sum'] = this.sha512sum;
    } else {
      json[r'sha512sum'] = null;
    }
    if (this.status != null) {
      json[r'status'] = this.status;
    } else {
      json[r'status'] = null;
    }
    return json;
  }

  /// Returns a new [Iso] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static Iso? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      assert(() {
        requiredKeys.forEach((key) {
          assert(json.containsKey(key), 'Required key "Iso[$key]" is missing from JSON.');
          assert(json[key] != null, 'Required key "Iso[$key]" has a null value in JSON.');
        });
        return true;
      }());

      return Iso(
        id: mapValueOfType<String>(json, r'id'),
        dateCreated: mapValueOfType<String>(json, r'date_created'),
        filename: mapValueOfType<String>(json, r'filename'),
        size: mapValueOfType<int>(json, r'size'),
        md5sum: mapValueOfType<String>(json, r'md5sum'),
        sha512sum: mapValueOfType<String>(json, r'sha512sum'),
        status: mapValueOfType<String>(json, r'status'),
      );
    }
    return null;
  }

  static List<Iso> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <Iso>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = Iso.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, Iso> mapFromJson(dynamic json) {
    final map = <String, Iso>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = Iso.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of Iso-objects as value to a dart map
  static Map<String, List<Iso>> mapListFromJson(dynamic json, {bool growable = false,}) {
    final map = <String, List<Iso>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = Iso.listFromJson(entry.value, growable: growable,);
      }
    }
    return map;
  }

  /// The list of required keys that must be present in a JSON.
  static const requiredKeys = <String>{
  };
}

