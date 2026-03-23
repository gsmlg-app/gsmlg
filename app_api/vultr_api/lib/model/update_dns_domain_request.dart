//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of openapi.api;

class UpdateDnsDomainRequest {
  /// Returns a new [UpdateDnsDomainRequest] instance.
  UpdateDnsDomainRequest({
    required this.dnsSec,
  });

  /// Enable or disable DNSSEC.  * enabled * disabled
  String dnsSec;

  @override
  bool operator ==(Object other) => identical(this, other) || other is UpdateDnsDomainRequest &&
    other.dnsSec == dnsSec;

  @override
  int get hashCode =>
    // ignore: unnecessary_parenthesis
    (dnsSec.hashCode);

  @override
  String toString() => 'UpdateDnsDomainRequest[dnsSec=$dnsSec]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
      json[r'dns_sec'] = this.dnsSec;
    return json;
  }

  /// Returns a new [UpdateDnsDomainRequest] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static UpdateDnsDomainRequest? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      assert(() {
        requiredKeys.forEach((key) {
          assert(json.containsKey(key), 'Required key "UpdateDnsDomainRequest[$key]" is missing from JSON.');
          assert(json[key] != null, 'Required key "UpdateDnsDomainRequest[$key]" has a null value in JSON.');
        });
        return true;
      }());

      return UpdateDnsDomainRequest(
        dnsSec: mapValueOfType<String>(json, r'dns_sec')!,
      );
    }
    return null;
  }

  static List<UpdateDnsDomainRequest> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <UpdateDnsDomainRequest>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = UpdateDnsDomainRequest.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, UpdateDnsDomainRequest> mapFromJson(dynamic json) {
    final map = <String, UpdateDnsDomainRequest>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = UpdateDnsDomainRequest.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of UpdateDnsDomainRequest-objects as value to a dart map
  static Map<String, List<UpdateDnsDomainRequest>> mapListFromJson(dynamic json, {bool growable = false,}) {
    final map = <String, List<UpdateDnsDomainRequest>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = UpdateDnsDomainRequest.listFromJson(entry.value, growable: growable,);
      }
    }
    return map;
  }

  /// The list of required keys that must be present in a JSON.
  static const requiredKeys = <String>{
    'dns_sec',
  };
}

