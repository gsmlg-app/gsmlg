//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of openapi.api;

class Pullzone {
  /// Returns a new [Pullzone] instance.
  Pullzone({
    this.id,
    this.dateCreated,
    this.status,
    this.label,
    this.originScheme,
    this.originDomain,
    this.cdnUrl,
    this.vanityDomain,
    this.cacheSize,
    this.requests,
    this.inBytes,
    this.outBytes,
    this.packetsPerSec,
    this.lastPurge,
    this.cors,
    this.gzip,
    this.blockAi,
    this.blockBadBots,
    this.regions = const [],
  });

  /// A unique ID for the CDN Pull Zone.
  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  String? id;

  /// The date this CDN Pull Zone was created.
  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  String? dateCreated;

  /// The current status.  * active * pending
  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  String? status;

  /// The user-supplied label.
  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  String? label;

  /// The URI scheme of the origin domain.
  PullzoneOriginSchemeEnum? originScheme;

  /// The domain name from which the content stored in the CDN will be pulled.
  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  String? originDomain;

  /// The Vultr CDN endpoint to access your cached files.
  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  String? cdnUrl;

  /// A custom domain provided by the user which can be used to access the cached files.
  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  String? vanityDomain;

  /// How much data may be cached on each CDN node.
  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  num? cacheSize;

  /// The amount of requests to limit to the CDN.
  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  num? requests;

  /// The amount of inbound bytes allowed to the CDN.
  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  num? inBytes;

  /// The amount of outbound bytes allowed from the CDN.
  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  num? outBytes;

  /// Per CDN rate limiting per requests/sec.
  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  num? packetsPerSec;

  /// The last date and time that the cached content on server proxies was cleared
  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  String? lastPurge;

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

  /// A list of [Region ids](#operation/list-regions) for locations to be used for content delivery.
  List<String> regions;

  @override
  bool operator ==(Object other) => identical(this, other) || other is Pullzone &&
    other.id == id &&
    other.dateCreated == dateCreated &&
    other.status == status &&
    other.label == label &&
    other.originScheme == originScheme &&
    other.originDomain == originDomain &&
    other.cdnUrl == cdnUrl &&
    other.vanityDomain == vanityDomain &&
    other.cacheSize == cacheSize &&
    other.requests == requests &&
    other.inBytes == inBytes &&
    other.outBytes == outBytes &&
    other.packetsPerSec == packetsPerSec &&
    other.lastPurge == lastPurge &&
    other.cors == cors &&
    other.gzip == gzip &&
    other.blockAi == blockAi &&
    other.blockBadBots == blockBadBots &&
    _deepEquality.equals(other.regions, regions);

  @override
  int get hashCode =>
    // ignore: unnecessary_parenthesis
    (id == null ? 0 : id!.hashCode) +
    (dateCreated == null ? 0 : dateCreated!.hashCode) +
    (status == null ? 0 : status!.hashCode) +
    (label == null ? 0 : label!.hashCode) +
    (originScheme == null ? 0 : originScheme!.hashCode) +
    (originDomain == null ? 0 : originDomain!.hashCode) +
    (cdnUrl == null ? 0 : cdnUrl!.hashCode) +
    (vanityDomain == null ? 0 : vanityDomain!.hashCode) +
    (cacheSize == null ? 0 : cacheSize!.hashCode) +
    (requests == null ? 0 : requests!.hashCode) +
    (inBytes == null ? 0 : inBytes!.hashCode) +
    (outBytes == null ? 0 : outBytes!.hashCode) +
    (packetsPerSec == null ? 0 : packetsPerSec!.hashCode) +
    (lastPurge == null ? 0 : lastPurge!.hashCode) +
    (cors == null ? 0 : cors!.hashCode) +
    (gzip == null ? 0 : gzip!.hashCode) +
    (blockAi == null ? 0 : blockAi!.hashCode) +
    (blockBadBots == null ? 0 : blockBadBots!.hashCode) +
    (regions.hashCode);

