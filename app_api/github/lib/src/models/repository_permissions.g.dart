// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'repository_permissions.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

RepositoryPermissions _$RepositoryPermissionsFromJson(
  Map<String, dynamic> json,
) => RepositoryPermissions(
  admin: json['admin'] as bool?,
  maintain: json['maintain'] as bool?,
  push: json['push'] as bool?,
  triage: json['triage'] as bool?,
  pull: json['pull'] as bool?,
);

Map<String, dynamic> _$RepositoryPermissionsToJson(
  RepositoryPermissions instance,
) => <String, dynamic>{
  'admin': instance.admin,
  'maintain': instance.maintain,
  'push': instance.push,
  'triage': instance.triage,
  'pull': instance.pull,
};
