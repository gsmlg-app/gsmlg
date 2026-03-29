//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of openapi.api;

class BaremetalGet {
  /// Returns a new [BaremetalGet] instance.
  BaremetalGet({
    this.id,
    this.os,
    this.ram,
    this.disk,
    this.mainIp,
    this.cpuCount,
    this.region,
    this.defaultPassword,
    this.dateCreated,
    this.status,
    this.netmaskV4,
    this.gatewayV4,
    this.plan,
    this.label,
    this.internalIp,
    this.vpcs = const [],
    this.tag,
    this.osId,
    this.appId,
    this.imageId,
    this.snapshotId,
    this.v6Network,
    this.v6MainIp,
    this.v6NetworkSize,
    this.macAddress,
    this.tags = const [],
    this.userScheme,
  });

  /// A unique ID for the Bare Metal instance.
  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  String? id;

  /// The [Operating System name](#operation/list-os).
  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  String? os;

  /// Text description of the instances' RAM.
  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  String? ram;

  /// Text description of the instances' disk configuration.
  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  String? disk;

  /// The main IPv4 address.
  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  String? mainIp;

  /// Number of CPUs.
  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  int? cpuCount;

  /// The [Region id](#operation/list-regions) where the instance is located.
  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  String? region;

  /// The default password assigned at deployment. Only available for ten minutes after deployment.
  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  String? defaultPassword;

  /// The date this instance was created.
  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  String? dateCreated;

  /// The current status.  * active * pending * suspended
  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  String? status;

  /// The IPv4 netmask in dot-decimal notation.
  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  String? netmaskV4;

  /// The IPv4 gateway address.
  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  String? gatewayV4;

  /// The [Bare Metal Plan id](#operation/list-metal-plans) used by this instance.
  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  String? plan;

  /// The user-supplied label for this instance.
  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  String? label;

  /// The internal IP used by this instance, if set. Only relevant when a VPC is attached.
  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  String? internalIp;

  /// List of VPC Networks to which the instance is attached.
  List<AttachedVpcs> vpcs;

  /// Use `tags` instead. The user-supplied tag for this instance.
  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  String? tag;

  /// The [Operating System id](#operation/list-os).
  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  int? osId;

  /// The [Application id](#operation/list-applications).
  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  int? appId;

  /// The [Application image_id](#operation/list-applications).
  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  String? imageId;

  /// The [Snapshot id](#operation/list-snapshots).
  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  String? snapshotId;

  /// The IPv6 network size in bits.
  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  String? v6Network;

  /// The main IPv6 network address.
  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  String? v6MainIp;

  /// The IPv6 subnet.
  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  int? v6NetworkSize;

  /// The MAC address for a Bare Metal server.
  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  int? macAddress;

  /// Tags to apply to the instance.
  List<String> tags;

  /// The user scheme.  * root * limited
  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  String? userScheme;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BaremetalGet &&
          other.id == id &&
          other.os == os &&
          other.ram == ram &&
          other.disk == disk &&
          other.mainIp == mainIp &&
          other.cpuCount == cpuCount &&
          other.region == region &&
          other.defaultPassword == defaultPassword &&
          other.dateCreated == dateCreated &&
          other.status == status &&
          other.netmaskV4 == netmaskV4 &&
          other.gatewayV4 == gatewayV4 &&
          other.plan == plan &&
          other.label == label &&
          other.internalIp == internalIp &&
          _deepEquality.equals(other.vpcs, vpcs) &&
          other.tag == tag &&
          other.osId == osId &&
          other.appId == appId &&
          other.imageId == imageId &&
          other.snapshotId == snapshotId &&
          other.v6Network == v6Network &&
          other.v6MainIp == v6MainIp &&
          other.v6NetworkSize == v6NetworkSize &&
          other.macAddress == macAddress &&
          _deepEquality.equals(other.tags, tags) &&
          other.userScheme == userScheme;

