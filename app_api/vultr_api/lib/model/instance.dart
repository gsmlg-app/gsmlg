//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of openapi.api;

class Instance {
  /// Returns a new [Instance] instance.
  Instance({
    this.id,
    this.os,
    this.ram,
    this.disk,
    this.mainIp,
    this.vcpuCount,
    this.region,
    this.defaultPassword,
    this.dateCreated,
    this.status,
    this.powerStatus,
    this.serverStatus,
    this.allowedBandwidth,
    this.netmaskV4,
    this.gatewayV4,
    this.v6Networks = const [],
    this.hostname,
    this.label,
    this.tag,
    this.internalIp,
    this.vpcOnly,
    this.kvm,
    this.osId,
    this.appId,
    this.imageId,
    this.snapshotId,
    this.firewallGroupId,
    this.features = const [],
    this.plan,
    this.tags = const [],
    this.userScheme,
  });

  /// A unique ID for the VPS Instance.
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

  /// The amount of RAM in MB.
  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  int? ram;

  /// The size of the disk in GB.
  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  int? disk;

  /// The main IPv4 address.
  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  String? mainIp;

  /// Number of vCPUs.
  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  int? vcpuCount;

  /// The [Region id](#operation/list-regions) where the Instance is located.
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

  /// The current status.  * active * pending * suspended * resizing
  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  String? status;

  /// The power-on status.  * running * stopped
  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  String? powerStatus;

  /// The server health status.  * none * locked * installingbooting * ok
  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  String? serverStatus;

  /// Monthly bandwidth quota in GB.
  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  int? allowedBandwidth;

  /// The IPv4 netmask in dot-decimal notation.
  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  String? netmaskV4;

  /// The gateway IP address.
  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  String? gatewayV4;

  /// An array of IPv6 objects.
  List<InstanceV6NetworksInner> v6Networks;

  /// The hostname for this instance.
  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  String? hostname;

  /// The user-supplied label for this instance.
  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  String? label;

  /// Use `tags` instead. The user-supplied tag for this instance.
  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  String? tag;

  /// The internal IP used by this instance, if set. Only relevant when a VPC is attached.
  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  String? internalIp;

  /// The flag used when this VM will not receive a public IP and get its internet access through a NAT Gateway on the VPC.
  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  bool? vpcOnly;

  /// HTTPS link to the Vultr noVNC Web Console.
  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  String? kvm;

  /// The [Operating System id](#operation/list-os) used by this instance.
  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  int? osId;

  /// The [Application id](#operation/list-applications) used by this instance.
  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  int? appId;

  /// The [Application image_id](#operation/list-applications) used by this instance.
  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  String? imageId;

  /// The [Snapshot id](#operation/list-snapshots) used by this instance.
  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  String? snapshotId;

  /// The [Firewall Group id](#operation/list-firewall-groups) linked to this Instance.
  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  String? firewallGroupId;

  /// \"auto_backups\", \"ipv6\", \"ddos_protection\"
  List<String> features;

