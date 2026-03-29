//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of openapi.api;

class CreateVpc2Request {
  /// Returns a new [CreateVpc2Request] instance.
  CreateVpc2Request({
    required this.region,
    this.description,
    this.ipType,
    this.ipBlock,
    this.prefixLength,
  });

  /// Create the VPC in this [Region id](#operation/list-regions).
  String region;

  /// A description of the VPC. </br> Must be no longer than 255 characters and may include only letters, numbers, spaces, underscores and hyphens.
  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  String? description;

  /// Accepted values: * `v4`
  CreateVpc2RequestIpTypeEnum? ipType;

  /// The VPC subnet IP address. For example: 10.99.0.0<br><span style=\"color: red\">If a prefix_length is specified then ip_block is a required field.</span>
  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  String? ipBlock;

  /// The number of bits for the netmask in CIDR notation. Example: 24<br><span style=\"color: red\">If an ip_block is specified then prefix_length is a required field.</span>
  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  int? prefixLength;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CreateVpc2Request &&
          other.region == region &&
          other.description == description &&
          other.ipType == ipType &&
          other.ipBlock == ipBlock &&
          other.prefixLength == prefixLength;

  @override
  int get hashCode =>
      // ignore: unnecessary_parenthesis
      (region.hashCode) +
      (description == null ? 0 : description!.hashCode) +
      (ipType == null ? 0 : ipType!.hashCode) +
      (ipBlock == null ? 0 : ipBlock!.hashCode) +
      (prefixLength == null ? 0 : prefixLength!.hashCode);

  @override
  String toString() =>
      'CreateVpc2Request[region=$region, description=$description, ipType=$ipType, ipBlock=$ipBlock, prefixLength=$prefixLength]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
    json[r'region'] = this.region;
    if (this.description != null) {
      json[r'description'] = this.description;
    } else {
      json[r'description'] = null;
    }
    if (this.ipType != null) {
      json[r'ip_type'] = this.ipType;
    } else {
      json[r'ip_type'] = null;
    }
    if (this.ipBlock != null) {
      json[r'ip_block'] = this.ipBlock;
    } else {
      json[r'ip_block'] = null;
    }
    if (this.prefixLength != null) {
      json[r'prefix_length'] = this.prefixLength;
    } else {
      json[r'prefix_length'] = null;
    }
    return json;
  }

  /// Returns a new [CreateVpc2Request] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static CreateVpc2Request? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      assert(() {
        requiredKeys.forEach((key) {
          assert(json.containsKey(key),
              'Required key "CreateVpc2Request[$key]" is missing from JSON.');
          assert(json[key] != null,
              'Required key "CreateVpc2Request[$key]" has a null value in JSON.');
        });
        return true;
      }());

      return CreateVpc2Request(
        region: mapValueOfType<String>(json, r'region')!,
        description: mapValueOfType<String>(json, r'description'),
        ipType: CreateVpc2RequestIpTypeEnum.fromJson(json[r'ip_type']),
        ipBlock: mapValueOfType<String>(json, r'ip_block'),
        prefixLength: mapValueOfType<int>(json, r'prefix_length'),
      );
    }
    return null;
  }

  static List<CreateVpc2Request> listFromJson(
    dynamic json, {
    bool growable = false,
  }) {
    final result = <CreateVpc2Request>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = CreateVpc2Request.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, CreateVpc2Request> mapFromJson(dynamic json) {
    final map = <String, CreateVpc2Request>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = CreateVpc2Request.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of CreateVpc2Request-objects as value to a dart map
  static Map<String, List<CreateVpc2Request>> mapListFromJson(
    dynamic json, {
    bool growable = false,
  }) {
    final map = <String, List<CreateVpc2Request>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = CreateVpc2Request.listFromJson(
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
  };
}

/// Accepted values: * `v4`
class CreateVpc2RequestIpTypeEnum {
  /// Instantiate a new enum with the provided [value].
  const CreateVpc2RequestIpTypeEnum._(this.value);

  /// The underlying value of this enum member.
  final String value;

  @override
  String toString() => value;

  String toJson() => value;

  static const v4 = CreateVpc2RequestIpTypeEnum._(r'v4');

  /// List of all possible values in this [enum][CreateVpc2RequestIpTypeEnum].
  static const values = <CreateVpc2RequestIpTypeEnum>[
    v4,
  ];

  static CreateVpc2RequestIpTypeEnum? fromJson(dynamic value) =>
      CreateVpc2RequestIpTypeEnumTypeTransformer().decode(value);

  static List<CreateVpc2RequestIpTypeEnum> listFromJson(
    dynamic json, {
    bool growable = false,
  }) {
    final result = <CreateVpc2RequestIpTypeEnum>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = CreateVpc2RequestIpTypeEnum.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }
}

/// Transformation class that can [encode] an instance of [CreateVpc2RequestIpTypeEnum] to String,
/// and [decode] dynamic data back to [CreateVpc2RequestIpTypeEnum].
class CreateVpc2RequestIpTypeEnumTypeTransformer {
  factory CreateVpc2RequestIpTypeEnumTypeTransformer() =>
      _instance ??= const CreateVpc2RequestIpTypeEnumTypeTransformer._();

  const CreateVpc2RequestIpTypeEnumTypeTransformer._();

  String encode(CreateVpc2RequestIpTypeEnum data) => data.value;

  /// Decodes a [dynamic value][data] to a CreateVpc2RequestIpTypeEnum.
  ///
  /// If [allowNull] is true and the [dynamic value][data] cannot be decoded successfully,
  /// then null is returned. However, if [allowNull] is false and the [dynamic value][data]
  /// cannot be decoded successfully, then an [UnimplementedError] is thrown.
  ///
  /// The [allowNull] is very handy when an API changes and a new enum value is added or removed,
  /// and users are still using an old app with the old code.
  CreateVpc2RequestIpTypeEnum? decode(dynamic data, {bool allowNull = true}) {
    if (data != null) {
      switch (data) {
        case r'v4':
          return CreateVpc2RequestIpTypeEnum.v4;
        default:
          if (!allowNull) {
            throw ArgumentError('Unknown enum value to decode: $data');
          }
      }
    }
    return null;
  }

  /// Singleton [CreateVpc2RequestIpTypeEnumTypeTransformer] instance.
  static CreateVpc2RequestIpTypeEnumTypeTransformer? _instance;
}
