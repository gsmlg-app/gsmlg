// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'commit_author.dart';

part 'commit.g.dart';

@JsonSerializable()
class Commit {
  const Commit({
    this.id,
    this.treeId,
    this.message,
    this.timestamp,
    this.author,
    this.committer,
  });
  
  factory Commit.fromJson(Map<String, Object?> json) => _$CommitFromJson(json);
  
  final String? id;
  @JsonKey(name: 'tree_id')
  final String? treeId;
  final String? message;
  final DateTime? timestamp;
  final CommitAuthor? author;
  final CommitAuthor? committer;

  Map<String, Object?> toJson() => _$CommitToJson(this);
}
