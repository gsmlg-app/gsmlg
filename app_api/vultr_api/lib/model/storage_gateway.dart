//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of openapi.api;

class StorageGateway {
  /// Returns a new [StorageGateway] instance.
  StorageGateway({
    this.id,
    this.dateCreated,
    this.status,
    this.type,
    this.label,
    this.pendingCharges,
    this.tags = const [],
    this.health,
    this.networkConfig,
    this.exportConfig,
  });

  /// A unique ID for the Storage Gateway.
  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  String? id;

  /// Date the Storage Gateway was created.
  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  String? dateCreated;

  /// The status of this Storage Gateway. * active * pending
  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  String? status;

  /// The type of Storage Gateway.
  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  String? type;

  /// The user-supplied label for this Storage Gateway.
  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  String? label;

  /// The current charges for this subscription.
  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  double? pendingCharges;

  /// Tags to apply to the instance.
  List<String> tags;

  /// Quick reference variable to ensure your gateway is running.
  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  String? health;

  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  StorageGatewayNetwork? networkConfig;

  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  StorageGatewayExport? exportConfig;

  @override
  bool operator ==(Object other) => identical(this, other) || other is StorageGateway &&
    other.id == id &&
    other.dateCreated == dateCreated &&
    other.status == status &&
    other.type == type &&
    other.label == label &&
    other.pendingCharges == pendingCharges &&
    _deepEquality.equals(other.tags, tags) &&
    other.health == health &&
    other.networkConfig == networkConfig &&
    other.exportConfig == exportConfig;

  @override
  int get hashCode =>
    // ignore: unnecessary_parenthesis
    (id == null ? 0 : id!.hashCode) +
    (dateCreated == null ? 0 : dateCreated!.hashCode) +
    (status == null ? 0 : status!.hashCode) +
    (type == null ? 0 : type!.hashCode) +
    (label == null ? 0 : label!.hashCode) +
    (pendingCharges == null ? 0 : pendingCharges!.hashCode) +
    (tags.hashCode) +
    (health == null ? 0 : health!.hashCode) +
    (networkConfig == null ? 0 : networkConfig!.hashCode) +
    (exportConfig == null ? 0 : exportConfig!.hashCode);

  @override
  String toString() => 'StorageGateway[id=$id, dateCreated=$dateCreated, status=$status, type=$type, label=$label, pendingCharges=$pendingCharges, tags=$tags, health=$health, networkConfig=$networkConfig, exportConfig=$exportConfig]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
    if (this.id != null) {
      json[r'id'] = this.id;
    } else {
      json[r'id'] = null;
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
    if (this.type != null) {
      json[r'type'] = this.type;
    } else {
      json[r'type'] = null;
    }
    if (this.label != null) {
      json[r'label'] = this.label;
    } else {
      json[r'label'] = null;
    }
    if (this.pendingCharges != null) {
      json[r'pending_charges'] = this.pendingCharges;
    } else {
      json[r'pending_charges'] = null;
    }
      json[r'tags'] = this.tags;
    if (this.health != null) {
      json[r'health'] = this.health;
    } else {
      json[r'health'] = null;
    }
    if (this.networkConfig != null) {
      json[r'network_config'] = this.networkConfig;
    } else {
      json[r'network_config'] = null;
    }
    if (this.exportConfig != null) {
      json[r'export_config'] = this.exportConfig;
    } else {
      json[r'export_config'] = null;
    }
    return json;
  }

  /// Returns a new [StorageGateway] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static StorageGateway? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      assert(() {
        requiredKeys.forEach((key) {
          assert(json.containsKey(key), 'Required key "StorageGateway[$key]" is missing from JSON.');
          assert(json[key] != null, 'Required key "StorageGateway[$key]" has a null value in JSON.');
        });
        return true;
      }());

      return StorageGateway(
        id: mapValueOfType<String>(json, r'id'),
        dateCreated: mapValueOfType<String>(json, r'date_created'),
        status: mapValueOfType<String>(json, r'status'),
        type: mapValueOfType<String>(json, r'type'),
        label: mapValueOfType<String>(json, r'label'),
        pendingCharges: mapValueOfType<double>(json, r'pending_charges'),
        tags: json[r'tags'] is Iterable
            ? (json[r'tags'] as Iterable).cast<String>().toList(growable: false)
            : const [],
        health: mapValueOfType<String>(json, r'health'),
        networkConfig: StorageGatewayNetwork.fromJson(json[r'network_config']),
        exportConfig: StorageGatewayExport.fromJson(json[r'export_config']),
      );
    }
    return null;
  }

  static List<StorageGateway> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <StorageGateway>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = StorageGateway.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, StorageGateway> mapFromJson(dynamic json) {
    final map = <String, StorageGateway>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = StorageGateway.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of StorageGateway-objects as value to a dart map
  static Map<String, List<StorageGateway>> mapListFromJson(dynamic json, {bool growable = false,}) {
    final map = <String, List<StorageGateway>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = StorageGateway.listFromJson(entry.value, growable: growable,);
      }
    }
    return map;
  }

  /// The list of required keys that must be present in a JSON.
  static const requiredKeys = <String>{
  };
}

