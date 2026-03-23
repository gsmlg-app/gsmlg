//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of openapi.api;

class AccountBandwidthPreviousMonth {
  /// Returns a new [AccountBandwidthPreviousMonth] instance.
  AccountBandwidthPreviousMonth({
    this.timestampStart,
    this.timestampEnd,
    this.gbIn,
    this.gbOut,
    this.totalInstanceHours,
    this.totalInstanceCount,
    this.instanceBandwidthCredits,
    this.freeBandwidthCredits,
    this.purchasedBandwidthCredits,
    this.overage,
    this.overageUnitCost,
    this.overageCost,
  });

  /// Timestamp start date
  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  String? timestampStart;

  /// Timestamp end date
  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  String? timestampEnd;

  /// Gigabytes In
  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  num? gbIn;

  /// Gigabytes Out
  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  num? gbOut;

  /// Total Hours in Instances
  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  num? totalInstanceHours;

  /// Amount of Instances
  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  num? totalInstanceCount;

  /// Credits for instance bandwidth
  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  num? instanceBandwidthCredits;

  /// Free bandwidth credit
  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  num? freeBandwidthCredits;

  /// Bandwidth credit purchased
  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  num? purchasedBandwidthCredits;

  /// Amount in overages
  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  num? overage;

  /// Unit cost of overage
  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  num? overageUnitCost;

  /// Total amount due of overages
  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  num? overageCost;

  @override
  bool operator ==(Object other) => identical(this, other) || other is AccountBandwidthPreviousMonth &&
    other.timestampStart == timestampStart &&
    other.timestampEnd == timestampEnd &&
    other.gbIn == gbIn &&
    other.gbOut == gbOut &&
    other.totalInstanceHours == totalInstanceHours &&
    other.totalInstanceCount == totalInstanceCount &&
    other.instanceBandwidthCredits == instanceBandwidthCredits &&
    other.freeBandwidthCredits == freeBandwidthCredits &&
    other.purchasedBandwidthCredits == purchasedBandwidthCredits &&
    other.overage == overage &&
    other.overageUnitCost == overageUnitCost &&
    other.overageCost == overageCost;

  @override
  int get hashCode =>
    // ignore: unnecessary_parenthesis
    (timestampStart == null ? 0 : timestampStart!.hashCode) +
    (timestampEnd == null ? 0 : timestampEnd!.hashCode) +
    (gbIn == null ? 0 : gbIn!.hashCode) +
    (gbOut == null ? 0 : gbOut!.hashCode) +
    (totalInstanceHours == null ? 0 : totalInstanceHours!.hashCode) +
    (totalInstanceCount == null ? 0 : totalInstanceCount!.hashCode) +
    (instanceBandwidthCredits == null ? 0 : instanceBandwidthCredits!.hashCode) +
    (freeBandwidthCredits == null ? 0 : freeBandwidthCredits!.hashCode) +
    (purchasedBandwidthCredits == null ? 0 : purchasedBandwidthCredits!.hashCode) +
    (overage == null ? 0 : overage!.hashCode) +
    (overageUnitCost == null ? 0 : overageUnitCost!.hashCode) +
    (overageCost == null ? 0 : overageCost!.hashCode);

