// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'head.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Head _$HeadFromJson(Map<String, dynamic> json) => Head(
  ref: json['ref'] as String?,
  sha: json['sha'] as String?,
  repo: json['repo'] == null
      ? null
      : Repo.fromJson(json['repo'] as Map<String, dynamic>),
);

Map<String, dynamic> _$HeadToJson(Head instance) => <String, dynamic>{
  'ref': instance.ref,
  'sha': instance.sha,
  'repo': instance.repo,
};
