//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of openapi.api;

class Apikey {
  /// Returns a new [Apikey] instance.
  Apikey({
    this.id,
    this.apiKey,
    this.name,
    this.expire,
    this.dateExpire,
  });

  /// A unique ID for the API key.
  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  String? id;

  /// The API key.
  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  String? apiKey;

  /// Custom name of the API key.
  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  String? name;

  /// Will the API key expire?
  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  bool? expire;

  /// Date when the API key expires. Only valid when `expire` is `true`.
  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  String? dateExpire;

  @override
  bool operator ==(Object other) => identical(this, other) || other is Apikey &&
    other.id == id &&
    other.apiKey == apiKey &&
    other.name == name &&
    other.expire == expire &&
    other.dateExpire == dateExpire;

  @override
  int get hashCode =>
    // ignore: unnecessary_parenthesis
    (id == null ? 0 : id!.hashCode) +
    (apiKey == null ? 0 : apiKey!.hashCode) +
    (name == null ? 0 : name!.hashCode) +
    (expire == null ? 0 : expire!.hashCode) +
    (dateExpire == null ? 0 : dateExpire!.hashCode);

  @override
  String toString() => 'Apikey[id=$id, apiKey=$apiKey, name=$name, expire=$expire, dateExpire=$dateExpire]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
    if (this.id != null) {
      json[r'id'] = this.id;
    } else {
      json[r'id'] = null;
    }
    if (this.apiKey != null) {
      json[r'api_key'] = this.apiKey;
    } else {
      json[r'api_key'] = null;
    }
    if (this.name != null) {
      json[r'name'] = this.name;
    } else {
      json[r'name'] = null;
    }
    if (this.expire != null) {
      json[r'expire'] = this.expire;
    } else {
      json[r'expire'] = null;
    }
    if (this.dateExpire != null) {
      json[r'date_expire'] = this.dateExpire;
    } else {
      json[r'date_expire'] = null;
    }
    return json;
  }

  /// Returns a new [Apikey] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static Apikey? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      assert(() {
        requiredKeys.forEach((key) {
          assert(json.containsKey(key), 'Required key "Apikey[$key]" is missing from JSON.');
          assert(json[key] != null, 'Required key "Apikey[$key]" has a null value in JSON.');
        });
        return true;
      }());

      return Apikey(
        id: mapValueOfType<String>(json, r'id'),
        apiKey: mapValueOfType<String>(json, r'api_key'),
        name: mapValueOfType<String>(json, r'name'),
        expire: mapValueOfType<bool>(json, r'expire'),
        dateExpire: mapValueOfType<String>(json, r'date_expire'),
      );
    }
    return null;
  }

  static List<Apikey> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <Apikey>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = Apikey.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, Apikey> mapFromJson(dynamic json) {
    final map = <String, Apikey>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = Apikey.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of Apikey-objects as value to a dart map
  static Map<String, List<Apikey>> mapListFromJson(dynamic json, {bool growable = false,}) {
    final map = <String, List<Apikey>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = Apikey.listFromJson(entry.value, growable: growable,);
      }
    }
    return map;
  }

  /// The list of required keys that must be present in a JSON.
  static const requiredKeys = <String>{
  };
}

