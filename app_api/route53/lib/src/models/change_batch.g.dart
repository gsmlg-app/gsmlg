// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'change_batch.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ChangeBatch _$ChangeBatchFromJson(Map<String, dynamic> json) => ChangeBatch(
      changes: (json['changes'] as List<dynamic>)
          .map((e) => Change.fromJson(e as Map<String, dynamic>))
          .toList(),
      comment: json['comment'] as String?,
    );

Map<String, dynamic> _$ChangeBatchToJson(ChangeBatch instance) =>
    <String, dynamic>{
      'comment': instance.comment,
      'changes': instance.changes,
    };
