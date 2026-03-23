//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of openapi.api;

class UpdateDnsDomainRecordRequest {
  /// Returns a new [UpdateDnsDomainRecordRequest] instance.
  UpdateDnsDomainRecordRequest({
    this.name,
    this.data,
    this.ttl,
    this.priority,
  });

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

  /// Time to Live in seconds.
  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  int? ttl;

  /// DNS priority. Does not apply to all record types.
  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  int? priority;

  @override
  bool operator ==(Object other) => identical(this, other) || other is UpdateDnsDomainRecordRequest &&
    other.name == name &&
    other.data == data &&
    other.ttl == ttl &&
    other.priority == priority;

  @override
  int get hashCode =>
    // ignore: unnecessary_parenthesis
    (name == null ? 0 : name!.hashCode) +
    (data == null ? 0 : data!.hashCode) +
    (ttl == null ? 0 : ttl!.hashCode) +
    (priority == null ? 0 : priority!.hashCode);

  @override
  String toString() => 'UpdateDnsDomainRecordRequest[name=$name, data=$data, ttl=$ttl, priority=$priority]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
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
    if (this.ttl != null) {
      json[r'ttl'] = this.ttl;
    } else {
      json[r'ttl'] = null;
    }
    if (this.priority != null) {
      json[r'priority'] = this.priority;
    } else {
      json[r'priority'] = null;
    }
    return json;
  }

  /// Returns a new [UpdateDnsDomainRecordRequest] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static UpdateDnsDomainRecordRequest? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      assert(() {
        requiredKeys.forEach((key) {
          assert(json.containsKey(key), 'Required key "UpdateDnsDomainRecordRequest[$key]" is missing from JSON.');
          assert(json[key] != null, 'Required key "UpdateDnsDomainRecordRequest[$key]" has a null value in JSON.');
        });
        return true;
      }());

      return UpdateDnsDomainRecordRequest(
        name: mapValueOfType<String>(json, r'name'),
        data: mapValueOfType<String>(json, r'data'),
        ttl: mapValueOfType<int>(json, r'ttl'),
        priority: mapValueOfType<int>(json, r'priority'),
      );
    }
    return null;
  }

  static List<UpdateDnsDomainRecordRequest> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <UpdateDnsDomainRecordRequest>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = UpdateDnsDomainRecordRequest.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, UpdateDnsDomainRecordRequest> mapFromJson(dynamic json) {
    final map = <String, UpdateDnsDomainRecordRequest>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = UpdateDnsDomainRecordRequest.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of UpdateDnsDomainRecordRequest-objects as value to a dart map
  static Map<String, List<UpdateDnsDomainRecordRequest>> mapListFromJson(dynamic json, {bool growable = false,}) {
    final map = <String, List<UpdateDnsDomainRecordRequest>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = UpdateDnsDomainRecordRequest.listFromJson(entry.value, growable: growable,);
      }
    }
    return map;
  }

  /// The list of required keys that must be present in a JSON.
  static const requiredKeys = <String>{
  };
}

