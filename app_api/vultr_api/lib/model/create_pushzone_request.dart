//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of openapi.api;

class CreatePushzoneRequest {
  /// Returns a new [CreatePushzoneRequest] instance.
  CreatePushzoneRequest({
    required this.label,
    this.vanityDomain,
    this.sslCert,
    this.sslCertKey,
    this.cors,
    this.gzip,
    this.blockAi,
    this.blockBadBots,
  });

  /// The user-supplied label.
  String label;

  /// An optional domain name that can be used to access the cached files in adition to the domain that is automaticaly created.  This vanity domain will need to have a CNAME DNS record created to point it at the standard CDN domain that is automaticaly generated on creation of the CDN.
  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  String? vanityDomain;

  /// Base 64 encoded file content for an ssl/tls certificate associated with the optional vanity_domain.  This field is required if a vanity domain is provided.
  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  String? sslCert;

  /// Base 64 encoded file content for the private key associated with the ssl_cert.  This field is required if a vanity domain is provided.
  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  String? sslCertKey;

  /// Enable Cross-origin resource sharing.  CORS is a content validation mechanism used by web browsers to validate file access permissions. The Vultr CDN CORS policy protects your static assets from hotlinking threats by only accepting requests associated with your Origin URL.
  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  bool? cors;

  /// Enable Gzip compression to reduce the static content size to speed up the delivery process.
  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  bool? gzip;

  /// Block AI bots.
  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  bool? blockAi;

  /// Block potentially malicious bots.
  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  bool? blockBadBots;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CreatePushzoneRequest &&
          other.label == label &&
          other.vanityDomain == vanityDomain &&
          other.sslCert == sslCert &&
          other.sslCertKey == sslCertKey &&
          other.cors == cors &&
          other.gzip == gzip &&
          other.blockAi == blockAi &&
          other.blockBadBots == blockBadBots;

  @override
  int get hashCode =>
      // ignore: unnecessary_parenthesis
      (label.hashCode) +
      (vanityDomain == null ? 0 : vanityDomain!.hashCode) +
      (sslCert == null ? 0 : sslCert!.hashCode) +
      (sslCertKey == null ? 0 : sslCertKey!.hashCode) +
      (cors == null ? 0 : cors!.hashCode) +
      (gzip == null ? 0 : gzip!.hashCode) +
      (blockAi == null ? 0 : blockAi!.hashCode) +
      (blockBadBots == null ? 0 : blockBadBots!.hashCode);

  @override
  String toString() =>
      'CreatePushzoneRequest[label=$label, vanityDomain=$vanityDomain, sslCert=$sslCert, sslCertKey=$sslCertKey, cors=$cors, gzip=$gzip, blockAi=$blockAi, blockBadBots=$blockBadBots]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
    json[r'label'] = this.label;
    if (this.vanityDomain != null) {
      json[r'vanity_domain'] = this.vanityDomain;
    } else {
      json[r'vanity_domain'] = null;
    }
    if (this.sslCert != null) {
      json[r'ssl_cert'] = this.sslCert;
    } else {
      json[r'ssl_cert'] = null;
    }
    if (this.sslCertKey != null) {
      json[r'ssl_cert_key'] = this.sslCertKey;
    } else {
      json[r'ssl_cert_key'] = null;
    }
    if (this.cors != null) {
      json[r'cors'] = this.cors;
    } else {
      json[r'cors'] = null;
    }
    if (this.gzip != null) {
      json[r'gzip'] = this.gzip;
    } else {
      json[r'gzip'] = null;
    }
    if (this.blockAi != null) {
      json[r'block_ai'] = this.blockAi;
    } else {
      json[r'block_ai'] = null;
    }
    if (this.blockBadBots != null) {
      json[r'block_bad_bots'] = this.blockBadBots;
    } else {
      json[r'block_bad_bots'] = null;
    }
    return json;
  }

  /// Returns a new [CreatePushzoneRequest] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static CreatePushzoneRequest? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      assert(() {
        requiredKeys.forEach((key) {
          assert(json.containsKey(key),
              'Required key "CreatePushzoneRequest[$key]" is missing from JSON.');
          assert(json[key] != null,
              'Required key "CreatePushzoneRequest[$key]" has a null value in JSON.');
        });
        return true;
      }());

      return CreatePushzoneRequest(
        label: mapValueOfType<String>(json, r'label')!,
        vanityDomain: mapValueOfType<String>(json, r'vanity_domain'),
        sslCert: mapValueOfType<String>(json, r'ssl_cert'),
        sslCertKey: mapValueOfType<String>(json, r'ssl_cert_key'),
        cors: mapValueOfType<bool>(json, r'cors'),
        gzip: mapValueOfType<bool>(json, r'gzip'),
        blockAi: mapValueOfType<bool>(json, r'block_ai'),
        blockBadBots: mapValueOfType<bool>(json, r'block_bad_bots'),
      );
    }
    return null;
  }

  static List<CreatePushzoneRequest> listFromJson(
    dynamic json, {
    bool growable = false,
  }) {
    final result = <CreatePushzoneRequest>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = CreatePushzoneRequest.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, CreatePushzoneRequest> mapFromJson(dynamic json) {
    final map = <String, CreatePushzoneRequest>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = CreatePushzoneRequest.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of CreatePushzoneRequest-objects as value to a dart map
  static Map<String, List<CreatePushzoneRequest>> mapListFromJson(
    dynamic json, {
    bool growable = false,
  }) {
    final map = <String, List<CreatePushzoneRequest>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = CreatePushzoneRequest.listFromJson(
          entry.value,
          growable: growable,
        );
      }
    }
    return map;
  }

  /// The list of required keys that must be present in a JSON.
  static const requiredKeys = <String>{
    'label',
  };
}
