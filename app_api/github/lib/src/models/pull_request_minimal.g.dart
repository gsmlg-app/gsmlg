// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'pull_request_minimal.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PullRequestMinimal _$PullRequestMinimalFromJson(Map<String, dynamic> json) =>
    PullRequestMinimal(
      id: (json['id'] as num?)?.toInt(),
      number: (json['number'] as num?)?.toInt(),
      url: json['url'] as String?,
      head: json['head'] == null
          ? null
          : Head.fromJson(json['head'] as Map<String, dynamic>),
      baseValue: json['base'] == null
          ? null
          : BaseValue.fromJson(json['base'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$PullRequestMinimalToJson(PullRequestMinimal instance) =>
    <String, dynamic>{
      'id': instance.id,
      'number': instance.number,
      'url': instance.url,
      'head': instance.head,
      'base': instance.baseValue,
    };
