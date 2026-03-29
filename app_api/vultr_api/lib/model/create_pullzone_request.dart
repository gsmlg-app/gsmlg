//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of openapi.api;

class CreatePullzoneRequest {
  /// Returns a new [CreatePullzoneRequest] instance.
  CreatePullzoneRequest({
    required this.label,
    required this.originScheme,
    required this.originDomain,
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

  /// The URI scheme of the origin domain.
  CreatePullzoneRequestOriginSchemeEnum originScheme;

  /// The domain name from which the content stored in the CDN will be pulled.
  String originDomain;

  /// An optional domain name that can be used to access the cached files in adition to the domain that is automaticaly created.  This vanity domain will need to have a CNAME DNS record created to point it at the standard CDN domain that is automaticaly generated on creation of the CDN.
  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  String? vanityDomain;

  /// Base 64 encoded file content for an ssl/tls certificate associated with the optional vanity_domain.  This field is required if a vanity domain is provided and the origin_scheme is https.
  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  String? sslCert;

  /// Base 64 encoded file content for the private key associated with the ssl_cert.  This field is required if a vanity domain is provided and the origin_scheme is https.
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
      other is CreatePullzoneRequest &&
          other.label == label &&
          other.originScheme == originScheme &&
          other.originDomain == originDomain &&
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
      (originScheme.hashCode) +
      (originDomain.hashCode) +
      (vanityDomain == null ? 0 : vanityDomain!.hashCode) +
      (sslCert == null ? 0 : sslCert!.hashCode) +
      (sslCertKey == null ? 0 : sslCertKey!.hashCode) +
      (cors == null ? 0 : cors!.hashCode) +
      (gzip == null ? 0 : gzip!.hashCode) +
      (blockAi == null ? 0 : blockAi!.hashCode) +
      (blockBadBots == null ? 0 : blockBadBots!.hashCode);

  @override
  String toString() =>
      'CreatePullzoneRequest[label=$label, originScheme=$originScheme, originDomain=$originDomain, vanityDomain=$vanityDomain, sslCert=$sslCert, sslCertKey=$sslCertKey, cors=$cors, gzip=$gzip, blockAi=$blockAi, blockBadBots=$blockBadBots]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
    json[r'label'] = this.label;
    json[r'origin_scheme'] = this.originScheme;
    json[r'origin_domain'] = this.originDomain;
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

  /// Returns a new [CreatePullzoneRequest] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static CreatePullzoneRequest? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      assert(() {
        requiredKeys.forEach((key) {
          assert(json.containsKey(key),
              'Required key "CreatePullzoneRequest[$key]" is missing from JSON.');
          assert(json[key] != null,
              'Required key "CreatePullzoneRequest[$key]" has a null value in JSON.');
        });
        return true;
      }());

      return CreatePullzoneRequest(
        label: mapValueOfType<String>(json, r'label')!,
        originScheme: CreatePullzoneRequestOriginSchemeEnum.fromJson(
            json[r'origin_scheme'])!,
        originDomain: mapValueOfType<String>(json, r'origin_domain')!,
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

  static List<CreatePullzoneRequest> listFromJson(
    dynamic json, {
    bool growable = false,
  }) {
    final result = <CreatePullzoneRequest>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = CreatePullzoneRequest.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, CreatePullzoneRequest> mapFromJson(dynamic json) {
    final map = <String, CreatePullzoneRequest>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = CreatePullzoneRequest.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of CreatePullzoneRequest-objects as value to a dart map
  static Map<String, List<CreatePullzoneRequest>> mapListFromJson(
    dynamic json, {
    bool growable = false,
  }) {
    final map = <String, List<CreatePullzoneRequest>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = CreatePullzoneRequest.listFromJson(
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
    'origin_scheme',
    'origin_domain',
  };
}

/// The URI scheme of the origin domain.
class CreatePullzoneRequestOriginSchemeEnum {
  /// Instantiate a new enum with the provided [value].
  const CreatePullzoneRequestOriginSchemeEnum._(this.value);

  /// The underlying value of this enum member.
  final String value;

  @override
  String toString() => value;

  String toJson() => value;

  static const http = CreatePullzoneRequestOriginSchemeEnum._(r'http');
  static const https = CreatePullzoneRequestOriginSchemeEnum._(r'https');

  /// List of all possible values in this [enum][CreatePullzoneRequestOriginSchemeEnum].
  static const values = <CreatePullzoneRequestOriginSchemeEnum>[
    http,
    https,
  ];

  static CreatePullzoneRequestOriginSchemeEnum? fromJson(dynamic value) =>
      CreatePullzoneRequestOriginSchemeEnumTypeTransformer().decode(value);

  static List<CreatePullzoneRequestOriginSchemeEnum> listFromJson(
    dynamic json, {
    bool growable = false,
  }) {
    final result = <CreatePullzoneRequestOriginSchemeEnum>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = CreatePullzoneRequestOriginSchemeEnum.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }
}

/// Transformation class that can [encode] an instance of [CreatePullzoneRequestOriginSchemeEnum] to String,
/// and [decode] dynamic data back to [CreatePullzoneRequestOriginSchemeEnum].
class CreatePullzoneRequestOriginSchemeEnumTypeTransformer {
  factory CreatePullzoneRequestOriginSchemeEnumTypeTransformer() =>
      _instance ??=
          const CreatePullzoneRequestOriginSchemeEnumTypeTransformer._();

  const CreatePullzoneRequestOriginSchemeEnumTypeTransformer._();

  String encode(CreatePullzoneRequestOriginSchemeEnum data) => data.value;

  /// Decodes a [dynamic value][data] to a CreatePullzoneRequestOriginSchemeEnum.
  ///
  /// If [allowNull] is true and the [dynamic value][data] cannot be decoded successfully,
  /// then null is returned. However, if [allowNull] is false and the [dynamic value][data]
  /// cannot be decoded successfully, then an [UnimplementedError] is thrown.
  ///
  /// The [allowNull] is very handy when an API changes and a new enum value is added or removed,
  /// and users are still using an old app with the old code.
  CreatePullzoneRequestOriginSchemeEnum? decode(dynamic data,
      {bool allowNull = true}) {
    if (data != null) {
      switch (data) {
        case r'http':
          return CreatePullzoneRequestOriginSchemeEnum.http;
        case r'https':
          return CreatePullzoneRequestOriginSchemeEnum.https;
        default:
          if (!allowNull) {
            throw ArgumentError('Unknown enum value to decode: $data');
          }
      }
    }
    return null;
  }

  /// Singleton [CreatePullzoneRequestOriginSchemeEnumTypeTransformer] instance.
  static CreatePullzoneRequestOriginSchemeEnumTypeTransformer? _instance;
}
