//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of openapi.api;

class InferenceUsageChat {
  /// Returns a new [InferenceUsageChat] instance.
  InferenceUsageChat({
    this.currentTokens,
    this.monthlyAllotment,
    this.overage,
  });

  /// The total number of chat completion tokens used in this monthly period.
  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  String? currentTokens;

  /// The monthly token allotment for this Serverless Inference subscription.
  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  String? monthlyAllotment;

  /// The number of overage chat completion tokens in this monthly period.
  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  String? overage;

  @override
  bool operator ==(Object other) => identical(this, other) || other is InferenceUsageChat &&
    other.currentTokens == currentTokens &&
    other.monthlyAllotment == monthlyAllotment &&
    other.overage == overage;

  @override
  int get hashCode =>
    // ignore: unnecessary_parenthesis
    (currentTokens == null ? 0 : currentTokens!.hashCode) +
    (monthlyAllotment == null ? 0 : monthlyAllotment!.hashCode) +
    (overage == null ? 0 : overage!.hashCode);

  @override
  String toString() => 'InferenceUsageChat[currentTokens=$currentTokens, monthlyAllotment=$monthlyAllotment, overage=$overage]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
    if (this.currentTokens != null) {
      json[r'current_tokens'] = this.currentTokens;
    } else {
      json[r'current_tokens'] = null;
    }
    if (this.monthlyAllotment != null) {
      json[r'monthly_allotment'] = this.monthlyAllotment;
    } else {
      json[r'monthly_allotment'] = null;
    }
    if (this.overage != null) {
      json[r'overage'] = this.overage;
    } else {
      json[r'overage'] = null;
    }
    return json;
  }

  /// Returns a new [InferenceUsageChat] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static InferenceUsageChat? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      assert(() {
        requiredKeys.forEach((key) {
          assert(json.containsKey(key), 'Required key "InferenceUsageChat[$key]" is missing from JSON.');
          assert(json[key] != null, 'Required key "InferenceUsageChat[$key]" has a null value in JSON.');
        });
        return true;
      }());

      return InferenceUsageChat(
        currentTokens: mapValueOfType<String>(json, r'current_tokens'),
        monthlyAllotment: mapValueOfType<String>(json, r'monthly_allotment'),
        overage: mapValueOfType<String>(json, r'overage'),
      );
    }
    return null;
  }

  static List<InferenceUsageChat> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <InferenceUsageChat>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = InferenceUsageChat.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, InferenceUsageChat> mapFromJson(dynamic json) {
    final map = <String, InferenceUsageChat>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = InferenceUsageChat.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of InferenceUsageChat-objects as value to a dart map
  static Map<String, List<InferenceUsageChat>> mapListFromJson(dynamic json, {bool growable = false,}) {
    final map = <String, List<InferenceUsageChat>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = InferenceUsageChat.listFromJson(entry.value, growable: growable,);
      }
    }
    return map;
  }

  /// The list of required keys that must be present in a JSON.
  static const requiredKeys = <String>{
  };
}

