// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

@JsonEnum()
enum RecordType {
  @JsonValue('A')
  a,
  @JsonValue('AAAA')
  aaaa,
  @JsonValue('CAA')
  caa,
  @JsonValue('CNAME')
  cname,
  @JsonValue('DS')
  ds,
  @JsonValue('MX')
  mx,
  @JsonValue('NAPTR')
  naptr,
  @JsonValue('NS')
  ns,
  @JsonValue('PTR')
  ptr,
  @JsonValue('SOA')
  soa,
  @JsonValue('SPF')
  spf,
  @JsonValue('SRV')
  srv,
  @JsonValue('TXT')
  txt;

  @override
  String toString() => switch (this) {
        RecordType.a => 'A',
        RecordType.aaaa => 'AAAA',
        RecordType.caa => 'CAA',
        RecordType.cname => 'CNAME',
        RecordType.ds => 'DS',
        RecordType.mx => 'MX',
        RecordType.naptr => 'NAPTR',
        RecordType.ns => 'NS',
        RecordType.ptr => 'PTR',
        RecordType.soa => 'SOA',
        RecordType.spf => 'SPF',
        RecordType.srv => 'SRV',
        RecordType.txt => 'TXT',
      };
}