  /// A unique ID for the Plan.
  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  String? plan;

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
      other is Instance &&
          other.id == id &&
          other.os == os &&
          other.ram == ram &&
          other.disk == disk &&
          other.mainIp == mainIp &&
          other.vcpuCount == vcpuCount &&
          other.region == region &&
          other.defaultPassword == defaultPassword &&
          other.dateCreated == dateCreated &&
          other.status == status &&
          other.powerStatus == powerStatus &&
          other.serverStatus == serverStatus &&
          other.allowedBandwidth == allowedBandwidth &&
          other.netmaskV4 == netmaskV4 &&
          other.gatewayV4 == gatewayV4 &&
          _deepEquality.equals(other.v6Networks, v6Networks) &&
          other.hostname == hostname &&
          other.label == label &&
          other.tag == tag &&
          other.internalIp == internalIp &&
          other.vpcOnly == vpcOnly &&
          other.kvm == kvm &&
          other.osId == osId &&
          other.appId == appId &&
          other.imageId == imageId &&
          other.snapshotId == snapshotId &&
          other.firewallGroupId == firewallGroupId &&
          _deepEquality.equals(other.features, features) &&
          other.plan == plan &&
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
      (vcpuCount == null ? 0 : vcpuCount!.hashCode) +
      (region == null ? 0 : region!.hashCode) +
      (defaultPassword == null ? 0 : defaultPassword!.hashCode) +
      (dateCreated == null ? 0 : dateCreated!.hashCode) +
      (status == null ? 0 : status!.hashCode) +
      (powerStatus == null ? 0 : powerStatus!.hashCode) +
      (serverStatus == null ? 0 : serverStatus!.hashCode) +
      (allowedBandwidth == null ? 0 : allowedBandwidth!.hashCode) +
      (netmaskV4 == null ? 0 : netmaskV4!.hashCode) +
      (gatewayV4 == null ? 0 : gatewayV4!.hashCode) +
      (v6Networks.hashCode) +
      (hostname == null ? 0 : hostname!.hashCode) +
      (label == null ? 0 : label!.hashCode) +
      (tag == null ? 0 : tag!.hashCode) +
      (internalIp == null ? 0 : internalIp!.hashCode) +
      (vpcOnly == null ? 0 : vpcOnly!.hashCode) +
      (kvm == null ? 0 : kvm!.hashCode) +
      (osId == null ? 0 : osId!.hashCode) +
      (appId == null ? 0 : appId!.hashCode) +
      (imageId == null ? 0 : imageId!.hashCode) +
      (snapshotId == null ? 0 : snapshotId!.hashCode) +
      (firewallGroupId == null ? 0 : firewallGroupId!.hashCode) +
      (features.hashCode) +
      (plan == null ? 0 : plan!.hashCode) +
      (tags.hashCode) +
      (userScheme == null ? 0 : userScheme!.hashCode);

  @override
  String toString() =>
      'Instance[id=$id, os=$os, ram=$ram, disk=$disk, mainIp=$mainIp, vcpuCount=$vcpuCount, region=$region, defaultPassword=$defaultPassword, dateCreated=$dateCreated, status=$status, powerStatus=$powerStatus, serverStatus=$serverStatus, allowedBandwidth=$allowedBandwidth, netmaskV4=$netmaskV4, gatewayV4=$gatewayV4, v6Networks=$v6Networks, hostname=$hostname, label=$label, tag=$tag, internalIp=$internalIp, vpcOnly=$vpcOnly, kvm=$kvm, osId=$osId, appId=$appId, imageId=$imageId, snapshotId=$snapshotId, firewallGroupId=$firewallGroupId, features=$features, plan=$plan, tags=$tags, userScheme=$userScheme]';

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
    if (this.vcpuCount != null) {
      json[r'vcpu_count'] = this.vcpuCount;
    } else {
      json[r'vcpu_count'] = null;
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
    if (this.powerStatus != null) {
      json[r'power_status'] = this.powerStatus;
    } else {
      json[r'power_status'] = null;
    }
    if (this.serverStatus != null) {
      json[r'server_status'] = this.serverStatus;
    } else {
      json[r'server_status'] = null;
    }
    if (this.allowedBandwidth != null) {
      json[r'allowed_bandwidth'] = this.allowedBandwidth;
    } else {
      json[r'allowed_bandwidth'] = null;
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
    json[r'v6_networks'] = this.v6Networks;
    if (this.hostname != null) {
      json[r'hostname'] = this.hostname;
    } else {
      json[r'hostname'] = null;
    }
    if (this.label != null) {
      json[r'label'] = this.label;
    } else {
      json[r'label'] = null;
    }
    if (this.tag != null) {
      json[r'tag'] = this.tag;
    } else {
      json[r'tag'] = null;
    }
    if (this.internalIp != null) {
      json[r'internal_ip'] = this.internalIp;
    } else {
      json[r'internal_ip'] = null;
    }
    if (this.vpcOnly != null) {
      json[r'vpc_only'] = this.vpcOnly;
    } else {
      json[r'vpc_only'] = null;
    }
    if (this.kvm != null) {
      json[r'kvm'] = this.kvm;
    } else {
      json[r'kvm'] = null;
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
    if (this.firewallGroupId != null) {
      json[r'firewall_group_id'] = this.firewallGroupId;
    } else {
      json[r'firewall_group_id'] = null;
    }
    json[r'features'] = this.features;
    if (this.plan != null) {
      json[r'plan'] = this.plan;
    } else {
      json[r'plan'] = null;
    }
    json[r'tags'] = this.tags;
    if (this.userScheme != null) {
      json[r'user_scheme'] = this.userScheme;
    } else {
      json[r'user_scheme'] = null;
    }
    return json;
  }

  /// Returns a new [Instance] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static Instance? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      assert(() {
        requiredKeys.forEach((key) {
          assert(json.containsKey(key),
              'Required key "Instance[$key]" is missing from JSON.');
          assert(json[key] != null,
              'Required key "Instance[$key]" has a null value in JSON.');
        });
        return true;
      }());

