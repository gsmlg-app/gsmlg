//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of openapi.api;

class VfsRegionPricePerGb {
  /// Returns a new [VfsRegionPricePerGb] instance.
  VfsRegionPricePerGb({
    this.nvme,
    this.hdd,
  });

  /// Price per GB for NVMe storage
  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  double? nvme;

  /// Price per GB for HDD storage
  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  double? hdd;

  @override
  bool operator ==(Object other) => identical(this, other) || other is VfsRegionPricePerGb &&
    other.nvme == nvme &&
    other.hdd == hdd;

  @override
  int get hashCode =>
    // ignore: unnecessary_parenthesis
    (nvme == null ? 0 : nvme!.hashCode) +
    (hdd == null ? 0 : hdd!.hashCode);

  @override
  String toString() => 'VfsRegionPricePerGb[nvme=$nvme, hdd=$hdd]';

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

  /// Returns a new [VfsRegionPricePerGb] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static VfsRegionPricePerGb? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      assert(() {
        requiredKeys.forEach((key) {
          assert(json.containsKey(key), 'Required key "VfsRegionPricePerGb[$key]" is missing from JSON.');
          assert(json[key] != null, 'Required key "VfsRegionPricePerGb[$key]" has a null value in JSON.');
        });
        return true;
      }());

      return VfsRegionPricePerGb(
        nvme: mapValueOfType<double>(json, r'nvme'),
        hdd: mapValueOfType<double>(json, r'hdd'),
      );
    }
    return null;
  }

  static List<VfsRegionPricePerGb> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <VfsRegionPricePerGb>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = VfsRegionPricePerGb.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, VfsRegionPricePerGb> mapFromJson(dynamic json) {
    final map = <String, VfsRegionPricePerGb>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = VfsRegionPricePerGb.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of VfsRegionPricePerGb-objects as value to a dart map
  static Map<String, List<VfsRegionPricePerGb>> mapListFromJson(dynamic json, {bool growable = false,}) {
    final map = <String, List<VfsRegionPricePerGb>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = VfsRegionPricePerGb.listFromJson(entry.value, growable: growable,);
      }
    }
    return map;
  }

  /// The list of required keys that must be present in a JSON.
  static const requiredKeys = <String>{
  };
}

