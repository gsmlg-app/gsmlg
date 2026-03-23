//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of openapi.api;

class VfsRegion {
  /// Returns a new [VfsRegion] instance.
  VfsRegion({
    this.id,
    this.country,
    this.continent,
    this.description,
    this.pricePerGb,
    this.minSizeGb,
  });

  /// Unique identifier for the region
  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  String? id;

  /// Country where the region is located
  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  String? country;

  /// Continent where the region is located
  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  String? continent;

  /// Human-readable description of the region
  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  String? description;

  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  VfsRegionPricePerGb? pricePerGb;

  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  VfsRegionMinSizeGb? minSizeGb;

  @override
  bool operator ==(Object other) => identical(this, other) || other is VfsRegion &&
    other.id == id &&
    other.country == country &&
    other.continent == continent &&
    other.description == description &&
    other.pricePerGb == pricePerGb &&
    other.minSizeGb == minSizeGb;

  @override
  int get hashCode =>
    // ignore: unnecessary_parenthesis
    (id == null ? 0 : id!.hashCode) +
    (country == null ? 0 : country!.hashCode) +
    (continent == null ? 0 : continent!.hashCode) +
    (description == null ? 0 : description!.hashCode) +
    (pricePerGb == null ? 0 : pricePerGb!.hashCode) +
    (minSizeGb == null ? 0 : minSizeGb!.hashCode);

  @override
  String toString() => 'VfsRegion[id=$id, country=$country, continent=$continent, description=$description, pricePerGb=$pricePerGb, minSizeGb=$minSizeGb]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
    if (this.id != null) {
      json[r'id'] = this.id;
    } else {
      json[r'id'] = null;
    }
    if (this.country != null) {
      json[r'country'] = this.country;
    } else {
      json[r'country'] = null;
    }
    if (this.continent != null) {
      json[r'continent'] = this.continent;
    } else {
      json[r'continent'] = null;
    }
    if (this.description != null) {
      json[r'description'] = this.description;
    } else {
      json[r'description'] = null;
    }
    if (this.pricePerGb != null) {
      json[r'price_per_gb'] = this.pricePerGb;
    } else {
      json[r'price_per_gb'] = null;
    }
    if (this.minSizeGb != null) {
      json[r'min_size_gb'] = this.minSizeGb;
    } else {
      json[r'min_size_gb'] = null;
    }
    return json;
  }

  /// Returns a new [VfsRegion] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static VfsRegion? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      assert(() {
        requiredKeys.forEach((key) {
          assert(json.containsKey(key), 'Required key "VfsRegion[$key]" is missing from JSON.');
          assert(json[key] != null, 'Required key "VfsRegion[$key]" has a null value in JSON.');
        });
        return true;
      }());

      return VfsRegion(
        id: mapValueOfType<String>(json, r'id'),
        country: mapValueOfType<String>(json, r'country'),
        continent: mapValueOfType<String>(json, r'continent'),
        description: mapValueOfType<String>(json, r'description'),
        pricePerGb: VfsRegionPricePerGb.fromJson(json[r'price_per_gb']),
        minSizeGb: VfsRegionMinSizeGb.fromJson(json[r'min_size_gb']),
      );
    }
    return null;
  }

  static List<VfsRegion> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <VfsRegion>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = VfsRegion.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, VfsRegion> mapFromJson(dynamic json) {
    final map = <String, VfsRegion>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = VfsRegion.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of VfsRegion-objects as value to a dart map
  static Map<String, List<VfsRegion>> mapListFromJson(dynamic json, {bool growable = false,}) {
    final map = <String, List<VfsRegion>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = VfsRegion.listFromJson(entry.value, growable: growable,);
      }
    }
    return map;
  }

  /// The list of required keys that must be present in a JSON.
  static const requiredKeys = <String>{
  };
}

