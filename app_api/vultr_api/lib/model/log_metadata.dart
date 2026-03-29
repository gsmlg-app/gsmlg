//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of openapi.api;

class LogMetadata {
  /// Returns a new [LogMetadata] instance.
  LogMetadata({
    required this.userId,
    required this.ipAddress,
    this.username,
    this.httpStatusCode,
    this.method,
    this.requestPath,
    this.requestBody,
    this.queryParameters,
  });

  /// The UUID for the user who triggered the event that is being logged.
  String userId;

  /// The IP address from which the request that generated the log originated.
  String ipAddress;

  /// The email address of a user who is logging in.<br>*This field is only included in the metadata for logs relating to users logging in.*
  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  String? username;

  /// The status code returned for and API request.<br>*This field is only included in the metadata for logs relating to API requests.*
  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  int? httpStatusCode;

  /// The HTTP request method of the API request being logged.<br>*This field is only included in the metadata for logs relating to API requests.* * `GET` * `POST` * `PUT` * `PATCH` * `DELETE`
  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  String? method;

  /// The URI path of the API request being logged.<br>*This field is only included in the metadata for logs relating to API requests.*
  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  String? requestPath;

  /// The request body provided for the API request being logged.<br>*This field is only included in the metadata for logs relating to API requests.*
  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  String? requestBody;

  /// The query string provided for the API request being logged.<br>*This field is only included in the metadata for logs relating to API requests.*
  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  String? queryParameters;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is LogMetadata &&
          other.userId == userId &&
          other.ipAddress == ipAddress &&
          other.username == username &&
          other.httpStatusCode == httpStatusCode &&
          other.method == method &&
          other.requestPath == requestPath &&
          other.requestBody == requestBody &&
          other.queryParameters == queryParameters;

  @override
  int get hashCode =>
      // ignore: unnecessary_parenthesis
      (userId.hashCode) +
      (ipAddress.hashCode) +
      (username == null ? 0 : username!.hashCode) +
      (httpStatusCode == null ? 0 : httpStatusCode!.hashCode) +
      (method == null ? 0 : method!.hashCode) +
      (requestPath == null ? 0 : requestPath!.hashCode) +
      (requestBody == null ? 0 : requestBody!.hashCode) +
      (queryParameters == null ? 0 : queryParameters!.hashCode);

  @override
  String toString() =>
      'LogMetadata[userId=$userId, ipAddress=$ipAddress, username=$username, httpStatusCode=$httpStatusCode, method=$method, requestPath=$requestPath, requestBody=$requestBody, queryParameters=$queryParameters]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
    json[r'user_id'] = this.userId;
    json[r'ip_address'] = this.ipAddress;
    if (this.username != null) {
      json[r'username'] = this.username;
    } else {
      json[r'username'] = null;
    }
    if (this.httpStatusCode != null) {
      json[r'http_status_code'] = this.httpStatusCode;
    } else {
      json[r'http_status_code'] = null;
    }
    if (this.method != null) {
      json[r'method'] = this.method;
    } else {
      json[r'method'] = null;
    }
    if (this.requestPath != null) {
      json[r'request_path'] = this.requestPath;
    } else {
      json[r'request_path'] = null;
    }
    if (this.requestBody != null) {
      json[r'request_body'] = this.requestBody;
    } else {
      json[r'request_body'] = null;
    }
    if (this.queryParameters != null) {
      json[r'query_parameters'] = this.queryParameters;
    } else {
      json[r'query_parameters'] = null;
    }
    return json;
  }

  /// Returns a new [LogMetadata] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static LogMetadata? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      assert(() {
        requiredKeys.forEach((key) {
          assert(json.containsKey(key),
              'Required key "LogMetadata[$key]" is missing from JSON.');
          assert(json[key] != null,
              'Required key "LogMetadata[$key]" has a null value in JSON.');
        });
        return true;
      }());

      return LogMetadata(
        userId: mapValueOfType<String>(json, r'user_id')!,
        ipAddress: mapValueOfType<String>(json, r'ip_address')!,
        username: mapValueOfType<String>(json, r'username'),
        httpStatusCode: mapValueOfType<int>(json, r'http_status_code'),
        method: mapValueOfType<String>(json, r'method'),
        requestPath: mapValueOfType<String>(json, r'request_path'),
        requestBody: mapValueOfType<String>(json, r'request_body'),
        queryParameters: mapValueOfType<String>(json, r'query_parameters'),
      );
    }
    return null;
  }

  static List<LogMetadata> listFromJson(
    dynamic json, {
    bool growable = false,
  }) {
    final result = <LogMetadata>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = LogMetadata.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, LogMetadata> mapFromJson(dynamic json) {
    final map = <String, LogMetadata>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = LogMetadata.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of LogMetadata-objects as value to a dart map
  static Map<String, List<LogMetadata>> mapListFromJson(
    dynamic json, {
    bool growable = false,
  }) {
    final map = <String, List<LogMetadata>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = LogMetadata.listFromJson(
          entry.value,
          growable: growable,
        );
      }
    }
    return map;
  }

  /// The list of required keys that must be present in a JSON.
  static const requiredKeys = <String>{
    'user_id',
    'ip_address',
  };
}
