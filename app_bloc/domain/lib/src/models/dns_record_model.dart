import 'package:equatable/equatable.dart';

/// Unified DNS record model for both Route53 and Cloudflare.
class DnsRecordModel extends Equatable {
  final String? id;
  final String name;
  final String type;
  final String content;
  final int ttl;
  final bool? proxied; // Cloudflare only
  final String? comment;

  const DnsRecordModel({
    this.id,
    required this.name,
    required this.type,
    required this.content,
    this.ttl = 300,
    this.proxied,
    this.comment,
  });

  DnsRecordModel copyWith({
    String? id,
    String? name,
    String? type,
    String? content,
    int? ttl,
    bool? proxied,
    String? comment,
  }) {
    return DnsRecordModel(
      id: id ?? this.id,
      name: name ?? this.name,
      type: type ?? this.type,
      content: content ?? this.content,
      ttl: ttl ?? this.ttl,
      proxied: proxied ?? this.proxied,
      comment: comment ?? this.comment,
    );
  }

  @override
  List<Object?> get props => [id, name, type, content, ttl, proxied, comment];
}

/// Supported DNS record types.
class DnsRecordTypes {
  static const List<String> common = [
    'A',
    'AAAA',
    'CNAME',
    'MX',
    'TXT',
    'NS',
    'SRV',
    'CAA',
    'PTR',
  ];

  static const List<String> route53 = [
    'A',
    'AAAA',
    'CAA',
    'CNAME',
    'DS',
    'MX',
    'NAPTR',
    'NS',
    'PTR',
    'SOA',
    'SPF',
    'SRV',
    'TXT',
  ];

  static const List<String> cloudflare = [
    'A',
    'AAAA',
    'CAA',
    'CERT',
    'CNAME',
    'DNSKEY',
    'DS',
    'HTTPS',
    'LOC',
    'MX',
    'NAPTR',
    'NS',
    'PTR',
    'SMIMEA',
    'SRV',
    'SSHFP',
    'SVCB',
    'TLSA',
    'TXT',
    'URI',
  ];
}
