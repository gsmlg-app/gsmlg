//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of openapi.api;

class StorageGatewayExport {
  /// Returns a new [StorageGatewayExport] instance.
  StorageGatewayExport({
    this.label,
    this.vfsUuid,
    this.pseudoRootPath,
    this.allowedIps = const [],
  });

  /// A meaningful name for this export
  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  String? label;

  /// Associated VFS uuid
  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  String? vfsUuid;

  /// Pseudo root path
  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  String? pseudoRootPath;

  List<String> allowedIps;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is StorageGatewayExport &&
          other.label == label &&
          other.vfsUuid == vfsUuid &&
          other.pseudoRootPath == pseudoRootPath &&
          _deepEquality.equals(other.allowedIps, allowedIps);

  @override
  int get hashCode =>
      // ignore: unnecessary_parenthesis
      (label == null ? 0 : label!.hashCode) +
      (vfsUuid == null ? 0 : vfsUuid!.hashCode) +
      (pseudoRootPath == null ? 0 : pseudoRootPath!.hashCode) +
      (allowedIps.hashCode);

  @override
  String toString() =>
      'StorageGatewayExport[label=$label, vfsUuid=$vfsUuid, pseudoRootPath=$pseudoRootPath, allowedIps=$allowedIps]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
    if (this.label != null) {
      json[r'label'] = this.label;
    } else {
      json[r'label'] = null;
    }
    if (this.vfsUuid != null) {
      json[r'vfs_uuid'] = this.vfsUuid;
    } else {
      json[r'vfs_uuid'] = null;
    }
    if (this.pseudoRootPath != null) {
      json[r'pseudo_root_path'] = this.pseudoRootPath;
    } else {
      json[r'pseudo_root_path'] = null;
    }
    json[r'allowed_ips'] = this.allowedIps;
    return json;
  }

  /// Returns a new [StorageGatewayExport] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static StorageGatewayExport? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      assert(() {
        requiredKeys.forEach((key) {
          assert(json.containsKey(key),
              'Required key "StorageGatewayExport[$key]" is missing from JSON.');
          assert(json[key] != null,
              'Required key "StorageGatewayExport[$key]" has a null value in JSON.');
        });
        return true;
      }());

      return StorageGatewayExport(
        label: mapValueOfType<String>(json, r'label'),
        vfsUuid: mapValueOfType<String>(json, r'vfs_uuid'),
        pseudoRootPath: mapValueOfType<String>(json, r'pseudo_root_path'),
        allowedIps: json[r'allowed_ips'] is Iterable
            ? (json[r'allowed_ips'] as Iterable)
                .cast<String>()
                .toList(growable: false)
            : const [],
      );
    }
    return null;
  }

  static List<StorageGatewayExport> listFromJson(
    dynamic json, {
    bool growable = false,
  }) {
    final result = <StorageGatewayExport>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = StorageGatewayExport.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, StorageGatewayExport> mapFromJson(dynamic json) {
    final map = <String, StorageGatewayExport>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = StorageGatewayExport.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of StorageGatewayExport-objects as value to a dart map
  static Map<String, List<StorageGatewayExport>> mapListFromJson(
    dynamic json, {
    bool growable = false,
  }) {
    final map = <String, List<StorageGatewayExport>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = StorageGatewayExport.listFromJson(
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
