//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of openapi.api;

class LoadbalancerNodeIps {
  /// Returns a new [LoadbalancerNodeIps] instance.
  LoadbalancerNodeIps({
    this.v4 = const [],
    this.v6 = const [],
  });

  /// IPV4 addresses of the load balancer nodes.
  List<String> v4;

  /// IPV6 addresses of the load balancer nodes.
  List<String> v6;

  @override
  bool operator ==(Object other) => identical(this, other) || other is LoadbalancerNodeIps &&
    _deepEquality.equals(other.v4, v4) &&
    _deepEquality.equals(other.v6, v6);

  @override
  int get hashCode =>
    // ignore: unnecessary_parenthesis
    (v4.hashCode) +
    (v6.hashCode);

  @override
  String toString() => 'LoadbalancerNodeIps[v4=$v4, v6=$v6]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
      json[r'v4'] = this.v4;
      json[r'v6'] = this.v6;
    return json;
  }

  /// Returns a new [LoadbalancerNodeIps] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static LoadbalancerNodeIps? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      assert(() {
        requiredKeys.forEach((key) {
          assert(json.containsKey(key), 'Required key "LoadbalancerNodeIps[$key]" is missing from JSON.');
          assert(json[key] != null, 'Required key "LoadbalancerNodeIps[$key]" has a null value in JSON.');
        });
        return true;
      }());

      return LoadbalancerNodeIps(
        v4: json[r'v4'] is Iterable
            ? (json[r'v4'] as Iterable).cast<String>().toList(growable: false)
            : const [],
        v6: json[r'v6'] is Iterable
            ? (json[r'v6'] as Iterable).cast<String>().toList(growable: false)
            : const [],
      );
    }
    return null;
  }

  static List<LoadbalancerNodeIps> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <LoadbalancerNodeIps>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = LoadbalancerNodeIps.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, LoadbalancerNodeIps> mapFromJson(dynamic json) {
    final map = <String, LoadbalancerNodeIps>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = LoadbalancerNodeIps.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of LoadbalancerNodeIps-objects as value to a dart map
  static Map<String, List<LoadbalancerNodeIps>> mapListFromJson(dynamic json, {bool growable = false,}) {
    final map = <String, List<LoadbalancerNodeIps>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = LoadbalancerNodeIps.listFromJson(entry.value, growable: growable,);
      }
    }
    return map;
  }

  /// The list of required keys that must be present in a JSON.
  static const requiredKeys = <String>{
  };
}

