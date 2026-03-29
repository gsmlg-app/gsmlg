//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of openapi.api;

class CreateVFSRequest {
  /// Returns a new [CreateVFSRequest] instance.
  CreateVFSRequest({
    required this.region,
    required this.label,
    required this.storageSize,
    this.diskType,
    this.tags = const [],
  });

  /// Region identifier where to create the VFS
  String region;

  /// User-defined label for the VFS subscription
  String label;

  CreateVFSRequestStorageSize storageSize;

  /// Type of storage disk (defaults to nvme if not specified)
  CreateVFSRequestDiskTypeEnum? diskType;

  /// Optional tags to apply to the VFS subscription
  List<String> tags;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CreateVFSRequest &&
          other.region == region &&
          other.label == label &&
          other.storageSize == storageSize &&
          other.diskType == diskType &&
          _deepEquality.equals(other.tags, tags);

  @override
  int get hashCode =>
      // ignore: unnecessary_parenthesis
      (region.hashCode) +
      (label.hashCode) +
      (storageSize.hashCode) +
      (diskType == null ? 0 : diskType!.hashCode) +
      (tags.hashCode);

  @override
  String toString() =>
      'CreateVFSRequest[region=$region, label=$label, storageSize=$storageSize, diskType=$diskType, tags=$tags]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
    json[r'region'] = this.region;
    json[r'label'] = this.label;
    json[r'storage_size'] = this.storageSize;
    if (this.diskType != null) {
      json[r'disk_type'] = this.diskType;
    } else {
      json[r'disk_type'] = null;
    }
    json[r'tags'] = this.tags;
    return json;
  }

  /// Returns a new [CreateVFSRequest] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static CreateVFSRequest? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      assert(() {
        requiredKeys.forEach((key) {
          assert(json.containsKey(key),
              'Required key "CreateVFSRequest[$key]" is missing from JSON.');
          assert(json[key] != null,
              'Required key "CreateVFSRequest[$key]" has a null value in JSON.');
        });
        return true;
      }());

      return CreateVFSRequest(
        region: mapValueOfType<String>(json, r'region')!,
        label: mapValueOfType<String>(json, r'label')!,
        storageSize:
            CreateVFSRequestStorageSize.fromJson(json[r'storage_size'])!,
        diskType: CreateVFSRequestDiskTypeEnum.fromJson(json[r'disk_type']),
        tags: json[r'tags'] is Iterable
            ? (json[r'tags'] as Iterable).cast<String>().toList(growable: false)
            : const [],
      );
    }
    return null;
  }

  static List<CreateVFSRequest> listFromJson(
    dynamic json, {
    bool growable = false,
  }) {
    final result = <CreateVFSRequest>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = CreateVFSRequest.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, CreateVFSRequest> mapFromJson(dynamic json) {
    final map = <String, CreateVFSRequest>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = CreateVFSRequest.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of CreateVFSRequest-objects as value to a dart map
  static Map<String, List<CreateVFSRequest>> mapListFromJson(
    dynamic json, {
    bool growable = false,
  }) {
    final map = <String, List<CreateVFSRequest>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = CreateVFSRequest.listFromJson(
          entry.value,
          growable: growable,
        );
      }
    }
    return map;
  }

  /// The list of required keys that must be present in a JSON.
  static const requiredKeys = <String>{
    'region',
    'label',
    'storage_size',
  };
}

/// Type of storage disk (defaults to nvme if not specified)
class CreateVFSRequestDiskTypeEnum {
  /// Instantiate a new enum with the provided [value].
  const CreateVFSRequestDiskTypeEnum._(this.value);

  /// The underlying value of this enum member.
  final String value;

  @override
  String toString() => value;

  String toJson() => value;

  static const nvme = CreateVFSRequestDiskTypeEnum._(r'nvme');

  /// List of all possible values in this [enum][CreateVFSRequestDiskTypeEnum].
  static const values = <CreateVFSRequestDiskTypeEnum>[
    nvme,
  ];

  static CreateVFSRequestDiskTypeEnum? fromJson(dynamic value) =>
      CreateVFSRequestDiskTypeEnumTypeTransformer().decode(value);

  static List<CreateVFSRequestDiskTypeEnum> listFromJson(
    dynamic json, {
    bool growable = false,
  }) {
    final result = <CreateVFSRequestDiskTypeEnum>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = CreateVFSRequestDiskTypeEnum.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }
}

/// Transformation class that can [encode] an instance of [CreateVFSRequestDiskTypeEnum] to String,
/// and [decode] dynamic data back to [CreateVFSRequestDiskTypeEnum].
class CreateVFSRequestDiskTypeEnumTypeTransformer {
  factory CreateVFSRequestDiskTypeEnumTypeTransformer() =>
      _instance ??= const CreateVFSRequestDiskTypeEnumTypeTransformer._();

  const CreateVFSRequestDiskTypeEnumTypeTransformer._();

  String encode(CreateVFSRequestDiskTypeEnum data) => data.value;

  /// Decodes a [dynamic value][data] to a CreateVFSRequestDiskTypeEnum.
  ///
  /// If [allowNull] is true and the [dynamic value][data] cannot be decoded successfully,
  /// then null is returned. However, if [allowNull] is false and the [dynamic value][data]
  /// cannot be decoded successfully, then an [UnimplementedError] is thrown.
  ///
  /// The [allowNull] is very handy when an API changes and a new enum value is added or removed,
  /// and users are still using an old app with the old code.
  CreateVFSRequestDiskTypeEnum? decode(dynamic data, {bool allowNull = true}) {
    if (data != null) {
      switch (data) {
        case r'nvme':
          return CreateVFSRequestDiskTypeEnum.nvme;
        default:
          if (!allowNull) {
            throw ArgumentError('Unknown enum value to decode: $data');
          }
      }
    }
    return null;
  }

  /// Singleton [CreateVFSRequestDiskTypeEnumTypeTransformer] instance.
  static CreateVFSRequestDiskTypeEnumTypeTransformer? _instance;
}
