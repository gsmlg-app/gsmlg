//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of openapi.api;

class Tiers {
  /// Returns a new [Tiers] instance.
  Tiers({
    this.id,
    this.bwGbPrice,
    this.diskGbPrice,
    this.isDefault,
    this.price,
    this.ratelimitOpsBytes,
    this.ratelimitOpsSecs,
    this.salesDesc,
    this.salesName,
    this.slug,
    this.locations = const [],
  });

  /// Object Storage Tier ID.
  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  int? id;

  /// Price per additional gigabyte of bandwidth.
  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  double? bwGbPrice;

  /// Price per additional gigabyte of capacity.
  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  double? diskGbPrice;

  /// Is this tier the default?
  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  String? isDefault;

  /// Monthly price for this tier.
  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  double? price;

  /// Rate limit on the number of bytes per second.
  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  int? ratelimitOpsBytes;

  /// Rate limit on the number of operations per second.
  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  int? ratelimitOpsSecs;

  /// Sales description.
  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  String? salesDesc;

  /// Sales name.
  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  String? salesName;

  /// Slug, unique name.
  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  String? slug;

  /// Clusters where the tier is available.
  List<TiersLocationsInner> locations;

  @override
  bool operator ==(Object other) => identical(this, other) || other is Tiers &&
    other.id == id &&
    other.bwGbPrice == bwGbPrice &&
    other.diskGbPrice == diskGbPrice &&
    other.isDefault == isDefault &&
    other.price == price &&
    other.ratelimitOpsBytes == ratelimitOpsBytes &&
    other.ratelimitOpsSecs == ratelimitOpsSecs &&
    other.salesDesc == salesDesc &&
    other.salesName == salesName &&
    other.slug == slug &&
    _deepEquality.equals(other.locations, locations);

  @override
  int get hashCode =>
    // ignore: unnecessary_parenthesis
    (id == null ? 0 : id!.hashCode) +
    (bwGbPrice == null ? 0 : bwGbPrice!.hashCode) +
    (diskGbPrice == null ? 0 : diskGbPrice!.hashCode) +
    (isDefault == null ? 0 : isDefault!.hashCode) +
    (price == null ? 0 : price!.hashCode) +
    (ratelimitOpsBytes == null ? 0 : ratelimitOpsBytes!.hashCode) +
    (ratelimitOpsSecs == null ? 0 : ratelimitOpsSecs!.hashCode) +
    (salesDesc == null ? 0 : salesDesc!.hashCode) +
    (salesName == null ? 0 : salesName!.hashCode) +
    (slug == null ? 0 : slug!.hashCode) +
    (locations.hashCode);

  @override
  String toString() => 'Tiers[id=$id, bwGbPrice=$bwGbPrice, diskGbPrice=$diskGbPrice, isDefault=$isDefault, price=$price, ratelimitOpsBytes=$ratelimitOpsBytes, ratelimitOpsSecs=$ratelimitOpsSecs, salesDesc=$salesDesc, salesName=$salesName, slug=$slug, locations=$locations]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
    if (this.id != null) {
      json[r'id'] = this.id;
    } else {
      json[r'id'] = null;
    }
    if (this.bwGbPrice != null) {
      json[r'bw_gb_price'] = this.bwGbPrice;
    } else {
      json[r'bw_gb_price'] = null;
    }
    if (this.diskGbPrice != null) {
      json[r'disk_gb_price'] = this.diskGbPrice;
    } else {
      json[r'disk_gb_price'] = null;
    }
    if (this.isDefault != null) {
      json[r'is_default'] = this.isDefault;
    } else {
      json[r'is_default'] = null;
    }
    if (this.price != null) {
      json[r'price'] = this.price;
    } else {
      json[r'price'] = null;
    }
    if (this.ratelimitOpsBytes != null) {
      json[r'ratelimit_ops_bytes'] = this.ratelimitOpsBytes;
    } else {
      json[r'ratelimit_ops_bytes'] = null;
    }
    if (this.ratelimitOpsSecs != null) {
      json[r'ratelimit_ops_secs'] = this.ratelimitOpsSecs;
    } else {
      json[r'ratelimit_ops_secs'] = null;
    }
    if (this.salesDesc != null) {
      json[r'sales_desc'] = this.salesDesc;
    } else {
      json[r'sales_desc'] = null;
    }
    if (this.salesName != null) {
      json[r'sales_name'] = this.salesName;
    } else {
      json[r'sales_name'] = null;
    }
    if (this.slug != null) {
      json[r'slug'] = this.slug;
    } else {
      json[r'slug'] = null;
    }
      json[r'locations'] = this.locations;
    return json;
  }

  /// Returns a new [Tiers] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static Tiers? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      assert(() {
        requiredKeys.forEach((key) {
          assert(json.containsKey(key), 'Required key "Tiers[$key]" is missing from JSON.');
          assert(json[key] != null, 'Required key "Tiers[$key]" has a null value in JSON.');
        });
        return true;
      }());

      return Tiers(
        id: mapValueOfType<int>(json, r'id'),
        bwGbPrice: mapValueOfType<double>(json, r'bw_gb_price'),
        diskGbPrice: mapValueOfType<double>(json, r'disk_gb_price'),
        isDefault: mapValueOfType<String>(json, r'is_default'),
        price: mapValueOfType<double>(json, r'price'),
        ratelimitOpsBytes: mapValueOfType<int>(json, r'ratelimit_ops_bytes'),
        ratelimitOpsSecs: mapValueOfType<int>(json, r'ratelimit_ops_secs'),
        salesDesc: mapValueOfType<String>(json, r'sales_desc'),
        salesName: mapValueOfType<String>(json, r'sales_name'),
        slug: mapValueOfType<String>(json, r'slug'),
        locations: TiersLocationsInner.listFromJson(json[r'locations']),
      );
    }
    return null;
  }

  static List<Tiers> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <Tiers>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = Tiers.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, Tiers> mapFromJson(dynamic json) {
    final map = <String, Tiers>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = Tiers.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of Tiers-objects as value to a dart map
  static Map<String, List<Tiers>> mapListFromJson(dynamic json, {bool growable = false,}) {
    final map = <String, List<Tiers>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = Tiers.listFromJson(entry.value, growable: growable,);
      }
    }
    return map;
  }

  /// The list of required keys that must be present in a JSON.
  static const requiredKeys = <String>{
  };
}

