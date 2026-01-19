// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

part 'repo.g.dart';

@JsonSerializable()
class Repo {
  const Repo({
    this.id,
    this.url,
    this.name,
  });
  
  factory Repo.fromJson(Map<String, Object?> json) => _$RepoFromJson(json);
  
  final int? id;
  final String? url;
  final String? name;

  Map<String, Object?> toJson() => _$RepoToJson(this);
}
