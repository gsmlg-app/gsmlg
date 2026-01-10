// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'result_info.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ResultInfo _$ResultInfoFromJson(Map<String, dynamic> json) => ResultInfo(
      page: (json['page'] as num?)?.toInt(),
      perPage: (json['per_page'] as num?)?.toInt(),
      count: (json['count'] as num?)?.toInt(),
      totalCount: (json['total_count'] as num?)?.toInt(),
      totalPages: (json['total_pages'] as num?)?.toInt(),
    );

Map<String, dynamic> _$ResultInfoToJson(ResultInfo instance) =>
    <String, dynamic>{
      'page': instance.page,
      'per_page': instance.perPage,
      'count': instance.count,
      'total_count': instance.totalCount,
      'total_pages': instance.totalPages,
    };
