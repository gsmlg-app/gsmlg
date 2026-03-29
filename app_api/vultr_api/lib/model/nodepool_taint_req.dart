//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of openapi.api;

class NodepoolTaintReq {
  /// Returns a new [NodepoolTaintReq] instance.
  NodepoolTaintReq({
    this.key,
    this.value,
    this.effect,
  });

  /// Key of the Taint
  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  String? key;

  /// Value of the Taint
  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  String? value;

  /// Effect of the Taint
  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  String? effect;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is NodepoolTaintReq &&
          other.key == key &&
          other.value == value &&
          other.effect == effect;

  @override
  int get hashCode =>
      // ignore: unnecessary_parenthesis
      (key == null ? 0 : key!.hashCode) +
      (value == null ? 0 : value!.hashCode) +
      (effect == null ? 0 : effect!.hashCode);

  @override
  String toString() =>
      'NodepoolTaintReq[key=$key, value=$value, effect=$effect]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
    if (this.key != null) {
      json[r'key'] = this.key;
    } else {
      json[r'key'] = null;
    }
    if (this.value != null) {
      json[r'value'] = this.value;
    } else {
      json[r'value'] = null;
    }
    if (this.effect != null) {
      json[r'effect'] = this.effect;
    } else {
      json[r'effect'] = null;
    }
    return json;
  }

  /// Returns a new [NodepoolTaintReq] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static NodepoolTaintReq? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      assert(() {
        requiredKeys.forEach((key) {
          assert(json.containsKey(key),
              'Required key "NodepoolTaintReq[$key]" is missing from JSON.');
          assert(json[key] != null,
              'Required key "NodepoolTaintReq[$key]" has a null value in JSON.');
        });
        return true;
      }());

      return NodepoolTaintReq(
        key: mapValueOfType<String>(json, r'key'),
        value: mapValueOfType<String>(json, r'value'),
        effect: mapValueOfType<String>(json, r'effect'),
      );
    }
    return null;
  }

  static List<NodepoolTaintReq> listFromJson(
    dynamic json, {
    bool growable = false,
  }) {
    final result = <NodepoolTaintReq>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = NodepoolTaintReq.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, NodepoolTaintReq> mapFromJson(dynamic json) {
    final map = <String, NodepoolTaintReq>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = NodepoolTaintReq.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of NodepoolTaintReq-objects as value to a dart map
  static Map<String, List<NodepoolTaintReq>> mapListFromJson(
    dynamic json, {
    bool growable = false,
  }) {
    final map = <String, List<NodepoolTaintReq>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = NodepoolTaintReq.listFromJson(
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
