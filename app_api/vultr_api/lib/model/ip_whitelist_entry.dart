//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of openapi.api;

class IpWhitelistEntry {
  /// Returns a new [IpWhitelistEntry] instance.
  IpWhitelistEntry({
    this.subnet,
    this.subnetSize,
    this.dateAdded,
    this.ipType,
  });

  /// The IP address or subnet.
  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  String? subnet;

  /// The subnet size.
  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  int? subnetSize;

  /// Date the entry was added.
  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  String? dateAdded;

  /// The IP type (v4 or v6).
  IpWhitelistEntryIpTypeEnum? ipType;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is IpWhitelistEntry &&
          other.subnet == subnet &&
          other.subnetSize == subnetSize &&
          other.dateAdded == dateAdded &&
          other.ipType == ipType;

  @override
  int get hashCode =>
      // ignore: unnecessary_parenthesis
      (subnet == null ? 0 : subnet!.hashCode) +
      (subnetSize == null ? 0 : subnetSize!.hashCode) +
      (dateAdded == null ? 0 : dateAdded!.hashCode) +
      (ipType == null ? 0 : ipType!.hashCode);

  @override
  String toString() =>
      'IpWhitelistEntry[subnet=$subnet, subnetSize=$subnetSize, dateAdded=$dateAdded, ipType=$ipType]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
    if (this.subnet != null) {
      json[r'subnet'] = this.subnet;
    } else {
      json[r'subnet'] = null;
    }
    if (this.subnetSize != null) {
      json[r'subnet_size'] = this.subnetSize;
    } else {
      json[r'subnet_size'] = null;
    }
    if (this.dateAdded != null) {
      json[r'date_added'] = this.dateAdded;
    } else {
      json[r'date_added'] = null;
    }
    if (this.ipType != null) {
      json[r'ip_type'] = this.ipType;
    } else {
      json[r'ip_type'] = null;
    }
    return json;
  }

  /// Returns a new [IpWhitelistEntry] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static IpWhitelistEntry? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      assert(() {
        requiredKeys.forEach((key) {
          assert(json.containsKey(key),
              'Required key "IpWhitelistEntry[$key]" is missing from JSON.');
          assert(json[key] != null,
              'Required key "IpWhitelistEntry[$key]" has a null value in JSON.');
        });
        return true;
      }());

      return IpWhitelistEntry(
        subnet: mapValueOfType<String>(json, r'subnet'),
        subnetSize: mapValueOfType<int>(json, r'subnet_size'),
        dateAdded: mapValueOfType<String>(json, r'date_added'),
        ipType: IpWhitelistEntryIpTypeEnum.fromJson(json[r'ip_type']),
      );
    }
    return null;
  }

  static List<IpWhitelistEntry> listFromJson(
    dynamic json, {
    bool growable = false,
  }) {
    final result = <IpWhitelistEntry>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = IpWhitelistEntry.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, IpWhitelistEntry> mapFromJson(dynamic json) {
    final map = <String, IpWhitelistEntry>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = IpWhitelistEntry.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of IpWhitelistEntry-objects as value to a dart map
  static Map<String, List<IpWhitelistEntry>> mapListFromJson(
    dynamic json, {
    bool growable = false,
  }) {
    final map = <String, List<IpWhitelistEntry>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = IpWhitelistEntry.listFromJson(
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

/// The IP type (v4 or v6).
class IpWhitelistEntryIpTypeEnum {
  /// Instantiate a new enum with the provided [value].
  const IpWhitelistEntryIpTypeEnum._(this.value);

  /// The underlying value of this enum member.
  final String value;

  @override
  String toString() => value;

  String toJson() => value;

  static const v4 = IpWhitelistEntryIpTypeEnum._(r'v4');
  static const v6 = IpWhitelistEntryIpTypeEnum._(r'v6');

  /// List of all possible values in this [enum][IpWhitelistEntryIpTypeEnum].
  static const values = <IpWhitelistEntryIpTypeEnum>[
    v4,
    v6,
  ];

  static IpWhitelistEntryIpTypeEnum? fromJson(dynamic value) =>
      IpWhitelistEntryIpTypeEnumTypeTransformer().decode(value);

  static List<IpWhitelistEntryIpTypeEnum> listFromJson(
    dynamic json, {
    bool growable = false,
  }) {
    final result = <IpWhitelistEntryIpTypeEnum>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = IpWhitelistEntryIpTypeEnum.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }
}

/// Transformation class that can [encode] an instance of [IpWhitelistEntryIpTypeEnum] to String,
/// and [decode] dynamic data back to [IpWhitelistEntryIpTypeEnum].
class IpWhitelistEntryIpTypeEnumTypeTransformer {
  factory IpWhitelistEntryIpTypeEnumTypeTransformer() =>
      _instance ??= const IpWhitelistEntryIpTypeEnumTypeTransformer._();

  const IpWhitelistEntryIpTypeEnumTypeTransformer._();

  String encode(IpWhitelistEntryIpTypeEnum data) => data.value;

  /// Decodes a [dynamic value][data] to a IpWhitelistEntryIpTypeEnum.
  ///
  /// If [allowNull] is true and the [dynamic value][data] cannot be decoded successfully,
  /// then null is returned. However, if [allowNull] is false and the [dynamic value][data]
  /// cannot be decoded successfully, then an [UnimplementedError] is thrown.
  ///
  /// The [allowNull] is very handy when an API changes and a new enum value is added or removed,
  /// and users are still using an old app with the old code.
  IpWhitelistEntryIpTypeEnum? decode(dynamic data, {bool allowNull = true}) {
    if (data != null) {
      switch (data) {
        case r'v4':
          return IpWhitelistEntryIpTypeEnum.v4;
        case r'v6':
          return IpWhitelistEntryIpTypeEnum.v6;
        default:
          if (!allowNull) {
            throw ArgumentError('Unknown enum value to decode: $data');
          }
      }
    }
    return null;
  }

  /// Singleton [IpWhitelistEntryIpTypeEnumTypeTransformer] instance.
  static IpWhitelistEntryIpTypeEnumTypeTransformer? _instance;
}
