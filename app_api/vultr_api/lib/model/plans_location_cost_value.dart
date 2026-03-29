//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of openapi.api;

class PlansLocationCostValue {
  /// Returns a new [PlansLocationCostValue] instance.
  PlansLocationCostValue({
    this.monthlyCost,
    this.hourlyCost,
    this.monthlyCostPreemptible,
    this.hourlyCostPreemptible,
  });

  /// The monthly cost in US Dollars for this location.
  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  num? monthlyCost;

  /// The hourly cost in US Dollars for this location.
  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  num? hourlyCost;

  /// The monthly cost in US Dollars for preemptible configurations in this location.
  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  num? monthlyCostPreemptible;

  /// The hourly cost in US Dollars for preemptible configurations in this location.
  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  num? hourlyCostPreemptible;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PlansLocationCostValue &&
          other.monthlyCost == monthlyCost &&
          other.hourlyCost == hourlyCost &&
          other.monthlyCostPreemptible == monthlyCostPreemptible &&
          other.hourlyCostPreemptible == hourlyCostPreemptible;

  @override
  int get hashCode =>
      // ignore: unnecessary_parenthesis
      (monthlyCost == null ? 0 : monthlyCost!.hashCode) +
      (hourlyCost == null ? 0 : hourlyCost!.hashCode) +
      (monthlyCostPreemptible == null ? 0 : monthlyCostPreemptible!.hashCode) +
      (hourlyCostPreemptible == null ? 0 : hourlyCostPreemptible!.hashCode);

  @override
  String toString() =>
      'PlansLocationCostValue[monthlyCost=$monthlyCost, hourlyCost=$hourlyCost, monthlyCostPreemptible=$monthlyCostPreemptible, hourlyCostPreemptible=$hourlyCostPreemptible]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
    if (this.monthlyCost != null) {
      json[r'monthly_cost'] = this.monthlyCost;
    } else {
      json[r'monthly_cost'] = null;
    }
    if (this.hourlyCost != null) {
      json[r'hourly_cost'] = this.hourlyCost;
    } else {
      json[r'hourly_cost'] = null;
    }
    if (this.monthlyCostPreemptible != null) {
      json[r'monthly_cost_preemptible'] = this.monthlyCostPreemptible;
    } else {
      json[r'monthly_cost_preemptible'] = null;
    }
    if (this.hourlyCostPreemptible != null) {
      json[r'hourly_cost_preemptible'] = this.hourlyCostPreemptible;
    } else {
      json[r'hourly_cost_preemptible'] = null;
    }
    return json;
  }

  /// Returns a new [PlansLocationCostValue] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static PlansLocationCostValue? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      assert(() {
        requiredKeys.forEach((key) {
          assert(json.containsKey(key),
              'Required key "PlansLocationCostValue[$key]" is missing from JSON.');
          assert(json[key] != null,
              'Required key "PlansLocationCostValue[$key]" has a null value in JSON.');
        });
        return true;
      }());

      return PlansLocationCostValue(
        monthlyCost: num.parse('${json[r'monthly_cost']}'),
        hourlyCost: num.parse('${json[r'hourly_cost']}'),
        monthlyCostPreemptible:
            num.parse('${json[r'monthly_cost_preemptible']}'),
        hourlyCostPreemptible: num.parse('${json[r'hourly_cost_preemptible']}'),
      );
    }
    return null;
  }

  static List<PlansLocationCostValue> listFromJson(
    dynamic json, {
    bool growable = false,
  }) {
    final result = <PlansLocationCostValue>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = PlansLocationCostValue.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, PlansLocationCostValue> mapFromJson(dynamic json) {
    final map = <String, PlansLocationCostValue>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = PlansLocationCostValue.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of PlansLocationCostValue-objects as value to a dart map
  static Map<String, List<PlansLocationCostValue>> mapListFromJson(
    dynamic json, {
    bool growable = false,
  }) {
    final map = <String, List<PlansLocationCostValue>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = PlansLocationCostValue.listFromJson(
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
