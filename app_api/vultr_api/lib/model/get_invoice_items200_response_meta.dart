//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of openapi.api;

class GetInvoiceItems200ResponseMeta {
  /// Returns a new [GetInvoiceItems200ResponseMeta] instance.
  GetInvoiceItems200ResponseMeta({
    this.total,
    this.links,
  });

  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  num? total;

  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  GetInvoiceItems200ResponseMetaLinks? links;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is GetInvoiceItems200ResponseMeta &&
          other.total == total &&
          other.links == links;

  @override
  int get hashCode =>
      // ignore: unnecessary_parenthesis
      (total == null ? 0 : total!.hashCode) +
      (links == null ? 0 : links!.hashCode);

  @override
  String toString() =>
      'GetInvoiceItems200ResponseMeta[total=$total, links=$links]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
    if (this.total != null) {
      json[r'total'] = this.total;
    } else {
      json[r'total'] = null;
    }
    if (this.links != null) {
      json[r'links'] = this.links;
    } else {
      json[r'links'] = null;
    }
    return json;
  }

  /// Returns a new [GetInvoiceItems200ResponseMeta] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static GetInvoiceItems200ResponseMeta? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      assert(() {
        requiredKeys.forEach((key) {
          assert(json.containsKey(key),
              'Required key "GetInvoiceItems200ResponseMeta[$key]" is missing from JSON.');
          assert(json[key] != null,
              'Required key "GetInvoiceItems200ResponseMeta[$key]" has a null value in JSON.');
        });
        return true;
      }());

      return GetInvoiceItems200ResponseMeta(
        total: num.parse('${json[r'total']}'),
        links: GetInvoiceItems200ResponseMetaLinks.fromJson(json[r'links']),
      );
    }
    return null;
  }

  static List<GetInvoiceItems200ResponseMeta> listFromJson(
    dynamic json, {
    bool growable = false,
  }) {
    final result = <GetInvoiceItems200ResponseMeta>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = GetInvoiceItems200ResponseMeta.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, GetInvoiceItems200ResponseMeta> mapFromJson(dynamic json) {
    final map = <String, GetInvoiceItems200ResponseMeta>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = GetInvoiceItems200ResponseMeta.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of GetInvoiceItems200ResponseMeta-objects as value to a dart map
  static Map<String, List<GetInvoiceItems200ResponseMeta>> mapListFromJson(
    dynamic json, {
    bool growable = false,
  }) {
    final map = <String, List<GetInvoiceItems200ResponseMeta>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = GetInvoiceItems200ResponseMeta.listFromJson(
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
