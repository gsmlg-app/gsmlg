//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of openapi.api;

class CreateLoadBalancerRequestSsl {
  /// Returns a new [CreateLoadBalancerRequestSsl] instance.
  CreateLoadBalancerRequestSsl({
    this.privateKey,
    this.certificate,
    this.chain,
    this.privateKeyB64,
    this.certificateB64,
    this.chainB64,
  });

  /// The private key.
  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  String? privateKey;

  /// The SSL certificate.
  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  String? certificate;

  /// The certificate chain.
  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  String? chain;

  /// The private key base64 encoded. (Base64 encoded values should not be used alongside with non-Base64 encoded values)
  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  String? privateKeyB64;

  /// The SSL certificate base64 encoded. (Base64 encoded values should not be used alongside with non-Base64 encoded values)
  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  String? certificateB64;

  /// The certificate chain base64 encoded. (Base64 encoded values should not be used alongside with non-Base64 encoded values)
  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  String? chainB64;

  @override
  bool operator ==(Object other) => identical(this, other) || other is CreateLoadBalancerRequestSsl &&
    other.privateKey == privateKey &&
    other.certificate == certificate &&
    other.chain == chain &&
    other.privateKeyB64 == privateKeyB64 &&
    other.certificateB64 == certificateB64 &&
    other.chainB64 == chainB64;

  @override
  int get hashCode =>
    // ignore: unnecessary_parenthesis
    (privateKey == null ? 0 : privateKey!.hashCode) +
    (certificate == null ? 0 : certificate!.hashCode) +
    (chain == null ? 0 : chain!.hashCode) +
    (privateKeyB64 == null ? 0 : privateKeyB64!.hashCode) +
    (certificateB64 == null ? 0 : certificateB64!.hashCode) +
    (chainB64 == null ? 0 : chainB64!.hashCode);

  @override
  String toString() => 'CreateLoadBalancerRequestSsl[privateKey=$privateKey, certificate=$certificate, chain=$chain, privateKeyB64=$privateKeyB64, certificateB64=$certificateB64, chainB64=$chainB64]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
    if (this.privateKey != null) {
      json[r'private_key'] = this.privateKey;
    } else {
      json[r'private_key'] = null;
    }
    if (this.certificate != null) {
      json[r'certificate'] = this.certificate;
    } else {
      json[r'certificate'] = null;
    }
    if (this.chain != null) {
      json[r'chain'] = this.chain;
    } else {
      json[r'chain'] = null;
    }
    if (this.privateKeyB64 != null) {
      json[r'private_key_b64'] = this.privateKeyB64;
    } else {
      json[r'private_key_b64'] = null;
    }
    if (this.certificateB64 != null) {
      json[r'certificate_b64'] = this.certificateB64;
    } else {
      json[r'certificate_b64'] = null;
    }
    if (this.chainB64 != null) {
      json[r'chain_b64'] = this.chainB64;
    } else {
      json[r'chain_b64'] = null;
    }
    return json;
  }

  /// Returns a new [CreateLoadBalancerRequestSsl] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static CreateLoadBalancerRequestSsl? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      assert(() {
        requiredKeys.forEach((key) {
          assert(json.containsKey(key), 'Required key "CreateLoadBalancerRequestSsl[$key]" is missing from JSON.');
          assert(json[key] != null, 'Required key "CreateLoadBalancerRequestSsl[$key]" has a null value in JSON.');
        });
        return true;
      }());

      return CreateLoadBalancerRequestSsl(
        privateKey: mapValueOfType<String>(json, r'private_key'),
        certificate: mapValueOfType<String>(json, r'certificate'),
        chain: mapValueOfType<String>(json, r'chain'),
        privateKeyB64: mapValueOfType<String>(json, r'private_key_b64'),
        certificateB64: mapValueOfType<String>(json, r'certificate_b64'),
        chainB64: mapValueOfType<String>(json, r'chain_b64'),
      );
    }
    return null;
  }

  static List<CreateLoadBalancerRequestSsl> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <CreateLoadBalancerRequestSsl>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = CreateLoadBalancerRequestSsl.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, CreateLoadBalancerRequestSsl> mapFromJson(dynamic json) {
    final map = <String, CreateLoadBalancerRequestSsl>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = CreateLoadBalancerRequestSsl.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of CreateLoadBalancerRequestSsl-objects as value to a dart map
  static Map<String, List<CreateLoadBalancerRequestSsl>> mapListFromJson(dynamic json, {bool growable = false,}) {
    final map = <String, List<CreateLoadBalancerRequestSsl>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = CreateLoadBalancerRequestSsl.listFromJson(entry.value, growable: growable,);
      }
    }
    return map;
  }

  /// The list of required keys that must be present in a JSON.
  static const requiredKeys = <String>{
  };
}

