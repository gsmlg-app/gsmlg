// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'repo.dart';

part 'head.g.dart';

@JsonSerializable()
class Head {
  const Head({this.ref, this.sha, this.repo});

  factory Head.fromJson(Map<String, Object?> json) => _$HeadFromJson(json);

  final String? ref;
  final String? sha;
  final Repo? repo;

  Map<String, Object?> toJson() => _$HeadToJson(this);
}
