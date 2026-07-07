// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

part 'repository_content.g.dart';

/// A repository file content response.
@JsonSerializable()
class RepositoryContent {
  const RepositoryContent({
    required this.type,
    required this.name,
    required this.path,
    required this.sha,
    this.encoding,
    this.size,
    this.content,
    this.url,
    this.gitUrl,
    this.htmlUrl,
    this.downloadUrl,
  });

  factory RepositoryContent.fromJson(Map<String, Object?> json) =>
      _$RepositoryContentFromJson(json);

  /// Content type.
  final String type;

  /// Content encoding.
  final String? encoding;

  final int? size;

  final String name;

  final String path;

  /// Base64 encoded file contents.
  final String? content;

  final String sha;

  final String? url;

  @JsonKey(name: 'git_url')
  final String? gitUrl;

  @JsonKey(name: 'html_url')
  final String? htmlUrl;

  @JsonKey(name: 'download_url')
  final String? downloadUrl;

  Map<String, Object?> toJson() => _$RepositoryContentToJson(this);
}
