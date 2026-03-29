//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of openapi.api;

class CreateInstanceRequest {
  /// Returns a new [CreateInstanceRequest] instance.
  CreateInstanceRequest({
    required this.region,
    required this.plan,
    this.osId,
    this.ipxeChainUrl,
    this.isoId,
    this.scriptId,
    this.snapshotId,
    this.enableIpv6,
    this.disablePublicIpv4,
    this.attachPrivateNetwork = const [],
    this.attachVpc = const [],
    this.attachVpc2 = const [],
    this.label,
    this.sshkeyId = const [],
    this.backups,
    this.blockDevices = const [],
    this.appId,
    this.imageId,
    this.userData,
    this.ddosProtection,
    this.activationEmail,
    this.hostname,
    this.tag,
    this.firewallGroupId,
    this.reservedIpv4,
    this.enablePrivateNetwork,
    this.enableVpc,
    this.enableVpc2,
    this.vpcOnly,
    this.tags = const [],
    this.userScheme,
    this.appVariables,
  });

  /// The [Region id](#operation/list-regions) where the Instance is located.
  String region;

  /// The [Plan id](#operation/list-plans) to use when deploying this instance.
  String plan;

  /// The [Operating System id](#operation/list-os) to use when deploying this instance.
  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  int? osId;

  /// The URL location of the iPXE chainloader.
  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  String? ipxeChainUrl;

  /// The [ISO id](#operation/list-isos) to use when deploying this instance.
  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  String? isoId;

  /// The [Startup Script id](#operation/list-startup-scripts) to use when deploying this instance.
  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  String? scriptId;

  /// The [Snapshot id](#operation/list-snapshots) to use when deploying the instance.
  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  String? snapshotId;

  /// Enable IPv6.  * true
  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  bool? enableIpv6;

  /// Don't set up a public IPv4 address when IPv6 is enabled. Will not do anything unless `enable_ipv6` is also `true`.  * true
  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  bool? disablePublicIpv4;

  /// Use `attach_vpc` instead. An array of [Private Network ids](#operation/list-networks) to attach to this Instance. This parameter takes precedence over `enable_private_network`. Please choose one parameter.
  List<String> attachPrivateNetwork;

  /// An array of [VPC IDs](#operation/list-vpcs) to attach to this Instance. This parameter takes precedence over `enable_vpc`. Please choose one parameter.
  List<String> attachVpc;

  /// Use `attach_vpc` instead. An array of [VPC IDs](#operation/list-vpc2) to attach to this Instance. This parameter takes precedence over `enable_vpc2`. Please choose one parameter.
  List<String> attachVpc2;

  /// A user-supplied label for this instance.
  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  String? label;

  /// The [SSH Key id](#operation/list-ssh-keys) to install on this instance.
  List<String> sshkeyId;

  /// Enable automatic backups for the instance (does not work for VX1 block storage).  * enabled * disabled
  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  String? backups;

  /// Available for VX1 instances: Define your block devices, create bootable block devices, use local storage (if plan has local storage) as scratch disk. Local Only: ``` \"block_devices\": [   {     \"block_id\": \"local\",     \"bootable\": true   } ] ``` Local Boot + New Block: ``` \"block_devices\": [   {     \"block_id\": \"local\",     \"bootable\": true   },   {     \"disk_size\": 50,     \"label\": \"New Block Label\"   } ] ``` Bootable Block (new): ``` \"block_devices\": [   {     \"disk_size\": 50,     \"label\": \"New Bootable Block\",     \"bootable\": true   } ] ``` Bootable Block (existing): ``` \"block_devices\": [   {     \"block_id\": \"BLOCK_DEVICE_UUID\",     \"bootable\": true   } ] ``` Bootable Block (existing) and Local NVMe: ``` \"block_devices\": [   {     \"block_id\": \"local\"   },   {     \"block_id\": \"BLOCK_DEVICE_UUID\",     \"bootable\": true   } ] ```
  List<Object> blockDevices;

  /// The [Application id](#operation/list-applications) to use when deploying this instance.
  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  int? appId;

  /// The [Application image_id](#operation/list-applications) to use when deploying this instance.
  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  String? imageId;

  /// The user-supplied, base64 encoded [user data](https://docs.vultr.com/manage-instance-user-data-with-the-vultr-metadata-api/) to attach to this instance.
  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  String? userData;

  /// Enable DDoS protection (there is an additional charge for this).  * true * false
  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  bool? ddosProtection;

  /// Notify by email after deployment.  * true * false (default)
  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  bool? activationEmail;

  /// The hostname to use when deploying this instance.
  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  String? hostname;

  /// Use `tags` instead. The user-supplied tag.
  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  String? tag;

  /// The [Firewall Group id](#operation/list-firewall-groups) to attach to this Instance.
  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  String? firewallGroupId;

