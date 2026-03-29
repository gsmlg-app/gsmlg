//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of openapi.api;

class CreateNodepoolsRequest {
  /// Returns a new [CreateNodepoolsRequest] instance.
  CreateNodepoolsRequest({
    required this.nodeQuantity,
    required this.label,
    required this.plan,
    this.tag,
    this.autoScaler,
    this.minNodes,
    this.maxNodes,
    this.labels,
    this.taints = const [],
    this.userData,
  });

  /// Number of instances in this nodepool
  int nodeQuantity;

  /// Label for the nodepool. You cannot change the label after a nodepool is created. You cannot have duplicate node pool labels in the same cluster.
  String label;

  /// Plan that this nodepool will use
  String plan;

  /// Tag for node pool
  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  String? tag;

  /// Option to use the auto scaler with your cluster. Default false.
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

  /// Map of key/value pairs defining labels to automatically apply to all nodes in this nodepool. Labels will be applied to both new and existing nodes.
  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  Object? labels;

  /// Array of objects containing key, value, and effect.
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
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CreateNodepoolsRequest &&
          other.nodeQuantity == nodeQuantity &&
          other.label == label &&
          other.plan == plan &&
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
      (nodeQuantity.hashCode) +
      (label.hashCode) +
      (plan.hashCode) +
      (tag == null ? 0 : tag!.hashCode) +
      (autoScaler == null ? 0 : autoScaler!.hashCode) +
      (minNodes == null ? 0 : minNodes!.hashCode) +
      (maxNodes == null ? 0 : maxNodes!.hashCode) +
      (labels == null ? 0 : labels!.hashCode) +
      (taints.hashCode) +
      (userData == null ? 0 : userData!.hashCode);

  @override
  String toString() =>
      'CreateNodepoolsRequest[nodeQuantity=$nodeQuantity, label=$label, plan=$plan, tag=$tag, autoScaler=$autoScaler, minNodes=$minNodes, maxNodes=$maxNodes, labels=$labels, taints=$taints, userData=$userData]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
    json[r'node_quantity'] = this.nodeQuantity;
    json[r'label'] = this.label;
    json[r'plan'] = this.plan;
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

  /// Returns a new [CreateNodepoolsRequest] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static CreateNodepoolsRequest? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      assert(() {
        requiredKeys.forEach((key) {
          assert(json.containsKey(key),
              'Required key "CreateNodepoolsRequest[$key]" is missing from JSON.');
          assert(json[key] != null,
              'Required key "CreateNodepoolsRequest[$key]" has a null value in JSON.');
        });
        return true;
      }());

      return CreateNodepoolsRequest(
        nodeQuantity: mapValueOfType<int>(json, r'node_quantity')!,
        label: mapValueOfType<String>(json, r'label')!,
        plan: mapValueOfType<String>(json, r'plan')!,
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

  static List<CreateNodepoolsRequest> listFromJson(
    dynamic json, {
    bool growable = false,
  }) {
    final result = <CreateNodepoolsRequest>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = CreateNodepoolsRequest.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, CreateNodepoolsRequest> mapFromJson(dynamic json) {
    final map = <String, CreateNodepoolsRequest>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = CreateNodepoolsRequest.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of CreateNodepoolsRequest-objects as value to a dart map
  static Map<String, List<CreateNodepoolsRequest>> mapListFromJson(
    dynamic json, {
    bool growable = false,
  }) {
    final map = <String, List<CreateNodepoolsRequest>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = CreateNodepoolsRequest.listFromJson(
          entry.value,
          growable: growable,
        );
      }
    }
    return map;
  }

  /// The list of required keys that must be present in a JSON.
  static const requiredKeys = <String>{
    'node_quantity',
    'label',
    'plan',
  };
}
