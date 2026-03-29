//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of openapi.api;

class CreateUserRequest {
  /// Returns a new [CreateUserRequest] instance.
  CreateUserRequest({
    required this.email,
    this.name,
    required this.firstName,
    required this.lastName,
    required this.password,
    this.apiEnabled,
    this.acls = const [],
    this.serviceUser,
  });

  /// The User's email address.
  String email;

  /// Use `first_name`, `last_name` instead. The User's full name.
  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  String? name;

  /// The User's first name.
  String firstName;

  /// The User's last name.
  String lastName;

  /// The User's password.
  String password;

  /// API access is permitted for this User.  * true (default) * false
  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  bool? apiEnabled;

  /// An array of permissions granted.  * abuse * activity_logs * alerts * billing * dns * firewall * loadbalancer * manage\\_users * objstore * provisioning * subscriptions * subscriptions\\_view * support * upgrade
  List<String> acls;

  /// Create this user as a service user (API-only access, no portal login). Service users will receive their API key upon creation.  * true * false (default)
  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  bool? serviceUser;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CreateUserRequest &&
          other.email == email &&
          other.name == name &&
          other.firstName == firstName &&
          other.lastName == lastName &&
          other.password == password &&
          other.apiEnabled == apiEnabled &&
          _deepEquality.equals(other.acls, acls) &&
          other.serviceUser == serviceUser;

  @override
  int get hashCode =>
      // ignore: unnecessary_parenthesis
      (email.hashCode) +
      (name == null ? 0 : name!.hashCode) +
      (firstName.hashCode) +
      (lastName.hashCode) +
      (password.hashCode) +
      (apiEnabled == null ? 0 : apiEnabled!.hashCode) +
      (acls.hashCode) +
      (serviceUser == null ? 0 : serviceUser!.hashCode);

  @override
  String toString() =>
      'CreateUserRequest[email=$email, name=$name, firstName=$firstName, lastName=$lastName, password=$password, apiEnabled=$apiEnabled, acls=$acls, serviceUser=$serviceUser]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
    json[r'email'] = this.email;
    if (this.name != null) {
      json[r'name'] = this.name;
    } else {
      json[r'name'] = null;
    }
    json[r'first_name'] = this.firstName;
    json[r'last_name'] = this.lastName;
    json[r'password'] = this.password;
    if (this.apiEnabled != null) {
      json[r'api_enabled'] = this.apiEnabled;
    } else {
      json[r'api_enabled'] = null;
    }
    json[r'acls'] = this.acls;
    if (this.serviceUser != null) {
      json[r'service_user'] = this.serviceUser;
    } else {
      json[r'service_user'] = null;
    }
    return json;
  }

  /// Returns a new [CreateUserRequest] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static CreateUserRequest? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      assert(() {
        requiredKeys.forEach((key) {
          assert(json.containsKey(key),
              'Required key "CreateUserRequest[$key]" is missing from JSON.');
          assert(json[key] != null,
              'Required key "CreateUserRequest[$key]" has a null value in JSON.');
        });
        return true;
      }());

      return CreateUserRequest(
        email: mapValueOfType<String>(json, r'email')!,
        name: mapValueOfType<String>(json, r'name'),
        firstName: mapValueOfType<String>(json, r'first_name')!,
        lastName: mapValueOfType<String>(json, r'last_name')!,
        password: mapValueOfType<String>(json, r'password')!,
        apiEnabled: mapValueOfType<bool>(json, r'api_enabled'),
        acls: json[r'acls'] is Iterable
            ? (json[r'acls'] as Iterable).cast<String>().toList(growable: false)
            : const [],
        serviceUser: mapValueOfType<bool>(json, r'service_user'),
      );
    }
    return null;
  }

  static List<CreateUserRequest> listFromJson(
    dynamic json, {
    bool growable = false,
  }) {
    final result = <CreateUserRequest>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = CreateUserRequest.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, CreateUserRequest> mapFromJson(dynamic json) {
    final map = <String, CreateUserRequest>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = CreateUserRequest.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of CreateUserRequest-objects as value to a dart map
  static Map<String, List<CreateUserRequest>> mapListFromJson(
    dynamic json, {
    bool growable = false,
  }) {
    final map = <String, List<CreateUserRequest>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = CreateUserRequest.listFromJson(
          entry.value,
          growable: growable,
        );
      }
    }
    return map;
  }

  /// The list of required keys that must be present in a JSON.
  static const requiredKeys = <String>{
    'email',
    'first_name',
    'last_name',
    'password',
  };
}