  /// ID of the floating IP to use as the main IP of this server.
  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  String? reservedIpv4;

  /// Use `enable_vpc` instead.  If `true`, private networking support will be added to the new server.  This parameter attaches a single network. When no network exists in the region, it will be automatically created.  If there are multiple private networks in the instance's region, use `attach_private_network` instead to specify a network.
  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  bool? enablePrivateNetwork;

  /// If `true`, VPC support will be added to the new server.  This parameter attaches a single VPC. When no VPC exists in the region, it will be automatically created.  If there are multiple VPCs in the instance's region, use `attach_vpc` instead to specify a network.
  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  bool? enableVpc;

  /// Use `enable_vpc` instead.  If `true`, VPC 2.0 support will be added to the new server.  This parameter attaches a single VPC 2.0 network. When no VPC 2.0 network exists in the region, it will be automatically created.  If there are multiple VPC 2.0 networks in the instance's region, use `attach_vpc2` instead to specify a network.
  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  bool? enableVpc2;

  /// if `true`, this VPS will not receive a public IP or public NIC.  A `vpc_id` will be required in the `attach_vpc` array. The first `vpc_id` provided must have a NAT Gateway attached.  This VPS will gain access to the internet via the NAT Gateway attached to the VPC.
  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  bool? vpcOnly;

  /// Tags to apply to the instance
  List<String> tags;

  /// Linux-only: The user scheme used for logging into this instance. By default, the \"root\" user is configured. Alternatively, a limited user with sudo permissions can be selected.  * root * limited
  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  String? userScheme;

  /// The [app variable inputs](#operation/list-marketplace-app-variables) for configuring the marketplace app (name/value pairs).
  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  Object? appVariables;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CreateInstanceRequest &&
          other.region == region &&
          other.plan == plan &&
          other.osId == osId &&
          other.ipxeChainUrl == ipxeChainUrl &&
          other.isoId == isoId &&
          other.scriptId == scriptId &&
          other.snapshotId == snapshotId &&
          other.enableIpv6 == enableIpv6 &&
          other.disablePublicIpv4 == disablePublicIpv4 &&
          _deepEquality.equals(
              other.attachPrivateNetwork, attachPrivateNetwork) &&
          _deepEquality.equals(other.attachVpc, attachVpc) &&
          _deepEquality.equals(other.attachVpc2, attachVpc2) &&
          other.label == label &&
          _deepEquality.equals(other.sshkeyId, sshkeyId) &&
          other.backups == backups &&
          _deepEquality.equals(other.blockDevices, blockDevices) &&
          other.appId == appId &&
          other.imageId == imageId &&
          other.userData == userData &&
          other.ddosProtection == ddosProtection &&
          other.activationEmail == activationEmail &&
          other.hostname == hostname &&
          other.tag == tag &&
          other.firewallGroupId == firewallGroupId &&
          other.reservedIpv4 == reservedIpv4 &&
          other.enablePrivateNetwork == enablePrivateNetwork &&
          other.enableVpc == enableVpc &&
          other.enableVpc2 == enableVpc2 &&
          other.vpcOnly == vpcOnly &&
          _deepEquality.equals(other.tags, tags) &&
          other.userScheme == userScheme &&
          other.appVariables == appVariables;

  @override
  int get hashCode =>
      // ignore: unnecessary_parenthesis
      (region.hashCode) +
      (plan.hashCode) +
      (osId == null ? 0 : osId!.hashCode) +
      (ipxeChainUrl == null ? 0 : ipxeChainUrl!.hashCode) +
      (isoId == null ? 0 : isoId!.hashCode) +
      (scriptId == null ? 0 : scriptId!.hashCode) +
      (snapshotId == null ? 0 : snapshotId!.hashCode) +
      (enableIpv6 == null ? 0 : enableIpv6!.hashCode) +
      (disablePublicIpv4 == null ? 0 : disablePublicIpv4!.hashCode) +
      (attachPrivateNetwork.hashCode) +
      (attachVpc.hashCode) +
      (attachVpc2.hashCode) +
      (label == null ? 0 : label!.hashCode) +
      (sshkeyId.hashCode) +
      (backups == null ? 0 : backups!.hashCode) +
      (blockDevices.hashCode) +
      (appId == null ? 0 : appId!.hashCode) +
      (imageId == null ? 0 : imageId!.hashCode) +
      (userData == null ? 0 : userData!.hashCode) +
      (ddosProtection == null ? 0 : ddosProtection!.hashCode) +
      (activationEmail == null ? 0 : activationEmail!.hashCode) +
      (hostname == null ? 0 : hostname!.hashCode) +
      (tag == null ? 0 : tag!.hashCode) +
      (firewallGroupId == null ? 0 : firewallGroupId!.hashCode) +
      (reservedIpv4 == null ? 0 : reservedIpv4!.hashCode) +
      (enablePrivateNetwork == null ? 0 : enablePrivateNetwork!.hashCode) +
      (enableVpc == null ? 0 : enableVpc!.hashCode) +
      (enableVpc2 == null ? 0 : enableVpc2!.hashCode) +
      (vpcOnly == null ? 0 : vpcOnly!.hashCode) +
      (tags.hashCode) +
      (userScheme == null ? 0 : userScheme!.hashCode) +
      (appVariables == null ? 0 : appVariables!.hashCode);

