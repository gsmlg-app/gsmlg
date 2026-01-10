// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'account.dart';
import 'owner.dart';
import 'plan.dart';
import 'zone_status.dart';
import 'zone_type.dart';

part 'zone.g.dart';

@JsonSerializable()
class Zone {
  const Zone({
    required this.id,
    required this.name,
    this.status,
    this.paused,
    this.type,
    this.developmentMode,
    this.nameServers,
    this.originalNameServers,
    this.originalRegistrar,
    this.originalDnshost,
    this.modifiedOn,
    this.createdOn,
    this.activatedOn,
    this.meta,
    this.owner,
    this.account,
    this.permissions,
    this.plan,
  });
  
  factory Zone.fromJson(Map<String, Object?> json) => _$ZoneFromJson(json);

  /// Zone identifier.
  final String id;

  /// The domain name.
  final String name;

  @JsonKey(unknownEnumValue: JsonKey.nullForUndefinedEnumValue)
  final ZoneStatus? status;

  /// Indicates if the zone is only using Cloudflare DNS services.
  final bool? paused;

  /// A full zone implies that DNS is hosted with Cloudflare. A partial zone is typically a partner-hosted zone or a CNAME setup.
  @JsonKey(unknownEnumValue: JsonKey.nullForUndefinedEnumValue)
  final ZoneType? type;

  /// The interval (in seconds) from when development mode expires.
  @JsonKey(name: 'development_mode')
  final int? developmentMode;

  /// Cloudflare-assigned name servers.
  @JsonKey(name: 'name_servers')
  final List<String>? nameServers;

  /// Original name servers before moving to Cloudflare.
  @JsonKey(name: 'original_name_servers')
  final List<String>? originalNameServers;

  /// Registrar for the domain at the time of switching to Cloudflare.
  @JsonKey(name: 'original_registrar')
  final String? originalRegistrar;

  /// DNS host at the time of switching to Cloudflare.
  @JsonKey(name: 'original_dnshost')
  final String? originalDnshost;

  /// Last modification time.
  @JsonKey(name: 'modified_on')
  final DateTime? modifiedOn;

  /// When the zone was created.
  @JsonKey(name: 'created_on')
  final DateTime? createdOn;

  /// When the zone was activated.
  @JsonKey(name: 'activated_on')
  final DateTime? activatedOn;
  final dynamic meta;
  final Owner? owner;
  final Account? account;
  final List<String>? permissions;
  final Plan? plan;

  Map<String, Object?> toJson() => _$ZoneToJson(this);
}
