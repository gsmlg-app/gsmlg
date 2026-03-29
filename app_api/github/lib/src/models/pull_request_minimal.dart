// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'base_value.dart';
import 'head.dart';

part 'pull_request_minimal.g.dart';

@JsonSerializable()
class PullRequestMinimal {
  const PullRequestMinimal({
    this.id,
    this.number,
    this.url,
    this.head,
    this.baseValue,
  });

  factory PullRequestMinimal.fromJson(Map<String, Object?> json) =>
      _$PullRequestMinimalFromJson(json);

  final int? id;
  final int? number;
  final String? url;
  final Head? head;

  /// The name has been replaced because it contains a keyword. Original name: `base`.
  @JsonKey(name: 'base')
  final BaseValue? baseValue;

  Map<String, Object?> toJson() => _$PullRequestMinimalToJson(this);
}
