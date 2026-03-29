//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of openapi.api;

class UploadendpointInputs {
  /// Returns a new [UploadendpointInputs] instance.
  UploadendpointInputs({
    this.acl,
    this.key,
    this.xAmzCredential,
    this.xAmzAlgorithm,
    this.policy,
    this.xAmzSignature,
  });

  /// The access control list rule assigned to requst.  Include this in the upload request from data
  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  String? acl;

  /// The key used to upload the file.  Include this in the upload request from data.
  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  String? key;

  /// The credentials linked to the presigned request.  Include this in the upload request from data
  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  String? xAmzCredential;

  /// The algorithm that was used to create the request signature.  Include this in the upload request from data
  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  String? xAmzAlgorithm;

  /// The encrypted policy linked to the presigned request.  Include this in the upload request from data
  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  String? policy;

  /// The signature of the presigned request.  Include this in the upload request from data
  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  String? xAmzSignature;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UploadendpointInputs &&
          other.acl == acl &&
          other.key == key &&
          other.xAmzCredential == xAmzCredential &&
          other.xAmzAlgorithm == xAmzAlgorithm &&
          other.policy == policy &&
          other.xAmzSignature == xAmzSignature;

  @override
  int get hashCode =>
      // ignore: unnecessary_parenthesis
      (acl == null ? 0 : acl!.hashCode) +
      (key == null ? 0 : key!.hashCode) +
      (xAmzCredential == null ? 0 : xAmzCredential!.hashCode) +
      (xAmzAlgorithm == null ? 0 : xAmzAlgorithm!.hashCode) +
      (policy == null ? 0 : policy!.hashCode) +
      (xAmzSignature == null ? 0 : xAmzSignature!.hashCode);

  @override
  String toString() =>
      'UploadendpointInputs[acl=$acl, key=$key, xAmzCredential=$xAmzCredential, xAmzAlgorithm=$xAmzAlgorithm, policy=$policy, xAmzSignature=$xAmzSignature]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
    if (this.acl != null) {
      json[r'acl'] = this.acl;
    } else {
      json[r'acl'] = null;
    }
    if (this.key != null) {
      json[r'key'] = this.key;
    } else {
      json[r'key'] = null;
    }
    if (this.xAmzCredential != null) {
      json[r'X-Amz-Credential'] = this.xAmzCredential;
    } else {
      json[r'X-Amz-Credential'] = null;
    }
    if (this.xAmzAlgorithm != null) {
      json[r'X-Amz-Algorithm'] = this.xAmzAlgorithm;
    } else {
      json[r'X-Amz-Algorithm'] = null;
    }
    if (this.policy != null) {
      json[r'Policy'] = this.policy;
    } else {
      json[r'Policy'] = null;
    }
    if (this.xAmzSignature != null) {
      json[r'X-Amz-Signature'] = this.xAmzSignature;
    } else {
      json[r'X-Amz-Signature'] = null;
    }
    return json;
  }

  /// Returns a new [UploadendpointInputs] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static UploadendpointInputs? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      assert(() {
        requiredKeys.forEach((key) {
          assert(json.containsKey(key),
              'Required key "UploadendpointInputs[$key]" is missing from JSON.');
          assert(json[key] != null,
              'Required key "UploadendpointInputs[$key]" has a null value in JSON.');
        });
        return true;
      }());

      return UploadendpointInputs(
        acl: mapValueOfType<String>(json, r'acl'),
        key: mapValueOfType<String>(json, r'key'),
        xAmzCredential: mapValueOfType<String>(json, r'X-Amz-Credential'),
        xAmzAlgorithm: mapValueOfType<String>(json, r'X-Amz-Algorithm'),
        policy: mapValueOfType<String>(json, r'Policy'),
        xAmzSignature: mapValueOfType<String>(json, r'X-Amz-Signature'),
      );
    }
    return null;
  }

  static List<UploadendpointInputs> listFromJson(
    dynamic json, {
    bool growable = false,
  }) {
    final result = <UploadendpointInputs>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = UploadendpointInputs.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, UploadendpointInputs> mapFromJson(dynamic json) {
    final map = <String, UploadendpointInputs>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = UploadendpointInputs.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of UploadendpointInputs-objects as value to a dart map
  static Map<String, List<UploadendpointInputs>> mapListFromJson(
    dynamic json, {
    bool growable = false,
  }) {
    final map = <String, List<UploadendpointInputs>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = UploadendpointInputs.listFromJson(
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
