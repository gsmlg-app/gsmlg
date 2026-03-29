//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of openapi.api;

class DnsRecord {
  /// Returns a new [DnsRecord] instance.
  DnsRecord({
    this.id,
    this.type,
    this.name,
    this.data,
    this.priority,
    this.ttl,
  });

  /// A unique ID for the DNS Record.
  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  String? id;

  /// The DNS record type.  * A * AAAA * CNAME * NS * MX * SRV * TXT * CAA * SSHFP
  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  String? type;

  /// The hostname for this DNS record.
  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  String? name;

  /// The DNS data for this record type.
  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  String? data;

  /// DNS priority. Does not apply to all record types.
  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  int? priority;

  /// Time to Live in seconds.
  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  int? ttl;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DnsRecord &&
          other.id == id &&
          other.type == type &&
          other.name == name &&
          other.data == data &&
          other.priority == priority &&
          other.ttl == ttl;

  @override
  int get hashCode =>
      // ignore: unnecessary_parenthesis
      (id == null ? 0 : id!.hashCode) +
      (type == null ? 0 : type!.hashCode) +
      (name == null ? 0 : name!.hashCode) +
      (data == null ? 0 : data!.hashCode) +
      (priority == null ? 0 : priority!.hashCode) +
      (ttl == null ? 0 : ttl!.hashCode);

  @override
  String toString() =>
      'DnsRecord[id=$id, type=$type, name=$name, data=$data, priority=$priority, ttl=$ttl]';

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
    if (this.name != null) {
      json[r'name'] = this.name;
    } else {
      json[r'name'] = null;
    }
    if (this.data != null) {
      json[r'data'] = this.data;
    } else {
      json[r'data'] = null;
    }
    if (this.priority != null) {
      json[r'priority'] = this.priority;
    } else {
      json[r'priority'] = null;
    }
    if (this.ttl != null) {
      json[r'ttl'] = this.ttl;
    } else {
      json[r'ttl'] = null;
    }
    return json;
  }

  /// Returns a new [DnsRecord] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static DnsRecord? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      assert(() {
        requiredKeys.forEach((key) {
          assert(json.containsKey(key),
              'Required key "DnsRecord[$key]" is missing from JSON.');
          assert(json[key] != null,
              'Required key "DnsRecord[$key]" has a null value in JSON.');
        });
        return true;
      }());

      return DnsRecord(
        id: mapValueOfType<String>(json, r'id'),
        type: mapValueOfType<String>(json, r'type'),
        name: mapValueOfType<String>(json, r'name'),
        data: mapValueOfType<String>(json, r'data'),
        priority: mapValueOfType<int>(json, r'priority'),
        ttl: mapValueOfType<int>(json, r'ttl'),
      );
    }
    return null;
  }

  static List<DnsRecord> listFromJson(
    dynamic json, {
    bool growable = false,
  }) {
    final result = <DnsRecord>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = DnsRecord.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, DnsRecord> mapFromJson(dynamic json) {
    final map = <String, DnsRecord>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = DnsRecord.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of DnsRecord-objects as value to a dart map
  static Map<String, List<DnsRecord>> mapListFromJson(
    dynamic json, {
    bool growable = false,
  }) {
    final map = <String, List<DnsRecord>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = DnsRecord.listFromJson(
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