  @override
  String toString() =>
      'CreateInstanceRequest[region=$region, plan=$plan, osId=$osId, ipxeChainUrl=$ipxeChainUrl, isoId=$isoId, scriptId=$scriptId, snapshotId=$snapshotId, enableIpv6=$enableIpv6, disablePublicIpv4=$disablePublicIpv4, attachPrivateNetwork=$attachPrivateNetwork, attachVpc=$attachVpc, attachVpc2=$attachVpc2, label=$label, sshkeyId=$sshkeyId, backups=$backups, blockDevices=$blockDevices, appId=$appId, imageId=$imageId, userData=$userData, ddosProtection=$ddosProtection, activationEmail=$activationEmail, hostname=$hostname, tag=$tag, firewallGroupId=$firewallGroupId, reservedIpv4=$reservedIpv4, enablePrivateNetwork=$enablePrivateNetwork, enableVpc=$enableVpc, enableVpc2=$enableVpc2, vpcOnly=$vpcOnly, tags=$tags, userScheme=$userScheme, appVariables=$appVariables]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
    json[r'region'] = this.region;
    json[r'plan'] = this.plan;
    if (this.osId != null) {
      json[r'os_id'] = this.osId;
    } else {
      json[r'os_id'] = null;
    }
    if (this.ipxeChainUrl != null) {
      json[r'ipxe_chain_url'] = this.ipxeChainUrl;
    } else {
      json[r'ipxe_chain_url'] = null;
    }
    if (this.isoId != null) {
      json[r'iso_id'] = this.isoId;
    } else {
      json[r'iso_id'] = null;
    }
    if (this.scriptId != null) {
      json[r'script_id'] = this.scriptId;
    } else {
      json[r'script_id'] = null;
    }
    if (this.snapshotId != null) {
      json[r'snapshot_id'] = this.snapshotId;
    } else {
      json[r'snapshot_id'] = null;
    }
    if (this.enableIpv6 != null) {
      json[r'enable_ipv6'] = this.enableIpv6;
    } else {
      json[r'enable_ipv6'] = null;
    }
    if (this.disablePublicIpv4 != null) {
      json[r'disable_public_ipv4'] = this.disablePublicIpv4;
    } else {
      json[r'disable_public_ipv4'] = null;
    }
    json[r'attach_private_network'] = this.attachPrivateNetwork;
    json[r'attach_vpc'] = this.attachVpc;
    json[r'attach_vpc2'] = this.attachVpc2;
    if (this.label != null) {
      json[r'label'] = this.label;
    } else {
      json[r'label'] = null;
    }
    json[r'sshkey_id'] = this.sshkeyId;
    if (this.backups != null) {
      json[r'backups'] = this.backups;
    } else {
      json[r'backups'] = null;
    }
    json[r'block_devices'] = this.blockDevices;
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
    if (this.userData != null) {
      json[r'user_data'] = this.userData;
    } else {
      json[r'user_data'] = null;
    }
    if (this.ddosProtection != null) {
      json[r'ddos_protection'] = this.ddosProtection;
    } else {
      json[r'ddos_protection'] = null;
    }
    if (this.activationEmail != null) {
      json[r'activation_email'] = this.activationEmail;
    } else {
      json[r'activation_email'] = null;
    }
    if (this.hostname != null) {
      json[r'hostname'] = this.hostname;
    } else {
      json[r'hostname'] = null;
    }
    if (this.tag != null) {
      json[r'tag'] = this.tag;
    } else {
      json[r'tag'] = null;
    }
    if (this.firewallGroupId != null) {
      json[r'firewall_group_id'] = this.firewallGroupId;
    } else {
      json[r'firewall_group_id'] = null;
    }
    if (this.reservedIpv4 != null) {
      json[r'reserved_ipv4'] = this.reservedIpv4;
    } else {
      json[r'reserved_ipv4'] = null;
    }
    if (this.enablePrivateNetwork != null) {
      json[r'enable_private_network'] = this.enablePrivateNetwork;
    } else {
      json[r'enable_private_network'] = null;
    }
    if (this.enableVpc != null) {
      json[r'enable_vpc'] = this.enableVpc;
    } else {
      json[r'enable_vpc'] = null;
    }
    if (this.enableVpc2 != null) {
      json[r'enable_vpc2'] = this.enableVpc2;
    } else {
      json[r'enable_vpc2'] = null;
    }
    if (this.vpcOnly != null) {
      json[r'vpc_only'] = this.vpcOnly;
    } else {
      json[r'vpc_only'] = null;
    }
    json[r'tags'] = this.tags;
    if (this.userScheme != null) {
      json[r'user_scheme'] = this.userScheme;
    } else {
      json[r'user_scheme'] = null;
    }
    if (this.appVariables != null) {
      json[r'app_variables'] = this.appVariables;
    } else {
      json[r'app_variables'] = null;
    }
    return json;
  }

  /// Returns a new [CreateInstanceRequest] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static CreateInstanceRequest? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      assert(() {
        requiredKeys.forEach((key) {
          assert(json.containsKey(key),
              'Required key "CreateInstanceRequest[$key]" is missing from JSON.');
          assert(json[key] != null,
              'Required key "CreateInstanceRequest[$key]" has a null value in JSON.');
        });
        return true;
      }());

      return CreateInstanceRequest(
        region: mapValueOfType<String>(json, r'region')!,
        plan: mapValueOfType<String>(json, r'plan')!,
        osId: mapValueOfType<int>(json, r'os_id'),
        ipxeChainUrl: mapValueOfType<String>(json, r'ipxe_chain_url'),
        isoId: mapValueOfType<String>(json, r'iso_id'),
        scriptId: mapValueOfType<String>(json, r'script_id'),
        snapshotId: mapValueOfType<String>(json, r'snapshot_id'),
        enableIpv6: mapValueOfType<bool>(json, r'enable_ipv6'),
        disablePublicIpv4: mapValueOfType<bool>(json, r'disable_public_ipv4'),
        attachPrivateNetwork: json[r'attach_private_network'] is Iterable
            ? (json[r'attach_private_network'] as Iterable)
                .cast<String>()
                .toList(growable: false)
            : const [],
        attachVpc: json[r'attach_vpc'] is Iterable
            ? (json[r'attach_vpc'] as Iterable)
                .cast<String>()
                .toList(growable: false)
            : const [],
        attachVpc2: json[r'attach_vpc2'] is Iterable
            ? (json[r'attach_vpc2'] as Iterable)
                .cast<String>()
                .toList(growable: false)
            : const [],
        label: mapValueOfType<String>(json, r'label'),
        sshkeyId: json[r'sshkey_id'] is Iterable
            ? (json[r'sshkey_id'] as Iterable)
                .cast<String>()
                .toList(growable: false)
            : const [],
        backups: mapValueOfType<String>(json, r'backups'),
        blockDevices: json[r'block_devices'] is Iterable
            ? (json[r'block_devices'] as Iterable)
                .cast<Object>()
                .toList(growable: false)
            : const [],
        appId: mapValueOfType<int>(json, r'app_id'),
        imageId: mapValueOfType<String>(json, r'image_id'),
        userData: mapValueOfType<String>(json, r'user_data'),
        ddosProtection: mapValueOfType<bool>(json, r'ddos_protection'),
        activationEmail: mapValueOfType<bool>(json, r'activation_email'),
        hostname: mapValueOfType<String>(json, r'hostname'),
        tag: mapValueOfType<String>(json, r'tag'),
        firewallGroupId: mapValueOfType<String>(json, r'firewall_group_id'),
        reservedIpv4: mapValueOfType<String>(json, r'reserved_ipv4'),
        enablePrivateNetwork:
            mapValueOfType<bool>(json, r'enable_private_network'),
        enableVpc: mapValueOfType<bool>(json, r'enable_vpc'),
        enableVpc2: mapValueOfType<bool>(json, r'enable_vpc2'),
        vpcOnly: mapValueOfType<bool>(json, r'vpc_only'),
        tags: json[r'tags'] is Iterable
            ? (json[r'tags'] as Iterable).cast<String>().toList(growable: false)
            : const [],
        userScheme: mapValueOfType<String>(json, r'user_scheme'),
        appVariables: mapValueOfType<Object>(json, r'app_variables'),
      );
    }
    return null;
  }

  static List<CreateInstanceRequest> listFromJson(
    dynamic json, {
    bool growable = false,
  }) {
    final result = <CreateInstanceRequest>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = CreateInstanceRequest.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, CreateInstanceRequest> mapFromJson(dynamic json) {
    final map = <String, CreateInstanceRequest>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = CreateInstanceRequest.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of CreateInstanceRequest-objects as value to a dart map
  static Map<String, List<CreateInstanceRequest>> mapListFromJson(
    dynamic json, {
    bool growable = false,
  }) {
    final map = <String, List<CreateInstanceRequest>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = CreateInstanceRequest.listFromJson(
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
    'plan',
  };
}
