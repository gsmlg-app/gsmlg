//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of openapi.api;

class InferenceUsageAudio {
  /// Returns a new [InferenceUsageAudio] instance.
  InferenceUsageAudio({
    this.ttsCharacters,
    this.ttsSmCharacters,
  });

  /// The total number of text-to-speech input characters used this period with the HD model.
  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  String? ttsCharacters;

  /// The total number of text-to-speech input characters used this period with the basic model.
  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  String? ttsSmCharacters;

  @override
  bool operator ==(Object other) => identical(this, other) || other is InferenceUsageAudio &&
    other.ttsCharacters == ttsCharacters &&
    other.ttsSmCharacters == ttsSmCharacters;

  @override
  int get hashCode =>
    // ignore: unnecessary_parenthesis
    (ttsCharacters == null ? 0 : ttsCharacters!.hashCode) +
    (ttsSmCharacters == null ? 0 : ttsSmCharacters!.hashCode);

  @override
  String toString() => 'InferenceUsageAudio[ttsCharacters=$ttsCharacters, ttsSmCharacters=$ttsSmCharacters]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
    if (this.ttsCharacters != null) {
      json[r'tts_characters'] = this.ttsCharacters;
    } else {
      json[r'tts_characters'] = null;
    }
    if (this.ttsSmCharacters != null) {
      json[r'tts_sm_characters'] = this.ttsSmCharacters;
    } else {
      json[r'tts_sm_characters'] = null;
    }
    return json;
  }

  /// Returns a new [InferenceUsageAudio] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static InferenceUsageAudio? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      assert(() {
        requiredKeys.forEach((key) {
          assert(json.containsKey(key), 'Required key "InferenceUsageAudio[$key]" is missing from JSON.');
          assert(json[key] != null, 'Required key "InferenceUsageAudio[$key]" has a null value in JSON.');
        });
        return true;
      }());

      return InferenceUsageAudio(
        ttsCharacters: mapValueOfType<String>(json, r'tts_characters'),
        ttsSmCharacters: mapValueOfType<String>(json, r'tts_sm_characters'),
      );
    }
    return null;
  }

  static List<InferenceUsageAudio> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <InferenceUsageAudio>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = InferenceUsageAudio.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, InferenceUsageAudio> mapFromJson(dynamic json) {
    final map = <String, InferenceUsageAudio>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = InferenceUsageAudio.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of InferenceUsageAudio-objects as value to a dart map
  static Map<String, List<InferenceUsageAudio>> mapListFromJson(dynamic json, {bool growable = false,}) {
    final map = <String, List<InferenceUsageAudio>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = InferenceUsageAudio.listFromJson(entry.value, growable: growable,);
      }
    }
    return map;
  }

  /// The list of required keys that must be present in a JSON.
  static const requiredKeys = <String>{
  };
}

