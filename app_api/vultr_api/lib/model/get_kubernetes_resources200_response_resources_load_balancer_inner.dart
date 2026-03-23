//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of openapi.api;

class GetKubernetesResources200ResponseResourcesLoadBalancerInner {
  /// Returns a new [GetKubernetesResources200ResponseResourcesLoadBalancerInner] instance.
  GetKubernetesResources200ResponseResourcesLoadBalancerInner({
    this.id,
    this.label,
    this.dateCreated,
    this.status,
  });

  /// Unique identifier for the load balancer
  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  String? id;

  /// Label given to the load balancer
  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  String? label;

  /// Date the load balancer was created
  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  String? dateCreated;

  /// Status of the load balancer
  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  String? status;

  @override
  bool operator ==(Object other) => identical(this, other) || other is GetKubernetesResources200ResponseResourcesLoadBalancerInner &&
    other.id == id &&
    other.label == label &&
    other.dateCreated == dateCreated &&
    other.status == status;

  @override
  int get hashCode =>
    // ignore: unnecessary_parenthesis
    (id == null ? 0 : id!.hashCode) +
    (label == null ? 0 : label!.hashCode) +
    (dateCreated == null ? 0 : dateCreated!.hashCode) +
    (status == null ? 0 : status!.hashCode);

  @override
  String toString() => 'GetKubernetesResources200ResponseResourcesLoadBalancerInner[id=$id, label=$label, dateCreated=$dateCreated, status=$status]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
    if (this.id != null) {
      json[r'id'] = this.id;
    } else {
      json[r'id'] = null;
    }
    if (this.label != null) {
      json[r'label'] = this.label;
    } else {
      json[r'label'] = null;
    }
    if (this.dateCreated != null) {
      json[r'date_created'] = this.dateCreated;
    } else {
      json[r'date_created'] = null;
    }
    if (this.status != null) {
      json[r'status'] = this.status;
    } else {
      json[r'status'] = null;
    }
    return json;
  }

  /// Returns a new [GetKubernetesResources200ResponseResourcesLoadBalancerInner] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static GetKubernetesResources200ResponseResourcesLoadBalancerInner? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      assert(() {
        requiredKeys.forEach((key) {
          assert(json.containsKey(key), 'Required key "GetKubernetesResources200ResponseResourcesLoadBalancerInner[$key]" is missing from JSON.');
          assert(json[key] != null, 'Required key "GetKubernetesResources200ResponseResourcesLoadBalancerInner[$key]" has a null value in JSON.');
        });
        return true;
      }());

      return GetKubernetesResources200ResponseResourcesLoadBalancerInner(
        id: mapValueOfType<String>(json, r'id'),
        label: mapValueOfType<String>(json, r'label'),
        dateCreated: mapValueOfType<String>(json, r'date_created'),
        status: mapValueOfType<String>(json, r'status'),
      );
    }
    return null;
  }

  static List<GetKubernetesResources200ResponseResourcesLoadBalancerInner> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <GetKubernetesResources200ResponseResourcesLoadBalancerInner>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = GetKubernetesResources200ResponseResourcesLoadBalancerInner.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, GetKubernetesResources200ResponseResourcesLoadBalancerInner> mapFromJson(dynamic json) {
    final map = <String, GetKubernetesResources200ResponseResourcesLoadBalancerInner>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = GetKubernetesResources200ResponseResourcesLoadBalancerInner.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of GetKubernetesResources200ResponseResourcesLoadBalancerInner-objects as value to a dart map
  static Map<String, List<GetKubernetesResources200ResponseResourcesLoadBalancerInner>> mapListFromJson(dynamic json, {bool growable = false,}) {
    final map = <String, List<GetKubernetesResources200ResponseResourcesLoadBalancerInner>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = GetKubernetesResources200ResponseResourcesLoadBalancerInner.listFromJson(entry.value, growable: growable,);
      }
    }
    return map;
  }

  /// The list of required keys that must be present in a JSON.
  static const requiredKeys = <String>{
  };
}

