//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of openapi.api;

class Vfs {
  /// Returns a new [Vfs] instance.
  Vfs({
    this.id,
    this.region,
    this.dateCreated,
    this.status,
    this.label,
    this.tags = const [],
    this.diskType,
    this.storageSize,
    this.storageUsed,
    this.billing,
  });

  /// Unique identifier for the VFS subscription
  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  String? id;

  /// Region identifier where the VFS is located
  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  String? region;

  /// Creation timestamp of the VFS subscription
  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  DateTime? dateCreated;

  /// Current status of the VFS subscription
  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  String? status;

  /// User-defined label for the VFS subscription
  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  String? label;

  /// List of tags associated with the VFS subscription
  List<String> tags;

  /// Type of storage disk
  VfsDiskTypeEnum? diskType;

  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  VfsStorageSize? storageSize;

  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  VfsStorageSize? storageUsed;

  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  VfsBilling? billing;

  @override
  bool operator ==(Object other) => identical(this, other) || other is Vfs &&
    other.id == id &&
    other.region == region &&
    other.dateCreated == dateCreated &&
    other.status == status &&
    other.label == label &&
    _deepEquality.equals(other.tags, tags) &&
    other.diskType == diskType &&
    other.storageSize == storageSize &&
    other.storageUsed == storageUsed &&
    other.billing == billing;

  @override
  int get hashCode =>
    // ignore: unnecessary_parenthesis
    (id == null ? 0 : id!.hashCode) +
    (region == null ? 0 : region!.hashCode) +
    (dateCreated == null ? 0 : dateCreated!.hashCode) +
    (status == null ? 0 : status!.hashCode) +
    (label == null ? 0 : label!.hashCode) +
    (tags.hashCode) +
    (diskType == null ? 0 : diskType!.hashCode) +
    (storageSize == null ? 0 : storageSize!.hashCode) +
    (storageUsed == null ? 0 : storageUsed!.hashCode) +
    (billing == null ? 0 : billing!.hashCode);

  @override
  String toString() => 'Vfs[id=$id, region=$region, dateCreated=$dateCreated, status=$status, label=$label, tags=$tags, diskType=$diskType, storageSize=$storageSize, storageUsed=$storageUsed, billing=$billing]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
    if (this.id != null) {
      json[r'id'] = this.id;
    } else {
      json[r'id'] = null;
    }
    if (this.region != null) {
      json[r'region'] = this.region;
    } else {
      json[r'region'] = null;
    }
    if (this.dateCreated != null) {
      json[r'date_created'] = this.dateCreated!.toUtc().toIso8601String();
    } else {
      json[r'date_created'] = null;
    }
    if (this.status != null) {
      json[r'status'] = this.status;
    } else {
      json[r'status'] = null;
    }
    if (this.label != null) {
      json[r'label'] = this.label;
    } else {
      json[r'label'] = null;
    }
      json[r'tags'] = this.tags;
    if (this.diskType != null) {
      json[r'disk_type'] = this.diskType;
    } else {
      json[r'disk_type'] = null;
    }
    if (this.storageSize != null) {
      json[r'storage_size'] = this.storageSize;
    } else {
      json[r'storage_size'] = null;
    }
    if (this.storageUsed != null) {
      json[r'storage_used'] = this.storageUsed;
    } else {
      json[r'storage_used'] = null;
    }
    if (this.billing != null) {
      json[r'billing'] = this.billing;
    } else {
      json[r'billing'] = null;
    }
    return json;
  }

  /// Returns a new [Vfs] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static Vfs? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      assert(() {
        requiredKeys.forEach((key) {
          assert(json.containsKey(key), 'Required key "Vfs[$key]" is missing from JSON.');
          assert(json[key] != null, 'Required key "Vfs[$key]" has a null value in JSON.');
        });
        return true;
      }());

      return Vfs(
        id: mapValueOfType<String>(json, r'id'),
        region: mapValueOfType<String>(json, r'region'),
        dateCreated: mapDateTime(json, r'date_created', r''),
        status: mapValueOfType<String>(json, r'status'),
        label: mapValueOfType<String>(json, r'label'),
        tags: json[r'tags'] is Iterable
            ? (json[r'tags'] as Iterable).cast<String>().toList(growable: false)
            : const [],
        diskType: VfsDiskTypeEnum.fromJson(json[r'disk_type']),
        storageSize: VfsStorageSize.fromJson(json[r'storage_size']),
        storageUsed: VfsStorageSize.fromJson(json[r'storage_used']),
        billing: VfsBilling.fromJson(json[r'billing']),
      );
    }
    return null;
  }

  static List<Vfs> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <Vfs>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = Vfs.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, Vfs> mapFromJson(dynamic json) {
    final map = <String, Vfs>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = Vfs.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of Vfs-objects as value to a dart map
  static Map<String, List<Vfs>> mapListFromJson(dynamic json, {bool growable = false,}) {
    final map = <String, List<Vfs>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = Vfs.listFromJson(entry.value, growable: growable,);
      }
    }
    return map;
  }

  /// The list of required keys that must be present in a JSON.
  static const requiredKeys = <String>{
  };
}

/// Type of storage disk
class VfsDiskTypeEnum {
  /// Instantiate a new enum with the provided [value].
  const VfsDiskTypeEnum._(this.value);

  /// The underlying value of this enum member.
  final String value;

  @override
  String toString() => value;

  String toJson() => value;

  static const nvme = VfsDiskTypeEnum._(r'nvme');

  /// List of all possible values in this [enum][VfsDiskTypeEnum].
  static const values = <VfsDiskTypeEnum>[
    nvme,
  ];

  static VfsDiskTypeEnum? fromJson(dynamic value) => VfsDiskTypeEnumTypeTransformer().decode(value);

  static List<VfsDiskTypeEnum> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <VfsDiskTypeEnum>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = VfsDiskTypeEnum.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }
}

/// Transformation class that can [encode] an instance of [VfsDiskTypeEnum] to String,
/// and [decode] dynamic data back to [VfsDiskTypeEnum].
class VfsDiskTypeEnumTypeTransformer {
  factory VfsDiskTypeEnumTypeTransformer() => _instance ??= const VfsDiskTypeEnumTypeTransformer._();

  const VfsDiskTypeEnumTypeTransformer._();

  String encode(VfsDiskTypeEnum data) => data.value;

  /// Decodes a [dynamic value][data] to a VfsDiskTypeEnum.
  ///
  /// If [allowNull] is true and the [dynamic value][data] cannot be decoded successfully,
  /// then null is returned. However, if [allowNull] is false and the [dynamic value][data]
  /// cannot be decoded successfully, then an [UnimplementedError] is thrown.
  ///
  /// The [allowNull] is very handy when an API changes and a new enum value is added or removed,
  /// and users are still using an old app with the old code.
  VfsDiskTypeEnum? decode(dynamic data, {bool allowNull = true}) {
    if (data != null) {
      switch (data) {
        case r'nvme': return VfsDiskTypeEnum.nvme;
        default:
          if (!allowNull) {
            throw ArgumentError('Unknown enum value to decode: $data');
          }
      }
    }
    return null;
  }

  /// Singleton [VfsDiskTypeEnumTypeTransformer] instance.
  static VfsDiskTypeEnumTypeTransformer? _instance;
}


