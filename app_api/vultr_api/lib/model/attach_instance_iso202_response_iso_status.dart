//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of openapi.api;

class AttachInstanceIso202ResponseIsoStatus {
  /// Returns a new [AttachInstanceIso202ResponseIsoStatus] instance.
  AttachInstanceIso202ResponseIsoStatus({
    this.state,
    this.isoId,
  });

  /// State of the ISO  * ismounting
  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  String? state;

  /// The [ISO id](#operation/list-isos) being attached.
  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  String? isoId;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AttachInstanceIso202ResponseIsoStatus &&
          other.state == state &&
          other.isoId == isoId;

  @override
  int get hashCode =>
      // ignore: unnecessary_parenthesis
      (state == null ? 0 : state!.hashCode) +
      (isoId == null ? 0 : isoId!.hashCode);

  @override
  String toString() =>
      'AttachInstanceIso202ResponseIsoStatus[state=$state, isoId=$isoId]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
    if (this.state != null) {
      json[r'state'] = this.state;
    } else {
      json[r'state'] = null;
    }
    if (this.isoId != null) {
      json[r'iso_id'] = this.isoId;
    } else {
      json[r'iso_id'] = null;
    }
    return json;
  }

  /// Returns a new [AttachInstanceIso202ResponseIsoStatus] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static AttachInstanceIso202ResponseIsoStatus? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      assert(() {
        requiredKeys.forEach((key) {
          assert(json.containsKey(key),
              'Required key "AttachInstanceIso202ResponseIsoStatus[$key]" is missing from JSON.');
          assert(json[key] != null,
              'Required key "AttachInstanceIso202ResponseIsoStatus[$key]" has a null value in JSON.');
        });
        return true;
      }());

      return AttachInstanceIso202ResponseIsoStatus(
        state: mapValueOfType<String>(json, r'state'),
        isoId: mapValueOfType<String>(json, r'iso_id'),
      );
    }
    return null;
  }

  static List<AttachInstanceIso202ResponseIsoStatus> listFromJson(
    dynamic json, {
    bool growable = false,
  }) {
    final result = <AttachInstanceIso202ResponseIsoStatus>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = AttachInstanceIso202ResponseIsoStatus.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, AttachInstanceIso202ResponseIsoStatus> mapFromJson(
      dynamic json) {
    final map = <String, AttachInstanceIso202ResponseIsoStatus>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value =
            AttachInstanceIso202ResponseIsoStatus.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of AttachInstanceIso202ResponseIsoStatus-objects as value to a dart map
  static Map<String, List<AttachInstanceIso202ResponseIsoStatus>>
      mapListFromJson(
    dynamic json, {
    bool growable = false,
  }) {
    final map = <String, List<AttachInstanceIso202ResponseIsoStatus>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = AttachInstanceIso202ResponseIsoStatus.listFromJson(
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
