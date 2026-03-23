//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of openapi.api;

class CreateBlockRequest {
  /// Returns a new [CreateBlockRequest] instance.
  CreateBlockRequest({
    required this.region,
    required this.sizeGb,
    this.label,
    this.blockType,
  });

  /// The [Region id](#operation/list-regions) where the Block Storage will be created.
  String region;

  /// Size in GB may range between 10 and 40000, depending on the `block_type`.
  int sizeGb;

  /// The user-supplied label.
  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  String? label;

  /// An optional parameter, that determines on the type of block storage volume that will be created. Soon to become a required parameter.  * `high_perf` from 10GB to 10,000GB * `storage_opt` from 40GB to 40,000GB
  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  String? blockType;

  @override
  bool operator ==(Object other) => identical(this, other) || other is CreateBlockRequest &&
    other.region == region &&
    other.sizeGb == sizeGb &&
    other.label == label &&
    other.blockType == blockType;

  @override
  int get hashCode =>
    // ignore: unnecessary_parenthesis
    (region.hashCode) +
    (sizeGb.hashCode) +
    (label == null ? 0 : label!.hashCode) +
    (blockType == null ? 0 : blockType!.hashCode);

  @override
  String toString() => 'CreateBlockRequest[region=$region, sizeGb=$sizeGb, label=$label, blockType=$blockType]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
      json[r'region'] = this.region;
      json[r'size_gb'] = this.sizeGb;
    if (this.label != null) {
      json[r'label'] = this.label;
    } else {
      json[r'label'] = null;
    }
    if (this.blockType != null) {
      json[r'block_type'] = this.blockType;
    } else {
      json[r'block_type'] = null;
    }
    return json;
  }

  /// Returns a new [CreateBlockRequest] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static CreateBlockRequest? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      assert(() {
        requiredKeys.forEach((key) {
          assert(json.containsKey(key), 'Required key "CreateBlockRequest[$key]" is missing from JSON.');
          assert(json[key] != null, 'Required key "CreateBlockRequest[$key]" has a null value in JSON.');
        });
        return true;
      }());

      return CreateBlockRequest(
        region: mapValueOfType<String>(json, r'region')!,
        sizeGb: mapValueOfType<int>(json, r'size_gb')!,
        label: mapValueOfType<String>(json, r'label'),
        blockType: mapValueOfType<String>(json, r'block_type'),
      );
    }
    return null;
  }

  static List<CreateBlockRequest> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <CreateBlockRequest>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = CreateBlockRequest.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, CreateBlockRequest> mapFromJson(dynamic json) {
    final map = <String, CreateBlockRequest>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = CreateBlockRequest.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of CreateBlockRequest-objects as value to a dart map
  static Map<String, List<CreateBlockRequest>> mapListFromJson(dynamic json, {bool growable = false,}) {
    final map = <String, List<CreateBlockRequest>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = CreateBlockRequest.listFromJson(entry.value, growable: growable,);
      }
    }
    return map;
  }

  /// The list of required keys that must be present in a JSON.
  static const requiredKeys = <String>{
    'region',
    'size_gb',
  };
}

