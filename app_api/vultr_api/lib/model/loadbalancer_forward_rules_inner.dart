//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of openapi.api;

class LoadbalancerForwardRulesInner {
  /// Returns a new [LoadbalancerForwardRulesInner] instance.
  LoadbalancerForwardRulesInner({
    this.id,
    this.frontendProtocol,
    this.frontendPort,
    this.backendPortocol,
    this.backendPort,
  });

  /// A unique ID for the forwarding rule.
  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  String? id;

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
  String? backendPortocol;

  /// The port number destination on the backend server. 
  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  int? backendPort;

  @override
  bool operator ==(Object other) => identical(this, other) || other is LoadbalancerForwardRulesInner &&
    other.id == id &&
    other.frontendProtocol == frontendProtocol &&
    other.frontendPort == frontendPort &&
    other.backendPortocol == backendPortocol &&
    other.backendPort == backendPort;

  @override
  int get hashCode =>
    // ignore: unnecessary_parenthesis
    (id == null ? 0 : id!.hashCode) +
    (frontendProtocol == null ? 0 : frontendProtocol!.hashCode) +
    (frontendPort == null ? 0 : frontendPort!.hashCode) +
    (backendPortocol == null ? 0 : backendPortocol!.hashCode) +
    (backendPort == null ? 0 : backendPort!.hashCode);

  @override
  String toString() => 'LoadbalancerForwardRulesInner[id=$id, frontendProtocol=$frontendProtocol, frontendPort=$frontendPort, backendPortocol=$backendPortocol, backendPort=$backendPort]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
    if (this.id != null) {
      json[r'id'] = this.id;
    } else {
      json[r'id'] = null;
    }
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
    if (this.backendPortocol != null) {
      json[r'backend_portocol'] = this.backendPortocol;
    } else {
      json[r'backend_portocol'] = null;
    }
    if (this.backendPort != null) {
      json[r'backend_port'] = this.backendPort;
    } else {
      json[r'backend_port'] = null;
    }
    return json;
  }

  /// Returns a new [LoadbalancerForwardRulesInner] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static LoadbalancerForwardRulesInner? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      assert(() {
        requiredKeys.forEach((key) {
          assert(json.containsKey(key), 'Required key "LoadbalancerForwardRulesInner[$key]" is missing from JSON.');
          assert(json[key] != null, 'Required key "LoadbalancerForwardRulesInner[$key]" has a null value in JSON.');
        });
        return true;
      }());

      return LoadbalancerForwardRulesInner(
        id: mapValueOfType<String>(json, r'id'),
        frontendProtocol: mapValueOfType<String>(json, r'frontend_protocol'),
        frontendPort: mapValueOfType<int>(json, r'frontend_port'),
        backendPortocol: mapValueOfType<String>(json, r'backend_portocol'),
        backendPort: mapValueOfType<int>(json, r'backend_port'),
      );
    }
    return null;
  }

  static List<LoadbalancerForwardRulesInner> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <LoadbalancerForwardRulesInner>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = LoadbalancerForwardRulesInner.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, LoadbalancerForwardRulesInner> mapFromJson(dynamic json) {
    final map = <String, LoadbalancerForwardRulesInner>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = LoadbalancerForwardRulesInner.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of LoadbalancerForwardRulesInner-objects as value to a dart map
  static Map<String, List<LoadbalancerForwardRulesInner>> mapListFromJson(dynamic json, {bool growable = false,}) {
    final map = <String, List<LoadbalancerForwardRulesInner>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = LoadbalancerForwardRulesInner.listFromJson(entry.value, growable: growable,);
      }
    }
    return map;
  }

  /// The list of required keys that must be present in a JSON.
  static const requiredKeys = <String>{
  };
}

