//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of openapi.api;

class ReservedIp {
  /// Returns a new [ReservedIp] instance.
  ReservedIp({
    this.id,
    this.region,
    this.ipType,
    this.subnet,
    this.subnetSize,
    this.label,
    this.instanceId,
  });

  /// A unique ID for the Reserved IP.
  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  String? id;

  /// The [Region id](#operation/list-regions) where the Reserved IP is located.
  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  String? region;

  /// The type of IP address.  * v4 * v6
  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  String? ipType;

  /// The IP subnet.
  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  String? subnet;

  /// The IP network size in bits.
  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  int? subnetSize;

  /// The user-supplied label.
  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  String? label;

  /// The [Instance id](#operation/list-instances) attached to this Reserved IP.
  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  String? instanceId;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ReservedIp &&
          other.id == id &&
          other.region == region &&
          other.ipType == ipType &&
          other.subnet == subnet &&
          other.subnetSize == subnetSize &&
          other.label == label &&
          other.instanceId == instanceId;

  @override
  int get hashCode =>
      // ignore: unnecessary_parenthesis
      (id == null ? 0 : id!.hashCode) +
      (region == null ? 0 : region!.hashCode) +
      (ipType == null ? 0 : ipType!.hashCode) +
      (subnet == null ? 0 : subnet!.hashCode) +
      (subnetSize == null ? 0 : subnetSize!.hashCode) +
      (label == null ? 0 : label!.hashCode) +
      (instanceId == null ? 0 : instanceId!.hashCode);

  @override
  String toString() =>
      'ReservedIp[id=$id, region=$region, ipType=$ipType, subnet=$subnet, subnetSize=$subnetSize, label=$label, instanceId=$instanceId]';

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
    if (this.ipType != null) {
      json[r'ip_type'] = this.ipType;
    } else {
      json[r'ip_type'] = null;
    }
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
    if (this.label != null) {
      json[r'label'] = this.label;
    } else {
      json[r'label'] = null;
    }
    if (this.instanceId != null) {
      json[r'instance_id'] = this.instanceId;
    } else {
      json[r'instance_id'] = null;
    }
    return json;
  }

  /// Returns a new [ReservedIp] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static ReservedIp? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      assert(() {
        requiredKeys.forEach((key) {
          assert(json.containsKey(key),
              'Required key "ReservedIp[$key]" is missing from JSON.');
          assert(json[key] != null,
              'Required key "ReservedIp[$key]" has a null value in JSON.');
        });
        return true;
      }());

      return ReservedIp(
        id: mapValueOfType<String>(json, r'id'),
        region: mapValueOfType<String>(json, r'region'),
        ipType: mapValueOfType<String>(json, r'ip_type'),
        subnet: mapValueOfType<String>(json, r'subnet'),
        subnetSize: mapValueOfType<int>(json, r'subnet_size'),
        label: mapValueOfType<String>(json, r'label'),
        instanceId: mapValueOfType<String>(json, r'instance_id'),
      );
    }
    return null;
  }

  static List<ReservedIp> listFromJson(
    dynamic json, {
    bool growable = false,
  }) {
    final result = <ReservedIp>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = ReservedIp.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, ReservedIp> mapFromJson(dynamic json) {
    final map = <String, ReservedIp>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = ReservedIp.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of ReservedIp-objects as value to a dart map
  static Map<String, List<ReservedIp>> mapListFromJson(
    dynamic json, {
    bool growable = false,
  }) {
    final map = <String, List<ReservedIp>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = ReservedIp.listFromJson(
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
