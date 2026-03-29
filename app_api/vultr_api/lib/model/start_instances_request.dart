//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of openapi.api;

class StartInstancesRequest {
  /// Returns a new [StartInstancesRequest] instance.
  StartInstancesRequest({
    this.instanceIds = const [],
  });

  /// The [Instance IDs](#operation/list-instances) to start.
  List<String> instanceIds;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is StartInstancesRequest &&
          _deepEquality.equals(other.instanceIds, instanceIds);

  @override
  int get hashCode =>
      // ignore: unnecessary_parenthesis
      (instanceIds.hashCode);

  @override
  String toString() => 'StartInstancesRequest[instanceIds=$instanceIds]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
    json[r'instance_ids'] = this.instanceIds;
    return json;
  }

  /// Returns a new [StartInstancesRequest] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static StartInstancesRequest? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      assert(() {
        requiredKeys.forEach((key) {
          assert(json.containsKey(key),
              'Required key "StartInstancesRequest[$key]" is missing from JSON.');
          assert(json[key] != null,
              'Required key "StartInstancesRequest[$key]" has a null value in JSON.');
        });
        return true;
      }());

      return StartInstancesRequest(
        instanceIds: json[r'instance_ids'] is Iterable
            ? (json[r'instance_ids'] as Iterable)
                .cast<String>()
                .toList(growable: false)
            : const [],
      );
    }
    return null;
  }

  static List<StartInstancesRequest> listFromJson(
    dynamic json, {
    bool growable = false,
  }) {
    final result = <StartInstancesRequest>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = StartInstancesRequest.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, StartInstancesRequest> mapFromJson(dynamic json) {
    final map = <String, StartInstancesRequest>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = StartInstancesRequest.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of StartInstancesRequest-objects as value to a dart map
  static Map<String, List<StartInstancesRequest>> mapListFromJson(
    dynamic json, {
    bool growable = false,
  }) {
    final map = <String, List<StartInstancesRequest>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = StartInstancesRequest.listFromJson(
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
