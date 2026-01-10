import 'dart:convert';

import 'package:equatable/equatable.dart';

/// Credentials for AWS Route 53.
class Route53Credentials extends Equatable {
  final String accessKeyId;
  final String secretAccessKey;
  final String region;

  const Route53Credentials({
    required this.accessKeyId,
    required this.secretAccessKey,
    this.region = 'us-east-1',
  });

  factory Route53Credentials.fromJson(Map<String, dynamic> json) {
    return Route53Credentials(
      accessKeyId: json['accessKeyId'] as String,
      secretAccessKey: json['secretAccessKey'] as String,
      region: json['region'] as String? ?? 'us-east-1',
    );
  }

  Map<String, dynamic> toJson() => {
        'accessKeyId': accessKeyId,
        'secretAccessKey': secretAccessKey,
        'region': region,
      };

  String encode() => jsonEncode(toJson());

  static Route53Credentials decode(String encoded) {
    return Route53Credentials.fromJson(
      jsonDecode(encoded) as Map<String, dynamic>,
    );
  }

  @override
  List<Object?> get props => [accessKeyId, secretAccessKey, region];
}

/// Credentials for Cloudflare DNS.
class CloudflareCredentials extends Equatable {
  final String apiToken;

  const CloudflareCredentials({
    required this.apiToken,
  });

  factory CloudflareCredentials.fromJson(Map<String, dynamic> json) {
    return CloudflareCredentials(
      apiToken: json['apiToken'] as String,
    );
  }

  Map<String, dynamic> toJson() => {
        'apiToken': apiToken,
      };

  String encode() => jsonEncode(toJson());

  static CloudflareCredentials decode(String encoded) {
    return CloudflareCredentials.fromJson(
      jsonDecode(encoded) as Map<String, dynamic>,
    );
  }

  @override
  List<Object?> get props => [apiToken];
}
