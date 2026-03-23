//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of openapi.api;

class CreateObjectStorageRequest {
  /// Returns a new [CreateObjectStorageRequest] instance.
  CreateObjectStorageRequest({
    required this.clusterId,
    required this.tierId,
    this.label,
  });

  /// The [Cluster id](#operation/list-object-storage-clusters) where the Object Storage will be created.
  int clusterId;

  /// The [Tier id](#operation/list-object-storage-tiers) of the tier to set up for. Must be one of available tiers for the cluster.
  int tierId;

  /// The user-supplied label for this Object Storage.
  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  String? label;

  @override
  bool operator ==(Object other) => identical(this, other) || other is CreateObjectStorageRequest &&
    other.clusterId == clusterId &&
    other.tierId == tierId &&
    other.label == label;

  @override
  int get hashCode =>
    // ignore: unnecessary_parenthesis
    (clusterId.hashCode) +
    (tierId.hashCode) +
    (label == null ? 0 : label!.hashCode);

  @override
  String toString() => 'CreateObjectStorageRequest[clusterId=$clusterId, tierId=$tierId, label=$label]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
      json[r'cluster_id'] = this.clusterId;
      json[r'tier_id'] = this.tierId;
    if (this.label != null) {
      json[r'label'] = this.label;
    } else {
      json[r'label'] = null;
    }
    return json;
  }

  /// Returns a new [CreateObjectStorageRequest] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static CreateObjectStorageRequest? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      assert(() {
        requiredKeys.forEach((key) {
          assert(json.containsKey(key), 'Required key "CreateObjectStorageRequest[$key]" is missing from JSON.');
          assert(json[key] != null, 'Required key "CreateObjectStorageRequest[$key]" has a null value in JSON.');
        });
        return true;
      }());

      return CreateObjectStorageRequest(
        clusterId: mapValueOfType<int>(json, r'cluster_id')!,
        tierId: mapValueOfType<int>(json, r'tier_id')!,
        label: mapValueOfType<String>(json, r'label'),
      );
    }
    return null;
  }

  static List<CreateObjectStorageRequest> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <CreateObjectStorageRequest>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = CreateObjectStorageRequest.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, CreateObjectStorageRequest> mapFromJson(dynamic json) {
    final map = <String, CreateObjectStorageRequest>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = CreateObjectStorageRequest.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of CreateObjectStorageRequest-objects as value to a dart map
  static Map<String, List<CreateObjectStorageRequest>> mapListFromJson(dynamic json, {bool growable = false,}) {
    final map = <String, List<CreateObjectStorageRequest>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = CreateObjectStorageRequest.listFromJson(entry.value, growable: growable,);
      }
    }
    return map;
  }

  /// The list of required keys that must be present in a JSON.
  static const requiredKeys = <String>{
    'cluster_id',
    'tier_id',
  };
}

