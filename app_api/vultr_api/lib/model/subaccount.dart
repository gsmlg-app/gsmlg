//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of openapi.api;

class Subaccount {
  /// Returns a new [Subaccount] instance.
  Subaccount({
    this.id,
    this.email,
    this.subaccountName,
    this.subaccountId,
    this.activated,
    this.balance,
    this.pendingCharges,
  });

  /// A unique ID for the sub-account.
  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  String? id;

  /// The email address of this sub-account.
  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  String? email;

  /// Your name for this sub-account.
  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  String? subaccountName;

  /// Your ID for this sub-account.
  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  String? subaccountId;

  /// Has this sub-account been activated or not.
  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  bool? activated;

  /// The current balance of the sub-account.
  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  double? balance;

  /// Charges due for this sub-account at the end of the billing period.
  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  double? pendingCharges;

  @override
  bool operator ==(Object other) => identical(this, other) || other is Subaccount &&
    other.id == id &&
    other.email == email &&
    other.subaccountName == subaccountName &&
    other.subaccountId == subaccountId &&
    other.activated == activated &&
    other.balance == balance &&
    other.pendingCharges == pendingCharges;

  @override
  int get hashCode =>
    // ignore: unnecessary_parenthesis
    (id == null ? 0 : id!.hashCode) +
    (email == null ? 0 : email!.hashCode) +
    (subaccountName == null ? 0 : subaccountName!.hashCode) +
    (subaccountId == null ? 0 : subaccountId!.hashCode) +
    (activated == null ? 0 : activated!.hashCode) +
    (balance == null ? 0 : balance!.hashCode) +
    (pendingCharges == null ? 0 : pendingCharges!.hashCode);

  @override
  String toString() => 'Subaccount[id=$id, email=$email, subaccountName=$subaccountName, subaccountId=$subaccountId, activated=$activated, balance=$balance, pendingCharges=$pendingCharges]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
    if (this.id != null) {
      json[r'id'] = this.id;
    } else {
      json[r'id'] = null;
    }
    if (this.email != null) {
      json[r'email'] = this.email;
    } else {
      json[r'email'] = null;
    }
    if (this.subaccountName != null) {
      json[r'subaccount_name'] = this.subaccountName;
    } else {
      json[r'subaccount_name'] = null;
    }
    if (this.subaccountId != null) {
      json[r'subaccount_id'] = this.subaccountId;
    } else {
      json[r'subaccount_id'] = null;
    }
    if (this.activated != null) {
      json[r'activated'] = this.activated;
    } else {
      json[r'activated'] = null;
    }
    if (this.balance != null) {
      json[r'balance'] = this.balance;
    } else {
      json[r'balance'] = null;
    }
    if (this.pendingCharges != null) {
      json[r'pending_charges'] = this.pendingCharges;
    } else {
      json[r'pending_charges'] = null;
    }
    return json;
  }

  /// Returns a new [Subaccount] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static Subaccount? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      assert(() {
        requiredKeys.forEach((key) {
          assert(json.containsKey(key), 'Required key "Subaccount[$key]" is missing from JSON.');
          assert(json[key] != null, 'Required key "Subaccount[$key]" has a null value in JSON.');
        });
        return true;
      }());

      return Subaccount(
        id: mapValueOfType<String>(json, r'id'),
        email: mapValueOfType<String>(json, r'email'),
        subaccountName: mapValueOfType<String>(json, r'subaccount_name'),
        subaccountId: mapValueOfType<String>(json, r'subaccount_id'),
        activated: mapValueOfType<bool>(json, r'activated'),
        balance: mapValueOfType<double>(json, r'balance'),
        pendingCharges: mapValueOfType<double>(json, r'pending_charges'),
      );
    }
    return null;
  }

  static List<Subaccount> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <Subaccount>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = Subaccount.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, Subaccount> mapFromJson(dynamic json) {
    final map = <String, Subaccount>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = Subaccount.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of Subaccount-objects as value to a dart map
  static Map<String, List<Subaccount>> mapListFromJson(dynamic json, {bool growable = false,}) {
    final map = <String, List<Subaccount>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = Subaccount.listFromJson(entry.value, growable: growable,);
      }
    }
    return map;
  }

  /// The list of required keys that must be present in a JSON.
  static const requiredKeys = <String>{
  };
}

