//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of openapi.api;

class AttachBlockRequest {
  /// Returns a new [AttachBlockRequest] instance.
  AttachBlockRequest({
    required this.instanceId,
    this.live,
  });

  /// Attach the Block Storage to this [Instance id](#operation/list-instances).
  String instanceId;

  /// Attach Block Storage without restarting the Instance.  |   | Value | Description | | - | ----- | ----------- | |   | true | Attach live, do not restart the instance. | |   | false | Restart the instance and attach the Block Storage. |
  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  bool? live;

  @override
  bool operator ==(Object other) => identical(this, other) || other is AttachBlockRequest &&
    other.instanceId == instanceId &&
    other.live == live;

  @override
  int get hashCode =>
    // ignore: unnecessary_parenthesis
    (instanceId.hashCode) +
    (live == null ? 0 : live!.hashCode);

  @override
  String toString() => 'AttachBlockRequest[instanceId=$instanceId, live=$live]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
      json[r'instance_id'] = this.instanceId;
    if (this.live != null) {
      json[r'live'] = this.live;
    } else {
      json[r'live'] = null;
    }
    return json;
  }

  /// Returns a new [AttachBlockRequest] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static AttachBlockRequest? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      assert(() {
        requiredKeys.forEach((key) {
          assert(json.containsKey(key), 'Required key "AttachBlockRequest[$key]" is missing from JSON.');
          assert(json[key] != null, 'Required key "AttachBlockRequest[$key]" has a null value in JSON.');
        });
        return true;
      }());

      return AttachBlockRequest(
        instanceId: mapValueOfType<String>(json, r'instance_id')!,
        live: mapValueOfType<bool>(json, r'live'),
      );
    }
    return null;
  }

  static List<AttachBlockRequest> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <AttachBlockRequest>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = AttachBlockRequest.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, AttachBlockRequest> mapFromJson(dynamic json) {
    final map = <String, AttachBlockRequest>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = AttachBlockRequest.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of AttachBlockRequest-objects as value to a dart map
  static Map<String, List<AttachBlockRequest>> mapListFromJson(dynamic json, {bool growable = false,}) {
    final map = <String, List<AttachBlockRequest>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = AttachBlockRequest.listFromJson(entry.value, growable: growable,);
      }
    }
    return map;
  }

  /// The list of required keys that must be present in a JSON.
  static const requiredKeys = <String>{
    'instance_id',
  };
}

