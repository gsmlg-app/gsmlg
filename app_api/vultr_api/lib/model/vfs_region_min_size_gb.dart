//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of openapi.api;

class VfsRegionMinSizeGb {
  /// Returns a new [VfsRegionMinSizeGb] instance.
  VfsRegionMinSizeGb({
    this.nvme,
    this.hdd,
  });

  /// Minimum size in GB for NVMe storage
  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  int? nvme;

  /// Minimum size in GB for HDD storage
  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  int? hdd;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is VfsRegionMinSizeGb && other.nvme == nvme && other.hdd == hdd;

  @override
  int get hashCode =>
      // ignore: unnecessary_parenthesis
      (nvme == null ? 0 : nvme!.hashCode) + (hdd == null ? 0 : hdd!.hashCode);

  @override
  String toString() => 'VfsRegionMinSizeGb[nvme=$nvme, hdd=$hdd]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
    if (this.nvme != null) {
      json[r'nvme'] = this.nvme;
    } else {
      json[r'nvme'] = null;
    }
    if (this.hdd != null) {
      json[r'hdd'] = this.hdd;
    } else {
      json[r'hdd'] = null;
    }
    return json;
  }

  /// Returns a new [VfsRegionMinSizeGb] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static VfsRegionMinSizeGb? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      assert(() {
        requiredKeys.forEach((key) {
          assert(json.containsKey(key),
              'Required key "VfsRegionMinSizeGb[$key]" is missing from JSON.');
          assert(json[key] != null,
              'Required key "VfsRegionMinSizeGb[$key]" has a null value in JSON.');
        });
        return true;
      }());

      return VfsRegionMinSizeGb(
        nvme: mapValueOfType<int>(json, r'nvme'),
        hdd: mapValueOfType<int>(json, r'hdd'),
      );
    }
    return null;
  }

  static List<VfsRegionMinSizeGb> listFromJson(
    dynamic json, {
    bool growable = false,
  }) {
    final result = <VfsRegionMinSizeGb>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = VfsRegionMinSizeGb.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, VfsRegionMinSizeGb> mapFromJson(dynamic json) {
    final map = <String, VfsRegionMinSizeGb>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = VfsRegionMinSizeGb.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of VfsRegionMinSizeGb-objects as value to a dart map
  static Map<String, List<VfsRegionMinSizeGb>> mapListFromJson(
    dynamic json, {
    bool growable = false,
  }) {
    final map = <String, List<VfsRegionMinSizeGb>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = VfsRegionMinSizeGb.listFromJson(
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
