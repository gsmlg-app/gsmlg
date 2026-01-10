// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'record_type.dart';
import 'resource_record_set.dart';

part 'list_resource_record_sets_response.g.dart';

@JsonSerializable()
class ListResourceRecordSetsResponse {
  const ListResourceRecordSetsResponse({
    required this.resourceRecordSets,
    required this.isTruncated,
    required this.maxItems,
    this.nextRecordName,
    this.nextRecordType,
    this.nextRecordIdentifier,
  });
  
  factory ListResourceRecordSetsResponse.fromJson(Map<String, Object?> json) => _$ListResourceRecordSetsResponseFromJson(json);
  
  final List<ResourceRecordSet> resourceRecordSets;
  final bool isTruncated;
  final String? nextRecordName;
  final RecordType? nextRecordType;
  final String? nextRecordIdentifier;
  final int maxItems;

  Map<String, Object?> toJson() => _$ListResourceRecordSetsResponseToJson(this);
}