  @override
  int get hashCode =>
      // ignore: unnecessary_parenthesis
      (id == null ? 0 : id!.hashCode) +
      (os == null ? 0 : os!.hashCode) +
      (ram == null ? 0 : ram!.hashCode) +
      (disk == null ? 0 : disk!.hashCode) +
      (mainIp == null ? 0 : mainIp!.hashCode) +
      (cpuCount == null ? 0 : cpuCount!.hashCode) +
      (region == null ? 0 : region!.hashCode) +
      (defaultPassword == null ? 0 : defaultPassword!.hashCode) +
      (dateCreated == null ? 0 : dateCreated!.hashCode) +
      (status == null ? 0 : status!.hashCode) +
      (netmaskV4 == null ? 0 : netmaskV4!.hashCode) +
      (gatewayV4 == null ? 0 : gatewayV4!.hashCode) +
      (plan == null ? 0 : plan!.hashCode) +
      (label == null ? 0 : label!.hashCode) +
      (internalIp == null ? 0 : internalIp!.hashCode) +
      (vpcs.hashCode) +
      (tag == null ? 0 : tag!.hashCode) +
      (osId == null ? 0 : osId!.hashCode) +
      (appId == null ? 0 : appId!.hashCode) +
      (imageId == null ? 0 : imageId!.hashCode) +
      (snapshotId == null ? 0 : snapshotId!.hashCode) +
      (v6Network == null ? 0 : v6Network!.hashCode) +
      (v6MainIp == null ? 0 : v6MainIp!.hashCode) +
      (v6NetworkSize == null ? 0 : v6NetworkSize!.hashCode) +
      (macAddress == null ? 0 : macAddress!.hashCode) +
      (tags.hashCode) +
      (userScheme == null ? 0 : userScheme!.hashCode);

