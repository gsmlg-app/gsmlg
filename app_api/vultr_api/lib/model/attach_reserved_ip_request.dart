//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of openapi.api;

class AttachReservedIpRequest {
  /// Returns a new [AttachReservedIpRequest] instance.
  AttachReservedIpRequest({
    required this.instanceId,
  });

  /// Attach the Reserved IP to a [Compute Instance id](#operation/list-instances) or a [Bare Metal Instance id](#operation/list-baremetals).
  String instanceId;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AttachReservedIpRequest && other.instanceId == instanceId;

  @override
  int get hashCode =>
      // ignore: unnecessary_parenthesis
      (instanceId.hashCode);

  @override
  String toString() => 'AttachReservedIpRequest[instanceId=$instanceId]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
    json[r'instance_id'] = this.instanceId;
    return json;
  }

  /// Returns a new [AttachReservedIpRequest] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static AttachReservedIpRequest? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      assert(() {
        requiredKeys.forEach((key) {
          assert(json.containsKey(key),
              'Required key "AttachReservedIpRequest[$key]" is missing from JSON.');
          assert(json[key] != null,
              'Required key "AttachReservedIpRequest[$key]" has a null value in JSON.');
        });
        return true;
      }());

      return AttachReservedIpRequest(
        instanceId: mapValueOfType<String>(json, r'instance_id')!,
      );
    }
    return null;
  }

  static List<AttachReservedIpRequest> listFromJson(
    dynamic json, {
    bool growable = false,
  }) {
    final result = <AttachReservedIpRequest>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = AttachReservedIpRequest.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, AttachReservedIpRequest> mapFromJson(dynamic json) {
    final map = <String, AttachReservedIpRequest>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = AttachReservedIpRequest.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of AttachReservedIpRequest-objects as value to a dart map
  static Map<String, List<AttachReservedIpRequest>> mapListFromJson(
    dynamic json, {
    bool growable = false,
  }) {
    final map = <String, List<AttachReservedIpRequest>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = AttachReservedIpRequest.listFromJson(
          entry.value,
          growable: growable,
        );
      }
    }
    return map;
  }

  /// The list of required keys that must be present in a JSON.
  static const requiredKeys = <String>{
    'instance_id',
  };
}