  @override
  String toString() => 'Pullzone[id=$id, dateCreated=$dateCreated, status=$status, label=$label, originScheme=$originScheme, originDomain=$originDomain, cdnUrl=$cdnUrl, vanityDomain=$vanityDomain, cacheSize=$cacheSize, requests=$requests, inBytes=$inBytes, outBytes=$outBytes, packetsPerSec=$packetsPerSec, lastPurge=$lastPurge, cors=$cors, gzip=$gzip, blockAi=$blockAi, blockBadBots=$blockBadBots, regions=$regions]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
    if (this.id != null) {
      json[r'id'] = this.id;
    } else {
      json[r'id'] = null;
    }
    if (this.dateCreated != null) {
      json[r'date_created'] = this.dateCreated;
    } else {
      json[r'date_created'] = null;
    }
    if (this.status != null) {
      json[r'status'] = this.status;
    } else {
      json[r'status'] = null;
    }
    if (this.label != null) {
      json[r'label'] = this.label;
    } else {
      json[r'label'] = null;
    }
    if (this.originScheme != null) {
      json[r'origin_scheme'] = this.originScheme;
    } else {
      json[r'origin_scheme'] = null;
    }
    if (this.originDomain != null) {
      json[r'origin_domain'] = this.originDomain;
    } else {
      json[r'origin_domain'] = null;
    }
    if (this.cdnUrl != null) {
      json[r'cdn_url'] = this.cdnUrl;
    } else {
      json[r'cdn_url'] = null;
    }
    if (this.vanityDomain != null) {
      json[r'vanity_domain'] = this.vanityDomain;
    } else {
      json[r'vanity_domain'] = null;
    }
    if (this.cacheSize != null) {
      json[r'cache_size'] = this.cacheSize;
    } else {
      json[r'cache_size'] = null;
    }
    if (this.requests != null) {
      json[r'requests'] = this.requests;
    } else {
      json[r'requests'] = null;
    }
    if (this.inBytes != null) {
      json[r'in_bytes'] = this.inBytes;
    } else {
      json[r'in_bytes'] = null;
    }
    if (this.outBytes != null) {
      json[r'out_bytes'] = this.outBytes;
    } else {
      json[r'out_bytes'] = null;
    }
    if (this.packetsPerSec != null) {
      json[r'packets_per_sec'] = this.packetsPerSec;
    } else {
      json[r'packets_per_sec'] = null;
    }
    if (this.lastPurge != null) {
      json[r'last_purge'] = this.lastPurge;
    } else {
      json[r'last_purge'] = null;
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

  /// Returns a new [Pullzone] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static Pullzone? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      assert(() {
        requiredKeys.forEach((key) {
          assert(json.containsKey(key), 'Required key "Pullzone[$key]" is missing from JSON.');
          assert(json[key] != null, 'Required key "Pullzone[$key]" has a null value in JSON.');
        });
        return true;
      }());

      return Pullzone(
        id: mapValueOfType<String>(json, r'id'),
        dateCreated: mapValueOfType<String>(json, r'date_created'),
        status: mapValueOfType<String>(json, r'status'),
        label: mapValueOfType<String>(json, r'label'),
        originScheme: PullzoneOriginSchemeEnum.fromJson(json[r'origin_scheme']),
        originDomain: mapValueOfType<String>(json, r'origin_domain'),
        cdnUrl: mapValueOfType<String>(json, r'cdn_url'),
        vanityDomain: mapValueOfType<String>(json, r'vanity_domain'),
        cacheSize: num.parse('${json[r'cache_size']}'),
        requests: num.parse('${json[r'requests']}'),
        inBytes: num.parse('${json[r'in_bytes']}'),
        outBytes: num.parse('${json[r'out_bytes']}'),
        packetsPerSec: num.parse('${json[r'packets_per_sec']}'),
        lastPurge: mapValueOfType<String>(json, r'last_purge'),
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

  static List<Pullzone> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <Pullzone>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = Pullzone.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, Pullzone> mapFromJson(dynamic json) {
    final map = <String, Pullzone>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = Pullzone.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of Pullzone-objects as value to a dart map
  static Map<String, List<Pullzone>> mapListFromJson(dynamic json, {bool growable = false,}) {
    final map = <String, List<Pullzone>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = Pullzone.listFromJson(entry.value, growable: growable,);
      }
    }
    return map;
  }

  /// The list of required keys that must be present in a JSON.
  static const requiredKeys = <String>{
  };
}

/// The URI scheme of the origin domain.
class PullzoneOriginSchemeEnum {
  /// Instantiate a new enum with the provided [value].
  const PullzoneOriginSchemeEnum._(this.value);

  /// The underlying value of this enum member.
  final String value;

  @override
  String toString() => value;

  String toJson() => value;

  static const http = PullzoneOriginSchemeEnum._(r'http');
  static const https = PullzoneOriginSchemeEnum._(r'https');

  /// List of all possible values in this [enum][PullzoneOriginSchemeEnum].
  static const values = <PullzoneOriginSchemeEnum>[
    http,
    https,
  ];

  static PullzoneOriginSchemeEnum? fromJson(dynamic value) => PullzoneOriginSchemeEnumTypeTransformer().decode(value);

  static List<PullzoneOriginSchemeEnum> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <PullzoneOriginSchemeEnum>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = PullzoneOriginSchemeEnum.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }
}

/// Transformation class that can [encode] an instance of [PullzoneOriginSchemeEnum] to String,
/// and [decode] dynamic data back to [PullzoneOriginSchemeEnum].
class PullzoneOriginSchemeEnumTypeTransformer {
  factory PullzoneOriginSchemeEnumTypeTransformer() => _instance ??= const PullzoneOriginSchemeEnumTypeTransformer._();

  const PullzoneOriginSchemeEnumTypeTransformer._();

  String encode(PullzoneOriginSchemeEnum data) => data.value;

  /// Decodes a [dynamic value][data] to a PullzoneOriginSchemeEnum.
  ///
  /// If [allowNull] is true and the [dynamic value][data] cannot be decoded successfully,
  /// then null is returned. However, if [allowNull] is false and the [dynamic value][data]
  /// cannot be decoded successfully, then an [UnimplementedError] is thrown.
  ///
  /// The [allowNull] is very handy when an API changes and a new enum value is added or removed,
  /// and users are still using an old app with the old code.
  PullzoneOriginSchemeEnum? decode(dynamic data, {bool allowNull = true}) {
    if (data != null) {
      switch (data) {
        case r'http': return PullzoneOriginSchemeEnum.http;
        case r'https': return PullzoneOriginSchemeEnum.https;
        default:
          if (!allowNull) {
            throw ArgumentError('Unknown enum value to decode: $data');
          }
      }
    }
    return null;
  }

  /// Singleton [PullzoneOriginSchemeEnumTypeTransformer] instance.
  static PullzoneOriginSchemeEnumTypeTransformer? _instance;
}


