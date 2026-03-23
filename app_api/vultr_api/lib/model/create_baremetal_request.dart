//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of openapi.api;

class CreateBaremetalRequest {
  /// Returns a new [CreateBaremetalRequest] instance.
  CreateBaremetalRequest({
    required this.region,
    required this.plan,
    this.scriptId,
    this.enableIpv6,
    this.sshkeyId = const [],
    this.userData,
    this.label,
    this.activationEmail,
    this.hostname,
    this.tag,
    this.reservedIpv4,
    this.osId,
    this.snapshotId,
    this.appId,
    this.imageId,
    this.ipxeChainUrl,
    this.persistentPxe,
    this.attachVpc2 = const [],
    this.detachVpc2 = const [],
    this.enableVpc2,
    this.tags = const [],
    this.userScheme,
    this.mdiskMode,
    this.appVariables,
  });

  /// The [Region id](#operation/list-regions) to create the instance.
  String region;

  /// The [Bare Metal plan id](#operation/list-metal-plans) to use for this instance.
  String plan;

  /// The [Startup Script id](#operation/list-startup-scripts) to use for this instance.
  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  String? scriptId;

  /// Enable IPv6.  * true
  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  bool? enableIpv6;

  /// The [SSH Key id](#operation/list-ssh-keys) to install on this instance.
  List<String> sshkeyId;

  /// The user-supplied, base64 encoded [user data](https://docs.vultr.com/manage-instance-user-data-with-the-vultr-metadata-api/) for this Instance.
  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  String? userData;

  /// The user-supplied label.
  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  String? label;

  /// Notify by email after deployment.  * true * false (default)
  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  bool? activationEmail;

  /// The user-supplied hostname to use when deploying this instance.
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

  /// The [Reserved IP id](#operation/list-reserved-ips) for this instance.
  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  String? reservedIpv4;

  /// If supplied, deploy the instance using this [Operating System id](#operation/list-os).
  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  int? osId;

  /// If supplied, deploy the instance using this [Snapshot ID](#operation/list-snapshots).
  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  String? snapshotId;

  /// If supplied, deploy the instance using this [Application id](#operation/list-applications).
  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  int? appId;

  /// If supplied, deploy the instance using this [Application image_id](#operation/list-applications).
  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  String? imageId;

  /// The URL location of the iPXE chainloader. If used, `os_id` must be set to 159.
  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  String? ipxeChainUrl;

  /// Enable persistent PXE.  * true * false (default)
  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  bool? persistentPxe;

  /// An array of [VPC IDs](#operation/list-vpc2) to attach to this Bare Metal Instance. This parameter takes precedence over `enable_vpc2`. Please choose one parameter.
  List<String> attachVpc2;

  /// An array of [VPC IDs](#operation/list-vpc2) to detach from this Bare Metal Instance. This parameter takes precedence over `enable_vpc2`.
  List<String> detachVpc2;

  /// If `true`, VPC 2.0 support will be added to the new server.  This parameter attaches a single VPC 2.0 network. When no VPC 2.0 network exists in the region, it will be automatically created.  If there are multiple VPC 2.0 networks in the instance's region, use `attach_vpc2` instead to specify a VPC 2.0 network.
  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  bool? enableVpc2;

  /// Tags to apply to the instance.
  List<String> tags;

  /// Linux-only: The user scheme used for logging into this instance. By default, the \"root\" user is configured. Alternatively, a limited user with sudo permissions can be selected.  * root * limited
  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  String? userScheme;

  /// The RAID configuration used for the disks on this instance. The instance must be reinstalled for this change to take effect.  * raid1 * jbod * none (default)
  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  String? mdiskMode;

  /// The [app variable inputs](#operation/list-marketplace-app-variables) for configuring the marketplace app (name/value pairs).
  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  Object? appVariables;