      return Instance(
        id: mapValueOfType<String>(json, r'id'),
        os: mapValueOfType<String>(json, r'os'),
        ram: mapValueOfType<int>(json, r'ram'),
        disk: mapValueOfType<int>(json, r'disk'),
        mainIp: mapValueOfType<String>(json, r'main_ip'),
        vcpuCount: mapValueOfType<int>(json, r'vcpu_count'),
        region: mapValueOfType<String>(json, r'region'),
        defaultPassword: mapValueOfType<String>(json, r'default_password'),
        dateCreated: mapValueOfType<String>(json, r'date_created'),
        status: mapValueOfType<String>(json, r'status'),
        powerStatus: mapValueOfType<String>(json, r'power_status'),
        serverStatus: mapValueOfType<String>(json, r'server_status'),
        allowedBandwidth: mapValueOfType<int>(json, r'allowed_bandwidth'),
        netmaskV4: mapValueOfType<String>(json, r'netmask_v4'),
        gatewayV4: mapValueOfType<String>(json, r'gateway_v4'),
        v6Networks: InstanceV6NetworksInner.listFromJson(json[r'v6_networks']),
        hostname: mapValueOfType<String>(json, r'hostname'),
        label: mapValueOfType<String>(json, r'label'),
        tag: mapValueOfType<String>(json, r'tag'),
        internalIp: mapValueOfType<String>(json, r'internal_ip'),
        vpcOnly: mapValueOfType<bool>(json, r'vpc_only'),
        kvm: mapValueOfType<String>(json, r'kvm'),
        osId: mapValueOfType<int>(json, r'os_id'),
        appId: mapValueOfType<int>(json, r'app_id'),
        imageId: mapValueOfType<String>(json, r'image_id'),
        snapshotId: mapValueOfType<String>(json, r'snapshot_id'),
        firewallGroupId: mapValueOfType<String>(json, r'firewall_group_id'),
        features: json[r'features'] is Iterable
            ? (json[r'features'] as Iterable)
                .cast<String>()
                .toList(growable: false)
            : const [],
        plan: mapValueOfType<String>(json, r'plan'),
        tags: json[r'tags'] is Iterable
            ? (json[r'tags'] as Iterable).cast<String>().toList(growable: false)
            : const [],
        userScheme: mapValueOfType<String>(json, r'user_scheme'),
      );
    }
    return null;
  }

  static List<Instance> listFromJson(
    dynamic json, {
    bool growable = false,
  }) {
    final result = <Instance>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = Instance.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, Instance> mapFromJson(dynamic json) {
    final map = <String, Instance>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = Instance.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of Instance-objects as value to a dart map
  static Map<String, List<Instance>> mapListFromJson(
    dynamic json, {
    bool growable = false,
  }) {
    final map = <String, List<Instance>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = Instance.listFromJson(
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
