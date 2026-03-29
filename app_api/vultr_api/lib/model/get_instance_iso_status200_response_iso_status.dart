//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of openapi.api;

class GetInstanceIsoStatus200ResponseIsoStatus {
  /// Returns a new [GetInstanceIsoStatus200ResponseIsoStatus] instance.
  GetInstanceIsoStatus200ResponseIsoStatus({
    this.isoId,
    this.state,
  });

  /// The [ISO id](#operation/list-isos).
  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  String? isoId;

  /// The status of this ISO. * ready * attached
  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  String? state;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is GetInstanceIsoStatus200ResponseIsoStatus &&
          other.isoId == isoId &&
          other.state == state;

  @override
  int get hashCode =>
      // ignore: unnecessary_parenthesis
      (isoId == null ? 0 : isoId!.hashCode) +
      (state == null ? 0 : state!.hashCode);

  @override
  String toString() =>
      'GetInstanceIsoStatus200ResponseIsoStatus[isoId=$isoId, state=$state]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
    if (this.isoId != null) {
      json[r'iso_id'] = this.isoId;
    } else {
      json[r'iso_id'] = null;
    }
    if (this.state != null) {
      json[r'state'] = this.state;
    } else {
      json[r'state'] = null;
    }
    return json;
  }

  /// Returns a new [GetInstanceIsoStatus200ResponseIsoStatus] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static GetInstanceIsoStatus200ResponseIsoStatus? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      assert(() {
        requiredKeys.forEach((key) {
          assert(json.containsKey(key),
              'Required key "GetInstanceIsoStatus200ResponseIsoStatus[$key]" is missing from JSON.');
          assert(json[key] != null,
              'Required key "GetInstanceIsoStatus200ResponseIsoStatus[$key]" has a null value in JSON.');
        });
        return true;
      }());

      return GetInstanceIsoStatus200ResponseIsoStatus(
        isoId: mapValueOfType<String>(json, r'iso_id'),
        state: mapValueOfType<String>(json, r'state'),
      );
    }
    return null;
  }

  static List<GetInstanceIsoStatus200ResponseIsoStatus> listFromJson(
    dynamic json, {
    bool growable = false,
  }) {
    final result = <GetInstanceIsoStatus200ResponseIsoStatus>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = GetInstanceIsoStatus200ResponseIsoStatus.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, GetInstanceIsoStatus200ResponseIsoStatus> mapFromJson(
      dynamic json) {
    final map = <String, GetInstanceIsoStatus200ResponseIsoStatus>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value =
            GetInstanceIsoStatus200ResponseIsoStatus.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of GetInstanceIsoStatus200ResponseIsoStatus-objects as value to a dart map
  static Map<String, List<GetInstanceIsoStatus200ResponseIsoStatus>>
      mapListFromJson(
    dynamic json, {
    bool growable = false,
  }) {
    final map = <String, List<GetInstanceIsoStatus200ResponseIsoStatus>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = GetInstanceIsoStatus200ResponseIsoStatus.listFromJson(
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
