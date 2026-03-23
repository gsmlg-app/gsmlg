//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of openapi.api;

class CreateStorageGatewayRequest {
  /// Returns a new [CreateStorageGatewayRequest] instance.
  CreateStorageGatewayRequest({
    required this.label,
    required this.type,
    required this.region,
    this.exportConfig = const [],
    this.networkConfig = const [],
  });

  /// The user-supplied label for this Storage Gateway.
  String label;

  /// The gateway type
  CreateStorageGatewayRequestTypeEnum type;

  /// The [Region id](#operation/list-regions) for this Storage Gateway.
  String region;

  List<StorageGatewayExport> exportConfig;

  List<StorageGatewayNetwork> networkConfig;

  @override
  bool operator ==(Object other) => identical(this, other) || other is CreateStorageGatewayRequest &&
    other.label == label &&
    other.type == type &&
    other.region == region &&
    _deepEquality.equals(other.exportConfig, exportConfig) &&
    _deepEquality.equals(other.networkConfig, networkConfig);

  @override
  int get hashCode =>
    // ignore: unnecessary_parenthesis
    (label.hashCode) +
    (type.hashCode) +
    (region.hashCode) +
    (exportConfig.hashCode) +
    (networkConfig.hashCode);

  @override
  String toString() => 'CreateStorageGatewayRequest[label=$label, type=$type, region=$region, exportConfig=$exportConfig, networkConfig=$networkConfig]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
      json[r'label'] = this.label;
      json[r'type'] = this.type;
      json[r'region'] = this.region;
      json[r'export_config'] = this.exportConfig;
      json[r'network_config'] = this.networkConfig;
    return json;
  }

  /// Returns a new [CreateStorageGatewayRequest] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static CreateStorageGatewayRequest? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      assert(() {
        requiredKeys.forEach((key) {
          assert(json.containsKey(key), 'Required key "CreateStorageGatewayRequest[$key]" is missing from JSON.');
          assert(json[key] != null, 'Required key "CreateStorageGatewayRequest[$key]" has a null value in JSON.');
        });
        return true;
      }());

      return CreateStorageGatewayRequest(
        label: mapValueOfType<String>(json, r'label')!,
        type: CreateStorageGatewayRequestTypeEnum.fromJson(json[r'type'])!,
        region: mapValueOfType<String>(json, r'region')!,
        exportConfig: StorageGatewayExport.listFromJson(json[r'export_config']),
        networkConfig: StorageGatewayNetwork.listFromJson(json[r'network_config']),
      );
    }
    return null;
  }

  static List<CreateStorageGatewayRequest> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <CreateStorageGatewayRequest>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = CreateStorageGatewayRequest.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, CreateStorageGatewayRequest> mapFromJson(dynamic json) {
    final map = <String, CreateStorageGatewayRequest>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = CreateStorageGatewayRequest.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of CreateStorageGatewayRequest-objects as value to a dart map
  static Map<String, List<CreateStorageGatewayRequest>> mapListFromJson(dynamic json, {bool growable = false,}) {
    final map = <String, List<CreateStorageGatewayRequest>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = CreateStorageGatewayRequest.listFromJson(entry.value, growable: growable,);
      }
    }
    return map;
  }

  /// The list of required keys that must be present in a JSON.
  static const requiredKeys = <String>{
    'label',
    'type',
    'region',
    'export_config',
    'network_config',
  };
}

/// The gateway type
class CreateStorageGatewayRequestTypeEnum {
  /// Instantiate a new enum with the provided [value].
  const CreateStorageGatewayRequestTypeEnum._(this.value);

  /// The underlying value of this enum member.
  final String value;

  @override
  String toString() => value;

  String toJson() => value;

  static const nfs4 = CreateStorageGatewayRequestTypeEnum._(r'nfs4');

  /// List of all possible values in this [enum][CreateStorageGatewayRequestTypeEnum].
  static const values = <CreateStorageGatewayRequestTypeEnum>[
    nfs4,
  ];

  static CreateStorageGatewayRequestTypeEnum? fromJson(dynamic value) => CreateStorageGatewayRequestTypeEnumTypeTransformer().decode(value);

  static List<CreateStorageGatewayRequestTypeEnum> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <CreateStorageGatewayRequestTypeEnum>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = CreateStorageGatewayRequestTypeEnum.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }
}

/// Transformation class that can [encode] an instance of [CreateStorageGatewayRequestTypeEnum] to String,
/// and [decode] dynamic data back to [CreateStorageGatewayRequestTypeEnum].
class CreateStorageGatewayRequestTypeEnumTypeTransformer {
  factory CreateStorageGatewayRequestTypeEnumTypeTransformer() => _instance ??= const CreateStorageGatewayRequestTypeEnumTypeTransformer._();

  const CreateStorageGatewayRequestTypeEnumTypeTransformer._();

  String encode(CreateStorageGatewayRequestTypeEnum data) => data.value;

  /// Decodes a [dynamic value][data] to a CreateStorageGatewayRequestTypeEnum.
  ///
  /// If [allowNull] is true and the [dynamic value][data] cannot be decoded successfully,
  /// then null is returned. However, if [allowNull] is false and the [dynamic value][data]
  /// cannot be decoded successfully, then an [UnimplementedError] is thrown.
  ///
  /// The [allowNull] is very handy when an API changes and a new enum value is added or removed,
  /// and users are still using an old app with the old code.
  CreateStorageGatewayRequestTypeEnum? decode(dynamic data, {bool allowNull = true}) {
    if (data != null) {
      switch (data) {
        case r'nfs4': return CreateStorageGatewayRequestTypeEnum.nfs4;
        default:
          if (!allowNull) {
            throw ArgumentError('Unknown enum value to decode: $data');
          }
      }
    }
    return null;
  }

  /// Singleton [CreateStorageGatewayRequestTypeEnumTypeTransformer] instance.
  static CreateStorageGatewayRequestTypeEnumTypeTransformer? _instance;
}


