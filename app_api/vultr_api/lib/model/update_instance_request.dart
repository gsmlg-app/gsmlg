//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of openapi.api;

class UpdateInstanceRequest {
  /// Returns a new [UpdateInstanceRequest] instance.
  UpdateInstanceRequest({
    this.appId,
    this.imageId,
    this.backups,
    this.firewallGroupId,
    this.enableIpv6,
    this.osId,
    this.userData,
    this.tag,
    this.plan,
    this.ddosProtection,
    this.attachPrivateNetwork = const [],
    this.attachVpc = const [],
    this.attachVpc2 = const [],
    this.detachPrivateNetwork = const [],
    this.detachVpc = const [],
    this.detachVpc2 = const [],
    this.enablePrivateNetwork,
    this.enableVpc,
    this.enableVpc2,
    this.label,
    this.tags = const [],
    this.userScheme,
  });

  /// Reinstall the instance with this [Application id](#operation/list-applications).
  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  int? appId;

  /// Reinstall the instance with this [Application image_id](#operation/list-applications).
  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  String? imageId;

  /// Enable automatic backups for the instance.  * enabled * disabled
  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  String? backups;

  /// The [Firewall Group id](#operation/list-firewall-groups) to attach to this Instance.
  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  String? firewallGroupId;

  /// Enable IPv6.  * true
  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  bool? enableIpv6;

  /// Reinstall the instance with this [ISO id](#operation/list-isos).
  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  String? osId;

  /// The user-supplied, base64 encoded [user data](https://docs.vultr.com/manage-instance-user-data-with-the-vultr-metadata-api/) to attach to this instance.
  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  String? userData;

  /// Use `tags` instead. The user-supplied tag.
  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  String? tag;

  /// Upgrade the instance with this [Plan id](#operation/list-plans).
  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  String? plan;

  /// Enable DDoS Protection (there is an additional charge for this).  * true * false
  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  bool? ddosProtection;

  /// Use `attach_vpc` instead. An array of [Private Network ids](#operation/list-networks) to attach to this Instance. This parameter takes precedence over `enable_private_network`. Please choose one parameter.
  List<String> attachPrivateNetwork;

  /// An array of [VPC IDs](#operation/list-vpcs) to attach to this Instance. This parameter takes precedence over `enable_vpc`. Please choose one parameter.
  List<String> attachVpc;

  /// Use `attach_vpc` instead. An array of [VPC IDs](#operation/list-vpc2) to attach to this Instance. This parameter takes precedence over `enable_vpc2`. Please choose one parameter.
  List<String> attachVpc2;

  /// Use `detach_vpc` instead. An array of [Private Network ids](#operation/list-networks) to detach from this Instance. This parameter takes precedence over `enable_private_network`.
  List<String> detachPrivateNetwork;

  /// An array of [VPC IDs](#operation/list-vpcs) to detach from this Instance. This parameter takes precedence over `enable_vpc`.
  List<String> detachVpc;

  /// Use `detach_vpc` instead. An array of [VPC IDs](#operation/list-vpc2) to detach from this Instance. This parameter takes precedence over `enable_vpc2`.
  List<String> detachVpc2;

  /// Use `enable_vpc` instead.  If `true`, private networking support will be added to the new server.  This parameter attaches a single network. When no network exists in the region, it will be automatically created.  If there are multiple private networks in the instance's region, use `attach_private_network` instead to specify a network.
  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  bool? enablePrivateNetwork;

  /// If `true`, VPC support will be added to the new server.  This parameter attaches a single VPC. When no VPC exists in the region, it will be automatically created.  If there are multiple VPCs in the instance's region, use `attach_vpc` instead to specify a VPC.
  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  bool? enableVpc;

  /// Use `enable_vpc` instead.  If `true`, VPC 2.0 support will be added to the new server.  This parameter attaches a single VPC 2.0 network. When no VPC 2.0 network exists in the region, it will be automatically created.  If there are multiple VPC 2.0 networks in the instance's region, use `attach_vpc2` instead to specify a VPC 2.0 network.
  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  bool? enableVpc2;

  /// The user supplied label.
  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  String? label;

