//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of openapi.api;

class GetInstanceUpgrades200ResponseUpgrades {
  /// Returns a new [GetInstanceUpgrades200ResponseUpgrades] instance.
  GetInstanceUpgrades200ResponseUpgrades({
    this.applications = const [],
    this.plans = const [],
    this.os = const [],
  });

  List<Object> applications;

  List<Object> plans;

  List<Object> os;

  @override
  bool operator ==(Object other) => identical(this, other) || other is GetInstanceUpgrades200ResponseUpgrades &&
    _deepEquality.equals(other.applications, applications) &&
    _deepEquality.equals(other.plans, plans) &&
    _deepEquality.equals(other.os, os);

  @override
  int get hashCode =>
    // ignore: unnecessary_parenthesis
    (applications.hashCode) +
    (plans.hashCode) +
    (os.hashCode);

  @override
  String toString() => 'GetInstanceUpgrades200ResponseUpgrades[applications=$applications, plans=$plans, os=$os]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
      json[r'applications'] = this.applications;
      json[r'plans'] = this.plans;
      json[r'os'] = this.os;
    return json;
  }

  /// Returns a new [GetInstanceUpgrades200ResponseUpgrades] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static GetInstanceUpgrades200ResponseUpgrades? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      assert(() {
        requiredKeys.forEach((key) {
          assert(json.containsKey(key), 'Required key "GetInstanceUpgrades200ResponseUpgrades[$key]" is missing from JSON.');
          assert(json[key] != null, 'Required key "GetInstanceUpgrades200ResponseUpgrades[$key]" has a null value in JSON.');
        });
        return true;
      }());

      return GetInstanceUpgrades200ResponseUpgrades(
        applications: json[r'applications'] is Iterable
            ? (json[r'applications'] as Iterable).cast<Object>().toList(growable: false)
            : const [],
        plans: json[r'plans'] is Iterable
            ? (json[r'plans'] as Iterable).cast<Object>().toList(growable: false)
            : const [],
        os: json[r'os'] is Iterable
            ? (json[r'os'] as Iterable).cast<Object>().toList(growable: false)
            : const [],
      );
    }
    return null;
  }

  static List<GetInstanceUpgrades200ResponseUpgrades> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <GetInstanceUpgrades200ResponseUpgrades>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = GetInstanceUpgrades200ResponseUpgrades.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, GetInstanceUpgrades200ResponseUpgrades> mapFromJson(dynamic json) {
    final map = <String, GetInstanceUpgrades200ResponseUpgrades>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = GetInstanceUpgrades200ResponseUpgrades.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of GetInstanceUpgrades200ResponseUpgrades-objects as value to a dart map
  static Map<String, List<GetInstanceUpgrades200ResponseUpgrades>> mapListFromJson(dynamic json, {bool growable = false,}) {
    final map = <String, List<GetInstanceUpgrades200ResponseUpgrades>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = GetInstanceUpgrades200ResponseUpgrades.listFromJson(entry.value, growable: growable,);
      }
    }
    return map;
  }

  /// The list of required keys that must be present in a JSON.
  static const requiredKeys = <String>{
  };
}

