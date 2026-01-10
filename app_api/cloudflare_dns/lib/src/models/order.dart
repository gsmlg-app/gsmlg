// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

@JsonEnum()
enum Order {
  @JsonValue('name')
  name,
  @JsonValue('status')
  status,
  /// Incorrect name has been replaced. Original name: `account.id`.
  @JsonValue('account.id')
  undefined0,
  /// Incorrect name has been replaced. Original name: `account.name`.
  @JsonValue('account.name')
  undefined1;

  @override
  String toString() => switch (this) {
        Order.name => 'name',
        Order.status => 'status',
        Order.undefined0 => 'account.id',
        Order.undefined1 => 'account.name',
      };
}
