//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of openapi.api;

class ListInstanceIpv6Reverse200ResponseReverseIpv6sInner {
  /// Returns a new [ListInstanceIpv6Reverse200ResponseReverseIpv6sInner] instance.
  ListInstanceIpv6Reverse200ResponseReverseIpv6sInner({
    this.reverse,
    this.ip,
  });

  /// The IPv6 reverse entry.
  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  String? reverse;

  /// The IPv6 address.
  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  String? ip;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ListInstanceIpv6Reverse200ResponseReverseIpv6sInner &&
          other.reverse == reverse &&
          other.ip == ip;

  @override
  int get hashCode =>
      // ignore: unnecessary_parenthesis
      (reverse == null ? 0 : reverse!.hashCode) +
      (ip == null ? 0 : ip!.hashCode);

  @override
  String toString() =>
      'ListInstanceIpv6Reverse200ResponseReverseIpv6sInner[reverse=$reverse, ip=$ip]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
    if (this.reverse != null) {
      json[r'reverse'] = this.reverse;
    } else {
      json[r'reverse'] = null;
    }
    if (this.ip != null) {
      json[r'ip'] = this.ip;
    } else {
      json[r'ip'] = null;
    }
    return json;
  }

  /// Returns a new [ListInstanceIpv6Reverse200ResponseReverseIpv6sInner] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static ListInstanceIpv6Reverse200ResponseReverseIpv6sInner? fromJson(
      dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      assert(() {
        requiredKeys.forEach((key) {
          assert(json.containsKey(key),
              'Required key "ListInstanceIpv6Reverse200ResponseReverseIpv6sInner[$key]" is missing from JSON.');
          assert(json[key] != null,
              'Required key "ListInstanceIpv6Reverse200ResponseReverseIpv6sInner[$key]" has a null value in JSON.');
        });
        return true;
      }());

      return ListInstanceIpv6Reverse200ResponseReverseIpv6sInner(
        reverse: mapValueOfType<String>(json, r'reverse'),
        ip: mapValueOfType<String>(json, r'ip'),
      );
    }
    return null;
  }

  static List<ListInstanceIpv6Reverse200ResponseReverseIpv6sInner> listFromJson(
    dynamic json, {
    bool growable = false,
  }) {
    final result = <ListInstanceIpv6Reverse200ResponseReverseIpv6sInner>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value =
            ListInstanceIpv6Reverse200ResponseReverseIpv6sInner.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, ListInstanceIpv6Reverse200ResponseReverseIpv6sInner>
      mapFromJson(dynamic json) {
    final map = <String, ListInstanceIpv6Reverse200ResponseReverseIpv6sInner>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value =
            ListInstanceIpv6Reverse200ResponseReverseIpv6sInner.fromJson(
                entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of ListInstanceIpv6Reverse200ResponseReverseIpv6sInner-objects as value to a dart map
  static Map<String, List<ListInstanceIpv6Reverse200ResponseReverseIpv6sInner>>
      mapListFromJson(
    dynamic json, {
    bool growable = false,
  }) {
    final map =
        <String, List<ListInstanceIpv6Reverse200ResponseReverseIpv6sInner>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] =
            ListInstanceIpv6Reverse200ResponseReverseIpv6sInner.listFromJson(
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
