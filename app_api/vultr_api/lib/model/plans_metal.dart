//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of openapi.api;

class PlansMetal {
  /// Returns a new [PlansMetal] instance.
  PlansMetal({
    this.id,
    this.cpuCount,
    this.cpuModel,
    this.cpuThreads,
    this.ram,
    this.disk,
    this.bandwidth,
    this.invoiceType,
    this.monthlyCost,
    this.hourlyCost,
    this.monthlyCostPreemptible,
    this.hourlyCostPreemptible,
    this.locations = const [],
    this.type,
    this.diskCount,
  });

  /// A unique ID for the Bare Metal Plan.
  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  String? id;

  /// The number of CPUs in this Plan.
  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  int? cpuCount;

  /// The CPU model type for this instance.
  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  String? cpuModel;

  /// The numner of supported threads for this instance.
  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  int? cpuThreads;

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
  String? disk;

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

  /// An array of Regions where this plan is valid for use.
  List<String> locations;

  /// The plan type.  * SSD
  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  String? type;

  /// The number of disks that this plan offers.
  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  int? diskCount;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PlansMetal &&
          other.id == id &&
          other.cpuCount == cpuCount &&
          other.cpuModel == cpuModel &&
          other.cpuThreads == cpuThreads &&
          other.ram == ram &&
          other.disk == disk &&
          other.bandwidth == bandwidth &&
          other.invoiceType == invoiceType &&
          other.monthlyCost == monthlyCost &&
          other.hourlyCost == hourlyCost &&
          other.monthlyCostPreemptible == monthlyCostPreemptible &&
          other.hourlyCostPreemptible == hourlyCostPreemptible &&
          _deepEquality.equals(other.locations, locations) &&
          other.type == type &&
          other.diskCount == diskCount;

  @override
  int get hashCode =>
      // ignore: unnecessary_parenthesis
      (id == null ? 0 : id!.hashCode) +
      (cpuCount == null ? 0 : cpuCount!.hashCode) +
      (cpuModel == null ? 0 : cpuModel!.hashCode) +
      (cpuThreads == null ? 0 : cpuThreads!.hashCode) +
      (ram == null ? 0 : ram!.hashCode) +
      (disk == null ? 0 : disk!.hashCode) +
      (bandwidth == null ? 0 : bandwidth!.hashCode) +
      (invoiceType == null ? 0 : invoiceType!.hashCode) +
      (monthlyCost == null ? 0 : monthlyCost!.hashCode) +
      (hourlyCost == null ? 0 : hourlyCost!.hashCode) +
      (monthlyCostPreemptible == null ? 0 : monthlyCostPreemptible!.hashCode) +
      (hourlyCostPreemptible == null ? 0 : hourlyCostPreemptible!.hashCode) +
      (locations.hashCode) +
      (type == null ? 0 : type!.hashCode) +
      (diskCount == null ? 0 : diskCount!.hashCode);

  @override
  String toString() =>
      'PlansMetal[id=$id, cpuCount=$cpuCount, cpuModel=$cpuModel, cpuThreads=$cpuThreads, ram=$ram, disk=$disk, bandwidth=$bandwidth, invoiceType=$invoiceType, monthlyCost=$monthlyCost, hourlyCost=$hourlyCost, monthlyCostPreemptible=$monthlyCostPreemptible, hourlyCostPreemptible=$hourlyCostPreemptible, locations=$locations, type=$type, diskCount=$diskCount]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
    if (this.id != null) {
      json[r'id'] = this.id;
    } else {
      json[r'id'] = null;
    }
    if (this.cpuCount != null) {
      json[r'cpu_count'] = this.cpuCount;
    } else {
      json[r'cpu_count'] = null;
    }
    if (this.cpuModel != null) {
      json[r'cpu_model'] = this.cpuModel;
    } else {
      json[r'cpu_model'] = null;
    }
    if (this.cpuThreads != null) {
      json[r'cpu_threads'] = this.cpuThreads;
    } else {
      json[r'cpu_threads'] = null;
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
    json[r'locations'] = this.locations;
    if (this.type != null) {
      json[r'type'] = this.type;
    } else {
      json[r'type'] = null;
    }
    if (this.diskCount != null) {
      json[r'disk_count'] = this.diskCount;
    } else {
      json[r'disk_count'] = null;
    }
    return json;
  }

  /// Returns a new [PlansMetal] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static PlansMetal? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      assert(() {
        requiredKeys.forEach((key) {
          assert(json.containsKey(key),
              'Required key "PlansMetal[$key]" is missing from JSON.');
          assert(json[key] != null,
              'Required key "PlansMetal[$key]" has a null value in JSON.');
        });
        return true;
      }());

      return PlansMetal(
        id: mapValueOfType<String>(json, r'id'),
        cpuCount: mapValueOfType<int>(json, r'cpu_count'),
        cpuModel: mapValueOfType<String>(json, r'cpu_model'),
        cpuThreads: mapValueOfType<int>(json, r'cpu_threads'),
        ram: mapValueOfType<int>(json, r'ram'),
        disk: mapValueOfType<String>(json, r'disk'),
        bandwidth: mapValueOfType<int>(json, r'bandwidth'),
        invoiceType: mapValueOfType<Object>(json, r'invoice_type'),
        monthlyCost: num.parse('${json[r'monthly_cost']}'),
        hourlyCost: num.parse('${json[r'hourly_cost']}'),
        monthlyCostPreemptible:
            num.parse('${json[r'monthly_cost_preemptible']}'),
        hourlyCostPreemptible: num.parse('${json[r'hourly_cost_preemptible']}'),
        locations: json[r'locations'] is Iterable
            ? (json[r'locations'] as Iterable)
                .cast<String>()
                .toList(growable: false)
            : const [],
        type: mapValueOfType<String>(json, r'type'),
        diskCount: mapValueOfType<int>(json, r'disk_count'),
      );
    }
    return null;
  }

  static List<PlansMetal> listFromJson(
    dynamic json, {
    bool growable = false,
  }) {
    final result = <PlansMetal>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = PlansMetal.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, PlansMetal> mapFromJson(dynamic json) {
    final map = <String, PlansMetal>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = PlansMetal.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of PlansMetal-objects as value to a dart map
  static Map<String, List<PlansMetal>> mapListFromJson(
    dynamic json, {
    bool growable = false,
  }) {
    final map = <String, List<PlansMetal>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = PlansMetal.listFromJson(
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
