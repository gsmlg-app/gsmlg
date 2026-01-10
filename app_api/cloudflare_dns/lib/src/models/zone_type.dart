// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

/// A full zone implies that DNS is hosted with Cloudflare. A partial zone is typically a partner-hosted zone or a CNAME setup.
@JsonEnum()
enum ZoneType {
  @JsonValue('full')
  full,
  @JsonValue('partial')
  partial,
  @JsonValue('secondary')
  secondary;
}