  @override
  bool operator ==(Object other) => identical(this, other) || other is CreateBaremetalRequest &&
    other.region == region &&
    other.plan == plan &&
    other.scriptId == scriptId &&
    other.enableIpv6 == enableIpv6 &&
    _deepEquality.equals(other.sshkeyId, sshkeyId) &&
    other.userData == userData &&
    other.label == label &&
    other.activationEmail == activationEmail &&
    other.hostname == hostname &&
    other.tag == tag &&
    other.reservedIpv4 == reservedIpv4 &&
    other.osId == osId &&
    other.snapshotId == snapshotId &&
    other.appId == appId &&
    other.imageId == imageId &&
    other.ipxeChainUrl == ipxeChainUrl &&
    other.persistentPxe == persistentPxe &&
    _deepEquality.equals(other.attachVpc2, attachVpc2) &&
    _deepEquality.equals(other.detachVpc2, detachVpc2) &&
    other.enableVpc2 == enableVpc2 &&
    _deepEquality.equals(other.tags, tags) &&
    other.userScheme == userScheme &&
    other.mdiskMode == mdiskMode &&
    other.appVariables == appVariables;

  @override
  int get hashCode =>
    // ignore: unnecessary_parenthesis
    (region.hashCode) +
    (plan.hashCode) +
    (scriptId == null ? 0 : scriptId!.hashCode) +
    (enableIpv6 == null ? 0 : enableIpv6!.hashCode) +
    (sshkeyId.hashCode) +
    (userData == null ? 0 : userData!.hashCode) +
    (label == null ? 0 : label!.hashCode) +
    (activationEmail == null ? 0 : activationEmail!.hashCode) +
    (hostname == null ? 0 : hostname!.hashCode) +
    (tag == null ? 0 : tag!.hashCode) +
    (reservedIpv4 == null ? 0 : reservedIpv4!.hashCode) +
    (osId == null ? 0 : osId!.hashCode) +
    (snapshotId == null ? 0 : snapshotId!.hashCode) +
    (appId == null ? 0 : appId!.hashCode) +
    (imageId == null ? 0 : imageId!.hashCode) +
    (ipxeChainUrl == null ? 0 : ipxeChainUrl!.hashCode) +
    (persistentPxe == null ? 0 : persistentPxe!.hashCode) +
    (attachVpc2.hashCode) +
    (detachVpc2.hashCode) +
    (enableVpc2 == null ? 0 : enableVpc2!.hashCode) +
    (tags.hashCode) +
    (userScheme == null ? 0 : userScheme!.hashCode) +
    (mdiskMode == null ? 0 : mdiskMode!.hashCode) +
    (appVariables == null ? 0 : appVariables!.hashCode);

