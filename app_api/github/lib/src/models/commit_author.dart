// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

part 'commit_author.g.dart';

@JsonSerializable()
class CommitAuthor {
  const CommitAuthor({
    this.name,
    this.email,
  });
  
  factory CommitAuthor.fromJson(Map<String, Object?> json) => _$CommitAuthorFromJson(json);
  
  final String? name;
  final String? email;

  Map<String, Object?> toJson() => _$CommitAuthorToJson(this);
}
