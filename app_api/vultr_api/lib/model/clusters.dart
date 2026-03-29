//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of openapi.api;

class Clusters {
  /// Returns a new [Clusters] instance.
  Clusters({
    this.id,
    this.region,
    this.hostname,
    this.deploy,
  });

  /// A unique ID for the Object Storage cluster.
  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  int? id;

  /// The [Region id](#operation/list-regions) where the cluster is located.
  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  String? region;

  /// The cluster host name.
  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  String? hostname;

  /// The Cluster is eligible for Object Storage deployment.  * yes * no
  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  String? deploy;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Clusters &&
          other.id == id &&
          other.region == region &&
          other.hostname == hostname &&
          other.deploy == deploy;

  @override
  int get hashCode =>
      // ignore: unnecessary_parenthesis
      (id == null ? 0 : id!.hashCode) +
      (region == null ? 0 : region!.hashCode) +
      (hostname == null ? 0 : hostname!.hashCode) +
      (deploy == null ? 0 : deploy!.hashCode);

  @override
  String toString() =>
      'Clusters[id=$id, region=$region, hostname=$hostname, deploy=$deploy]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
    if (this.id != null) {
      json[r'id'] = this.id;
    } else {
      json[r'id'] = null;
    }
    if (this.region != null) {
      json[r'region'] = this.region;
    } else {
      json[r'region'] = null;
    }
    if (this.hostname != null) {
      json[r'hostname'] = this.hostname;
    } else {
      json[r'hostname'] = null;
    }
    if (this.deploy != null) {
      json[r'deploy'] = this.deploy;
    } else {
      json[r'deploy'] = null;
    }
    return json;
  }

  /// Returns a new [Clusters] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static Clusters? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      assert(() {
        requiredKeys.forEach((key) {
          assert(json.containsKey(key),
              'Required key "Clusters[$key]" is missing from JSON.');
          assert(json[key] != null,
              'Required key "Clusters[$key]" has a null value in JSON.');
        });
        return true;
      }());

      return Clusters(
        id: mapValueOfType<int>(json, r'id'),
        region: mapValueOfType<String>(json, r'region'),
        hostname: mapValueOfType<String>(json, r'hostname'),
        deploy: mapValueOfType<String>(json, r'deploy'),
      );
    }
    return null;
  }

  static List<Clusters> listFromJson(
    dynamic json, {
    bool growable = false,
  }) {
    final result = <Clusters>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = Clusters.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, Clusters> mapFromJson(dynamic json) {
    final map = <String, Clusters>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = Clusters.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of Clusters-objects as value to a dart map
  static Map<String, List<Clusters>> mapListFromJson(
    dynamic json, {
    bool growable = false,
  }) {
    final map = <String, List<Clusters>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = Clusters.listFromJson(
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
