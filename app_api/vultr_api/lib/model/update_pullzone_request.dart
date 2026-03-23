//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of openapi.api;

class UpdatePullzoneRequest {
  /// Returns a new [UpdatePullzoneRequest] instance.
  UpdatePullzoneRequest({
    this.label,
    this.vanityDomain,
    this.sslCert,
    this.sslCertKey,
    this.cors,
    this.gzip,
    this.blockAi,
    this.blockBadBots,
    this.regions = const [],
  });

  /// The user-supplied label.
  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  String? label;

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

  /// Cross-origin resource sharing.
  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  bool? cors;

  /// Optional feature to compress files, reduce the amount of data that's transferred.
  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  bool? gzip;

  /// Optional feature to block AI bots.
  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  bool? blockAi;

  /// Optional feature to block potentially malicious bots.
  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  bool? blockBadBots;

  /// a list of [Region ids](#operation/list-regions) for locations to be used for content delivery.
  List<String> regions;

  @override
  bool operator ==(Object other) => identical(this, other) || other is UpdatePullzoneRequest &&
    other.label == label &&
    other.vanityDomain == vanityDomain &&
    other.sslCert == sslCert &&
    other.sslCertKey == sslCertKey &&
    other.cors == cors &&
    other.gzip == gzip &&
    other.blockAi == blockAi &&
    other.blockBadBots == blockBadBots &&
    _deepEquality.equals(other.regions, regions);

  @override
  int get hashCode =>
    // ignore: unnecessary_parenthesis
    (label == null ? 0 : label!.hashCode) +
    (vanityDomain == null ? 0 : vanityDomain!.hashCode) +
    (sslCert == null ? 0 : sslCert!.hashCode) +
    (sslCertKey == null ? 0 : sslCertKey!.hashCode) +
    (cors == null ? 0 : cors!.hashCode) +
    (gzip == null ? 0 : gzip!.hashCode) +
    (blockAi == null ? 0 : blockAi!.hashCode) +
    (blockBadBots == null ? 0 : blockBadBots!.hashCode) +
    (regions.hashCode);

  @override
  String toString() => 'UpdatePullzoneRequest[label=$label, vanityDomain=$vanityDomain, sslCert=$sslCert, sslCertKey=$sslCertKey, cors=$cors, gzip=$gzip, blockAi=$blockAi, blockBadBots=$blockBadBots, regions=$regions]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
    if (this.label != null) {
      json[r'label'] = this.label;
    } else {
      json[r'label'] = null;
    }
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
      json[r'regions'] = this.regions;
    return json;
  }

  /// Returns a new [UpdatePullzoneRequest] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static UpdatePullzoneRequest? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      assert(() {
        requiredKeys.forEach((key) {
          assert(json.containsKey(key), 'Required key "UpdatePullzoneRequest[$key]" is missing from JSON.');
          assert(json[key] != null, 'Required key "UpdatePullzoneRequest[$key]" has a null value in JSON.');
        });
        return true;
      }());

      return UpdatePullzoneRequest(
        label: mapValueOfType<String>(json, r'label'),
        vanityDomain: mapValueOfType<String>(json, r'vanity_domain'),
        sslCert: mapValueOfType<String>(json, r'ssl_cert'),
        sslCertKey: mapValueOfType<String>(json, r'ssl_cert_key'),
        cors: mapValueOfType<bool>(json, r'cors'),
        gzip: mapValueOfType<bool>(json, r'gzip'),
        blockAi: mapValueOfType<bool>(json, r'block_ai'),
        blockBadBots: mapValueOfType<bool>(json, r'block_bad_bots'),
        regions: json[r'regions'] is Iterable
            ? (json[r'regions'] as Iterable).cast<String>().toList(growable: false)
            : const [],
      );
    }
    return null;
  }

  static List<UpdatePullzoneRequest> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <UpdatePullzoneRequest>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = UpdatePullzoneRequest.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, UpdatePullzoneRequest> mapFromJson(dynamic json) {
    final map = <String, UpdatePullzoneRequest>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = UpdatePullzoneRequest.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of UpdatePullzoneRequest-objects as value to a dart map
  static Map<String, List<UpdatePullzoneRequest>> mapListFromJson(dynamic json, {bool growable = false,}) {
    final map = <String, List<UpdatePullzoneRequest>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = UpdatePullzoneRequest.listFromJson(entry.value, growable: growable,);
      }
    }
    return map;
  }

  /// The list of required keys that must be present in a JSON.
  static const requiredKeys = <String>{
  };
}

