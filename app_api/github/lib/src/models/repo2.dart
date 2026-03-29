// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

part 'repo2.g.dart';

@JsonSerializable()
class Repo2 {
  const Repo2({this.id, this.url, this.name});

  factory Repo2.fromJson(Map<String, Object?> json) => _$Repo2FromJson(json);

  final int? id;
  final String? url;
  final String? name;

  Map<String, Object?> toJson() => _$Repo2ToJson(this);
}
