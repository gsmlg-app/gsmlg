// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

@JsonEnum()
enum Match {
  @JsonValue('any')
  any,
  @JsonValue('all')
  all;

  @override
  String toString() => switch (this) {
        Match.any => 'any',
        Match.all => 'all',
      };
}
