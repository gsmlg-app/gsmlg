//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of openapi.api;

class VfsAttachment {
  /// Returns a new [VfsAttachment] instance.
  VfsAttachment({
    this.state,
    this.vfsId,
    this.targetId,
    this.mountTag,
  });

  /// Current state of the attachment
  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  String? state;

  /// ID of the VFS subscription
  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  String? vfsId;

  /// ID of the target resource
  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  String? targetId;

  /// Mount tag of the VFS subscription
  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  int? mountTag;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is VfsAttachment &&
          other.state == state &&
          other.vfsId == vfsId &&
          other.targetId == targetId &&
          other.mountTag == mountTag;

  @override
  int get hashCode =>
      // ignore: unnecessary_parenthesis
      (state == null ? 0 : state!.hashCode) +
      (vfsId == null ? 0 : vfsId!.hashCode) +
      (targetId == null ? 0 : targetId!.hashCode) +
      (mountTag == null ? 0 : mountTag!.hashCode);

  @override
  String toString() =>
      'VfsAttachment[state=$state, vfsId=$vfsId, targetId=$targetId, mountTag=$mountTag]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
    if (this.state != null) {
      json[r'state'] = this.state;
    } else {
      json[r'state'] = null;
    }
    if (this.vfsId != null) {
      json[r'vfs_id'] = this.vfsId;
    } else {
      json[r'vfs_id'] = null;
    }
    if (this.targetId != null) {
      json[r'target_id'] = this.targetId;
    } else {
      json[r'target_id'] = null;
    }
    if (this.mountTag != null) {
      json[r'mount_tag'] = this.mountTag;
    } else {
      json[r'mount_tag'] = null;
    }
    return json;
  }

  /// Returns a new [VfsAttachment] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static VfsAttachment? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      assert(() {
        requiredKeys.forEach((key) {
          assert(json.containsKey(key),
              'Required key "VfsAttachment[$key]" is missing from JSON.');
          assert(json[key] != null,
              'Required key "VfsAttachment[$key]" has a null value in JSON.');
        });
        return true;
      }());

      return VfsAttachment(
        state: mapValueOfType<String>(json, r'state'),
        vfsId: mapValueOfType<String>(json, r'vfs_id'),
        targetId: mapValueOfType<String>(json, r'target_id'),
        mountTag: mapValueOfType<int>(json, r'mount_tag'),
      );
    }
    return null;
  }

  static List<VfsAttachment> listFromJson(
    dynamic json, {
    bool growable = false,
  }) {
    final result = <VfsAttachment>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = VfsAttachment.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, VfsAttachment> mapFromJson(dynamic json) {
    final map = <String, VfsAttachment>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = VfsAttachment.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of VfsAttachment-objects as value to a dart map
  static Map<String, List<VfsAttachment>> mapListFromJson(
    dynamic json, {
    bool growable = false,
  }) {
    final map = <String, List<VfsAttachment>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = VfsAttachment.listFromJson(
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
