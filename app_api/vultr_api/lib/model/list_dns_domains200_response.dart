//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of openapi.api;

class ListDnsDomains200Response {
  /// Returns a new [ListDnsDomains200Response] instance.
  ListDnsDomains200Response({
    this.domains = const [],
    this.meta,
  });

  List<Domain> domains;

  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  Meta? meta;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ListDnsDomains200Response &&
          _deepEquality.equals(other.domains, domains) &&
          other.meta == meta;

  @override
  int get hashCode =>
      // ignore: unnecessary_parenthesis
      (domains.hashCode) + (meta == null ? 0 : meta!.hashCode);

  @override
  String toString() =>
      'ListDnsDomains200Response[domains=$domains, meta=$meta]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
    json[r'domains'] = this.domains;
    if (this.meta != null) {
      json[r'meta'] = this.meta;
    } else {
      json[r'meta'] = null;
    }
    return json;
  }

  /// Returns a new [ListDnsDomains200Response] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static ListDnsDomains200Response? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      assert(() {
        requiredKeys.forEach((key) {
          assert(json.containsKey(key),
              'Required key "ListDnsDomains200Response[$key]" is missing from JSON.');
          assert(json[key] != null,
              'Required key "ListDnsDomains200Response[$key]" has a null value in JSON.');
        });
        return true;
      }());

      return ListDnsDomains200Response(
        domains: Domain.listFromJson(json[r'domains']),
        meta: Meta.fromJson(json[r'meta']),
      );
    }
    return null;
  }

  static List<ListDnsDomains200Response> listFromJson(
    dynamic json, {
    bool growable = false,
  }) {
    final result = <ListDnsDomains200Response>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = ListDnsDomains200Response.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, ListDnsDomains200Response> mapFromJson(dynamic json) {
    final map = <String, ListDnsDomains200Response>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = ListDnsDomains200Response.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of ListDnsDomains200Response-objects as value to a dart map
  static Map<String, List<ListDnsDomains200Response>> mapListFromJson(
    dynamic json, {
    bool growable = false,
  }) {
    final map = <String, List<ListDnsDomains200Response>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = ListDnsDomains200Response.listFromJson(
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
