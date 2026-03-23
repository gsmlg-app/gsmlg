//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of openapi.api;

class InferenceSubscription {
  /// Returns a new [InferenceSubscription] instance.
  InferenceSubscription({
    this.id,
    this.dateCreated,
    this.label,
    this.apiKey,
  });

  /// A unique ID for the Serverless Inference subscription.
  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  String? id;

  /// The date this Serverless Inference subscription was created.
  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  String? dateCreated;

  /// The user-supplied label for this Serverless Inference subscription.
  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  String? label;

  /// The API key used to access the Vultr Inference API.
  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  String? apiKey;

  @override
  bool operator ==(Object other) => identical(this, other) || other is InferenceSubscription &&
    other.id == id &&
    other.dateCreated == dateCreated &&
    other.label == label &&
    other.apiKey == apiKey;

  @override
  int get hashCode =>
    // ignore: unnecessary_parenthesis
    (id == null ? 0 : id!.hashCode) +
    (dateCreated == null ? 0 : dateCreated!.hashCode) +
    (label == null ? 0 : label!.hashCode) +
    (apiKey == null ? 0 : apiKey!.hashCode);

  @override
  String toString() => 'InferenceSubscription[id=$id, dateCreated=$dateCreated, label=$label, apiKey=$apiKey]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
    if (this.id != null) {
      json[r'id'] = this.id;
    } else {
      json[r'id'] = null;
    }
    if (this.dateCreated != null) {
      json[r'date_created'] = this.dateCreated;
    } else {
      json[r'date_created'] = null;
    }
    if (this.label != null) {
      json[r'label'] = this.label;
    } else {
      json[r'label'] = null;
    }
    if (this.apiKey != null) {
      json[r'api_key'] = this.apiKey;
    } else {
      json[r'api_key'] = null;
    }
    return json;
  }

  /// Returns a new [InferenceSubscription] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static InferenceSubscription? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      assert(() {
        requiredKeys.forEach((key) {
          assert(json.containsKey(key), 'Required key "InferenceSubscription[$key]" is missing from JSON.');
          assert(json[key] != null, 'Required key "InferenceSubscription[$key]" has a null value in JSON.');
        });
        return true;
      }());

      return InferenceSubscription(
        id: mapValueOfType<String>(json, r'id'),
        dateCreated: mapValueOfType<String>(json, r'date_created'),
        label: mapValueOfType<String>(json, r'label'),
        apiKey: mapValueOfType<String>(json, r'api_key'),
      );
    }
    return null;
  }

  static List<InferenceSubscription> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <InferenceSubscription>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = InferenceSubscription.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, InferenceSubscription> mapFromJson(dynamic json) {
    final map = <String, InferenceSubscription>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = InferenceSubscription.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of InferenceSubscription-objects as value to a dart map
  static Map<String, List<InferenceSubscription>> mapListFromJson(dynamic json, {bool growable = false,}) {
    final map = <String, List<InferenceSubscription>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = InferenceSubscription.listFromJson(entry.value, growable: growable,);
      }
    }
    return map;
  }

  /// The list of required keys that must be present in a JSON.
  static const requiredKeys = <String>{
  };
}

