//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of openapi.api;

class VpcAttachmentIp {
  /// Returns a new [VpcAttachmentIp] instance.
  VpcAttachmentIp({
    this.v4,
  });

  /// The ipv4 of this VPC Attachment.
  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  String? v4;

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is VpcAttachmentIp && other.v4 == v4;

  @override
  int get hashCode =>
      // ignore: unnecessary_parenthesis
      (v4 == null ? 0 : v4!.hashCode);

  @override
  String toString() => 'VpcAttachmentIp[v4=$v4]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
    if (this.v4 != null) {
      json[r'v4'] = this.v4;
    } else {
      json[r'v4'] = null;
    }
    return json;
  }

  /// Returns a new [VpcAttachmentIp] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static VpcAttachmentIp? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      assert(() {
        requiredKeys.forEach((key) {
          assert(json.containsKey(key),
              'Required key "VpcAttachmentIp[$key]" is missing from JSON.');
          assert(json[key] != null,
              'Required key "VpcAttachmentIp[$key]" has a null value in JSON.');
        });
        return true;
      }());

      return VpcAttachmentIp(
        v4: mapValueOfType<String>(json, r'v4'),
      );
    }
    return null;
  }

  static List<VpcAttachmentIp> listFromJson(
    dynamic json, {
    bool growable = false,
  }) {
    final result = <VpcAttachmentIp>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = VpcAttachmentIp.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, VpcAttachmentIp> mapFromJson(dynamic json) {
    final map = <String, VpcAttachmentIp>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = VpcAttachmentIp.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of VpcAttachmentIp-objects as value to a dart map
  static Map<String, List<VpcAttachmentIp>> mapListFromJson(
    dynamic json, {
    bool growable = false,
  }) {
    final map = <String, List<VpcAttachmentIp>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = VpcAttachmentIp.listFromJson(
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
