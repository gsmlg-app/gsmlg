// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'commit.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Commit _$CommitFromJson(Map<String, dynamic> json) => Commit(
  id: json['id'] as String?,
  treeId: json['tree_id'] as String?,
  message: json['message'] as String?,
  timestamp: json['timestamp'] == null
      ? null
      : DateTime.parse(json['timestamp'] as String),
  author: json['author'] == null
      ? null
      : CommitAuthor.fromJson(json['author'] as Map<String, dynamic>),
  committer: json['committer'] == null
      ? null
      : CommitAuthor.fromJson(json['committer'] as Map<String, dynamic>),
);

Map<String, dynamic> _$CommitToJson(Commit instance) => <String, dynamic>{
  'id': instance.id,
  'tree_id': instance.treeId,
  'message': instance.message,
  'timestamp': instance.timestamp?.toIso8601String(),
  'author': instance.author,
  'committer': instance.committer,
};
