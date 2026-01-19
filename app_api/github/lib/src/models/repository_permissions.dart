// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

part 'repository_permissions.g.dart';

@JsonSerializable()
class RepositoryPermissions {
  const RepositoryPermissions({
    this.admin,
    this.maintain,
    this.push,
    this.triage,
    this.pull,
  });
  
  factory RepositoryPermissions.fromJson(Map<String, Object?> json) => _$RepositoryPermissionsFromJson(json);
  
  final bool? admin;
  final bool? maintain;
  final bool? push;
  final bool? triage;
  final bool? pull;

  Map<String, Object?> toJson() => _$RepositoryPermissionsToJson(this);
}
