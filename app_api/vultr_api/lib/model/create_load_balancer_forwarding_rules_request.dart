//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of openapi.api;

class CreateLoadBalancerForwardingRulesRequest {
  /// Returns a new [CreateLoadBalancerForwardingRulesRequest] instance.
  CreateLoadBalancerForwardingRulesRequest({
    required this.frontendProtocol,
    required this.frontendPort,
    required this.backendProtocol,
    required this.backendPort,
  });

  /// The protocol on the Load Balancer to forward to the backend.  * HTTP * HTTPS * TCP
  String frontendProtocol;

  /// The port number on the Load Balancer to forward to the backend.
  int frontendPort;

  /// The protocol destination on the backend server.  * HTTP * HTTPS * TCP
  String backendProtocol;

  /// The port number destination on the backend server.
  int backendPort;

  @override
  bool operator ==(Object other) => identical(this, other) || other is CreateLoadBalancerForwardingRulesRequest &&
    other.frontendProtocol == frontendProtocol &&
    other.frontendPort == frontendPort &&
    other.backendProtocol == backendProtocol &&
    other.backendPort == backendPort;

  @override
  int get hashCode =>
    // ignore: unnecessary_parenthesis
    (frontendProtocol.hashCode) +
    (frontendPort.hashCode) +
    (backendProtocol.hashCode) +
    (backendPort.hashCode);

  @override
  String toString() => 'CreateLoadBalancerForwardingRulesRequest[frontendProtocol=$frontendProtocol, frontendPort=$frontendPort, backendProtocol=$backendProtocol, backendPort=$backendPort]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
      json[r'frontend_protocol'] = this.frontendProtocol;
      json[r'frontend_port'] = this.frontendPort;
      json[r'backend_protocol'] = this.backendProtocol;
      json[r'backend_port'] = this.backendPort;
    return json;
  }

  /// Returns a new [CreateLoadBalancerForwardingRulesRequest] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static CreateLoadBalancerForwardingRulesRequest? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      assert(() {
        requiredKeys.forEach((key) {
          assert(json.containsKey(key), 'Required key "CreateLoadBalancerForwardingRulesRequest[$key]" is missing from JSON.');
          assert(json[key] != null, 'Required key "CreateLoadBalancerForwardingRulesRequest[$key]" has a null value in JSON.');
        });
        return true;
      }());

      return CreateLoadBalancerForwardingRulesRequest(
        frontendProtocol: mapValueOfType<String>(json, r'frontend_protocol')!,
        frontendPort: mapValueOfType<int>(json, r'frontend_port')!,
        backendProtocol: mapValueOfType<String>(json, r'backend_protocol')!,
        backendPort: mapValueOfType<int>(json, r'backend_port')!,
      );
    }
    return null;
  }

  static List<CreateLoadBalancerForwardingRulesRequest> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <CreateLoadBalancerForwardingRulesRequest>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = CreateLoadBalancerForwardingRulesRequest.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, CreateLoadBalancerForwardingRulesRequest> mapFromJson(dynamic json) {
    final map = <String, CreateLoadBalancerForwardingRulesRequest>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = CreateLoadBalancerForwardingRulesRequest.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of CreateLoadBalancerForwardingRulesRequest-objects as value to a dart map
  static Map<String, List<CreateLoadBalancerForwardingRulesRequest>> mapListFromJson(dynamic json, {bool growable = false,}) {
    final map = <String, List<CreateLoadBalancerForwardingRulesRequest>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = CreateLoadBalancerForwardingRulesRequest.listFromJson(entry.value, growable: growable,);
      }
    }
    return map;
  }

  /// The list of required keys that must be present in a JSON.
  static const requiredKeys = <String>{
    'frontend_protocol',
    'frontend_port',
    'backend_protocol',
    'backend_port',
  };
}

