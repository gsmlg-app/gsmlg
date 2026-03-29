//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of openapi.api;

class UpdateLoadBalancerRequestHealthCheck {
  /// Returns a new [UpdateLoadBalancerRequestHealthCheck] instance.
  UpdateLoadBalancerRequestHealthCheck({
    this.protocol,
    this.port,
    this.path,
    this.checkInterval,
    this.responseTimeout,
    this.unhealthyThreshold,
    this.healthyThreshold,
  });

  /// The protocol to use for health checks.  * HTTPS * HTTP * TCP
  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  String? protocol;

  /// The port to use for health checks.
  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  int? port;

  /// HTTP Path to check. Only applies if protocol is HTTP, or HTTPS.
  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  String? path;

  /// Interval between health checks.
  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  String? checkInterval;

  /// Timeout before health check fails.
  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  String? responseTimeout;

  /// Number times a check must fail before becoming unhealthy.
  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  String? unhealthyThreshold;

  /// Number of times a check must succeed before returning to healthy status.
  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  String? healthyThreshold;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UpdateLoadBalancerRequestHealthCheck &&
          other.protocol == protocol &&
          other.port == port &&
          other.path == path &&
          other.checkInterval == checkInterval &&
          other.responseTimeout == responseTimeout &&
          other.unhealthyThreshold == unhealthyThreshold &&
          other.healthyThreshold == healthyThreshold;

  @override
  int get hashCode =>
      // ignore: unnecessary_parenthesis
      (protocol == null ? 0 : protocol!.hashCode) +
      (port == null ? 0 : port!.hashCode) +
      (path == null ? 0 : path!.hashCode) +
      (checkInterval == null ? 0 : checkInterval!.hashCode) +
      (responseTimeout == null ? 0 : responseTimeout!.hashCode) +
      (unhealthyThreshold == null ? 0 : unhealthyThreshold!.hashCode) +
      (healthyThreshold == null ? 0 : healthyThreshold!.hashCode);

  @override
  String toString() =>
      'UpdateLoadBalancerRequestHealthCheck[protocol=$protocol, port=$port, path=$path, checkInterval=$checkInterval, responseTimeout=$responseTimeout, unhealthyThreshold=$unhealthyThreshold, healthyThreshold=$healthyThreshold]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
    if (this.protocol != null) {
      json[r'protocol'] = this.protocol;
    } else {
      json[r'protocol'] = null;
    }
    if (this.port != null) {
      json[r'port'] = this.port;
    } else {
      json[r'port'] = null;
    }
    if (this.path != null) {
      json[r'path'] = this.path;
    } else {
      json[r'path'] = null;
    }
    if (this.checkInterval != null) {
      json[r'check_interval'] = this.checkInterval;
    } else {
      json[r'check_interval'] = null;
    }
    if (this.responseTimeout != null) {
      json[r'response_timeout'] = this.responseTimeout;
    } else {
      json[r'response_timeout'] = null;
    }
    if (this.unhealthyThreshold != null) {
      json[r'unhealthy_threshold'] = this.unhealthyThreshold;
    } else {
      json[r'unhealthy_threshold'] = null;
    }
    if (this.healthyThreshold != null) {
      json[r'healthy_threshold'] = this.healthyThreshold;
    } else {
      json[r'healthy_threshold'] = null;
    }
    return json;
  }

  /// Returns a new [UpdateLoadBalancerRequestHealthCheck] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static UpdateLoadBalancerRequestHealthCheck? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      assert(() {
        requiredKeys.forEach((key) {
          assert(json.containsKey(key),
              'Required key "UpdateLoadBalancerRequestHealthCheck[$key]" is missing from JSON.');
          assert(json[key] != null,
              'Required key "UpdateLoadBalancerRequestHealthCheck[$key]" has a null value in JSON.');
        });
        return true;
      }());

      return UpdateLoadBalancerRequestHealthCheck(
        protocol: mapValueOfType<String>(json, r'protocol'),
        port: mapValueOfType<int>(json, r'port'),
        path: mapValueOfType<String>(json, r'path'),
        checkInterval: mapValueOfType<String>(json, r'check_interval'),
        responseTimeout: mapValueOfType<String>(json, r'response_timeout'),
        unhealthyThreshold:
            mapValueOfType<String>(json, r'unhealthy_threshold'),
        healthyThreshold: mapValueOfType<String>(json, r'healthy_threshold'),
      );
    }
    return null;
  }

  static List<UpdateLoadBalancerRequestHealthCheck> listFromJson(
    dynamic json, {
    bool growable = false,
  }) {
    final result = <UpdateLoadBalancerRequestHealthCheck>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = UpdateLoadBalancerRequestHealthCheck.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, UpdateLoadBalancerRequestHealthCheck> mapFromJson(
      dynamic json) {
    final map = <String, UpdateLoadBalancerRequestHealthCheck>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value =
            UpdateLoadBalancerRequestHealthCheck.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of UpdateLoadBalancerRequestHealthCheck-objects as value to a dart map
  static Map<String, List<UpdateLoadBalancerRequestHealthCheck>>
      mapListFromJson(
    dynamic json, {
    bool growable = false,
  }) {
    final map = <String, List<UpdateLoadBalancerRequestHealthCheck>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = UpdateLoadBalancerRequestHealthCheck.listFromJson(
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
