// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'result2.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Result2 _$Result2FromJson(Map<String, dynamic> json) => Result2(
      recsAdded: (json['recs_added'] as num?)?.toInt(),
      recsAddedByType:
          (json['recs_added_by_type'] as Map<String, dynamic>?)?.map(
        (k, e) => MapEntry(k, (e as num).toInt()),
      ),
      totalRecordsParsed: (json['total_records_parsed'] as num?)?.toInt(),
    );

Map<String, dynamic> _$Result2ToJson(Result2 instance) => <String, dynamic>{
      'recs_added': instance.recsAdded,
      'recs_added_by_type': instance.recsAddedByType,
      'total_records_parsed': instance.totalRecordsParsed,
    };
