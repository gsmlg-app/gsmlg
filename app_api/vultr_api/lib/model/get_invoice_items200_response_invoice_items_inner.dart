//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of openapi.api;

class GetInvoiceItems200ResponseInvoiceItemsInner {
  /// Returns a new [GetInvoiceItems200ResponseInvoiceItemsInner] instance.
  GetInvoiceItems200ResponseInvoiceItemsInner({
    this.description,
    this.product,
    this.startDate,
    this.endDate,
    this.units,
    this.unitType,
    this.unitPrice,
    this.total,
  });

  /// Invoice item description
  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  String? description;

  /// Product name
  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  String? product;

  /// Start date of item
  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  String? startDate;

  /// End date of item
  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  String? endDate;

  /// Number of units item consumed in billing period
  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  num? units;

  /// Unit type. Options include \"hours\", \"overage\", and \"discount\"
  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  String? unitType;

  /// Price per unit in dollars
  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  num? unitPrice;

  /// Total amount due in dollars
  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  num? total;

  @override
  bool operator ==(Object other) => identical(this, other) || other is GetInvoiceItems200ResponseInvoiceItemsInner &&
    other.description == description &&
    other.product == product &&
    other.startDate == startDate &&
    other.endDate == endDate &&
    other.units == units &&
    other.unitType == unitType &&
    other.unitPrice == unitPrice &&
    other.total == total;

  @override
  int get hashCode =>
    // ignore: unnecessary_parenthesis
    (description == null ? 0 : description!.hashCode) +
    (product == null ? 0 : product!.hashCode) +
    (startDate == null ? 0 : startDate!.hashCode) +
    (endDate == null ? 0 : endDate!.hashCode) +
    (units == null ? 0 : units!.hashCode) +
    (unitType == null ? 0 : unitType!.hashCode) +
    (unitPrice == null ? 0 : unitPrice!.hashCode) +
    (total == null ? 0 : total!.hashCode);

  @override
  String toString() => 'GetInvoiceItems200ResponseInvoiceItemsInner[description=$description, product=$product, startDate=$startDate, endDate=$endDate, units=$units, unitType=$unitType, unitPrice=$unitPrice, total=$total]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
    if (this.description != null) {
      json[r'description'] = this.description;
    } else {
      json[r'description'] = null;
    }
    if (this.product != null) {
      json[r'product'] = this.product;
    } else {
      json[r'product'] = null;
    }
    if (this.startDate != null) {
      json[r'start_date'] = this.startDate;
    } else {
      json[r'start_date'] = null;
    }
    if (this.endDate != null) {
      json[r'end_date'] = this.endDate;
    } else {
      json[r'end_date'] = null;
    }
    if (this.units != null) {
      json[r'units'] = this.units;
    } else {
      json[r'units'] = null;
    }
    if (this.unitType != null) {
      json[r'unit_type'] = this.unitType;
    } else {
      json[r'unit_type'] = null;
    }
    if (this.unitPrice != null) {
      json[r'unit_price'] = this.unitPrice;
    } else {
      json[r'unit_price'] = null;
    }
    if (this.total != null) {
      json[r'total'] = this.total;
    } else {
      json[r'total'] = null;
    }
    return json;
  }

  /// Returns a new [GetInvoiceItems200ResponseInvoiceItemsInner] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static GetInvoiceItems200ResponseInvoiceItemsInner? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      assert(() {
        requiredKeys.forEach((key) {
          assert(json.containsKey(key), 'Required key "GetInvoiceItems200ResponseInvoiceItemsInner[$key]" is missing from JSON.');
          assert(json[key] != null, 'Required key "GetInvoiceItems200ResponseInvoiceItemsInner[$key]" has a null value in JSON.');
        });
        return true;
      }());

      return GetInvoiceItems200ResponseInvoiceItemsInner(
        description: mapValueOfType<String>(json, r'description'),
        product: mapValueOfType<String>(json, r'product'),
        startDate: mapValueOfType<String>(json, r'start_date'),
        endDate: mapValueOfType<String>(json, r'end_date'),
        units: num.parse('${json[r'units']}'),
        unitType: mapValueOfType<String>(json, r'unit_type'),
        unitPrice: num.parse('${json[r'unit_price']}'),
        total: num.parse('${json[r'total']}'),
      );
    }
    return null;
  }

  static List<GetInvoiceItems200ResponseInvoiceItemsInner> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <GetInvoiceItems200ResponseInvoiceItemsInner>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = GetInvoiceItems200ResponseInvoiceItemsInner.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, GetInvoiceItems200ResponseInvoiceItemsInner> mapFromJson(dynamic json) {
    final map = <String, GetInvoiceItems200ResponseInvoiceItemsInner>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = GetInvoiceItems200ResponseInvoiceItemsInner.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of GetInvoiceItems200ResponseInvoiceItemsInner-objects as value to a dart map
  static Map<String, List<GetInvoiceItems200ResponseInvoiceItemsInner>> mapListFromJson(dynamic json, {bool growable = false,}) {
    final map = <String, List<GetInvoiceItems200ResponseInvoiceItemsInner>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = GetInvoiceItems200ResponseInvoiceItemsInner.listFromJson(entry.value, growable: growable,);
      }
    }
    return map;
  }

  /// The list of required keys that must be present in a JSON.
  static const requiredKeys = <String>{
  };
}

