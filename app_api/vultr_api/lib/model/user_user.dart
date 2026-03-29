//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of openapi.api;

class UserUser {
  /// Returns a new [UserUser] instance.
  UserUser({
    this.id,
    this.name,
    this.firstName,
    this.lastName,
    this.apiEnabled,
    this.email,
    this.password,
    this.acls = const [],
    this.serviceUser,
    this.apiKey,
  });

  /// The User's id.
  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  String? id;

  /// The User's full name.
  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  String? name;

  /// The User's first name.
  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  String? firstName;

  /// The User's last name.
  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  String? lastName;

  /// Permit API access for this User.  * true * false
  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  bool? apiEnabled;

  /// The User's email address.
  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  String? email;

  /// The User's password.
  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  String? password;

  /// An array of permission granted.  * abuse * activity_logs * alerts * billing * dns * firewall * loadbalancer * manage\\_users * objstore * provisioning * subscriptions * subscriptions\\_view * support * upgrade
  List<String> acls;

  /// Indicates if this is a service user (API-only access, no portal login).  * true * false
  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  bool? serviceUser;

  /// The API key for this user. Only returned when creating service users.
  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  String? apiKey;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UserUser &&
          other.id == id &&
          other.name == name &&
          other.firstName == firstName &&
          other.lastName == lastName &&
          other.apiEnabled == apiEnabled &&
          other.email == email &&
          other.password == password &&
          _deepEquality.equals(other.acls, acls) &&
          other.serviceUser == serviceUser &&
          other.apiKey == apiKey;

  @override
  int get hashCode =>
      // ignore: unnecessary_parenthesis
      (id == null ? 0 : id!.hashCode) +
      (name == null ? 0 : name!.hashCode) +
      (firstName == null ? 0 : firstName!.hashCode) +
      (lastName == null ? 0 : lastName!.hashCode) +
      (apiEnabled == null ? 0 : apiEnabled!.hashCode) +
      (email == null ? 0 : email!.hashCode) +
      (password == null ? 0 : password!.hashCode) +
      (acls.hashCode) +
      (serviceUser == null ? 0 : serviceUser!.hashCode) +
      (apiKey == null ? 0 : apiKey!.hashCode);

  @override
  String toString() =>
      'UserUser[id=$id, name=$name, firstName=$firstName, lastName=$lastName, apiEnabled=$apiEnabled, email=$email, password=$password, acls=$acls, serviceUser=$serviceUser, apiKey=$apiKey]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
    if (this.id != null) {
      json[r'id'] = this.id;
    } else {
      json[r'id'] = null;
    }
    if (this.name != null) {
      json[r'name'] = this.name;
    } else {
      json[r'name'] = null;
    }
    if (this.firstName != null) {
      json[r'first_name'] = this.firstName;
    } else {
      json[r'first_name'] = null;
    }
    if (this.lastName != null) {
      json[r'last_name'] = this.lastName;
    } else {
      json[r'last_name'] = null;
    }
    if (this.apiEnabled != null) {
      json[r'api_enabled'] = this.apiEnabled;
    } else {
      json[r'api_enabled'] = null;
    }
    if (this.email != null) {
      json[r'email'] = this.email;
    } else {
      json[r'email'] = null;
    }
    if (this.password != null) {
      json[r'password'] = this.password;
    } else {
      json[r'password'] = null;
    }
    json[r'acls'] = this.acls;
    if (this.serviceUser != null) {
      json[r'service_user'] = this.serviceUser;
    } else {
      json[r'service_user'] = null;
    }
    if (this.apiKey != null) {
      json[r'api_key'] = this.apiKey;
    } else {
      json[r'api_key'] = null;
    }
    return json;
  }

  /// Returns a new [UserUser] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static UserUser? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      assert(() {
        requiredKeys.forEach((key) {
          assert(json.containsKey(key),
              'Required key "UserUser[$key]" is missing from JSON.');
          assert(json[key] != null,
              'Required key "UserUser[$key]" has a null value in JSON.');
        });
        return true;
      }());

      return UserUser(
        id: mapValueOfType<String>(json, r'id'),
        name: mapValueOfType<String>(json, r'name'),
        firstName: mapValueOfType<String>(json, r'first_name'),
        lastName: mapValueOfType<String>(json, r'last_name'),
        apiEnabled: mapValueOfType<bool>(json, r'api_enabled'),
        email: mapValueOfType<String>(json, r'email'),
        password: mapValueOfType<String>(json, r'password'),
        acls: json[r'acls'] is Iterable
            ? (json[r'acls'] as Iterable).cast<String>().toList(growable: false)
            : const [],
        serviceUser: mapValueOfType<bool>(json, r'service_user'),
        apiKey: mapValueOfType<String>(json, r'api_key'),
      );
    }
    return null;
  }

  static List<UserUser> listFromJson(
    dynamic json, {
    bool growable = false,
  }) {
    final result = <UserUser>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = UserUser.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, UserUser> mapFromJson(dynamic json) {
    final map = <String, UserUser>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = UserUser.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of UserUser-objects as value to a dart map
  static Map<String, List<UserUser>> mapListFromJson(
    dynamic json, {
    bool growable = false,
  }) {
    final map = <String, List<UserUser>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = UserUser.listFromJson(
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
