//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of openapi.api;

class Account {
  /// Returns a new [Account] instance.
  Account({
    this.name,
    this.email,
    this.acls = const [],
    this.balance,
    this.pendingCharges,
    this.lastPaymentDate,
    this.lastPaymentAmount,
  });

  /// Your user name.
  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  String? name;

  /// Your email address.
  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  String? email;

  /// An array of permission granted. * manage\\_users * subscriptions_view * subscriptions * billing * support * provisioning * dns * abuse * upgrade * firewall * alerts * objstore * loadbalancer
  List<String> acls;

  /// Your current account balance.
  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  num? balance;

  /// Unbilled charges for this month.
  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  num? pendingCharges;

  /// Date of your last payment.
  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  String? lastPaymentDate;

  /// The amount of your last payment.
  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  num? lastPaymentAmount;

  @override
  bool operator ==(Object other) => identical(this, other) || other is Account &&
    other.name == name &&
    other.email == email &&
    _deepEquality.equals(other.acls, acls) &&
    other.balance == balance &&
    other.pendingCharges == pendingCharges &&
    other.lastPaymentDate == lastPaymentDate &&
    other.lastPaymentAmount == lastPaymentAmount;

  @override
  int get hashCode =>
    // ignore: unnecessary_parenthesis
    (name == null ? 0 : name!.hashCode) +
    (email == null ? 0 : email!.hashCode) +
    (acls.hashCode) +
    (balance == null ? 0 : balance!.hashCode) +
    (pendingCharges == null ? 0 : pendingCharges!.hashCode) +
    (lastPaymentDate == null ? 0 : lastPaymentDate!.hashCode) +
    (lastPaymentAmount == null ? 0 : lastPaymentAmount!.hashCode);

  @override
  String toString() => 'Account[name=$name, email=$email, acls=$acls, balance=$balance, pendingCharges=$pendingCharges, lastPaymentDate=$lastPaymentDate, lastPaymentAmount=$lastPaymentAmount]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
    if (this.name != null) {
      json[r'name'] = this.name;
    } else {
      json[r'name'] = null;
    }
    if (this.email != null) {
      json[r'email'] = this.email;
    } else {
      json[r'email'] = null;
    }
      json[r'acls'] = this.acls;
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
    if (this.lastPaymentDate != null) {
      json[r'last_payment_date'] = this.lastPaymentDate;
    } else {
      json[r'last_payment_date'] = null;
    }
    if (this.lastPaymentAmount != null) {
      json[r'last_payment_amount'] = this.lastPaymentAmount;
    } else {
      json[r'last_payment_amount'] = null;
    }
    return json;
  }

  /// Returns a new [Account] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static Account? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      assert(() {
        requiredKeys.forEach((key) {
          assert(json.containsKey(key), 'Required key "Account[$key]" is missing from JSON.');
          assert(json[key] != null, 'Required key "Account[$key]" has a null value in JSON.');
        });
        return true;
      }());

      return Account(
        name: mapValueOfType<String>(json, r'name'),
        email: mapValueOfType<String>(json, r'email'),
        acls: json[r'acls'] is Iterable
            ? (json[r'acls'] as Iterable).cast<String>().toList(growable: false)
            : const [],
        balance: num.parse('${json[r'balance']}'),
        pendingCharges: num.parse('${json[r'pending_charges']}'),
        lastPaymentDate: mapValueOfType<String>(json, r'last_payment_date'),
        lastPaymentAmount: num.parse('${json[r'last_payment_amount']}'),
      );
    }
    return null;
  }

  static List<Account> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <Account>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = Account.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, Account> mapFromJson(dynamic json) {
    final map = <String, Account>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = Account.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of Account-objects as value to a dart map
  static Map<String, List<Account>> mapListFromJson(dynamic json, {bool growable = false,}) {
    final map = <String, List<Account>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = Account.listFromJson(entry.value, growable: growable,);
      }
    }
    return map;
  }

  /// The list of required keys that must be present in a JSON.
  static const requiredKeys = <String>{
  };
}