  /// Tags to apply to the instance.
  List<String> tags;

  /// Linux-only: The user scheme used for logging into this instance. The instance must be reinstalled for this change to take effect.  * root * limited
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
      other is UpdateInstanceRequest &&
          other.appId == appId &&
          other.imageId == imageId &&
          other.backups == backups &&
          other.firewallGroupId == firewallGroupId &&
          other.enableIpv6 == enableIpv6 &&
          other.osId == osId &&
          other.userData == userData &&
          other.tag == tag &&
          other.plan == plan &&
          other.ddosProtection == ddosProtection &&
          _deepEquality.equals(
              other.attachPrivateNetwork, attachPrivateNetwork) &&
          _deepEquality.equals(other.attachVpc, attachVpc) &&
          _deepEquality.equals(other.attachVpc2, attachVpc2) &&
          _deepEquality.equals(
              other.detachPrivateNetwork, detachPrivateNetwork) &&
          _deepEquality.equals(other.detachVpc, detachVpc) &&
          _deepEquality.equals(other.detachVpc2, detachVpc2) &&
          other.enablePrivateNetwork == enablePrivateNetwork &&
          other.enableVpc == enableVpc &&
          other.enableVpc2 == enableVpc2 &&
          other.label == label &&
          _deepEquality.equals(other.tags, tags) &&
          other.userScheme == userScheme;

  @override
  int get hashCode =>
      // ignore: unnecessary_parenthesis
      (appId == null ? 0 : appId!.hashCode) +
      (imageId == null ? 0 : imageId!.hashCode) +
      (backups == null ? 0 : backups!.hashCode) +
      (firewallGroupId == null ? 0 : firewallGroupId!.hashCode) +
      (enableIpv6 == null ? 0 : enableIpv6!.hashCode) +
      (osId == null ? 0 : osId!.hashCode) +
      (userData == null ? 0 : userData!.hashCode) +
      (tag == null ? 0 : tag!.hashCode) +
      (plan == null ? 0 : plan!.hashCode) +
      (ddosProtection == null ? 0 : ddosProtection!.hashCode) +
      (attachPrivateNetwork.hashCode) +
      (attachVpc.hashCode) +
      (attachVpc2.hashCode) +
      (detachPrivateNetwork.hashCode) +
      (detachVpc.hashCode) +
      (detachVpc2.hashCode) +
      (enablePrivateNetwork == null ? 0 : enablePrivateNetwork!.hashCode) +
      (enableVpc == null ? 0 : enableVpc!.hashCode) +
      (enableVpc2 == null ? 0 : enableVpc2!.hashCode) +
      (label == null ? 0 : label!.hashCode) +
      (tags.hashCode) +
      (userScheme == null ? 0 : userScheme!.hashCode);

