//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of openapi.api;

class GetDnsDomainDnssec200Response {
  /// Returns a new [GetDnsDomainDnssec200Response] instance.
  GetDnsDomainDnssec200Response({
    this.dnsSec = const [],
  });

  List<String> dnsSec;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is GetDnsDomainDnssec200Response &&
          _deepEquality.equals(other.dnsSec, dnsSec);

  @override
  int get hashCode =>
      // ignore: unnecessary_parenthesis
      (dnsSec.hashCode);

  @override
  String toString() => 'GetDnsDomainDnssec200Response[dnsSec=$dnsSec]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
    json[r'dns_sec'] = this.dnsSec;
    return json;
  }

  /// Returns a new [GetDnsDomainDnssec200Response] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static GetDnsDomainDnssec200Response? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      assert(() {
        requiredKeys.forEach((key) {
          assert(json.containsKey(key),
              'Required key "GetDnsDomainDnssec200Response[$key]" is missing from JSON.');
          assert(json[key] != null,
              'Required key "GetDnsDomainDnssec200Response[$key]" has a null value in JSON.');
        });
        return true;
      }());

      return GetDnsDomainDnssec200Response(
        dnsSec: json[r'dns_sec'] is Iterable
            ? (json[r'dns_sec'] as Iterable)
                .cast<String>()
                .toList(growable: false)
            : const [],
      );
    }
    return null;
  }

  static List<GetDnsDomainDnssec200Response> listFromJson(
    dynamic json, {
    bool growable = false,
  }) {
    final result = <GetDnsDomainDnssec200Response>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = GetDnsDomainDnssec200Response.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, GetDnsDomainDnssec200Response> mapFromJson(dynamic json) {
    final map = <String, GetDnsDomainDnssec200Response>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = GetDnsDomainDnssec200Response.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of GetDnsDomainDnssec200Response-objects as value to a dart map
  static Map<String, List<GetDnsDomainDnssec200Response>> mapListFromJson(
    dynamic json, {
    bool growable = false,
  }) {
    final map = <String, List<GetDnsDomainDnssec200Response>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = GetDnsDomainDnssec200Response.listFromJson(
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
