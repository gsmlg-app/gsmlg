//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of openapi.api;

class PostBaremetalInstanceIdIpv4ReverseDefaultRequest {
  /// Returns a new [PostBaremetalInstanceIdIpv4ReverseDefaultRequest] instance.
  PostBaremetalInstanceIdIpv4ReverseDefaultRequest({
    required this.ip,
  });

  String ip;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PostBaremetalInstanceIdIpv4ReverseDefaultRequest &&
          other.ip == ip;

  @override
  int get hashCode =>
      // ignore: unnecessary_parenthesis
      (ip.hashCode);

  @override
  String toString() =>
      'PostBaremetalInstanceIdIpv4ReverseDefaultRequest[ip=$ip]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
    json[r'ip'] = this.ip;
    return json;
  }

  /// Returns a new [PostBaremetalInstanceIdIpv4ReverseDefaultRequest] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static PostBaremetalInstanceIdIpv4ReverseDefaultRequest? fromJson(
      dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      assert(() {
        requiredKeys.forEach((key) {
          assert(json.containsKey(key),
              'Required key "PostBaremetalInstanceIdIpv4ReverseDefaultRequest[$key]" is missing from JSON.');
          assert(json[key] != null,
              'Required key "PostBaremetalInstanceIdIpv4ReverseDefaultRequest[$key]" has a null value in JSON.');
        });
        return true;
      }());

      return PostBaremetalInstanceIdIpv4ReverseDefaultRequest(
        ip: mapValueOfType<String>(json, r'ip')!,
      );
    }
    return null;
  }

  static List<PostBaremetalInstanceIdIpv4ReverseDefaultRequest> listFromJson(
    dynamic json, {
    bool growable = false,
  }) {
    final result = <PostBaremetalInstanceIdIpv4ReverseDefaultRequest>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value =
            PostBaremetalInstanceIdIpv4ReverseDefaultRequest.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, PostBaremetalInstanceIdIpv4ReverseDefaultRequest>
      mapFromJson(dynamic json) {
    final map = <String, PostBaremetalInstanceIdIpv4ReverseDefaultRequest>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = PostBaremetalInstanceIdIpv4ReverseDefaultRequest.fromJson(
            entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of PostBaremetalInstanceIdIpv4ReverseDefaultRequest-objects as value to a dart map
  static Map<String, List<PostBaremetalInstanceIdIpv4ReverseDefaultRequest>>
      mapListFromJson(
    dynamic json, {
    bool growable = false,
  }) {
    final map =
        <String, List<PostBaremetalInstanceIdIpv4ReverseDefaultRequest>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] =
            PostBaremetalInstanceIdIpv4ReverseDefaultRequest.listFromJson(
          entry.value,
          growable: growable,
        );
      }
    }
    return map;
  }

  /// The list of required keys that must be present in a JSON.
  static const requiredKeys = <String>{
    'ip',
  };
}
