//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of openapi.api;

class DetachVpc2NodesRequest {
  /// Returns a new [DetachVpc2NodesRequest] instance.
  DetachVpc2NodesRequest({
    this.nodes = const [],
  });

  /// An array of ID strings for [nodes](#operation/list-vpc2-nodes) to detach from the VPC 2.0 network. A limit of 1000 nodes can be processed in a request
  List<String> nodes;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DetachVpc2NodesRequest &&
          _deepEquality.equals(other.nodes, nodes);

  @override
  int get hashCode =>
      // ignore: unnecessary_parenthesis
      (nodes.hashCode);

  @override
  String toString() => 'DetachVpc2NodesRequest[nodes=$nodes]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
    json[r'nodes'] = this.nodes;
    return json;
  }

  /// Returns a new [DetachVpc2NodesRequest] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static DetachVpc2NodesRequest? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      assert(() {
        requiredKeys.forEach((key) {
          assert(json.containsKey(key),
              'Required key "DetachVpc2NodesRequest[$key]" is missing from JSON.');
          assert(json[key] != null,
              'Required key "DetachVpc2NodesRequest[$key]" has a null value in JSON.');
        });
        return true;
      }());

      return DetachVpc2NodesRequest(
        nodes: json[r'nodes'] is Iterable
            ? (json[r'nodes'] as Iterable)
                .cast<String>()
                .toList(growable: false)
            : const [],
      );
    }
    return null;
  }

  static List<DetachVpc2NodesRequest> listFromJson(
    dynamic json, {
    bool growable = false,
  }) {
    final result = <DetachVpc2NodesRequest>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = DetachVpc2NodesRequest.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, DetachVpc2NodesRequest> mapFromJson(dynamic json) {
    final map = <String, DetachVpc2NodesRequest>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = DetachVpc2NodesRequest.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of DetachVpc2NodesRequest-objects as value to a dart map
  static Map<String, List<DetachVpc2NodesRequest>> mapListFromJson(
    dynamic json, {
    bool growable = false,
  }) {
    final map = <String, List<DetachVpc2NodesRequest>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = DetachVpc2NodesRequest.listFromJson(
          entry.value,
          growable: growable,
        );
      }
    }
    return map;
  }

  /// The list of required keys that must be present in a JSON.
  static const requiredKeys = <String>{
    'nodes',
  };
}
