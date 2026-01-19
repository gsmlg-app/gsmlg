// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'repo2.dart';

part 'base_value.g.dart';

@JsonSerializable()
class BaseValue {
  const BaseValue({
    this.ref,
    this.sha,
    this.repo,
  });
  
  factory BaseValue.fromJson(Map<String, Object?> json) => _$BaseValueFromJson(json);
  
  final String? ref;
  final String? sha;
  final Repo2? repo;

  Map<String, Object?> toJson() => _$BaseValueToJson(this);
}
