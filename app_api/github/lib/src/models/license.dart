// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

part 'license.g.dart';

@JsonSerializable()
class License {
  const License({this.key, this.name, this.spdxId, this.url, this.nodeId});

  factory License.fromJson(Map<String, Object?> json) =>
      _$LicenseFromJson(json);

  final String? key;
  final String? name;
  @JsonKey(name: 'spdx_id')
  final String? spdxId;
  final String? url;
  @JsonKey(name: 'node_id')
  final String? nodeId;

  Map<String, Object?> toJson() => _$LicenseToJson(this);
}
