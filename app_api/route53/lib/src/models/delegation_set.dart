// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

part 'delegation_set.g.dart';

@JsonSerializable()
class DelegationSet {
  const DelegationSet({
    this.id,
    this.callerReference,
    this.nameServers,
  });

  factory DelegationSet.fromJson(Map<String, Object?> json) =>
      _$DelegationSetFromJson(json);

  final String? id;
  final String? callerReference;
  final List<String>? nameServers;

  Map<String, Object?> toJson() => _$DelegationSetToJson(this);
}
