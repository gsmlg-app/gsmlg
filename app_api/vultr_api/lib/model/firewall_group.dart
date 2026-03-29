//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of openapi.api;

class FirewallGroup {
  /// Returns a new [FirewallGroup] instance.
  FirewallGroup({
    this.id,
    this.description,
    this.dateCreated,
    this.dateModified,
    this.instanceCount,
    this.ruleCount,
    this.maxRuleCount,
  });

  /// A unique ID for the Firewall Group.
  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  String? id;

  /// User-supplied description of this Firewall Group.
  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  String? description;

  /// Date the Firewall Group was originally created.
  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  String? dateCreated;

  /// Date of the last modification to this Firewall Group.
  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  String? dateModified;

  /// The number of instances linked to this Firewall Group.
  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  int? instanceCount;

  /// The number of rules in this Firewall Group.
  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  int? ruleCount;

  /// The maximum number of rules allowed for this Firewall Group.
  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  int? maxRuleCount;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FirewallGroup &&
          other.id == id &&
          other.description == description &&
          other.dateCreated == dateCreated &&
          other.dateModified == dateModified &&
          other.instanceCount == instanceCount &&
          other.ruleCount == ruleCount &&
          other.maxRuleCount == maxRuleCount;

  @override
  int get hashCode =>
      // ignore: unnecessary_parenthesis
      (id == null ? 0 : id!.hashCode) +
      (description == null ? 0 : description!.hashCode) +
      (dateCreated == null ? 0 : dateCreated!.hashCode) +
      (dateModified == null ? 0 : dateModified!.hashCode) +
      (instanceCount == null ? 0 : instanceCount!.hashCode) +
      (ruleCount == null ? 0 : ruleCount!.hashCode) +
      (maxRuleCount == null ? 0 : maxRuleCount!.hashCode);

  @override
  String toString() =>
      'FirewallGroup[id=$id, description=$description, dateCreated=$dateCreated, dateModified=$dateModified, instanceCount=$instanceCount, ruleCount=$ruleCount, maxRuleCount=$maxRuleCount]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
    if (this.id != null) {
      json[r'id'] = this.id;
    } else {
      json[r'id'] = null;
    }
    if (this.description != null) {
      json[r'description'] = this.description;
    } else {
      json[r'description'] = null;
    }
    if (this.dateCreated != null) {
      json[r'date_created'] = this.dateCreated;
    } else {
      json[r'date_created'] = null;
    }
    if (this.dateModified != null) {
      json[r'date_modified'] = this.dateModified;
    } else {
      json[r'date_modified'] = null;
    }
    if (this.instanceCount != null) {
      json[r'instance_count'] = this.instanceCount;
    } else {
      json[r'instance_count'] = null;
    }
    if (this.ruleCount != null) {
      json[r'rule_count'] = this.ruleCount;
    } else {
      json[r'rule_count'] = null;
    }
    if (this.maxRuleCount != null) {
      json[r'max_rule_count'] = this.maxRuleCount;
    } else {
      json[r'max_rule_count'] = null;
    }
    return json;
  }

  /// Returns a new [FirewallGroup] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static FirewallGroup? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      assert(() {
        requiredKeys.forEach((key) {
          assert(json.containsKey(key),
              'Required key "FirewallGroup[$key]" is missing from JSON.');
          assert(json[key] != null,
              'Required key "FirewallGroup[$key]" has a null value in JSON.');
        });
        return true;
      }());

      return FirewallGroup(
        id: mapValueOfType<String>(json, r'id'),
        description: mapValueOfType<String>(json, r'description'),
        dateCreated: mapValueOfType<String>(json, r'date_created'),
        dateModified: mapValueOfType<String>(json, r'date_modified'),
        instanceCount: mapValueOfType<int>(json, r'instance_count'),
        ruleCount: mapValueOfType<int>(json, r'rule_count'),
        maxRuleCount: mapValueOfType<int>(json, r'max_rule_count'),
      );
    }
    return null;
  }

  static List<FirewallGroup> listFromJson(
    dynamic json, {
    bool growable = false,
  }) {
    final result = <FirewallGroup>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = FirewallGroup.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, FirewallGroup> mapFromJson(dynamic json) {
    final map = <String, FirewallGroup>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = FirewallGroup.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of FirewallGroup-objects as value to a dart map
  static Map<String, List<FirewallGroup>> mapListFromJson(
    dynamic json, {
    bool growable = false,
  }) {
    final map = <String, List<FirewallGroup>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = FirewallGroup.listFromJson(
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
