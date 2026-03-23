//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of openapi.api;

class Backup {
  /// Returns a new [Backup] instance.
  Backup({
    this.id,
    this.dateCreated,
    this.description,
    this.size,
    this.status,
    this.osId,
    this.appId,
  });

  /// A unique ID for the backup.
  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  String? id;

  /// The date the backup was created.
  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  String? dateCreated;

  /// The user-supplied description of this backup.
  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  String? description;

  /// The size of the backup in Bytes.
  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  int? size;

  /// The Backup status.  * complete * pending
  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  String? status;

  /// The [Operating System id](#operation/list-os) for this Backup.
  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  int? osId;

  /// The [Application id](#operation/list-applications) for this Backup.
  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  int? appId;

  @override
  bool operator ==(Object other) => identical(this, other) || other is Backup &&
    other.id == id &&
    other.dateCreated == dateCreated &&
    other.description == description &&
    other.size == size &&
    other.status == status &&
    other.osId == osId &&
    other.appId == appId;

  @override
  int get hashCode =>
    // ignore: unnecessary_parenthesis
    (id == null ? 0 : id!.hashCode) +
    (dateCreated == null ? 0 : dateCreated!.hashCode) +
    (description == null ? 0 : description!.hashCode) +
    (size == null ? 0 : size!.hashCode) +
    (status == null ? 0 : status!.hashCode) +
    (osId == null ? 0 : osId!.hashCode) +
    (appId == null ? 0 : appId!.hashCode);

  @override
  String toString() => 'Backup[id=$id, dateCreated=$dateCreated, description=$description, size=$size, status=$status, osId=$osId, appId=$appId]';

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
    if (this.description != null) {
      json[r'description'] = this.description;
    } else {
      json[r'description'] = null;
    }
    if (this.size != null) {
      json[r'size'] = this.size;
    } else {
      json[r'size'] = null;
    }
    if (this.status != null) {
      json[r'status'] = this.status;
    } else {
      json[r'status'] = null;
    }
    if (this.osId != null) {
      json[r'os_id'] = this.osId;
    } else {
      json[r'os_id'] = null;
    }
    if (this.appId != null) {
      json[r'app_id'] = this.appId;
    } else {
      json[r'app_id'] = null;
    }
    return json;
  }

  /// Returns a new [Backup] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static Backup? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      assert(() {
        requiredKeys.forEach((key) {
          assert(json.containsKey(key), 'Required key "Backup[$key]" is missing from JSON.');
          assert(json[key] != null, 'Required key "Backup[$key]" has a null value in JSON.');
        });
        return true;
      }());

      return Backup(
        id: mapValueOfType<String>(json, r'id'),
        dateCreated: mapValueOfType<String>(json, r'date_created'),
        description: mapValueOfType<String>(json, r'description'),
        size: mapValueOfType<int>(json, r'size'),
        status: mapValueOfType<String>(json, r'status'),
        osId: mapValueOfType<int>(json, r'os_id'),
        appId: mapValueOfType<int>(json, r'app_id'),
      );
    }
    return null;
  }

  static List<Backup> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <Backup>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = Backup.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, Backup> mapFromJson(dynamic json) {
    final map = <String, Backup>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = Backup.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of Backup-objects as value to a dart map
  static Map<String, List<Backup>> mapListFromJson(dynamic json, {bool growable = false,}) {
    final map = <String, List<Backup>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = Backup.listFromJson(entry.value, growable: growable,);
      }
    }
    return map;
  }

  /// The list of required keys that must be present in a JSON.
  static const requiredKeys = <String>{
  };
}

