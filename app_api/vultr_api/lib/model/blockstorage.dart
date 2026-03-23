//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of openapi.api;

class Blockstorage {
  /// Returns a new [Blockstorage] instance.
  Blockstorage({
    this.id,
    this.cost,
    this.status,
    this.sizeGb,
    this.region,
    this.attachedToInstance,
    this.dateCreated,
    this.label,
    this.mountId,
  });

  /// A unique ID for the Block Storage.
  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  String? id;

  /// The monthly cost of this Block Storage.
  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  int? cost;

  /// The current status of this Block Storage.  * active
  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  String? status;

  /// Size of the Block Storage in GB.
  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  int? sizeGb;

  /// The [Region id](#operation/list-regions) where the Block Storage is located.
  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  String? region;

  /// The [Instance id](#operation/list-instances) with this Block Storage attached.
  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  String? attachedToInstance;

  /// The date this Block Storage was created.
  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  String? dateCreated;

  /// The user-supplied label.
  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  String? label;

  /// An ID associated with the instance, when mounted the ID can be found in /dev/disk/by-id prefixed with virtio.
  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  String? mountId;

  @override
  bool operator ==(Object other) => identical(this, other) || other is Blockstorage &&
    other.id == id &&
    other.cost == cost &&
    other.status == status &&
    other.sizeGb == sizeGb &&
    other.region == region &&
    other.attachedToInstance == attachedToInstance &&
    other.dateCreated == dateCreated &&
    other.label == label &&
    other.mountId == mountId;

  @override
  int get hashCode =>
    // ignore: unnecessary_parenthesis
    (id == null ? 0 : id!.hashCode) +
    (cost == null ? 0 : cost!.hashCode) +
    (status == null ? 0 : status!.hashCode) +
    (sizeGb == null ? 0 : sizeGb!.hashCode) +
    (region == null ? 0 : region!.hashCode) +
    (attachedToInstance == null ? 0 : attachedToInstance!.hashCode) +
    (dateCreated == null ? 0 : dateCreated!.hashCode) +
    (label == null ? 0 : label!.hashCode) +
    (mountId == null ? 0 : mountId!.hashCode);

  @override
  String toString() => 'Blockstorage[id=$id, cost=$cost, status=$status, sizeGb=$sizeGb, region=$region, attachedToInstance=$attachedToInstance, dateCreated=$dateCreated, label=$label, mountId=$mountId]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
    if (this.id != null) {
      json[r'id'] = this.id;
    } else {
      json[r'id'] = null;
    }
    if (this.cost != null) {
      json[r'cost'] = this.cost;
    } else {
      json[r'cost'] = null;
    }
    if (this.status != null) {
      json[r'status'] = this.status;
    } else {
      json[r'status'] = null;
    }
    if (this.sizeGb != null) {
      json[r'size_gb'] = this.sizeGb;
    } else {
      json[r'size_gb'] = null;
    }
    if (this.region != null) {
      json[r'region'] = this.region;
    } else {
      json[r'region'] = null;
    }
    if (this.attachedToInstance != null) {
      json[r'attached_to_instance'] = this.attachedToInstance;
    } else {
      json[r'attached_to_instance'] = null;
    }
    if (this.dateCreated != null) {
      json[r'date_created'] = this.dateCreated;
    } else {
      json[r'date_created'] = null;
    }
    if (this.label != null) {
      json[r'label'] = this.label;
    } else {
      json[r'label'] = null;
    }
    if (this.mountId != null) {
      json[r'mount_id'] = this.mountId;
    } else {
      json[r'mount_id'] = null;
    }
    return json;
  }

  /// Returns a new [Blockstorage] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static Blockstorage? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      assert(() {
        requiredKeys.forEach((key) {
          assert(json.containsKey(key), 'Required key "Blockstorage[$key]" is missing from JSON.');
          assert(json[key] != null, 'Required key "Blockstorage[$key]" has a null value in JSON.');
        });
        return true;
      }());

      return Blockstorage(
        id: mapValueOfType<String>(json, r'id'),
        cost: mapValueOfType<int>(json, r'cost'),
        status: mapValueOfType<String>(json, r'status'),
        sizeGb: mapValueOfType<int>(json, r'size_gb'),
        region: mapValueOfType<String>(json, r'region'),
        attachedToInstance: mapValueOfType<String>(json, r'attached_to_instance'),
        dateCreated: mapValueOfType<String>(json, r'date_created'),
        label: mapValueOfType<String>(json, r'label'),
        mountId: mapValueOfType<String>(json, r'mount_id'),
      );
    }
    return null;
  }

  static List<Blockstorage> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <Blockstorage>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = Blockstorage.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, Blockstorage> mapFromJson(dynamic json) {
    final map = <String, Blockstorage>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = Blockstorage.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of Blockstorage-objects as value to a dart map
  static Map<String, List<Blockstorage>> mapListFromJson(dynamic json, {bool growable = false,}) {
    final map = <String, List<Blockstorage>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = Blockstorage.listFromJson(entry.value, growable: growable,);
      }
    }
    return map;
  }

  /// The list of required keys that must be present in a JSON.
  static const requiredKeys = <String>{
  };
}

