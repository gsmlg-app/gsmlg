// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

part 'account.g.dart';

@JsonSerializable()
class Account {
  const Account({
    this.id,
    this.name,
  });
  
  factory Account.fromJson(Map<String, Object?> json) => _$AccountFromJson(json);
  
  /// Account identifier.
  final String? id;

  /// Account name.
  final String? name;

  Map<String, Object?> toJson() => _$AccountToJson(this);
}
