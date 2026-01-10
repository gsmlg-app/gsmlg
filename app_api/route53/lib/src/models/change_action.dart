// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

@JsonEnum()
enum ChangeAction {
  @JsonValue('CREATE')
  create,
  @JsonValue('DELETE')
  delete,
  @JsonValue('UPSERT')
  upsert;

  @override
  String toString() => switch (this) {
        ChangeAction.create => 'CREATE',
        ChangeAction.delete => 'DELETE',
        ChangeAction.upsert => 'UPSERT',
      };
}