  @override
  String toString() => 'AccountBandwidthPreviousMonth[timestampStart=$timestampStart, timestampEnd=$timestampEnd, gbIn=$gbIn, gbOut=$gbOut, totalInstanceHours=$totalInstanceHours, totalInstanceCount=$totalInstanceCount, instanceBandwidthCredits=$instanceBandwidthCredits, freeBandwidthCredits=$freeBandwidthCredits, purchasedBandwidthCredits=$purchasedBandwidthCredits, overage=$overage, overageUnitCost=$overageUnitCost, overageCost=$overageCost]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
    if (this.timestampStart != null) {
      json[r'timestamp_start'] = this.timestampStart;
    } else {
      json[r'timestamp_start'] = null;
    }
    if (this.timestampEnd != null) {
      json[r'timestamp_end'] = this.timestampEnd;
    } else {
      json[r'timestamp_end'] = null;
    }
    if (this.gbIn != null) {
      json[r'gb_in'] = this.gbIn;
    } else {
      json[r'gb_in'] = null;
    }
    if (this.gbOut != null) {
      json[r'gb_out'] = this.gbOut;
    } else {
      json[r'gb_out'] = null;
    }
    if (this.totalInstanceHours != null) {
      json[r'total_instance_hours'] = this.totalInstanceHours;
    } else {
      json[r'total_instance_hours'] = null;
    }
    if (this.totalInstanceCount != null) {
      json[r'total_instance_count'] = this.totalInstanceCount;
    } else {
      json[r'total_instance_count'] = null;
    }
    if (this.instanceBandwidthCredits != null) {
      json[r'instance_bandwidth_credits'] = this.instanceBandwidthCredits;
    } else {
      json[r'instance_bandwidth_credits'] = null;
    }
    if (this.freeBandwidthCredits != null) {
      json[r'free_bandwidth_credits'] = this.freeBandwidthCredits;
    } else {
      json[r'free_bandwidth_credits'] = null;
    }
    if (this.purchasedBandwidthCredits != null) {
      json[r'purchased_bandwidth_credits'] = this.purchasedBandwidthCredits;
    } else {
      json[r'purchased_bandwidth_credits'] = null;
    }
    if (this.overage != null) {
      json[r'overage'] = this.overage;
    } else {
      json[r'overage'] = null;
    }
    if (this.overageUnitCost != null) {
      json[r'overage_unit_cost'] = this.overageUnitCost;
    } else {
      json[r'overage_unit_cost'] = null;
    }
    if (this.overageCost != null) {
      json[r'overage_cost'] = this.overageCost;
    } else {
      json[r'overage_cost'] = null;
    }
    return json;
  }

  /// Returns a new [AccountBandwidthPreviousMonth] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static AccountBandwidthPreviousMonth? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      assert(() {
        requiredKeys.forEach((key) {
          assert(json.containsKey(key), 'Required key "AccountBandwidthPreviousMonth[$key]" is missing from JSON.');
          assert(json[key] != null, 'Required key "AccountBandwidthPreviousMonth[$key]" has a null value in JSON.');
        });
        return true;
      }());

      return AccountBandwidthPreviousMonth(
        timestampStart: mapValueOfType<String>(json, r'timestamp_start'),
        timestampEnd: mapValueOfType<String>(json, r'timestamp_end'),
        gbIn: num.parse('${json[r'gb_in']}'),
        gbOut: num.parse('${json[r'gb_out']}'),
        totalInstanceHours: num.parse('${json[r'total_instance_hours']}'),
        totalInstanceCount: num.parse('${json[r'total_instance_count']}'),
        instanceBandwidthCredits: num.parse('${json[r'instance_bandwidth_credits']}'),
        freeBandwidthCredits: num.parse('${json[r'free_bandwidth_credits']}'),
        purchasedBandwidthCredits: num.parse('${json[r'purchased_bandwidth_credits']}'),
        overage: num.parse('${json[r'overage']}'),
        overageUnitCost: num.parse('${json[r'overage_unit_cost']}'),
        overageCost: num.parse('${json[r'overage_cost']}'),
      );
    }
    return null;
  }

  static List<AccountBandwidthPreviousMonth> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <AccountBandwidthPreviousMonth>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = AccountBandwidthPreviousMonth.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, AccountBandwidthPreviousMonth> mapFromJson(dynamic json) {
    final map = <String, AccountBandwidthPreviousMonth>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = AccountBandwidthPreviousMonth.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of AccountBandwidthPreviousMonth-objects as value to a dart map
  static Map<String, List<AccountBandwidthPreviousMonth>> mapListFromJson(dynamic json, {bool growable = false,}) {
    final map = <String, List<AccountBandwidthPreviousMonth>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = AccountBandwidthPreviousMonth.listFromJson(entry.value, growable: growable,);
      }
    }
    return map;
  }

  /// The list of required keys that must be present in a JSON.
  static const requiredKeys = <String>{
  };
}

