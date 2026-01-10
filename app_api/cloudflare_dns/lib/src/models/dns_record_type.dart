// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

@JsonEnum()
enum DnsRecordType {
  @JsonValue('A')
  a,
  @JsonValue('AAAA')
  aaaa,
  @JsonValue('CAA')
  caa,
  @JsonValue('CERT')
  cert,
  @JsonValue('CNAME')
  cname,
  @JsonValue('DNSKEY')
  dnskey,
  @JsonValue('DS')
  ds,
  @JsonValue('HTTPS')
  https,
  @JsonValue('LOC')
  loc,
  @JsonValue('MX')
  mx,
  @JsonValue('NAPTR')
  naptr,
  @JsonValue('NS')
  ns,
  @JsonValue('PTR')
  ptr,
  @JsonValue('SMIMEA')
  smimea,
  @JsonValue('SRV')
  srv,
  @JsonValue('SSHFP')
  sshfp,
  @JsonValue('SVCB')
  svcb,
  @JsonValue('TLSA')
  tlsa,
  @JsonValue('TXT')
  txt,
  @JsonValue('URI')
  uri;

  @override
  String toString() => switch (this) {
        DnsRecordType.a => 'A',
        DnsRecordType.aaaa => 'AAAA',
        DnsRecordType.caa => 'CAA',
        DnsRecordType.cert => 'CERT',
        DnsRecordType.cname => 'CNAME',
        DnsRecordType.dnskey => 'DNSKEY',
        DnsRecordType.ds => 'DS',
        DnsRecordType.https => 'HTTPS',
        DnsRecordType.loc => 'LOC',
        DnsRecordType.mx => 'MX',
        DnsRecordType.naptr => 'NAPTR',
        DnsRecordType.ns => 'NS',
        DnsRecordType.ptr => 'PTR',
        DnsRecordType.smimea => 'SMIMEA',
        DnsRecordType.srv => 'SRV',
        DnsRecordType.sshfp => 'SSHFP',
        DnsRecordType.svcb => 'SVCB',
        DnsRecordType.tlsa => 'TLSA',
        DnsRecordType.txt => 'TXT',
        DnsRecordType.uri => 'URI',
      };
}