  @override
  String toString() =>
      'UpdateInstanceRequest[appId=$appId, imageId=$imageId, backups=$backups, firewallGroupId=$firewallGroupId, enableIpv6=$enableIpv6, osId=$osId, userData=$userData, tag=$tag, plan=$plan, ddosProtection=$ddosProtection, attachPrivateNetwork=$attachPrivateNetwork, attachVpc=$attachVpc, attachVpc2=$attachVpc2, detachPrivateNetwork=$detachPrivateNetwork, detachVpc=$detachVpc, detachVpc2=$detachVpc2, enablePrivateNetwork=$enablePrivateNetwork, enableVpc=$enableVpc, enableVpc2=$enableVpc2, label=$label, tags=$tags, userScheme=$userScheme]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
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
    if (this.backups != null) {
      json[r'backups'] = this.backups;
    } else {
      json[r'backups'] = null;
    }
    if (this.firewallGroupId != null) {
      json[r'firewall_group_id'] = this.firewallGroupId;
    } else {
      json[r'firewall_group_id'] = null;
    }
    if (this.enableIpv6 != null) {
      json[r'enable_ipv6'] = this.enableIpv6;
    } else {
      json[r'enable_ipv6'] = null;
    }
    if (this.osId != null) {
      json[r'os_id'] = this.osId;
    } else {
      json[r'os_id'] = null;
    }
    if (this.userData != null) {
      json[r'user_data'] = this.userData;
    } else {
      json[r'user_data'] = null;
    }
    if (this.tag != null) {
      json[r'tag'] = this.tag;
    } else {
      json[r'tag'] = null;
    }
    if (this.plan != null) {
      json[r'plan'] = this.plan;
    } else {
      json[r'plan'] = null;
    }
    if (this.ddosProtection != null) {
      json[r'ddos_protection'] = this.ddosProtection;
    } else {
      json[r'ddos_protection'] = null;
    }
    json[r'attach_private_network'] = this.attachPrivateNetwork;
    json[r'attach_vpc'] = this.attachVpc;
    json[r'attach_vpc2'] = this.attachVpc2;
    json[r'detach_private_network'] = this.detachPrivateNetwork;
    json[r'detach_vpc'] = this.detachVpc;
    json[r'detach_vpc2'] = this.detachVpc2;
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
    if (this.label != null) {
      json[r'label'] = this.label;
    } else {
      json[r'label'] = null;
    }
    json[r'tags'] = this.tags;
    if (this.userScheme != null) {
      json[r'user_scheme'] = this.userScheme;
    } else {
      json[r'user_scheme'] = null;
    }
    return json;
  }

  /// Returns a new [UpdateInstanceRequest] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static UpdateInstanceRequest? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      assert(() {
        requiredKeys.forEach((key) {
          assert(json.containsKey(key),
              'Required key "UpdateInstanceRequest[$key]" is missing from JSON.');
          assert(json[key] != null,
              'Required key "UpdateInstanceRequest[$key]" has a null value in JSON.');
        });
        return true;
      }());

      return UpdateInstanceRequest(
        appId: mapValueOfType<int>(json, r'app_id'),
        imageId: mapValueOfType<String>(json, r'image_id'),
        backups: mapValueOfType<String>(json, r'backups'),
        firewallGroupId: mapValueOfType<String>(json, r'firewall_group_id'),
        enableIpv6: mapValueOfType<bool>(json, r'enable_ipv6'),
        osId: mapValueOfType<String>(json, r'os_id'),
        userData: mapValueOfType<String>(json, r'user_data'),
        tag: mapValueOfType<String>(json, r'tag'),
        plan: mapValueOfType<String>(json, r'plan'),
        ddosProtection: mapValueOfType<bool>(json, r'ddos_protection'),
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
        detachPrivateNetwork: json[r'detach_private_network'] is Iterable
            ? (json[r'detach_private_network'] as Iterable)
                .cast<String>()
                .toList(growable: false)
            : const [],
        detachVpc: json[r'detach_vpc'] is Iterable
            ? (json[r'detach_vpc'] as Iterable)
                .cast<String>()
                .toList(growable: false)
            : const [],
        detachVpc2: json[r'detach_vpc2'] is Iterable
            ? (json[r'detach_vpc2'] as Iterable)
                .cast<String>()
                .toList(growable: false)
            : const [],
        enablePrivateNetwork:
            mapValueOfType<bool>(json, r'enable_private_network'),
        enableVpc: mapValueOfType<bool>(json, r'enable_vpc'),
        enableVpc2: mapValueOfType<bool>(json, r'enable_vpc2'),
        label: mapValueOfType<String>(json, r'label'),
        tags: json[r'tags'] is Iterable
            ? (json[r'tags'] as Iterable).cast<String>().toList(growable: false)
            : const [],
        userScheme: mapValueOfType<String>(json, r'user_scheme'),
      );
    }
    return null;
  }

  static List<UpdateInstanceRequest> listFromJson(
    dynamic json, {
    bool growable = false,
  }) {
    final result = <UpdateInstanceRequest>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = UpdateInstanceRequest.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, UpdateInstanceRequest> mapFromJson(dynamic json) {
    final map = <String, UpdateInstanceRequest>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = UpdateInstanceRequest.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of UpdateInstanceRequest-objects as value to a dart map
  static Map<String, List<UpdateInstanceRequest>> mapListFromJson(
    dynamic json, {
    bool growable = false,
  }) {
    final map = <String, List<UpdateInstanceRequest>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = UpdateInstanceRequest.listFromJson(
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
