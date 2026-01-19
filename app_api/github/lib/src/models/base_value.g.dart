// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'base_value.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

BaseValue _$BaseValueFromJson(Map<String, dynamic> json) => BaseValue(
  ref: json['ref'] as String?,
  sha: json['sha'] as String?,
  repo: json['repo'] == null
      ? null
      : Repo2.fromJson(json['repo'] as Map<String, dynamic>),
);

Map<String, dynamic> _$BaseValueToJson(BaseValue instance) => <String, dynamic>{
  'ref': instance.ref,
  'sha': instance.sha,
  'repo': instance.repo,
};
