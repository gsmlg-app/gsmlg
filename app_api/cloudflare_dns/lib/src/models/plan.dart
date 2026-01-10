// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

part 'plan.g.dart';

@JsonSerializable()
class Plan {
  const Plan({
    this.id,
    this.name,
    this.price,
    this.currency,
    this.frequency,
    this.isSubscribed,
    this.canSubscribe,
    this.legacyId,
    this.legacyDiscount,
    this.externallyManaged,
  });
  
  factory Plan.fromJson(Map<String, Object?> json) => _$PlanFromJson(json);
  
  final String? id;
  final String? name;
  final num? price;
  final String? currency;
  final String? frequency;
  @JsonKey(name: 'is_subscribed')
  final bool? isSubscribed;
  @JsonKey(name: 'can_subscribe')
  final bool? canSubscribe;
  @JsonKey(name: 'legacy_id')
  final String? legacyId;
  @JsonKey(name: 'legacy_discount')
  final bool? legacyDiscount;
  @JsonKey(name: 'externally_managed')
  final bool? externallyManaged;

  Map<String, Object?> toJson() => _$PlanToJson(this);
}
