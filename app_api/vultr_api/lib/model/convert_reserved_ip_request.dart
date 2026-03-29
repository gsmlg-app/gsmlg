//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of openapi.api;

class ConvertReservedIpRequest {
  /// Returns a new [ConvertReservedIpRequest] instance.
  ConvertReservedIpRequest({
    required this.ipAddress,
    this.label,
  });

  /// The IP address to convert.
  String ipAddress;

  /// A user-supplied label for this IP address.
  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  String? label;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ConvertReservedIpRequest &&
          other.ipAddress == ipAddress &&
          other.label == label;

  @override
  int get hashCode =>
      // ignore: unnecessary_parenthesis
      (ipAddress.hashCode) + (label == null ? 0 : label!.hashCode);

  @override
  String toString() =>
      'ConvertReservedIpRequest[ipAddress=$ipAddress, label=$label]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
    json[r'ip_address'] = this.ipAddress;
    if (this.label != null) {
      json[r'label'] = this.label;
    } else {
      json[r'label'] = null;
    }
    return json;
  }

  /// Returns a new [ConvertReservedIpRequest] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static ConvertReservedIpRequest? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      assert(() {
        requiredKeys.forEach((key) {
          assert(json.containsKey(key),
              'Required key "ConvertReservedIpRequest[$key]" is missing from JSON.');
          assert(json[key] != null,
              'Required key "ConvertReservedIpRequest[$key]" has a null value in JSON.');
        });
        return true;
      }());

      return ConvertReservedIpRequest(
        ipAddress: mapValueOfType<String>(json, r'ip_address')!,
        label: mapValueOfType<String>(json, r'label'),
      );
    }
    return null;
  }

  static List<ConvertReservedIpRequest> listFromJson(
    dynamic json, {
    bool growable = false,
  }) {
    final result = <ConvertReservedIpRequest>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = ConvertReservedIpRequest.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, ConvertReservedIpRequest> mapFromJson(dynamic json) {
    final map = <String, ConvertReservedIpRequest>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = ConvertReservedIpRequest.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of ConvertReservedIpRequest-objects as value to a dart map
  static Map<String, List<ConvertReservedIpRequest>> mapListFromJson(
    dynamic json, {
    bool growable = false,
  }) {
    final map = <String, List<ConvertReservedIpRequest>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = ConvertReservedIpRequest.listFromJson(
          entry.value,
          growable: growable,
        );
      }
    }
    return map;
  }

  /// The list of required keys that must be present in a JSON.
  static const requiredKeys = <String>{
    'ip_address',
  };
}
