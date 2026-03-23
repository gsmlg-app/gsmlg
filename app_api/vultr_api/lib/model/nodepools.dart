//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of openapi.api;

class Nodepools {
  /// Returns a new [Nodepools] instance.
  Nodepools({
    this.id,
    this.dateCreated,
    this.label,
    this.tag,
    this.plan,
    this.status,
    this.nodeQuantity,
    this.nodes = const [],
    this.dateUpdated,
    this.autoScaler,
    this.minNodes,
    this.maxNodes,
    this.labels,
    this.taints = const [],
    this.userData,
  });

  /// The [NodePool ID](#operation/get-nodepools).
  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  String? id;

  /// Date of creation
  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  String? dateCreated;

  /// Label for nodepool
  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  String? label;

  /// Tag for node pool
  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  String? tag;

  /// Plan used for nodepool
  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  String? plan;

  /// Status for nodepool
  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  String? status;

  /// Number of nodes in nodepool
  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  int? nodeQuantity;

  List<NodepoolInstances> nodes;

  /// Date the nodepool was updated.
  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  String? dateUpdated;

  /// Displays if the auto scaler is enabled or disabled for your cluster.
  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  bool? autoScaler;

  /// Auto scaler field that displays the minimum nodes you want for your cluster.
  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  int? minNodes;

  /// Auto scaler field that displays the maximum nodes you want for your cluster.
  Object? maxNodes;

  /// Map of key/value pairs defining labels to automatically apply to all nodes in this nodepool.
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
  bool operator ==(Object other) => identical(this, other) || other is Nodepools &&
    other.id == id &&
    other.dateCreated == dateCreated &&
    other.label == label &&
    other.tag == tag &&
    other.plan == plan &&
    other.status == status &&
    other.nodeQuantity == nodeQuantity &&
    _deepEquality.equals(other.nodes, nodes) &&
    other.dateUpdated == dateUpdated &&
    other.autoScaler == autoScaler &&
    other.minNodes == minNodes &&
    other.maxNodes == maxNodes &&
    other.labels == labels &&
    _deepEquality.equals(other.taints, taints) &&
    other.userData == userData;

  @override
  int get hashCode =>
    // ignore: unnecessary_parenthesis
    (id == null ? 0 : id!.hashCode) +
    (dateCreated == null ? 0 : dateCreated!.hashCode) +
    (label == null ? 0 : label!.hashCode) +
    (tag == null ? 0 : tag!.hashCode) +
    (plan == null ? 0 : plan!.hashCode) +
    (status == null ? 0 : status!.hashCode) +
    (nodeQuantity == null ? 0 : nodeQuantity!.hashCode) +
    (nodes.hashCode) +
    (dateUpdated == null ? 0 : dateUpdated!.hashCode) +
    (autoScaler == null ? 0 : autoScaler!.hashCode) +
    (minNodes == null ? 0 : minNodes!.hashCode) +
    (maxNodes == null ? 0 : maxNodes!.hashCode) +
    (labels == null ? 0 : labels!.hashCode) +
    (taints.hashCode) +
    (userData == null ? 0 : userData!.hashCode);

  @override
  String toString() => 'Nodepools[id=$id, dateCreated=$dateCreated, label=$label, tag=$tag, plan=$plan, status=$status, nodeQuantity=$nodeQuantity, nodes=$nodes, dateUpdated=$dateUpdated, autoScaler=$autoScaler, minNodes=$minNodes, maxNodes=$maxNodes, labels=$labels, taints=$taints, userData=$userData]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
    if (this.id != null) {
      json[r'id'] = this.id;
    } else {
      json[r'id'] = null;
    }
    if (this.dateCreated != null) {
      json[r'date_created'] = this.dateCreated;
    } else {
      json[r'date_created'] = null;
    }
    if (this.label != null) {
      json[r'label'] = this.label;
    } else {
      json[r'label'] = null;
    }
    if (this.tag != null) {
      json[r'tag'] = this.tag;
    } else {
      json[r'tag'] = null;
    }
    if (this.plan != null) {
      json[r'plan'] = this.plan;
    } else {
      json[r'plan'] = null;
    }
    if (this.status != null) {
      json[r'status'] = this.status;
    } else {
      json[r'status'] = null;
    }
    if (this.nodeQuantity != null) {
      json[r'node_quantity'] = this.nodeQuantity;
    } else {
      json[r'node_quantity'] = null;
    }
      json[r'nodes'] = this.nodes;
    if (this.dateUpdated != null) {
      json[r'date_updated'] = this.dateUpdated;
    } else {
      json[r'date_updated'] = null;
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

  /// Returns a new [Nodepools] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static Nodepools? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      assert(() {
        requiredKeys.forEach((key) {
          assert(json.containsKey(key), 'Required key "Nodepools[$key]" is missing from JSON.');
          assert(json[key] != null, 'Required key "Nodepools[$key]" has a null value in JSON.');
        });
        return true;
      }());

      return Nodepools(
        id: mapValueOfType<String>(json, r'id'),
        dateCreated: mapValueOfType<String>(json, r'date_created'),
        label: mapValueOfType<String>(json, r'label'),
        tag: mapValueOfType<String>(json, r'tag'),
        plan: mapValueOfType<String>(json, r'plan'),
        status: mapValueOfType<String>(json, r'status'),
        nodeQuantity: mapValueOfType<int>(json, r'node_quantity'),
        nodes: NodepoolInstances.listFromJson(json[r'nodes']),
        dateUpdated: mapValueOfType<String>(json, r'date_updated'),
        autoScaler: mapValueOfType<bool>(json, r'auto_scaler'),
        minNodes: mapValueOfType<int>(json, r'min_nodes'),
        maxNodes: mapValueOfType<Object>(json, r'max_nodes'),
        labels: mapValueOfType<Object>(json, r'labels'),
        taints: NodepoolTaintReq.listFromJson(json[r'taints']),
        userData: mapValueOfType<String>(json, r'user_data'),
      );
    }
    return null;
  }

  static List<Nodepools> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <Nodepools>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = Nodepools.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, Nodepools> mapFromJson(dynamic json) {
    final map = <String, Nodepools>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = Nodepools.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of Nodepools-objects as value to a dart map
  static Map<String, List<Nodepools>> mapListFromJson(dynamic json, {bool growable = false,}) {
    final map = <String, List<Nodepools>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = Nodepools.listFromJson(entry.value, growable: growable,);
      }
    }
    return map;
  }

  /// The list of required keys that must be present in a JSON.
  static const requiredKeys = <String>{
  };
}

