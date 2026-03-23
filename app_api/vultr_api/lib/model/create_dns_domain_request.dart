//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of openapi.api;

class CreateDnsDomainRequest {
  /// Returns a new [CreateDnsDomainRequest] instance.
  CreateDnsDomainRequest({
    required this.domain,
    this.ip,
    this.dnsSec,
  });

  /// Your registered DNS Domain name.
  String domain;

  /// The default IP address for your DNS Domain. If omitted an empty domain zone will be created.
  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  String? ip;

  /// Enable or disable DNSSEC.  * enabled * disabled (default)
  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  String? dnsSec;

  @override
  bool operator ==(Object other) => identical(this, other) || other is CreateDnsDomainRequest &&
    other.domain == domain &&
    other.ip == ip &&
    other.dnsSec == dnsSec;

  @override
  int get hashCode =>
    // ignore: unnecessary_parenthesis
    (domain.hashCode) +
    (ip == null ? 0 : ip!.hashCode) +
    (dnsSec == null ? 0 : dnsSec!.hashCode);

  @override
  String toString() => 'CreateDnsDomainRequest[domain=$domain, ip=$ip, dnsSec=$dnsSec]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
      json[r'domain'] = this.domain;
    if (this.ip != null) {
      json[r'ip'] = this.ip;
    } else {
      json[r'ip'] = null;
    }
    if (this.dnsSec != null) {
      json[r'dns_sec'] = this.dnsSec;
    } else {
      json[r'dns_sec'] = null;
    }
    return json;
  }

  /// Returns a new [CreateDnsDomainRequest] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static CreateDnsDomainRequest? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      assert(() {
        requiredKeys.forEach((key) {
          assert(json.containsKey(key), 'Required key "CreateDnsDomainRequest[$key]" is missing from JSON.');
          assert(json[key] != null, 'Required key "CreateDnsDomainRequest[$key]" has a null value in JSON.');
        });
        return true;
      }());

      return CreateDnsDomainRequest(
        domain: mapValueOfType<String>(json, r'domain')!,
        ip: mapValueOfType<String>(json, r'ip'),
        dnsSec: mapValueOfType<String>(json, r'dns_sec'),
      );
    }
    return null;
  }

  static List<CreateDnsDomainRequest> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <CreateDnsDomainRequest>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = CreateDnsDomainRequest.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, CreateDnsDomainRequest> mapFromJson(dynamic json) {
    final map = <String, CreateDnsDomainRequest>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = CreateDnsDomainRequest.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of CreateDnsDomainRequest-objects as value to a dart map
  static Map<String, List<CreateDnsDomainRequest>> mapListFromJson(dynamic json, {bool growable = false,}) {
    final map = <String, List<CreateDnsDomainRequest>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = CreateDnsDomainRequest.listFromJson(entry.value, growable: growable,);
      }
    }
    return map;
  }

  /// The list of required keys that must be present in a JSON.
  static const requiredKeys = <String>{
    'domain',
  };
}

