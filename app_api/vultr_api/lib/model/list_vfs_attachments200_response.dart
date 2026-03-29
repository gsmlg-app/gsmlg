//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of openapi.api;

class ListVFSAttachments200Response {
  /// Returns a new [ListVFSAttachments200Response] instance.
  ListVFSAttachments200Response({
    this.attachments = const [],
  });

  List<VfsAttachment> attachments;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ListVFSAttachments200Response &&
          _deepEquality.equals(other.attachments, attachments);

  @override
  int get hashCode =>
      // ignore: unnecessary_parenthesis
      (attachments.hashCode);

  @override
  String toString() =>
      'ListVFSAttachments200Response[attachments=$attachments]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
    json[r'attachments'] = this.attachments;
    return json;
  }

  /// Returns a new [ListVFSAttachments200Response] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static ListVFSAttachments200Response? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      assert(() {
        requiredKeys.forEach((key) {
          assert(json.containsKey(key),
              'Required key "ListVFSAttachments200Response[$key]" is missing from JSON.');
          assert(json[key] != null,
              'Required key "ListVFSAttachments200Response[$key]" has a null value in JSON.');
        });
        return true;
      }());

      return ListVFSAttachments200Response(
        attachments: VfsAttachment.listFromJson(json[r'attachments']),
      );
    }
    return null;
  }

  static List<ListVFSAttachments200Response> listFromJson(
    dynamic json, {
    bool growable = false,
  }) {
    final result = <ListVFSAttachments200Response>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = ListVFSAttachments200Response.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, ListVFSAttachments200Response> mapFromJson(dynamic json) {
    final map = <String, ListVFSAttachments200Response>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = ListVFSAttachments200Response.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of ListVFSAttachments200Response-objects as value to a dart map
  static Map<String, List<ListVFSAttachments200Response>> mapListFromJson(
    dynamic json, {
    bool growable = false,
  }) {
    final map = <String, List<ListVFSAttachments200Response>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = ListVFSAttachments200Response.listFromJson(
          entry.value,
          growable: growable,
        );
      }
    }
    return map;
  }

  /// The list of required keys that must be present in a JSON.
  static const requiredKeys = <String>{};
}
