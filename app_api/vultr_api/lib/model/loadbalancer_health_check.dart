//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of openapi.api;

class LoadbalancerHealthCheck {
  /// Returns a new [LoadbalancerHealthCheck] instance.
  LoadbalancerHealthCheck({
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

  /// HTTP Path to check. Only applies if Protocol is HTTP or HTTPS.
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
  int? checkInterval;

  /// Timeout before health check fails.
  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  int? responseTimeout;

  /// Number times a check must fail before becoming unhealthy.
  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  int? unhealthyThreshold;

  /// Number of times a check must succeed before returning to healthy status.
  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  int? healthyThreshold;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is LoadbalancerHealthCheck &&
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
      'LoadbalancerHealthCheck[protocol=$protocol, port=$port, path=$path, checkInterval=$checkInterval, responseTimeout=$responseTimeout, unhealthyThreshold=$unhealthyThreshold, healthyThreshold=$healthyThreshold]';

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

  /// Returns a new [LoadbalancerHealthCheck] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static LoadbalancerHealthCheck? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      assert(() {
        requiredKeys.forEach((key) {
          assert(json.containsKey(key),
              'Required key "LoadbalancerHealthCheck[$key]" is missing from JSON.');
          assert(json[key] != null,
              'Required key "LoadbalancerHealthCheck[$key]" has a null value in JSON.');
        });
        return true;
      }());

      return LoadbalancerHealthCheck(
        protocol: mapValueOfType<String>(json, r'protocol'),
        port: mapValueOfType<int>(json, r'port'),
        path: mapValueOfType<String>(json, r'path'),
        checkInterval: mapValueOfType<int>(json, r'check_interval'),
        responseTimeout: mapValueOfType<int>(json, r'response_timeout'),
        unhealthyThreshold: mapValueOfType<int>(json, r'unhealthy_threshold'),
        healthyThreshold: mapValueOfType<int>(json, r'healthy_threshold'),
      );
    }
    return null;
  }

  static List<LoadbalancerHealthCheck> listFromJson(
    dynamic json, {
    bool growable = false,
  }) {
    final result = <LoadbalancerHealthCheck>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = LoadbalancerHealthCheck.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, LoadbalancerHealthCheck> mapFromJson(dynamic json) {
    final map = <String, LoadbalancerHealthCheck>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = LoadbalancerHealthCheck.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of LoadbalancerHealthCheck-objects as value to a dart map
  static Map<String, List<LoadbalancerHealthCheck>> mapListFromJson(
    dynamic json, {
    bool growable = false,
  }) {
    final map = <String, List<LoadbalancerHealthCheck>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = LoadbalancerHealthCheck.listFromJson(
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
