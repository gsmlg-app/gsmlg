//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of openapi.api;

class Domain {
  /// Returns a new [Domain] instance.
  Domain({
    this.domain,
    this.dateCreated,
    this.dnsSec,
  });

  /// Your registered domain name.
  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  String? domain;

  /// Date the DNS Domain was created.
  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  String? dateCreated;

  /// The domain's DNSSEC status  * enabled * disabled
  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  String? dnsSec;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Domain &&
          other.domain == domain &&
          other.dateCreated == dateCreated &&
          other.dnsSec == dnsSec;

  @override
  int get hashCode =>
      // ignore: unnecessary_parenthesis
      (domain == null ? 0 : domain!.hashCode) +
      (dateCreated == null ? 0 : dateCreated!.hashCode) +
      (dnsSec == null ? 0 : dnsSec!.hashCode);

  @override
  String toString() =>
      'Domain[domain=$domain, dateCreated=$dateCreated, dnsSec=$dnsSec]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
    if (this.domain != null) {
      json[r'domain'] = this.domain;
    } else {
      json[r'domain'] = null;
    }
    if (this.dateCreated != null) {
      json[r'date_created'] = this.dateCreated;
    } else {
      json[r'date_created'] = null;
    }
    if (this.dnsSec != null) {
      json[r'dns_sec'] = this.dnsSec;
    } else {
      json[r'dns_sec'] = null;
    }
    return json;
  }

  /// Returns a new [Domain] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static Domain? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      assert(() {
        requiredKeys.forEach((key) {
          assert(json.containsKey(key),
              'Required key "Domain[$key]" is missing from JSON.');
          assert(json[key] != null,
              'Required key "Domain[$key]" has a null value in JSON.');
        });
        return true;
      }());

      return Domain(
        domain: mapValueOfType<String>(json, r'domain'),
        dateCreated: mapValueOfType<String>(json, r'date_created'),
        dnsSec: mapValueOfType<String>(json, r'dns_sec'),
      );
    }
    return null;
  }

  static List<Domain> listFromJson(
    dynamic json, {
    bool growable = false,
  }) {
    final result = <Domain>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = Domain.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, Domain> mapFromJson(dynamic json) {
    final map = <String, Domain>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = Domain.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of Domain-objects as value to a dart map
  static Map<String, List<Domain>> mapListFromJson(
    dynamic json, {
    bool growable = false,
  }) {
    final map = <String, List<Domain>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = Domain.listFromJson(
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