  @override
  String toString() =>
      'BaremetalGet[id=$id, os=$os, ram=$ram, disk=$disk, mainIp=$mainIp, cpuCount=$cpuCount, region=$region, defaultPassword=$defaultPassword, dateCreated=$dateCreated, status=$status, netmaskV4=$netmaskV4, gatewayV4=$gatewayV4, plan=$plan, label=$label, internalIp=$internalIp, vpcs=$vpcs, tag=$tag, osId=$osId, appId=$appId, imageId=$imageId, snapshotId=$snapshotId, v6Network=$v6Network, v6MainIp=$v6MainIp, v6NetworkSize=$v6NetworkSize, macAddress=$macAddress, tags=$tags, userScheme=$userScheme]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
    if (this.id != null) {
      json[r'id'] = this.id;
    } else {
      json[r'id'] = null;
    }
    if (this.os != null) {
      json[r'os'] = this.os;
    } else {
      json[r'os'] = null;
    }
    if (this.ram != null) {
      json[r'ram'] = this.ram;
    } else {
      json[r'ram'] = null;
    }
    if (this.disk != null) {
      json[r'disk'] = this.disk;
    } else {
      json[r'disk'] = null;
    }
    if (this.mainIp != null) {
      json[r'main_ip'] = this.mainIp;
    } else {
      json[r'main_ip'] = null;
    }
    if (this.cpuCount != null) {
      json[r'cpu_count'] = this.cpuCount;
    } else {
      json[r'cpu_count'] = null;
    }
    if (this.region != null) {
      json[r'region'] = this.region;
    } else {
      json[r'region'] = null;
    }
    if (this.defaultPassword != null) {
      json[r'default_password'] = this.defaultPassword;
    } else {
      json[r'default_password'] = null;
    }
    if (this.dateCreated != null) {
      json[r'date_created'] = this.dateCreated;
    } else {
      json[r'date_created'] = null;
    }
    if (this.status != null) {
      json[r'status'] = this.status;
    } else {
      json[r'status'] = null;
    }
    if (this.netmaskV4 != null) {
      json[r'netmask_v4'] = this.netmaskV4;
    } else {
      json[r'netmask_v4'] = null;
    }
    if (this.gatewayV4 != null) {
      json[r'gateway_v4'] = this.gatewayV4;
    } else {
      json[r'gateway_v4'] = null;
    }
    if (this.plan != null) {
      json[r'plan'] = this.plan;
    } else {
      json[r'plan'] = null;
    }
    if (this.label != null) {
      json[r'label'] = this.label;
    } else {
      json[r'label'] = null;
    }
    if (this.internalIp != null) {
      json[r'internal_ip'] = this.internalIp;
    } else {
      json[r'internal_ip'] = null;
    }
    json[r'vpcs'] = this.vpcs;
    if (this.tag != null) {
      json[r'tag'] = this.tag;
    } else {
      json[r'tag'] = null;
    }
    if (this.osId != null) {
      json[r'os_id'] = this.osId;
    } else {
      json[r'os_id'] = null;
    }
    if (this.appId != null) {
      json[r'app_id'] = this.appId;
    } else {
      json[r'app_id'] = null;
    }
    if (this.imageId != null) {
      json[r'image_id'] = this.imageId;
    } else {
      json[r'image_id'] = null;
    }
    if (this.snapshotId != null) {
      json[r'snapshot_id'] = this.snapshotId;
    } else {
      json[r'snapshot_id'] = null;
    }
    if (this.v6Network != null) {
      json[r'v6_network'] = this.v6Network;
    } else {
      json[r'v6_network'] = null;
    }
    if (this.v6MainIp != null) {
      json[r'v6_main_ip'] = this.v6MainIp;
    } else {
      json[r'v6_main_ip'] = null;
    }
    if (this.v6NetworkSize != null) {
      json[r'v6_network_size'] = this.v6NetworkSize;
    } else {
      json[r'v6_network_size'] = null;
    }
    if (this.macAddress != null) {
      json[r'mac_address'] = this.macAddress;
    } else {
      json[r'mac_address'] = null;
    }
    json[r'tags'] = this.tags;
    if (this.userScheme != null) {
      json[r'user_scheme'] = this.userScheme;
    } else {
      json[r'user_scheme'] = null;
    }
    return json;
  }

  /// Returns a new [BaremetalGet] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static BaremetalGet? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      assert(() {
        requiredKeys.forEach((key) {
          assert(json.containsKey(key),
              'Required key "BaremetalGet[$key]" is missing from JSON.');
          assert(json[key] != null,
              'Required key "BaremetalGet[$key]" has a null value in JSON.');
        });
        return true;
      }());

      return BaremetalGet(
        id: mapValueOfType<String>(json, r'id'),
        os: mapValueOfType<String>(json, r'os'),
        ram: mapValueOfType<String>(json, r'ram'),
        disk: mapValueOfType<String>(json, r'disk'),
        mainIp: mapValueOfType<String>(json, r'main_ip'),
        cpuCount: mapValueOfType<int>(json, r'cpu_count'),
        region: mapValueOfType<String>(json, r'region'),
        defaultPassword: mapValueOfType<String>(json, r'default_password'),
        dateCreated: mapValueOfType<String>(json, r'date_created'),
        status: mapValueOfType<String>(json, r'status'),
        netmaskV4: mapValueOfType<String>(json, r'netmask_v4'),
        gatewayV4: mapValueOfType<String>(json, r'gateway_v4'),
        plan: mapValueOfType<String>(json, r'plan'),
        label: mapValueOfType<String>(json, r'label'),
        internalIp: mapValueOfType<String>(json, r'internal_ip'),
        vpcs: AttachedVpcs.listFromJson(json[r'vpcs']),
        tag: mapValueOfType<String>(json, r'tag'),
        osId: mapValueOfType<int>(json, r'os_id'),
        appId: mapValueOfType<int>(json, r'app_id'),
        imageId: mapValueOfType<String>(json, r'image_id'),
        snapshotId: mapValueOfType<String>(json, r'snapshot_id'),
        v6Network: mapValueOfType<String>(json, r'v6_network'),
        v6MainIp: mapValueOfType<String>(json, r'v6_main_ip'),
        v6NetworkSize: mapValueOfType<int>(json, r'v6_network_size'),
        macAddress: mapValueOfType<int>(json, r'mac_address'),
        tags: json[r'tags'] is Iterable
            ? (json[r'tags'] as Iterable).cast<String>().toList(growable: false)
            : const [],
        userScheme: mapValueOfType<String>(json, r'user_scheme'),
      );
    }
    return null;
  }

  static List<BaremetalGet> listFromJson(
    dynamic json, {
    bool growable = false,
  }) {
    final result = <BaremetalGet>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = BaremetalGet.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, BaremetalGet> mapFromJson(dynamic json) {
    final map = <String, BaremetalGet>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = BaremetalGet.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of BaremetalGet-objects as value to a dart map
  static Map<String, List<BaremetalGet>> mapListFromJson(
    dynamic json, {
    bool growable = false,
  }) {
    final map = <String, List<BaremetalGet>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = BaremetalGet.listFromJson(
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
