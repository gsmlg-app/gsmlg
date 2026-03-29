//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of openapi.api;

class CreateLoadBalancerRequestForwardingRulesInner {
  /// Returns a new [CreateLoadBalancerRequestForwardingRulesInner] instance.
  CreateLoadBalancerRequestForwardingRulesInner({
    this.frontendProtocol,
    this.frontendPort,
    this.backendProtocol,
    this.backendPort,
  });

  /// The protocol on the Load Balancer to forward to the backend.  * HTTP * HTTPS * TCP
  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  String? frontendProtocol;

  /// The port number on the Load Balancer to forward to the backend.
  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  int? frontendPort;

  /// The protocol destination on the backend server.  * HTTP * HTTPS * TCP
  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  String? backendProtocol;

  /// The port number destination on the backend server.
  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  int? backendPort;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CreateLoadBalancerRequestForwardingRulesInner &&
          other.frontendProtocol == frontendProtocol &&
          other.frontendPort == frontendPort &&
          other.backendProtocol == backendProtocol &&
          other.backendPort == backendPort;

  @override
  int get hashCode =>
      // ignore: unnecessary_parenthesis
      (frontendProtocol == null ? 0 : frontendProtocol!.hashCode) +
      (frontendPort == null ? 0 : frontendPort!.hashCode) +
      (backendProtocol == null ? 0 : backendProtocol!.hashCode) +
      (backendPort == null ? 0 : backendPort!.hashCode);

  @override
  String toString() =>
      'CreateLoadBalancerRequestForwardingRulesInner[frontendProtocol=$frontendProtocol, frontendPort=$frontendPort, backendProtocol=$backendProtocol, backendPort=$backendPort]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
    if (this.frontendProtocol != null) {
      json[r'frontend_protocol'] = this.frontendProtocol;
    } else {
      json[r'frontend_protocol'] = null;
    }
    if (this.frontendPort != null) {
      json[r'frontend_port'] = this.frontendPort;
    } else {
      json[r'frontend_port'] = null;
    }
    if (this.backendProtocol != null) {
      json[r'backend_protocol'] = this.backendProtocol;
    } else {
      json[r'backend_protocol'] = null;
    }
    if (this.backendPort != null) {
      json[r'backend_port'] = this.backendPort;
    } else {
      json[r'backend_port'] = null;
    }
    return json;
  }

  /// Returns a new [CreateLoadBalancerRequestForwardingRulesInner] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static CreateLoadBalancerRequestForwardingRulesInner? fromJson(
      dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      assert(() {
        requiredKeys.forEach((key) {
          assert(json.containsKey(key),
              'Required key "CreateLoadBalancerRequestForwardingRulesInner[$key]" is missing from JSON.');
          assert(json[key] != null,
              'Required key "CreateLoadBalancerRequestForwardingRulesInner[$key]" has a null value in JSON.');
        });
        return true;
      }());

      return CreateLoadBalancerRequestForwardingRulesInner(
        frontendProtocol: mapValueOfType<String>(json, r'frontend_protocol'),
        frontendPort: mapValueOfType<int>(json, r'frontend_port'),
        backendProtocol: mapValueOfType<String>(json, r'backend_protocol'),
        backendPort: mapValueOfType<int>(json, r'backend_port'),
      );
    }
    return null;
  }

  static List<CreateLoadBalancerRequestForwardingRulesInner> listFromJson(
    dynamic json, {
    bool growable = false,
  }) {
    final result = <CreateLoadBalancerRequestForwardingRulesInner>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value =
            CreateLoadBalancerRequestForwardingRulesInner.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, CreateLoadBalancerRequestForwardingRulesInner> mapFromJson(
      dynamic json) {
    final map = <String, CreateLoadBalancerRequestForwardingRulesInner>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value =
            CreateLoadBalancerRequestForwardingRulesInner.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of CreateLoadBalancerRequestForwardingRulesInner-objects as value to a dart map
  static Map<String, List<CreateLoadBalancerRequestForwardingRulesInner>>
      mapListFromJson(
    dynamic json, {
    bool growable = false,
  }) {
    final map = <String, List<CreateLoadBalancerRequestForwardingRulesInner>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] =
            CreateLoadBalancerRequestForwardingRulesInner.listFromJson(
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
