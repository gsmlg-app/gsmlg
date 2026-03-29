//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of openapi.api;

class AccountBandwidth {
  /// Returns a new [AccountBandwidth] instance.
  AccountBandwidth({
    this.previousMonth,
    this.currentMonthToDate,
    this.currentMonthProjected,
  });

  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  AccountBandwidthPreviousMonth? previousMonth;

  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  AccountBandwidthCurrentMonthToDate? currentMonthToDate;

  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  AccountBandwidthCurrentMonthProjected? currentMonthProjected;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AccountBandwidth &&
          other.previousMonth == previousMonth &&
          other.currentMonthToDate == currentMonthToDate &&
          other.currentMonthProjected == currentMonthProjected;

  @override
  int get hashCode =>
      // ignore: unnecessary_parenthesis
      (previousMonth == null ? 0 : previousMonth!.hashCode) +
      (currentMonthToDate == null ? 0 : currentMonthToDate!.hashCode) +
      (currentMonthProjected == null ? 0 : currentMonthProjected!.hashCode);

  @override
  String toString() =>
      'AccountBandwidth[previousMonth=$previousMonth, currentMonthToDate=$currentMonthToDate, currentMonthProjected=$currentMonthProjected]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
    if (this.previousMonth != null) {
      json[r'previous_month'] = this.previousMonth;
    } else {
      json[r'previous_month'] = null;
    }
    if (this.currentMonthToDate != null) {
      json[r'current_month_to_date'] = this.currentMonthToDate;
    } else {
      json[r'current_month_to_date'] = null;
    }
    if (this.currentMonthProjected != null) {
      json[r'current_month_projected'] = this.currentMonthProjected;
    } else {
      json[r'current_month_projected'] = null;
    }
    return json;
  }

  /// Returns a new [AccountBandwidth] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static AccountBandwidth? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      assert(() {
        requiredKeys.forEach((key) {
          assert(json.containsKey(key),
              'Required key "AccountBandwidth[$key]" is missing from JSON.');
          assert(json[key] != null,
              'Required key "AccountBandwidth[$key]" has a null value in JSON.');
        });
        return true;
      }());

      return AccountBandwidth(
        previousMonth:
            AccountBandwidthPreviousMonth.fromJson(json[r'previous_month']),
        currentMonthToDate: AccountBandwidthCurrentMonthToDate.fromJson(
            json[r'current_month_to_date']),
        currentMonthProjected: AccountBandwidthCurrentMonthProjected.fromJson(
            json[r'current_month_projected']),
      );
    }
    return null;
  }

  static List<AccountBandwidth> listFromJson(
    dynamic json, {
    bool growable = false,
  }) {
    final result = <AccountBandwidth>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = AccountBandwidth.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, AccountBandwidth> mapFromJson(dynamic json) {
    final map = <String, AccountBandwidth>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = AccountBandwidth.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of AccountBandwidth-objects as value to a dart map
  static Map<String, List<AccountBandwidth>> mapListFromJson(
    dynamic json, {
    bool growable = false,
  }) {
    final map = <String, List<AccountBandwidth>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = AccountBandwidth.listFromJson(
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
