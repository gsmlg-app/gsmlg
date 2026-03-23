//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of openapi.api;

class InferenceUsage {
  /// Returns a new [InferenceUsage] instance.
  InferenceUsage({
    this.chat,
    this.audio,
  });

  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  InferenceUsageChat? chat;

  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  InferenceUsageAudio? audio;

  @override
  bool operator ==(Object other) => identical(this, other) || other is InferenceUsage &&
    other.chat == chat &&
    other.audio == audio;

  @override
  int get hashCode =>
    // ignore: unnecessary_parenthesis
    (chat == null ? 0 : chat!.hashCode) +
    (audio == null ? 0 : audio!.hashCode);

  @override
  String toString() => 'InferenceUsage[chat=$chat, audio=$audio]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
    if (this.chat != null) {
      json[r'chat'] = this.chat;
    } else {
      json[r'chat'] = null;
    }
    if (this.audio != null) {
      json[r'audio'] = this.audio;
    } else {
      json[r'audio'] = null;
    }
    return json;
  }

  /// Returns a new [InferenceUsage] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static InferenceUsage? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      assert(() {
        requiredKeys.forEach((key) {
          assert(json.containsKey(key), 'Required key "InferenceUsage[$key]" is missing from JSON.');
          assert(json[key] != null, 'Required key "InferenceUsage[$key]" has a null value in JSON.');
        });
        return true;
      }());

      return InferenceUsage(
        chat: InferenceUsageChat.fromJson(json[r'chat']),
        audio: InferenceUsageAudio.fromJson(json[r'audio']),
      );
    }
    return null;
  }

  static List<InferenceUsage> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <InferenceUsage>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = InferenceUsage.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, InferenceUsage> mapFromJson(dynamic json) {
    final map = <String, InferenceUsage>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = InferenceUsage.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of InferenceUsage-objects as value to a dart map
  static Map<String, List<InferenceUsage>> mapListFromJson(dynamic json, {bool growable = false,}) {
    final map = <String, List<InferenceUsage>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = InferenceUsage.listFromJson(entry.value, growable: growable,);
      }
    }
    return map;
  }

  /// The list of required keys that must be present in a JSON.
  static const requiredKeys = <String>{
  };
}

