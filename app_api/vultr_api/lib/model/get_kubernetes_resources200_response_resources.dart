//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of openapi.api;

class GetKubernetesResources200ResponseResources {
  /// Returns a new [GetKubernetesResources200ResponseResources] instance.
  GetKubernetesResources200ResponseResources({
    this.blockStorage = const {},
    this.loadBalancer = const {},
  });

  Set<GetKubernetesResources200ResponseResourcesBlockStorageInner> blockStorage;

  Set<GetKubernetesResources200ResponseResourcesLoadBalancerInner> loadBalancer;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is GetKubernetesResources200ResponseResources &&
          _deepEquality.equals(other.blockStorage, blockStorage) &&
          _deepEquality.equals(other.loadBalancer, loadBalancer);

  @override
  int get hashCode =>
      // ignore: unnecessary_parenthesis
      (blockStorage.hashCode) + (loadBalancer.hashCode);

  @override
  String toString() =>
      'GetKubernetesResources200ResponseResources[blockStorage=$blockStorage, loadBalancer=$loadBalancer]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
    json[r'block_storage'] = this.blockStorage.toList(growable: false);
    json[r'load_balancer'] = this.loadBalancer.toList(growable: false);
    return json;
  }

  /// Returns a new [GetKubernetesResources200ResponseResources] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static GetKubernetesResources200ResponseResources? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      assert(() {
        requiredKeys.forEach((key) {
          assert(json.containsKey(key),
              'Required key "GetKubernetesResources200ResponseResources[$key]" is missing from JSON.');
          assert(json[key] != null,
              'Required key "GetKubernetesResources200ResponseResources[$key]" has a null value in JSON.');
        });
        return true;
      }());

      return GetKubernetesResources200ResponseResources(
        blockStorage:
            GetKubernetesResources200ResponseResourcesBlockStorageInner
                    .listFromJson(json[r'block_storage'])
                .toSet(),
        loadBalancer:
            GetKubernetesResources200ResponseResourcesLoadBalancerInner
                    .listFromJson(json[r'load_balancer'])
                .toSet(),
      );
    }
    return null;
  }

  static List<GetKubernetesResources200ResponseResources> listFromJson(
    dynamic json, {
    bool growable = false,
  }) {
    final result = <GetKubernetesResources200ResponseResources>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = GetKubernetesResources200ResponseResources.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, GetKubernetesResources200ResponseResources> mapFromJson(
      dynamic json) {
    final map = <String, GetKubernetesResources200ResponseResources>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value =
            GetKubernetesResources200ResponseResources.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of GetKubernetesResources200ResponseResources-objects as value to a dart map
  static Map<String, List<GetKubernetesResources200ResponseResources>>
      mapListFromJson(
    dynamic json, {
    bool growable = false,
  }) {
    final map = <String, List<GetKubernetesResources200ResponseResources>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] =
            GetKubernetesResources200ResponseResources.listFromJson(
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