  @override
  String toString() => 'CreateBaremetalRequest[region=$region, plan=$plan, scriptId=$scriptId, enableIpv6=$enableIpv6, sshkeyId=$sshkeyId, userData=$userData, label=$label, activationEmail=$activationEmail, hostname=$hostname, tag=$tag, reservedIpv4=$reservedIpv4, osId=$osId, snapshotId=$snapshotId, appId=$appId, imageId=$imageId, ipxeChainUrl=$ipxeChainUrl, persistentPxe=$persistentPxe, attachVpc2=$attachVpc2, detachVpc2=$detachVpc2, enableVpc2=$enableVpc2, tags=$tags, userScheme=$userScheme, mdiskMode=$mdiskMode, appVariables=$appVariables]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
      json[r'region'] = this.region;
      json[r'plan'] = this.plan;
    if (this.scriptId != null) {
      json[r'script_id'] = this.scriptId;
    } else {
      json[r'script_id'] = null;
    }
    if (this.enableIpv6 != null) {
      json[r'enable_ipv6'] = this.enableIpv6;
    } else {
      json[r'enable_ipv6'] = null;
    }
      json[r'sshkey_id'] = this.sshkeyId;
    if (this.userData != null) {
      json[r'user_data'] = this.userData;
    } else {
      json[r'user_data'] = null;
    }
    if (this.label != null) {
      json[r'label'] = this.label;
    } else {
      json[r'label'] = null;
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
    if (this.reservedIpv4 != null) {
      json[r'reserved_ipv4'] = this.reservedIpv4;
    } else {
      json[r'reserved_ipv4'] = null;
    }
    if (this.osId != null) {
      json[r'os_id'] = this.osId;
    } else {
      json[r'os_id'] = null;
    }
    if (this.snapshotId != null) {
      json[r'snapshot_id'] = this.snapshotId;
    } else {
      json[r'snapshot_id'] = null;
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
    if (this.ipxeChainUrl != null) {
      json[r'ipxe_chain_url'] = this.ipxeChainUrl;
    } else {
      json[r'ipxe_chain_url'] = null;
    }
    if (this.persistentPxe != null) {
      json[r'persistent_pxe'] = this.persistentPxe;
    } else {
      json[r'persistent_pxe'] = null;
    }
      json[r'attach_vpc2'] = this.attachVpc2;
      json[r'detach_vpc2'] = this.detachVpc2;
    if (this.enableVpc2 != null) {
      json[r'enable_vpc2'] = this.enableVpc2;
    } else {
      json[r'enable_vpc2'] = null;
    }
      json[r'tags'] = this.tags;
    if (this.userScheme != null) {
      json[r'user_scheme'] = this.userScheme;
    } else {
      json[r'user_scheme'] = null;
    }
    if (this.mdiskMode != null) {
      json[r'mdisk_mode'] = this.mdiskMode;
    } else {
      json[r'mdisk_mode'] = null;
    }
    if (this.appVariables != null) {
      json[r'app_variables'] = this.appVariables;
    } else {
      json[r'app_variables'] = null;
    }
    return json;
  }

  /// Returns a new [CreateBaremetalRequest] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static CreateBaremetalRequest? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      assert(() {
        requiredKeys.forEach((key) {
          assert(json.containsKey(key), 'Required key "CreateBaremetalRequest[$key]" is missing from JSON.');
          assert(json[key] != null, 'Required key "CreateBaremetalRequest[$key]" has a null value in JSON.');
        });
        return true;
      }());

      return CreateBaremetalRequest(
        region: mapValueOfType<String>(json, r'region')!,
        plan: mapValueOfType<String>(json, r'plan')!,
        scriptId: mapValueOfType<String>(json, r'script_id'),
        enableIpv6: mapValueOfType<bool>(json, r'enable_ipv6'),
        sshkeyId: json[r'sshkey_id'] is Iterable
            ? (json[r'sshkey_id'] as Iterable).cast<String>().toList(growable: false)
            : const [],
        userData: mapValueOfType<String>(json, r'user_data'),
        label: mapValueOfType<String>(json, r'label'),
        activationEmail: mapValueOfType<bool>(json, r'activation_email'),
        hostname: mapValueOfType<String>(json, r'hostname'),
        tag: mapValueOfType<String>(json, r'tag'),
        reservedIpv4: mapValueOfType<String>(json, r'reserved_ipv4'),
        osId: mapValueOfType<int>(json, r'os_id'),
        snapshotId: mapValueOfType<String>(json, r'snapshot_id'),
        appId: mapValueOfType<int>(json, r'app_id'),
        imageId: mapValueOfType<String>(json, r'image_id'),
        ipxeChainUrl: mapValueOfType<String>(json, r'ipxe_chain_url'),
        persistentPxe: mapValueOfType<bool>(json, r'persistent_pxe'),
        attachVpc2: json[r'attach_vpc2'] is Iterable
            ? (json[r'attach_vpc2'] as Iterable).cast<String>().toList(growable: false)
            : const [],
        detachVpc2: json[r'detach_vpc2'] is Iterable
            ? (json[r'detach_vpc2'] as Iterable).cast<String>().toList(growable: false)
            : const [],
        enableVpc2: mapValueOfType<bool>(json, r'enable_vpc2'),
        tags: json[r'tags'] is Iterable
            ? (json[r'tags'] as Iterable).cast<String>().toList(growable: false)
            : const [],
        userScheme: mapValueOfType<String>(json, r'user_scheme'),
        mdiskMode: mapValueOfType<String>(json, r'mdisk_mode'),
        appVariables: mapValueOfType<Object>(json, r'app_variables'),
      );
    }
    return null;
  }

  static List<CreateBaremetalRequest> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <CreateBaremetalRequest>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = CreateBaremetalRequest.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, CreateBaremetalRequest> mapFromJson(dynamic json) {
    final map = <String, CreateBaremetalRequest>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = CreateBaremetalRequest.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of CreateBaremetalRequest-objects as value to a dart map
  static Map<String, List<CreateBaremetalRequest>> mapListFromJson(dynamic json, {bool growable = false,}) {
    final map = <String, List<CreateBaremetalRequest>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = CreateBaremetalRequest.listFromJson(entry.value, growable: growable,);
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

