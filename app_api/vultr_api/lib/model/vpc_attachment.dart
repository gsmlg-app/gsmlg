//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of openapi.api;

class VpcAttachment {
  /// Returns a new [VpcAttachment] instance.
  VpcAttachment({
    this.id,
    this.type,
    this.macAddress,
    this.dateAdded,
    this.ip,
    this.linkedSubscription,
  });

  /// The ID of the VPS or BareMetal Subscription attached to this VPC.
  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  String? id;

  /// The type of subscription attached, either vps or baremetal.
  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  String? type;

  /// The Mac Address of the attached interface.
  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  String? macAddress;

  /// The date this VPC was attached to this subscription.
  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  String? dateAdded;

  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  VpcAttachmentIp? ip;

  VpcAttachmentLinkedSubscription? linkedSubscription;

  @override
  bool operator ==(Object other) => identical(this, other) || other is VpcAttachment &&
    other.id == id &&
    other.type == type &&
    other.macAddress == macAddress &&
    other.dateAdded == dateAdded &&
    other.ip == ip &&
    other.linkedSubscription == linkedSubscription;

  @override
  int get hashCode =>
    // ignore: unnecessary_parenthesis
    (id == null ? 0 : id!.hashCode) +
    (type == null ? 0 : type!.hashCode) +
    (macAddress == null ? 0 : macAddress!.hashCode) +
    (dateAdded == null ? 0 : dateAdded!.hashCode) +
    (ip == null ? 0 : ip!.hashCode) +
    (linkedSubscription == null ? 0 : linkedSubscription!.hashCode);

  @override
  String toString() => 'VpcAttachment[id=$id, type=$type, macAddress=$macAddress, dateAdded=$dateAdded, ip=$ip, linkedSubscription=$linkedSubscription]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
    if (this.id != null) {
      json[r'id'] = this.id;
    } else {
      json[r'id'] = null;
    }
    if (this.type != null) {
      json[r'type'] = this.type;
    } else {
      json[r'type'] = null;
    }
    if (this.macAddress != null) {
      json[r'mac_address'] = this.macAddress;
    } else {
      json[r'mac_address'] = null;
    }
    if (this.dateAdded != null) {
      json[r'date_added'] = this.dateAdded;
    } else {
      json[r'date_added'] = null;
    }
    if (this.ip != null) {
      json[r'ip'] = this.ip;
    } else {
      json[r'ip'] = null;
    }
    if (this.linkedSubscription != null) {
      json[r'linked_subscription'] = this.linkedSubscription;
    } else {
      json[r'linked_subscription'] = null;
    }
    return json;
  }

  /// Returns a new [VpcAttachment] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static VpcAttachment? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      assert(() {
        requiredKeys.forEach((key) {
          assert(json.containsKey(key), 'Required key "VpcAttachment[$key]" is missing from JSON.');
          assert(json[key] != null, 'Required key "VpcAttachment[$key]" has a null value in JSON.');
        });
        return true;
      }());

      return VpcAttachment(
        id: mapValueOfType<String>(json, r'id'),
        type: mapValueOfType<String>(json, r'type'),
        macAddress: mapValueOfType<String>(json, r'mac_address'),
        dateAdded: mapValueOfType<String>(json, r'date_added'),
        ip: VpcAttachmentIp.fromJson(json[r'ip']),
        linkedSubscription: VpcAttachmentLinkedSubscription.fromJson(json[r'linked_subscription']),
      );
    }
    return null;
  }

  static List<VpcAttachment> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <VpcAttachment>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = VpcAttachment.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, VpcAttachment> mapFromJson(dynamic json) {
    final map = <String, VpcAttachment>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = VpcAttachment.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of VpcAttachment-objects as value to a dart map
  static Map<String, List<VpcAttachment>> mapListFromJson(dynamic json, {bool growable = false,}) {
    final map = <String, List<VpcAttachment>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = VpcAttachment.listFromJson(entry.value, growable: growable,);
      }
    }
    return map;
  }

  /// The list of required keys that must be present in a JSON.
  static const requiredKeys = <String>{
  };
}

