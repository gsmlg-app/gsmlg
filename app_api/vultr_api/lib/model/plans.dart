//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of openapi.api;

class Plans {
  /// Returns a new [Plans] instance.
  Plans({
    this.id,
    this.name,
    this.vcpuCount,
    this.ram,
    this.disk,
    this.bandwidth,
    this.invoiceType,
    this.monthlyCost,
    this.hourlyCost,
    this.monthlyCostPreemptible,
    this.hourlyCostPreemptible,
    this.type,
    this.locations = const [],
    this.diskCount,
    this.locationCost = const {},
  });

  /// A unique ID for the Plan.
  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  String? id;

  /// The Plan name.
  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  String? name;

  /// The number of vCPUs in this Plan.
  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  int? vcpuCount;

  /// The amount of RAM in MB.
  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  int? ram;

  /// The disk size in GB.
  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  int? disk;

  /// The monthly bandwidth quota in GB.
  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  int? bandwidth;

  /// The type of cost for the Plan.  * hourly * monthly
  Object? invoiceType;

  /// The monthly cost in US Dollars.
  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  num? monthlyCost;

  /// The hourly cost in US Dollars (hourly plans only).
  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  num? hourlyCost;

  /// The monthly cost in US Dollars for preemptible configurations.
  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  num? monthlyCostPreemptible;

  /// The hourly cost in US Dollars (hourly plans only) for preemptible configurations.
  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  num? hourlyCostPreemptible;

  /// The plan type.  |   | Type | Description | | - | ------ | ------------- | |   | vc2 | Cloud Compute | |   | vhf | High Frequency Compute | |   | vdc | Dedicated Cloud |
  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  String? type;

  /// An array of Regions where this plan is valid for use.
  List<String> locations;

  /// The number of disks that this plan offers.
  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  int? diskCount;

  /// An object containing location-specific pricing. Keys are region codes and values are objects with cost details.
  Map<String, PlansLocationCostValue> locationCost;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Plans &&
          other.id == id &&
          other.name == name &&
          other.vcpuCount == vcpuCount &&
          other.ram == ram &&
          other.disk == disk &&
          other.bandwidth == bandwidth &&
          other.invoiceType == invoiceType &&
          other.monthlyCost == monthlyCost &&
          other.hourlyCost == hourlyCost &&
          other.monthlyCostPreemptible == monthlyCostPreemptible &&
          other.hourlyCostPreemptible == hourlyCostPreemptible &&
          other.type == type &&
          _deepEquality.equals(other.locations, locations) &&
          other.diskCount == diskCount &&
          _deepEquality.equals(other.locationCost, locationCost);

  @override
  int get hashCode =>
      // ignore: unnecessary_parenthesis
      (id == null ? 0 : id!.hashCode) +
      (name == null ? 0 : name!.hashCode) +
      (vcpuCount == null ? 0 : vcpuCount!.hashCode) +
      (ram == null ? 0 : ram!.hashCode) +
      (disk == null ? 0 : disk!.hashCode) +
      (bandwidth == null ? 0 : bandwidth!.hashCode) +
      (invoiceType == null ? 0 : invoiceType!.hashCode) +
      (monthlyCost == null ? 0 : monthlyCost!.hashCode) +
      (hourlyCost == null ? 0 : hourlyCost!.hashCode) +
      (monthlyCostPreemptible == null ? 0 : monthlyCostPreemptible!.hashCode) +
      (hourlyCostPreemptible == null ? 0 : hourlyCostPreemptible!.hashCode) +
      (type == null ? 0 : type!.hashCode) +
      (locations.hashCode) +
      (diskCount == null ? 0 : diskCount!.hashCode) +
      (locationCost.hashCode);

  @override
  String toString() =>
      'Plans[id=$id, name=$name, vcpuCount=$vcpuCount, ram=$ram, disk=$disk, bandwidth=$bandwidth, invoiceType=$invoiceType, monthlyCost=$monthlyCost, hourlyCost=$hourlyCost, monthlyCostPreemptible=$monthlyCostPreemptible, hourlyCostPreemptible=$hourlyCostPreemptible, type=$type, locations=$locations, diskCount=$diskCount, locationCost=$locationCost]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
    if (this.id != null) {
      json[r'id'] = this.id;
    } else {
      json[r'id'] = null;
    }
    if (this.name != null) {
      json[r'name'] = this.name;
    } else {
      json[r'name'] = null;
    }
    if (this.vcpuCount != null) {
      json[r'vcpu_count'] = this.vcpuCount;
    } else {
      json[r'vcpu_count'] = null;
    }
    if (this.ram != null) {
      json[r'ram'] = this.ram;
    } else {
      json[r'ram'] = null;
    }
    if (this.disk != null) {
      json[r'disk'] = this.disk;
    } else {
      json[r'disk'] = null;
    }
    if (this.bandwidth != null) {
      json[r'bandwidth'] = this.bandwidth;
    } else {
      json[r'bandwidth'] = null;
    }
    if (this.invoiceType != null) {
      json[r'invoice_type'] = this.invoiceType;
    } else {
      json[r'invoice_type'] = null;
    }
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
    if (this.type != null) {
      json[r'type'] = this.type;
    } else {
      json[r'type'] = null;
    }
    json[r'locations'] = this.locations;
    if (this.diskCount != null) {
      json[r'disk_count'] = this.diskCount;
    } else {
      json[r'disk_count'] = null;
    }
    json[r'location_cost'] = this.locationCost;
    return json;
  }

  /// Returns a new [Plans] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static Plans? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      assert(() {
        requiredKeys.forEach((key) {
          assert(json.containsKey(key),
              'Required key "Plans[$key]" is missing from JSON.');
          assert(json[key] != null,
              'Required key "Plans[$key]" has a null value in JSON.');
        });
        return true;
      }());

      return Plans(
        id: mapValueOfType<String>(json, r'id'),
        name: mapValueOfType<String>(json, r'name'),
        vcpuCount: mapValueOfType<int>(json, r'vcpu_count'),
        ram: mapValueOfType<int>(json, r'ram'),
        disk: mapValueOfType<int>(json, r'disk'),
        bandwidth: mapValueOfType<int>(json, r'bandwidth'),
        invoiceType: mapValueOfType<Object>(json, r'invoice_type'),
        monthlyCost: num.parse('${json[r'monthly_cost']}'),
        hourlyCost: num.parse('${json[r'hourly_cost']}'),
        monthlyCostPreemptible:
            num.parse('${json[r'monthly_cost_preemptible']}'),
        hourlyCostPreemptible: num.parse('${json[r'hourly_cost_preemptible']}'),
        type: mapValueOfType<String>(json, r'type'),
        locations: json[r'locations'] is Iterable
            ? (json[r'locations'] as Iterable)
                .cast<String>()
                .toList(growable: false)
            : const [],
        diskCount: mapValueOfType<int>(json, r'disk_count'),
        locationCost:
            PlansLocationCostValue.mapFromJson(json[r'location_cost']),
      );
    }
    return null;
  }

  static List<Plans> listFromJson(
    dynamic json, {
    bool growable = false,
  }) {
    final result = <Plans>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = Plans.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, Plans> mapFromJson(dynamic json) {
    final map = <String, Plans>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = Plans.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of Plans-objects as value to a dart map
  static Map<String, List<Plans>> mapListFromJson(
    dynamic json, {
    bool growable = false,
  }) {
    final map = <String, List<Plans>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = Plans.listFromJson(
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
