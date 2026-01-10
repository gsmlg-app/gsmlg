// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'change_resource_record_sets_request.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ChangeResourceRecordSetsRequest _$ChangeResourceRecordSetsRequestFromJson(
        Map<String, dynamic> json) =>
    ChangeResourceRecordSetsRequest(
      changeBatch:
          ChangeBatch.fromJson(json['changeBatch'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$ChangeResourceRecordSetsRequestToJson(
        ChangeResourceRecordSetsRequest instance) =>
    <String, dynamic>{
      'changeBatch': instance.changeBatch,
    };
