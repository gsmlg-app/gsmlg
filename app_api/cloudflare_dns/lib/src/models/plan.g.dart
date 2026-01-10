// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'plan.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Plan _$PlanFromJson(Map<String, dynamic> json) => Plan(
      id: json['id'] as String?,
      name: json['name'] as String?,
      price: json['price'] as num?,
      currency: json['currency'] as String?,
      frequency: json['frequency'] as String?,
      isSubscribed: json['is_subscribed'] as bool?,
      canSubscribe: json['can_subscribe'] as bool?,
      legacyId: json['legacy_id'] as String?,
      legacyDiscount: json['legacy_discount'] as bool?,
      externallyManaged: json['externally_managed'] as bool?,
    );

Map<String, dynamic> _$PlanToJson(Plan instance) => <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'price': instance.price,
      'currency': instance.currency,
      'frequency': instance.frequency,
      'is_subscribed': instance.isSubscribed,
      'can_subscribe': instance.canSubscribe,
      'legacy_id': instance.legacyId,
      'legacy_discount': instance.legacyDiscount,
      'externally_managed': instance.externallyManaged,
    };
