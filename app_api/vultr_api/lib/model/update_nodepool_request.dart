//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of openapi.api;

class UpdateNodepoolRequest {
  /// Returns a new [UpdateNodepoolRequest] instance.
  UpdateNodepoolRequest({
    this.nodeQuantity,
    this.tag,
    this.autoScaler,
    this.minNodes,
    this.maxNodes,
    this.labels,
    this.taints = const [],
    this.userData,
  });

  /// Number of instances in the NodePool. Minimum of 1 is required, but at least 3 is recommended.
  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  int? nodeQuantity;

  /// Tag for your node pool
  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  String? tag;

  /// Option to use the auto scaler for your cluster. Default false.
  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  bool? autoScaler;

  /// Auto scaler field for minimum nodes you want for your cluster. Default 1.
  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  int? minNodes;

  /// Auto scaler field for maximum nodes you want for your cluster. Default 1.
  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  int? maxNodes;

  /// Map of key/value pairs defining labels to automatically apply to all nodes in this nodepool. Labels will be applied to both new and existing nodes. Existing labels are not removed when adding or updating, but can be managed in the separate labels endpoints.
  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  Object? labels;

  /// Array of objects containing key, value, and effect. Existing taints are not removed when adding or updating, but can be managed in the separate taints endpoints.
  List<NodepoolTaintReq> taints;

  /// The user-supplied, base64 encoded user data for all nodes in nodepool (only applied on nodes created after user data is set).
  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  String? userData;

  @override
  bool operator ==(Object other) => identical(this, other) || other is UpdateNodepoolRequest &&
    other.nodeQuantity == nodeQuantity &&
    other.tag == tag &&
    other.autoScaler == autoScaler &&
    other.minNodes == minNodes &&
    other.maxNodes == maxNodes &&
    other.labels == labels &&
    _deepEquality.equals(other.taints, taints) &&
    other.userData == userData;

  @override
  int get hashCode =>
    // ignore: unnecessary_parenthesis
    (nodeQuantity == null ? 0 : nodeQuantity!.hashCode) +
    (tag == null ? 0 : tag!.hashCode) +
    (autoScaler == null ? 0 : autoScaler!.hashCode) +
    (minNodes == null ? 0 : minNodes!.hashCode) +
    (maxNodes == null ? 0 : maxNodes!.hashCode) +
    (labels == null ? 0 : labels!.hashCode) +
    (taints.hashCode) +
    (userData == null ? 0 : userData!.hashCode);

  @override
  String toString() => 'UpdateNodepoolRequest[nodeQuantity=$nodeQuantity, tag=$tag, autoScaler=$autoScaler, minNodes=$minNodes, maxNodes=$maxNodes, labels=$labels, taints=$taints, userData=$userData]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
    if (this.nodeQuantity != null) {
      json[r'node_quantity'] = this.nodeQuantity;
    } else {
      json[r'node_quantity'] = null;
    }
    if (this.tag != null) {
      json[r'tag'] = this.tag;
    } else {
      json[r'tag'] = null;
    }
    if (this.autoScaler != null) {
      json[r'auto_scaler'] = this.autoScaler;
    } else {
      json[r'auto_scaler'] = null;
    }
    if (this.minNodes != null) {
      json[r'min_nodes'] = this.minNodes;
    } else {
      json[r'min_nodes'] = null;
    }
    if (this.maxNodes != null) {
      json[r'max_nodes'] = this.maxNodes;
    } else {
      json[r'max_nodes'] = null;
    }
    if (this.labels != null) {
      json[r'labels'] = this.labels;
    } else {
      json[r'labels'] = null;
    }
      json[r'taints'] = this.taints;
    if (this.userData != null) {
      json[r'user_data'] = this.userData;
    } else {
      json[r'user_data'] = null;
    }
    return json;
  }

  /// Returns a new [UpdateNodepoolRequest] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static UpdateNodepoolRequest? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      assert(() {
        requiredKeys.forEach((key) {
          assert(json.containsKey(key), 'Required key "UpdateNodepoolRequest[$key]" is missing from JSON.');
          assert(json[key] != null, 'Required key "UpdateNodepoolRequest[$key]" has a null value in JSON.');
        });
        return true;
      }());

      return UpdateNodepoolRequest(
        nodeQuantity: mapValueOfType<int>(json, r'node_quantity'),
        tag: mapValueOfType<String>(json, r'tag'),
        autoScaler: mapValueOfType<bool>(json, r'auto_scaler'),
        minNodes: mapValueOfType<int>(json, r'min_nodes'),
        maxNodes: mapValueOfType<int>(json, r'max_nodes'),
        labels: mapValueOfType<Object>(json, r'labels'),
        taints: NodepoolTaintReq.listFromJson(json[r'taints']),
        userData: mapValueOfType<String>(json, r'user_data'),
      );
    }
    return null;
  }

  static List<UpdateNodepoolRequest> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <UpdateNodepoolRequest>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = UpdateNodepoolRequest.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, UpdateNodepoolRequest> mapFromJson(dynamic json) {
    final map = <String, UpdateNodepoolRequest>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = UpdateNodepoolRequest.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of UpdateNodepoolRequest-objects as value to a dart map
  static Map<String, List<UpdateNodepoolRequest>> mapListFromJson(dynamic json, {bool growable = false,}) {
    final map = <String, List<UpdateNodepoolRequest>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = UpdateNodepoolRequest.listFromJson(entry.value, growable: growable,);
      }
    }
    return map;
  }

  /// The list of required keys that must be present in a JSON.
  static const requiredKeys = <String>{
  };
}

