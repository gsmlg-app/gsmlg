//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of openapi.api;

class CreateKubernetesClusterRequestOidc {
  /// Returns a new [CreateKubernetesClusterRequestOidc] instance.
  CreateKubernetesClusterRequestOidc({
    required this.issuerUrl,
    required this.clientId,
    this.usernameClaim,
    this.groupsClaim,
  });

  /// The URL of the OIDC provider that issues authentication tokens.
  String issuerUrl;

  /// The unique identifier assigned to your application by the OIDC provider.
  String clientId;

  /// The claim in the OIDC token that identifies the end user's username.
  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  String? usernameClaim;

  /// The claim in the OIDC token that contains the user's group memberships.
  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  String? groupsClaim;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CreateKubernetesClusterRequestOidc &&
          other.issuerUrl == issuerUrl &&
          other.clientId == clientId &&
          other.usernameClaim == usernameClaim &&
          other.groupsClaim == groupsClaim;

  @override
  int get hashCode =>
      // ignore: unnecessary_parenthesis
      (issuerUrl.hashCode) +
      (clientId.hashCode) +
      (usernameClaim == null ? 0 : usernameClaim!.hashCode) +
      (groupsClaim == null ? 0 : groupsClaim!.hashCode);

  @override
  String toString() =>
      'CreateKubernetesClusterRequestOidc[issuerUrl=$issuerUrl, clientId=$clientId, usernameClaim=$usernameClaim, groupsClaim=$groupsClaim]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
    json[r'issuer_url'] = this.issuerUrl;
    json[r'client_id'] = this.clientId;
    if (this.usernameClaim != null) {
      json[r'username_claim'] = this.usernameClaim;
    } else {
      json[r'username_claim'] = null;
    }
    if (this.groupsClaim != null) {
      json[r'groups_claim'] = this.groupsClaim;
    } else {
      json[r'groups_claim'] = null;
    }
    return json;
  }

  /// Returns a new [CreateKubernetesClusterRequestOidc] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static CreateKubernetesClusterRequestOidc? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      assert(() {
        requiredKeys.forEach((key) {
          assert(json.containsKey(key),
              'Required key "CreateKubernetesClusterRequestOidc[$key]" is missing from JSON.');
          assert(json[key] != null,
              'Required key "CreateKubernetesClusterRequestOidc[$key]" has a null value in JSON.');
        });
        return true;
      }());

      return CreateKubernetesClusterRequestOidc(
        issuerUrl: mapValueOfType<String>(json, r'issuer_url')!,
        clientId: mapValueOfType<String>(json, r'client_id')!,
        usernameClaim: mapValueOfType<String>(json, r'username_claim'),
        groupsClaim: mapValueOfType<String>(json, r'groups_claim'),
      );
    }
    return null;
  }

  static List<CreateKubernetesClusterRequestOidc> listFromJson(
    dynamic json, {
    bool growable = false,
  }) {
    final result = <CreateKubernetesClusterRequestOidc>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = CreateKubernetesClusterRequestOidc.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, CreateKubernetesClusterRequestOidc> mapFromJson(
      dynamic json) {
    final map = <String, CreateKubernetesClusterRequestOidc>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = CreateKubernetesClusterRequestOidc.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of CreateKubernetesClusterRequestOidc-objects as value to a dart map
  static Map<String, List<CreateKubernetesClusterRequestOidc>> mapListFromJson(
    dynamic json, {
    bool growable = false,
  }) {
    final map = <String, List<CreateKubernetesClusterRequestOidc>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = CreateKubernetesClusterRequestOidc.listFromJson(
          entry.value,
          growable: growable,
        );
      }
    }
    return map;
  }

  /// The list of required keys that must be present in a JSON.
  static const requiredKeys = <String>{
    'issuer_url',
    'client_id',
  };
}
