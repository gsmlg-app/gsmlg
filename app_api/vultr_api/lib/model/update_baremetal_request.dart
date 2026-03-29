//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of openapi.api;

class UpdateBaremetalRequest {
  /// Returns a new [UpdateBaremetalRequest] instance.
  UpdateBaremetalRequest({
    this.userData,
    this.label,
    this.tag,
    this.osId,
    this.appId,
    this.imageId,
    this.enableIpv6,
    this.attachVpc2 = const [],
    this.detachVpc2 = const [],
    this.enableVpc2,
    this.tags = const [],
    this.userScheme,
    this.mdiskMode,
    this.ipxeChainUrl,
  });

  /// The user-supplied, base64 encoded [user data](https://docs.vultr.com/manage-instance-user-data-with-the-vultr-metadata-api/) to attach to this instance.
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

  /// Use `tags` instead. The user-supplied tag.
  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  String? tag;

  /// If supplied, reinstall the instance using this [Operating System id](#operation/list-os).
  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  int? osId;

  /// If supplied, reinstall the instance using this [Application id](#operation/list-applications).
  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  int? appId;

  /// If supplied, reinstall the instance using this [Application image_id](#operation/list-applications).
  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  String? imageId;

  /// Enable IPv6.  * true
  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  bool? enableIpv6;

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

  /// Linux-only: The user scheme used for logging into this instance. The instance must be reinstalled for this change to take effect.  * root * limited
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

  /// The URL location of the iPXE chainloader.
  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  String? ipxeChainUrl;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UpdateBaremetalRequest &&
          other.userData == userData &&
          other.label == label &&
          other.tag == tag &&
          other.osId == osId &&
          other.appId == appId &&
          other.imageId == imageId &&
          other.enableIpv6 == enableIpv6 &&
          _deepEquality.equals(other.attachVpc2, attachVpc2) &&
          _deepEquality.equals(other.detachVpc2, detachVpc2) &&
          other.enableVpc2 == enableVpc2 &&
          _deepEquality.equals(other.tags, tags) &&
          other.userScheme == userScheme &&
          other.mdiskMode == mdiskMode &&
          other.ipxeChainUrl == ipxeChainUrl;

  @override
  int get hashCode =>
      // ignore: unnecessary_parenthesis
      (userData == null ? 0 : userData!.hashCode) +
      (label == null ? 0 : label!.hashCode) +
      (tag == null ? 0 : tag!.hashCode) +
      (osId == null ? 0 : osId!.hashCode) +
      (appId == null ? 0 : appId!.hashCode) +
      (imageId == null ? 0 : imageId!.hashCode) +
      (enableIpv6 == null ? 0 : enableIpv6!.hashCode) +
      (attachVpc2.hashCode) +
      (detachVpc2.hashCode) +
      (enableVpc2 == null ? 0 : enableVpc2!.hashCode) +
      (tags.hashCode) +
      (userScheme == null ? 0 : userScheme!.hashCode) +
      (mdiskMode == null ? 0 : mdiskMode!.hashCode) +
      (ipxeChainUrl == null ? 0 : ipxeChainUrl!.hashCode);

  @override
  String toString() =>
      'UpdateBaremetalRequest[userData=$userData, label=$label, tag=$tag, osId=$osId, appId=$appId, imageId=$imageId, enableIpv6=$enableIpv6, attachVpc2=$attachVpc2, detachVpc2=$detachVpc2, enableVpc2=$enableVpc2, tags=$tags, userScheme=$userScheme, mdiskMode=$mdiskMode, ipxeChainUrl=$ipxeChainUrl]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
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
    if (this.enableIpv6 != null) {
      json[r'enable_ipv6'] = this.enableIpv6;
    } else {
      json[r'enable_ipv6'] = null;
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
    if (this.ipxeChainUrl != null) {
      json[r'ipxe_chain_url'] = this.ipxeChainUrl;
    } else {
      json[r'ipxe_chain_url'] = null;
    }
    return json;
  }

  /// Returns a new [UpdateBaremetalRequest] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static UpdateBaremetalRequest? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      assert(() {
        requiredKeys.forEach((key) {
          assert(json.containsKey(key),
              'Required key "UpdateBaremetalRequest[$key]" is missing from JSON.');
          assert(json[key] != null,
              'Required key "UpdateBaremetalRequest[$key]" has a null value in JSON.');
        });
        return true;
      }());

      return UpdateBaremetalRequest(
        userData: mapValueOfType<String>(json, r'user_data'),
        label: mapValueOfType<String>(json, r'label'),
        tag: mapValueOfType<String>(json, r'tag'),
        osId: mapValueOfType<int>(json, r'os_id'),
        appId: mapValueOfType<int>(json, r'app_id'),
        imageId: mapValueOfType<String>(json, r'image_id'),
        enableIpv6: mapValueOfType<bool>(json, r'enable_ipv6'),
        attachVpc2: json[r'attach_vpc2'] is Iterable
            ? (json[r'attach_vpc2'] as Iterable)
                .cast<String>()
                .toList(growable: false)
            : const [],
        detachVpc2: json[r'detach_vpc2'] is Iterable
            ? (json[r'detach_vpc2'] as Iterable)
                .cast<String>()
                .toList(growable: false)
            : const [],
        enableVpc2: mapValueOfType<bool>(json, r'enable_vpc2'),
        tags: json[r'tags'] is Iterable
            ? (json[r'tags'] as Iterable).cast<String>().toList(growable: false)
            : const [],
        userScheme: mapValueOfType<String>(json, r'user_scheme'),
        mdiskMode: mapValueOfType<String>(json, r'mdisk_mode'),
        ipxeChainUrl: mapValueOfType<String>(json, r'ipxe_chain_url'),
      );
    }
    return null;
  }

  static List<UpdateBaremetalRequest> listFromJson(
    dynamic json, {
    bool growable = false,
  }) {
    final result = <UpdateBaremetalRequest>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = UpdateBaremetalRequest.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, UpdateBaremetalRequest> mapFromJson(dynamic json) {
    final map = <String, UpdateBaremetalRequest>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = UpdateBaremetalRequest.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of UpdateBaremetalRequest-objects as value to a dart map
  static Map<String, List<UpdateBaremetalRequest>> mapListFromJson(
    dynamic json, {
    bool growable = false,
  }) {
    final map = <String, List<UpdateBaremetalRequest>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = UpdateBaremetalRequest.listFromJson(
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
