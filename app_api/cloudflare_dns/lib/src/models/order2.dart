// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

@JsonEnum()
enum Order2 {
  @JsonValue('type')
  type,
  @JsonValue('name')
  name,
  @JsonValue('content')
  content,
  @JsonValue('ttl')
  ttl,
  @JsonValue('proxied')
  proxied;

  @override
  String toString() => switch (this) {
        Order2.type => 'type',
        Order2.name => 'name',
        Order2.content => 'content',
        Order2.ttl => 'ttl',
        Order2.proxied => 'proxied',
      };
}
