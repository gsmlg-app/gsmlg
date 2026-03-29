// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'simple_user.dart';

part 'minimal_repository.g.dart';

@JsonSerializable()
class MinimalRepository {
  const MinimalRepository({
    this.id,
    this.nodeId,
    this.name,
    this.fullName,
    this.owner,
    this.private,
    this.htmlUrl,
    this.description,
    this.fork,
    this.url,
  });

  factory MinimalRepository.fromJson(Map<String, Object?> json) =>
      _$MinimalRepositoryFromJson(json);

  final int? id;
  @JsonKey(name: 'node_id')
  final String? nodeId;
  final String? name;
  @JsonKey(name: 'full_name')
  final String? fullName;
  final SimpleUser? owner;
  final bool? private;
  @JsonKey(name: 'html_url')
  final String? htmlUrl;
  final String? description;
  final bool? fork;
  final String? url;

  Map<String, Object?> toJson() => _$MinimalRepositoryToJson(this);
}
