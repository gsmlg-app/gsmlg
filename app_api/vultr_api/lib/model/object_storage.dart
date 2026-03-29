//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of openapi.api;

class ObjectStorage {
  /// Returns a new [ObjectStorage] instance.
  ObjectStorage({
    this.id,
    this.dateCreated,
    this.clusterId,
    this.region,
    this.label,
    this.status,
    this.s3Hostname,
    this.s3AccessKey,
    this.s3SecretKey,
  });

  /// A unique ID for the Object Storage.
  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  String? id;

  /// Date the Object Store was created.
  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  String? dateCreated;

  /// The [Cluster id](#operation/list-object-storage-clusters).
  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  int? clusterId;

  /// The [Region id](#operation/list-regions) for this Object Storage.
  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  String? region;

  /// The user-supplied label for this Object Storage.
  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  String? label;

  /// The status of this Object Storage.  * active * pending
  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  String? status;

  /// The [Cluster hostname](#operation/list-object-storage-clusters) for this Object Storage.
  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  String? s3Hostname;

  /// The Object Storage access key.
  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  String? s3AccessKey;

  /// The Object Storage secret key.
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
      other is ObjectStorage &&
          other.id == id &&
          other.dateCreated == dateCreated &&
          other.clusterId == clusterId &&
          other.region == region &&
          other.label == label &&
          other.status == status &&
          other.s3Hostname == s3Hostname &&
          other.s3AccessKey == s3AccessKey &&
          other.s3SecretKey == s3SecretKey;

  @override
  int get hashCode =>
      // ignore: unnecessary_parenthesis
      (id == null ? 0 : id!.hashCode) +
      (dateCreated == null ? 0 : dateCreated!.hashCode) +
      (clusterId == null ? 0 : clusterId!.hashCode) +
      (region == null ? 0 : region!.hashCode) +
      (label == null ? 0 : label!.hashCode) +
      (status == null ? 0 : status!.hashCode) +
      (s3Hostname == null ? 0 : s3Hostname!.hashCode) +
      (s3AccessKey == null ? 0 : s3AccessKey!.hashCode) +
      (s3SecretKey == null ? 0 : s3SecretKey!.hashCode);

  @override
  String toString() =>
      'ObjectStorage[id=$id, dateCreated=$dateCreated, clusterId=$clusterId, region=$region, label=$label, status=$status, s3Hostname=$s3Hostname, s3AccessKey=$s3AccessKey, s3SecretKey=$s3SecretKey]';

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
    if (this.clusterId != null) {
      json[r'cluster_id'] = this.clusterId;
    } else {
      json[r'cluster_id'] = null;
    }
    if (this.region != null) {
      json[r'region'] = this.region;
    } else {
      json[r'region'] = null;
    }
    if (this.label != null) {
      json[r'label'] = this.label;
    } else {
      json[r'label'] = null;
    }
    if (this.status != null) {
      json[r'status'] = this.status;
    } else {
      json[r'status'] = null;
    }
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

  /// Returns a new [ObjectStorage] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static ObjectStorage? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      assert(() {
        requiredKeys.forEach((key) {
          assert(json.containsKey(key),
              'Required key "ObjectStorage[$key]" is missing from JSON.');
          assert(json[key] != null,
              'Required key "ObjectStorage[$key]" has a null value in JSON.');
        });
        return true;
      }());

      return ObjectStorage(
        id: mapValueOfType<String>(json, r'id'),
        dateCreated: mapValueOfType<String>(json, r'date_created'),
        clusterId: mapValueOfType<int>(json, r'cluster_id'),
        region: mapValueOfType<String>(json, r'region'),
        label: mapValueOfType<String>(json, r'label'),
        status: mapValueOfType<String>(json, r'status'),
        s3Hostname: mapValueOfType<String>(json, r's3_hostname'),
        s3AccessKey: mapValueOfType<String>(json, r's3_access_key'),
        s3SecretKey: mapValueOfType<String>(json, r's3_secret_key'),
      );
    }
    return null;
  }

  static List<ObjectStorage> listFromJson(
    dynamic json, {
    bool growable = false,
  }) {
    final result = <ObjectStorage>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = ObjectStorage.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, ObjectStorage> mapFromJson(dynamic json) {
    final map = <String, ObjectStorage>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = ObjectStorage.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of ObjectStorage-objects as value to a dart map
  static Map<String, List<ObjectStorage>> mapListFromJson(
    dynamic json, {
    bool growable = false,
  }) {
    final map = <String, List<ObjectStorage>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = ObjectStorage.listFromJson(
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
