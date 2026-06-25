// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'database.dart';

// ignore_for_file: type=lint
class $WhoisHistoryTableTable extends WhoisHistoryTable
    with TableInfo<$WhoisHistoryTableTable, WhoisHistoryTableData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $WhoisHistoryTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _queryMeta = const VerificationMeta('query');
  @override
  late final GeneratedColumn<String> query = GeneratedColumn<String>(
      'query', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  @override
  late final GeneratedColumnWithTypeConverter<List<String>?, String> result =
      GeneratedColumn<String>('result', aliasedName, true,
              type: DriftSqlType.string, requiredDuringInsert: false)
          .withConverter<List<String>?>(
              $WhoisHistoryTableTable.$converterresultn);
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  @override
  List<GeneratedColumn> get $columns => [id, query, result, createdAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'whois_history_table';
  @override
  VerificationContext validateIntegrity(
      Insertable<WhoisHistoryTableData> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('query')) {
      context.handle(
          _queryMeta, query.isAcceptableOrUnknown(data['query']!, _queryMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  WhoisHistoryTableData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return WhoisHistoryTableData(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      query: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}query']),
      result: $WhoisHistoryTableTable.$converterresultn.fromSql(attachedDatabase
          .typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}result'])),
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
    );
  }

  @override
  $WhoisHistoryTableTable createAlias(String alias) {
    return $WhoisHistoryTableTable(attachedDatabase, alias);
  }

  static TypeConverter<List<String>, String> $converterresult =
      const StringListConverter();
  static TypeConverter<List<String>?, String?> $converterresultn =
      NullAwareTypeConverter.wrap($converterresult);
}

class WhoisHistoryTableData extends DataClass
    implements Insertable<WhoisHistoryTableData> {
  /// Auto-incrementing primary key.
  final int id;

  /// The WHOIS query string (domain name, IP address, etc.).
  final String? query;

  /// The WHOIS lookup result as a list of strings (JSON encoded in DB).
  final List<String>? result;

  /// Timestamp when the record was created.
  final DateTime createdAt;
  const WhoisHistoryTableData(
      {required this.id, this.query, this.result, required this.createdAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    if (!nullToAbsent || query != null) {
      map['query'] = Variable<String>(query);
    }
    if (!nullToAbsent || result != null) {
      map['result'] = Variable<String>(
          $WhoisHistoryTableTable.$converterresultn.toSql(result));
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  WhoisHistoryTableCompanion toCompanion(bool nullToAbsent) {
    return WhoisHistoryTableCompanion(
      id: Value(id),
      query:
          query == null && nullToAbsent ? const Value.absent() : Value(query),
      result:
          result == null && nullToAbsent ? const Value.absent() : Value(result),
      createdAt: Value(createdAt),
    );
  }

  factory WhoisHistoryTableData.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return WhoisHistoryTableData(
      id: serializer.fromJson<int>(json['id']),
      query: serializer.fromJson<String?>(json['query']),
      result: serializer.fromJson<List<String>?>(json['result']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'query': serializer.toJson<String?>(query),
      'result': serializer.toJson<List<String>?>(result),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  WhoisHistoryTableData copyWith(
          {int? id,
          Value<String?> query = const Value.absent(),
          Value<List<String>?> result = const Value.absent(),
          DateTime? createdAt}) =>
      WhoisHistoryTableData(
        id: id ?? this.id,
        query: query.present ? query.value : this.query,
        result: result.present ? result.value : this.result,
        createdAt: createdAt ?? this.createdAt,
      );
  WhoisHistoryTableData copyWithCompanion(WhoisHistoryTableCompanion data) {
    return WhoisHistoryTableData(
      id: data.id.present ? data.id.value : this.id,
      query: data.query.present ? data.query.value : this.query,
      result: data.result.present ? data.result.value : this.result,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('WhoisHistoryTableData(')
          ..write('id: $id, ')
          ..write('query: $query, ')
          ..write('result: $result, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, query, result, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is WhoisHistoryTableData &&
          other.id == this.id &&
          other.query == this.query &&
          other.result == this.result &&
          other.createdAt == this.createdAt);
}

class WhoisHistoryTableCompanion
    extends UpdateCompanion<WhoisHistoryTableData> {
  final Value<int> id;
  final Value<String?> query;
  final Value<List<String>?> result;
  final Value<DateTime> createdAt;
  const WhoisHistoryTableCompanion({
    this.id = const Value.absent(),
    this.query = const Value.absent(),
    this.result = const Value.absent(),
    this.createdAt = const Value.absent(),
  });
  WhoisHistoryTableCompanion.insert({
    this.id = const Value.absent(),
    this.query = const Value.absent(),
    this.result = const Value.absent(),
    this.createdAt = const Value.absent(),
  });
  static Insertable<WhoisHistoryTableData> custom({
    Expression<int>? id,
    Expression<String>? query,
    Expression<String>? result,
    Expression<DateTime>? createdAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (query != null) 'query': query,
      if (result != null) 'result': result,
      if (createdAt != null) 'created_at': createdAt,
    });
  }

  WhoisHistoryTableCompanion copyWith(
      {Value<int>? id,
      Value<String?>? query,
      Value<List<String>?>? result,
      Value<DateTime>? createdAt}) {
    return WhoisHistoryTableCompanion(
      id: id ?? this.id,
      query: query ?? this.query,
      result: result ?? this.result,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (query.present) {
      map['query'] = Variable<String>(query.value);
    }
    if (result.present) {
      map['result'] = Variable<String>(
          $WhoisHistoryTableTable.$converterresultn.toSql(result.value));
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('WhoisHistoryTableCompanion(')
          ..write('id: $id, ')
          ..write('query: $query, ')
          ..write('result: $result, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }
}

class $DnsZoneTableTable extends DnsZoneTable
    with TableInfo<$DnsZoneTableTable, DnsZoneTableData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $DnsZoneTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  @override
  late final GeneratedColumnWithTypeConverter<DnsProvider, String> provider =
      GeneratedColumn<String>('provider', aliasedName, false,
              type: DriftSqlType.string, requiredDuringInsert: true)
          .withConverter<DnsProvider>($DnsZoneTableTable.$converterprovider);
  static const VerificationMeta _zoneIdMeta = const VerificationMeta('zoneId');
  @override
  late final GeneratedColumn<String> zoneId = GeneratedColumn<String>(
      'zone_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _zoneNameMeta =
      const VerificationMeta('zoneName');
  @override
  late final GeneratedColumn<String> zoneName = GeneratedColumn<String>(
      'zone_name', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _serviceAccountIdMeta =
      const VerificationMeta('serviceAccountId');
  @override
  late final GeneratedColumn<int> serviceAccountId = GeneratedColumn<int>(
      'service_account_id', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _commentMeta =
      const VerificationMeta('comment');
  @override
  late final GeneratedColumn<String> comment = GeneratedColumn<String>(
      'comment', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  static const VerificationMeta _updatedAtMeta =
      const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
      'updated_at', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        provider,
        zoneId,
        zoneName,
        serviceAccountId,
        comment,
        createdAt,
        updatedAt
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'dns_zone_table';
  @override
  VerificationContext validateIntegrity(Insertable<DnsZoneTableData> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('zone_id')) {
      context.handle(_zoneIdMeta,
          zoneId.isAcceptableOrUnknown(data['zone_id']!, _zoneIdMeta));
    } else if (isInserting) {
      context.missing(_zoneIdMeta);
    }
    if (data.containsKey('zone_name')) {
      context.handle(_zoneNameMeta,
          zoneName.isAcceptableOrUnknown(data['zone_name']!, _zoneNameMeta));
    } else if (isInserting) {
      context.missing(_zoneNameMeta);
    }
    if (data.containsKey('service_account_id')) {
      context.handle(
          _serviceAccountIdMeta,
          serviceAccountId.isAcceptableOrUnknown(
              data['service_account_id']!, _serviceAccountIdMeta));
    } else if (isInserting) {
      context.missing(_serviceAccountIdMeta);
    }
    if (data.containsKey('comment')) {
      context.handle(_commentMeta,
          comment.isAcceptableOrUnknown(data['comment']!, _commentMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    }
    if (data.containsKey('updated_at')) {
      context.handle(_updatedAtMeta,
          updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  DnsZoneTableData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return DnsZoneTableData(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      provider: $DnsZoneTableTable.$converterprovider.fromSql(attachedDatabase
          .typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}provider'])!),
      zoneId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}zone_id'])!,
      zoneName: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}zone_name'])!,
      serviceAccountId: attachedDatabase.typeMapping.read(
          DriftSqlType.int, data['${effectivePrefix}service_account_id'])!,
      comment: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}comment']),
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}updated_at'])!,
    );
  }

  @override
  $DnsZoneTableTable createAlias(String alias) {
    return $DnsZoneTableTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<DnsProvider, String, String> $converterprovider =
      const EnumNameConverter<DnsProvider>(DnsProvider.values);
}

class DnsZoneTableData extends DataClass
    implements Insertable<DnsZoneTableData> {
  /// Auto-incrementing primary key.
  final int id;

  /// DNS provider type (route53 or cloudflare).
  final DnsProvider provider;

  /// Zone ID from the provider.
  final String zoneId;

  /// Zone name (domain name).
  final String zoneName;

  /// Reference to the service account that holds API credentials.
  final int serviceAccountId;

  /// Optional comment/description.
  final String? comment;

  /// Timestamp when the record was created.
  final DateTime createdAt;

  /// Timestamp when the record was last updated.
  final DateTime updatedAt;
  const DnsZoneTableData(
      {required this.id,
      required this.provider,
      required this.zoneId,
      required this.zoneName,
      required this.serviceAccountId,
      this.comment,
      required this.createdAt,
      required this.updatedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    {
      map['provider'] = Variable<String>(
          $DnsZoneTableTable.$converterprovider.toSql(provider));
    }
    map['zone_id'] = Variable<String>(zoneId);
    map['zone_name'] = Variable<String>(zoneName);
    map['service_account_id'] = Variable<int>(serviceAccountId);
    if (!nullToAbsent || comment != null) {
      map['comment'] = Variable<String>(comment);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  DnsZoneTableCompanion toCompanion(bool nullToAbsent) {
    return DnsZoneTableCompanion(
      id: Value(id),
      provider: Value(provider),
      zoneId: Value(zoneId),
      zoneName: Value(zoneName),
      serviceAccountId: Value(serviceAccountId),
      comment: comment == null && nullToAbsent
          ? const Value.absent()
          : Value(comment),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory DnsZoneTableData.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return DnsZoneTableData(
      id: serializer.fromJson<int>(json['id']),
      provider: $DnsZoneTableTable.$converterprovider
          .fromJson(serializer.fromJson<String>(json['provider'])),
      zoneId: serializer.fromJson<String>(json['zoneId']),
      zoneName: serializer.fromJson<String>(json['zoneName']),
      serviceAccountId: serializer.fromJson<int>(json['serviceAccountId']),
      comment: serializer.fromJson<String?>(json['comment']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'provider': serializer.toJson<String>(
          $DnsZoneTableTable.$converterprovider.toJson(provider)),
      'zoneId': serializer.toJson<String>(zoneId),
      'zoneName': serializer.toJson<String>(zoneName),
      'serviceAccountId': serializer.toJson<int>(serviceAccountId),
      'comment': serializer.toJson<String?>(comment),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  DnsZoneTableData copyWith(
          {int? id,
          DnsProvider? provider,
          String? zoneId,
          String? zoneName,
          int? serviceAccountId,
          Value<String?> comment = const Value.absent(),
          DateTime? createdAt,
          DateTime? updatedAt}) =>
      DnsZoneTableData(
        id: id ?? this.id,
        provider: provider ?? this.provider,
        zoneId: zoneId ?? this.zoneId,
        zoneName: zoneName ?? this.zoneName,
        serviceAccountId: serviceAccountId ?? this.serviceAccountId,
        comment: comment.present ? comment.value : this.comment,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
      );
  DnsZoneTableData copyWithCompanion(DnsZoneTableCompanion data) {
    return DnsZoneTableData(
      id: data.id.present ? data.id.value : this.id,
      provider: data.provider.present ? data.provider.value : this.provider,
      zoneId: data.zoneId.present ? data.zoneId.value : this.zoneId,
      zoneName: data.zoneName.present ? data.zoneName.value : this.zoneName,
      serviceAccountId: data.serviceAccountId.present
          ? data.serviceAccountId.value
          : this.serviceAccountId,
      comment: data.comment.present ? data.comment.value : this.comment,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('DnsZoneTableData(')
          ..write('id: $id, ')
          ..write('provider: $provider, ')
          ..write('zoneId: $zoneId, ')
          ..write('zoneName: $zoneName, ')
          ..write('serviceAccountId: $serviceAccountId, ')
          ..write('comment: $comment, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, provider, zoneId, zoneName,
      serviceAccountId, comment, createdAt, updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is DnsZoneTableData &&
          other.id == this.id &&
          other.provider == this.provider &&
          other.zoneId == this.zoneId &&
          other.zoneName == this.zoneName &&
          other.serviceAccountId == this.serviceAccountId &&
          other.comment == this.comment &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class DnsZoneTableCompanion extends UpdateCompanion<DnsZoneTableData> {
  final Value<int> id;
  final Value<DnsProvider> provider;
  final Value<String> zoneId;
  final Value<String> zoneName;
  final Value<int> serviceAccountId;
  final Value<String?> comment;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  const DnsZoneTableCompanion({
    this.id = const Value.absent(),
    this.provider = const Value.absent(),
    this.zoneId = const Value.absent(),
    this.zoneName = const Value.absent(),
    this.serviceAccountId = const Value.absent(),
    this.comment = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
  });
  DnsZoneTableCompanion.insert({
    this.id = const Value.absent(),
    required DnsProvider provider,
    required String zoneId,
    required String zoneName,
    required int serviceAccountId,
    this.comment = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
  })  : provider = Value(provider),
        zoneId = Value(zoneId),
        zoneName = Value(zoneName),
        serviceAccountId = Value(serviceAccountId);
  static Insertable<DnsZoneTableData> custom({
    Expression<int>? id,
    Expression<String>? provider,
    Expression<String>? zoneId,
    Expression<String>? zoneName,
    Expression<int>? serviceAccountId,
    Expression<String>? comment,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (provider != null) 'provider': provider,
      if (zoneId != null) 'zone_id': zoneId,
      if (zoneName != null) 'zone_name': zoneName,
      if (serviceAccountId != null) 'service_account_id': serviceAccountId,
      if (comment != null) 'comment': comment,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
    });
  }

  DnsZoneTableCompanion copyWith(
      {Value<int>? id,
      Value<DnsProvider>? provider,
      Value<String>? zoneId,
      Value<String>? zoneName,
      Value<int>? serviceAccountId,
      Value<String?>? comment,
      Value<DateTime>? createdAt,
      Value<DateTime>? updatedAt}) {
    return DnsZoneTableCompanion(
      id: id ?? this.id,
      provider: provider ?? this.provider,
      zoneId: zoneId ?? this.zoneId,
      zoneName: zoneName ?? this.zoneName,
      serviceAccountId: serviceAccountId ?? this.serviceAccountId,
      comment: comment ?? this.comment,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (provider.present) {
      map['provider'] = Variable<String>(
          $DnsZoneTableTable.$converterprovider.toSql(provider.value));
    }
    if (zoneId.present) {
      map['zone_id'] = Variable<String>(zoneId.value);
    }
    if (zoneName.present) {
      map['zone_name'] = Variable<String>(zoneName.value);
    }
    if (serviceAccountId.present) {
      map['service_account_id'] = Variable<int>(serviceAccountId.value);
    }
    if (comment.present) {
      map['comment'] = Variable<String>(comment.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('DnsZoneTableCompanion(')
          ..write('id: $id, ')
          ..write('provider: $provider, ')
          ..write('zoneId: $zoneId, ')
          ..write('zoneName: $zoneName, ')
          ..write('serviceAccountId: $serviceAccountId, ')
          ..write('comment: $comment, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }
}

class $GitHubRepoTableTable extends GitHubRepoTable
    with TableInfo<$GitHubRepoTableTable, GitHubRepoTableData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $GitHubRepoTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _repoIdMeta = const VerificationMeta('repoId');
  @override
  late final GeneratedColumn<int> repoId = GeneratedColumn<int>(
      'repo_id', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _fullNameMeta =
      const VerificationMeta('fullName');
  @override
  late final GeneratedColumn<String> fullName = GeneratedColumn<String>(
      'full_name', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
      'name', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _ownerLoginMeta =
      const VerificationMeta('ownerLogin');
  @override
  late final GeneratedColumn<String> ownerLogin = GeneratedColumn<String>(
      'owner_login', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _ownerAvatarUrlMeta =
      const VerificationMeta('ownerAvatarUrl');
  @override
  late final GeneratedColumn<String> ownerAvatarUrl = GeneratedColumn<String>(
      'owner_avatar_url', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _descriptionMeta =
      const VerificationMeta('description');
  @override
  late final GeneratedColumn<String> description = GeneratedColumn<String>(
      'description', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _isPrivateMeta =
      const VerificationMeta('isPrivate');
  @override
  late final GeneratedColumn<bool> isPrivate = GeneratedColumn<bool>(
      'is_private', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("is_private" IN (0, 1))'),
      defaultValue: const Constant(false));
  static const VerificationMeta _defaultBranchMeta =
      const VerificationMeta('defaultBranch');
  @override
  late final GeneratedColumn<String> defaultBranch = GeneratedColumn<String>(
      'default_branch', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('main'));
  static const VerificationMeta _stargazersCountMeta =
      const VerificationMeta('stargazersCount');
  @override
  late final GeneratedColumn<int> stargazersCount = GeneratedColumn<int>(
      'stargazers_count', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  static const VerificationMeta _updatedAtMeta =
      const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
      'updated_at', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        repoId,
        fullName,
        name,
        ownerLogin,
        ownerAvatarUrl,
        description,
        isPrivate,
        defaultBranch,
        stargazersCount,
        createdAt,
        updatedAt
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'git_hub_repo_table';
  @override
  VerificationContext validateIntegrity(
      Insertable<GitHubRepoTableData> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('repo_id')) {
      context.handle(_repoIdMeta,
          repoId.isAcceptableOrUnknown(data['repo_id']!, _repoIdMeta));
    } else if (isInserting) {
      context.missing(_repoIdMeta);
    }
    if (data.containsKey('full_name')) {
      context.handle(_fullNameMeta,
          fullName.isAcceptableOrUnknown(data['full_name']!, _fullNameMeta));
    } else if (isInserting) {
      context.missing(_fullNameMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
          _nameMeta, name.isAcceptableOrUnknown(data['name']!, _nameMeta));
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('owner_login')) {
      context.handle(
          _ownerLoginMeta,
          ownerLogin.isAcceptableOrUnknown(
              data['owner_login']!, _ownerLoginMeta));
    } else if (isInserting) {
      context.missing(_ownerLoginMeta);
    }
    if (data.containsKey('owner_avatar_url')) {
      context.handle(
          _ownerAvatarUrlMeta,
          ownerAvatarUrl.isAcceptableOrUnknown(
              data['owner_avatar_url']!, _ownerAvatarUrlMeta));
    }
    if (data.containsKey('description')) {
      context.handle(
          _descriptionMeta,
          description.isAcceptableOrUnknown(
              data['description']!, _descriptionMeta));
    }
    if (data.containsKey('is_private')) {
      context.handle(_isPrivateMeta,
          isPrivate.isAcceptableOrUnknown(data['is_private']!, _isPrivateMeta));
    }
    if (data.containsKey('default_branch')) {
      context.handle(
          _defaultBranchMeta,
          defaultBranch.isAcceptableOrUnknown(
              data['default_branch']!, _defaultBranchMeta));
    }
    if (data.containsKey('stargazers_count')) {
      context.handle(
          _stargazersCountMeta,
          stargazersCount.isAcceptableOrUnknown(
              data['stargazers_count']!, _stargazersCountMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    }
    if (data.containsKey('updated_at')) {
      context.handle(_updatedAtMeta,
          updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  List<Set<GeneratedColumn>> get uniqueKeys => [
        {repoId},
      ];
  @override
  GitHubRepoTableData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return GitHubRepoTableData(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      repoId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}repo_id'])!,
      fullName: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}full_name'])!,
      name: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}name'])!,
      ownerLogin: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}owner_login'])!,
      ownerAvatarUrl: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}owner_avatar_url']),
      description: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}description']),
      isPrivate: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_private'])!,
      defaultBranch: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}default_branch'])!,
      stargazersCount: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}stargazers_count'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}updated_at'])!,
    );
  }

  @override
  $GitHubRepoTableTable createAlias(String alias) {
    return $GitHubRepoTableTable(attachedDatabase, alias);
  }
}

class GitHubRepoTableData extends DataClass
    implements Insertable<GitHubRepoTableData> {
  /// Auto-incrementing primary key.
  final int id;

  /// Repository ID from GitHub.
  final int repoId;

  /// Repository full name (owner/repo).
  final String fullName;

  /// Repository name.
  final String name;

  /// Owner login name.
  final String ownerLogin;

  /// Owner avatar URL.
  final String? ownerAvatarUrl;

  /// Repository description.
  final String? description;

  /// Whether the repository is private.
  final bool isPrivate;

  /// Default branch name.
  final String defaultBranch;

  /// Star count (cached).
  final int stargazersCount;

  /// Timestamp when the record was created.
  final DateTime createdAt;

  /// Timestamp when the record was last updated.
  final DateTime updatedAt;
  const GitHubRepoTableData(
      {required this.id,
      required this.repoId,
      required this.fullName,
      required this.name,
      required this.ownerLogin,
      this.ownerAvatarUrl,
      this.description,
      required this.isPrivate,
      required this.defaultBranch,
      required this.stargazersCount,
      required this.createdAt,
      required this.updatedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['repo_id'] = Variable<int>(repoId);
    map['full_name'] = Variable<String>(fullName);
    map['name'] = Variable<String>(name);
    map['owner_login'] = Variable<String>(ownerLogin);
    if (!nullToAbsent || ownerAvatarUrl != null) {
      map['owner_avatar_url'] = Variable<String>(ownerAvatarUrl);
    }
    if (!nullToAbsent || description != null) {
      map['description'] = Variable<String>(description);
    }
    map['is_private'] = Variable<bool>(isPrivate);
    map['default_branch'] = Variable<String>(defaultBranch);
    map['stargazers_count'] = Variable<int>(stargazersCount);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  GitHubRepoTableCompanion toCompanion(bool nullToAbsent) {
    return GitHubRepoTableCompanion(
      id: Value(id),
      repoId: Value(repoId),
      fullName: Value(fullName),
      name: Value(name),
      ownerLogin: Value(ownerLogin),
      ownerAvatarUrl: ownerAvatarUrl == null && nullToAbsent
          ? const Value.absent()
          : Value(ownerAvatarUrl),
      description: description == null && nullToAbsent
          ? const Value.absent()
          : Value(description),
      isPrivate: Value(isPrivate),
      defaultBranch: Value(defaultBranch),
      stargazersCount: Value(stargazersCount),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory GitHubRepoTableData.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return GitHubRepoTableData(
      id: serializer.fromJson<int>(json['id']),
      repoId: serializer.fromJson<int>(json['repoId']),
      fullName: serializer.fromJson<String>(json['fullName']),
      name: serializer.fromJson<String>(json['name']),
      ownerLogin: serializer.fromJson<String>(json['ownerLogin']),
      ownerAvatarUrl: serializer.fromJson<String?>(json['ownerAvatarUrl']),
      description: serializer.fromJson<String?>(json['description']),
      isPrivate: serializer.fromJson<bool>(json['isPrivate']),
      defaultBranch: serializer.fromJson<String>(json['defaultBranch']),
      stargazersCount: serializer.fromJson<int>(json['stargazersCount']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'repoId': serializer.toJson<int>(repoId),
      'fullName': serializer.toJson<String>(fullName),
      'name': serializer.toJson<String>(name),
      'ownerLogin': serializer.toJson<String>(ownerLogin),
      'ownerAvatarUrl': serializer.toJson<String?>(ownerAvatarUrl),
      'description': serializer.toJson<String?>(description),
      'isPrivate': serializer.toJson<bool>(isPrivate),
      'defaultBranch': serializer.toJson<String>(defaultBranch),
      'stargazersCount': serializer.toJson<int>(stargazersCount),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  GitHubRepoTableData copyWith(
          {int? id,
          int? repoId,
          String? fullName,
          String? name,
          String? ownerLogin,
          Value<String?> ownerAvatarUrl = const Value.absent(),
          Value<String?> description = const Value.absent(),
          bool? isPrivate,
          String? defaultBranch,
          int? stargazersCount,
          DateTime? createdAt,
          DateTime? updatedAt}) =>
      GitHubRepoTableData(
        id: id ?? this.id,
        repoId: repoId ?? this.repoId,
        fullName: fullName ?? this.fullName,
        name: name ?? this.name,
        ownerLogin: ownerLogin ?? this.ownerLogin,
        ownerAvatarUrl:
            ownerAvatarUrl.present ? ownerAvatarUrl.value : this.ownerAvatarUrl,
        description: description.present ? description.value : this.description,
        isPrivate: isPrivate ?? this.isPrivate,
        defaultBranch: defaultBranch ?? this.defaultBranch,
        stargazersCount: stargazersCount ?? this.stargazersCount,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
      );
  GitHubRepoTableData copyWithCompanion(GitHubRepoTableCompanion data) {
    return GitHubRepoTableData(
      id: data.id.present ? data.id.value : this.id,
      repoId: data.repoId.present ? data.repoId.value : this.repoId,
      fullName: data.fullName.present ? data.fullName.value : this.fullName,
      name: data.name.present ? data.name.value : this.name,
      ownerLogin:
          data.ownerLogin.present ? data.ownerLogin.value : this.ownerLogin,
      ownerAvatarUrl: data.ownerAvatarUrl.present
          ? data.ownerAvatarUrl.value
          : this.ownerAvatarUrl,
      description:
          data.description.present ? data.description.value : this.description,
      isPrivate: data.isPrivate.present ? data.isPrivate.value : this.isPrivate,
      defaultBranch: data.defaultBranch.present
          ? data.defaultBranch.value
          : this.defaultBranch,
      stargazersCount: data.stargazersCount.present
          ? data.stargazersCount.value
          : this.stargazersCount,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('GitHubRepoTableData(')
          ..write('id: $id, ')
          ..write('repoId: $repoId, ')
          ..write('fullName: $fullName, ')
          ..write('name: $name, ')
          ..write('ownerLogin: $ownerLogin, ')
          ..write('ownerAvatarUrl: $ownerAvatarUrl, ')
          ..write('description: $description, ')
          ..write('isPrivate: $isPrivate, ')
          ..write('defaultBranch: $defaultBranch, ')
          ..write('stargazersCount: $stargazersCount, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id,
      repoId,
      fullName,
      name,
      ownerLogin,
      ownerAvatarUrl,
      description,
      isPrivate,
      defaultBranch,
      stargazersCount,
      createdAt,
      updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is GitHubRepoTableData &&
          other.id == this.id &&
          other.repoId == this.repoId &&
          other.fullName == this.fullName &&
          other.name == this.name &&
          other.ownerLogin == this.ownerLogin &&
          other.ownerAvatarUrl == this.ownerAvatarUrl &&
          other.description == this.description &&
          other.isPrivate == this.isPrivate &&
          other.defaultBranch == this.defaultBranch &&
          other.stargazersCount == this.stargazersCount &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class GitHubRepoTableCompanion extends UpdateCompanion<GitHubRepoTableData> {
  final Value<int> id;
  final Value<int> repoId;
  final Value<String> fullName;
  final Value<String> name;
  final Value<String> ownerLogin;
  final Value<String?> ownerAvatarUrl;
  final Value<String?> description;
  final Value<bool> isPrivate;
  final Value<String> defaultBranch;
  final Value<int> stargazersCount;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  const GitHubRepoTableCompanion({
    this.id = const Value.absent(),
    this.repoId = const Value.absent(),
    this.fullName = const Value.absent(),
    this.name = const Value.absent(),
    this.ownerLogin = const Value.absent(),
    this.ownerAvatarUrl = const Value.absent(),
    this.description = const Value.absent(),
    this.isPrivate = const Value.absent(),
    this.defaultBranch = const Value.absent(),
    this.stargazersCount = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
  });
  GitHubRepoTableCompanion.insert({
    this.id = const Value.absent(),
    required int repoId,
    required String fullName,
    required String name,
    required String ownerLogin,
    this.ownerAvatarUrl = const Value.absent(),
    this.description = const Value.absent(),
    this.isPrivate = const Value.absent(),
    this.defaultBranch = const Value.absent(),
    this.stargazersCount = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
  })  : repoId = Value(repoId),
        fullName = Value(fullName),
        name = Value(name),
        ownerLogin = Value(ownerLogin);
  static Insertable<GitHubRepoTableData> custom({
    Expression<int>? id,
    Expression<int>? repoId,
    Expression<String>? fullName,
    Expression<String>? name,
    Expression<String>? ownerLogin,
    Expression<String>? ownerAvatarUrl,
    Expression<String>? description,
    Expression<bool>? isPrivate,
    Expression<String>? defaultBranch,
    Expression<int>? stargazersCount,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (repoId != null) 'repo_id': repoId,
      if (fullName != null) 'full_name': fullName,
      if (name != null) 'name': name,
      if (ownerLogin != null) 'owner_login': ownerLogin,
      if (ownerAvatarUrl != null) 'owner_avatar_url': ownerAvatarUrl,
      if (description != null) 'description': description,
      if (isPrivate != null) 'is_private': isPrivate,
      if (defaultBranch != null) 'default_branch': defaultBranch,
      if (stargazersCount != null) 'stargazers_count': stargazersCount,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
    });
  }

  GitHubRepoTableCompanion copyWith(
      {Value<int>? id,
      Value<int>? repoId,
      Value<String>? fullName,
      Value<String>? name,
      Value<String>? ownerLogin,
      Value<String?>? ownerAvatarUrl,
      Value<String?>? description,
      Value<bool>? isPrivate,
      Value<String>? defaultBranch,
      Value<int>? stargazersCount,
      Value<DateTime>? createdAt,
      Value<DateTime>? updatedAt}) {
    return GitHubRepoTableCompanion(
      id: id ?? this.id,
      repoId: repoId ?? this.repoId,
      fullName: fullName ?? this.fullName,
      name: name ?? this.name,
      ownerLogin: ownerLogin ?? this.ownerLogin,
      ownerAvatarUrl: ownerAvatarUrl ?? this.ownerAvatarUrl,
      description: description ?? this.description,
      isPrivate: isPrivate ?? this.isPrivate,
      defaultBranch: defaultBranch ?? this.defaultBranch,
      stargazersCount: stargazersCount ?? this.stargazersCount,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (repoId.present) {
      map['repo_id'] = Variable<int>(repoId.value);
    }
    if (fullName.present) {
      map['full_name'] = Variable<String>(fullName.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (ownerLogin.present) {
      map['owner_login'] = Variable<String>(ownerLogin.value);
    }
    if (ownerAvatarUrl.present) {
      map['owner_avatar_url'] = Variable<String>(ownerAvatarUrl.value);
    }
    if (description.present) {
      map['description'] = Variable<String>(description.value);
    }
    if (isPrivate.present) {
      map['is_private'] = Variable<bool>(isPrivate.value);
    }
    if (defaultBranch.present) {
      map['default_branch'] = Variable<String>(defaultBranch.value);
    }
    if (stargazersCount.present) {
      map['stargazers_count'] = Variable<int>(stargazersCount.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('GitHubRepoTableCompanion(')
          ..write('id: $id, ')
          ..write('repoId: $repoId, ')
          ..write('fullName: $fullName, ')
          ..write('name: $name, ')
          ..write('ownerLogin: $ownerLogin, ')
          ..write('ownerAvatarUrl: $ownerAvatarUrl, ')
          ..write('description: $description, ')
          ..write('isPrivate: $isPrivate, ')
          ..write('defaultBranch: $defaultBranch, ')
          ..write('stargazersCount: $stargazersCount, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }
}

class $ChatConversationTableTable extends ChatConversationTable
    with TableInfo<$ChatConversationTableTable, ChatConversationTableData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ChatConversationTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
      'title', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _systemPromptMeta =
      const VerificationMeta('systemPrompt');
  @override
  late final GeneratedColumn<String> systemPrompt = GeneratedColumn<String>(
      'system_prompt', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  static const VerificationMeta _updatedAtMeta =
      const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
      'updated_at', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  @override
  List<GeneratedColumn> get $columns =>
      [id, title, systemPrompt, createdAt, updatedAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'chat_conversation_table';
  @override
  VerificationContext validateIntegrity(
      Insertable<ChatConversationTableData> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('title')) {
      context.handle(
          _titleMeta, title.isAcceptableOrUnknown(data['title']!, _titleMeta));
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('system_prompt')) {
      context.handle(
          _systemPromptMeta,
          systemPrompt.isAcceptableOrUnknown(
              data['system_prompt']!, _systemPromptMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    }
    if (data.containsKey('updated_at')) {
      context.handle(_updatedAtMeta,
          updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ChatConversationTableData map(Map<String, dynamic> data,
      {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ChatConversationTableData(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      title: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}title'])!,
      systemPrompt: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}system_prompt']),
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}updated_at'])!,
    );
  }

  @override
  $ChatConversationTableTable createAlias(String alias) {
    return $ChatConversationTableTable(attachedDatabase, alias);
  }
}

class ChatConversationTableData extends DataClass
    implements Insertable<ChatConversationTableData> {
  /// Primary key (UUID string).
  final String id;

  /// Display title of the conversation.
  final String title;

  /// Optional system prompt for this conversation.
  final String? systemPrompt;

  /// Timestamp when the conversation was created.
  final DateTime createdAt;

  /// Timestamp when the conversation was last updated.
  final DateTime updatedAt;
  const ChatConversationTableData(
      {required this.id,
      required this.title,
      this.systemPrompt,
      required this.createdAt,
      required this.updatedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['title'] = Variable<String>(title);
    if (!nullToAbsent || systemPrompt != null) {
      map['system_prompt'] = Variable<String>(systemPrompt);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  ChatConversationTableCompanion toCompanion(bool nullToAbsent) {
    return ChatConversationTableCompanion(
      id: Value(id),
      title: Value(title),
      systemPrompt: systemPrompt == null && nullToAbsent
          ? const Value.absent()
          : Value(systemPrompt),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory ChatConversationTableData.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ChatConversationTableData(
      id: serializer.fromJson<String>(json['id']),
      title: serializer.fromJson<String>(json['title']),
      systemPrompt: serializer.fromJson<String?>(json['systemPrompt']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'title': serializer.toJson<String>(title),
      'systemPrompt': serializer.toJson<String?>(systemPrompt),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  ChatConversationTableData copyWith(
          {String? id,
          String? title,
          Value<String?> systemPrompt = const Value.absent(),
          DateTime? createdAt,
          DateTime? updatedAt}) =>
      ChatConversationTableData(
        id: id ?? this.id,
        title: title ?? this.title,
        systemPrompt:
            systemPrompt.present ? systemPrompt.value : this.systemPrompt,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
      );
  ChatConversationTableData copyWithCompanion(
      ChatConversationTableCompanion data) {
    return ChatConversationTableData(
      id: data.id.present ? data.id.value : this.id,
      title: data.title.present ? data.title.value : this.title,
      systemPrompt: data.systemPrompt.present
          ? data.systemPrompt.value
          : this.systemPrompt,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ChatConversationTableData(')
          ..write('id: $id, ')
          ..write('title: $title, ')
          ..write('systemPrompt: $systemPrompt, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, title, systemPrompt, createdAt, updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ChatConversationTableData &&
          other.id == this.id &&
          other.title == this.title &&
          other.systemPrompt == this.systemPrompt &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class ChatConversationTableCompanion
    extends UpdateCompanion<ChatConversationTableData> {
  final Value<String> id;
  final Value<String> title;
  final Value<String?> systemPrompt;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const ChatConversationTableCompanion({
    this.id = const Value.absent(),
    this.title = const Value.absent(),
    this.systemPrompt = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ChatConversationTableCompanion.insert({
    required String id,
    required String title,
    this.systemPrompt = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        title = Value(title);
  static Insertable<ChatConversationTableData> custom({
    Expression<String>? id,
    Expression<String>? title,
    Expression<String>? systemPrompt,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (title != null) 'title': title,
      if (systemPrompt != null) 'system_prompt': systemPrompt,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ChatConversationTableCompanion copyWith(
      {Value<String>? id,
      Value<String>? title,
      Value<String?>? systemPrompt,
      Value<DateTime>? createdAt,
      Value<DateTime>? updatedAt,
      Value<int>? rowid}) {
    return ChatConversationTableCompanion(
      id: id ?? this.id,
      title: title ?? this.title,
      systemPrompt: systemPrompt ?? this.systemPrompt,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (systemPrompt.present) {
      map['system_prompt'] = Variable<String>(systemPrompt.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ChatConversationTableCompanion(')
          ..write('id: $id, ')
          ..write('title: $title, ')
          ..write('systemPrompt: $systemPrompt, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ChatMessageTableTable extends ChatMessageTable
    with TableInfo<$ChatMessageTableTable, ChatMessageTableData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ChatMessageTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _conversationIdMeta =
      const VerificationMeta('conversationId');
  @override
  late final GeneratedColumn<String> conversationId = GeneratedColumn<String>(
      'conversation_id', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: true,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'REFERENCES chat_conversation_table (id)'));
  static const VerificationMeta _roleMeta = const VerificationMeta('role');
  @override
  late final GeneratedColumn<String> role = GeneratedColumn<String>(
      'role', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _contentMeta =
      const VerificationMeta('content');
  @override
  late final GeneratedColumn<String> content = GeneratedColumn<String>(
      'content', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _tokenCountMeta =
      const VerificationMeta('tokenCount');
  @override
  late final GeneratedColumn<int> tokenCount = GeneratedColumn<int>(
      'token_count', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _responseOutputTokensMeta =
      const VerificationMeta('responseOutputTokens');
  @override
  late final GeneratedColumn<int> responseOutputTokens = GeneratedColumn<int>(
      'response_output_tokens', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _responseContextTokensMeta =
      const VerificationMeta('responseContextTokens');
  @override
  late final GeneratedColumn<int> responseContextTokens = GeneratedColumn<int>(
      'response_context_tokens', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _responseMaxOutputTokensMeta =
      const VerificationMeta('responseMaxOutputTokens');
  @override
  late final GeneratedColumn<int> responseMaxOutputTokens =
      GeneratedColumn<int>('response_max_output_tokens', aliasedName, true,
          type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _responseDurationMsMeta =
      const VerificationMeta('responseDurationMs');
  @override
  late final GeneratedColumn<int> responseDurationMs = GeneratedColumn<int>(
      'response_duration_ms', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _imageBytesMeta =
      const VerificationMeta('imageBytes');
  @override
  late final GeneratedColumn<Uint8List> imageBytes = GeneratedColumn<Uint8List>(
      'image_bytes', aliasedName, true,
      type: DriftSqlType.blob, requiredDuringInsert: false);
  static const VerificationMeta _toolNameMeta =
      const VerificationMeta('toolName');
  @override
  late final GeneratedColumn<String> toolName = GeneratedColumn<String>(
      'tool_name', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _timestampMeta =
      const VerificationMeta('timestamp');
  @override
  late final GeneratedColumn<DateTime> timestamp = GeneratedColumn<DateTime>(
      'timestamp', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        conversationId,
        role,
        content,
        tokenCount,
        responseOutputTokens,
        responseContextTokens,
        responseMaxOutputTokens,
        responseDurationMs,
        imageBytes,
        toolName,
        timestamp
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'chat_message_table';
  @override
  VerificationContext validateIntegrity(
      Insertable<ChatMessageTableData> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('conversation_id')) {
      context.handle(
          _conversationIdMeta,
          conversationId.isAcceptableOrUnknown(
              data['conversation_id']!, _conversationIdMeta));
    } else if (isInserting) {
      context.missing(_conversationIdMeta);
    }
    if (data.containsKey('role')) {
      context.handle(
          _roleMeta, role.isAcceptableOrUnknown(data['role']!, _roleMeta));
    } else if (isInserting) {
      context.missing(_roleMeta);
    }
    if (data.containsKey('content')) {
      context.handle(_contentMeta,
          content.isAcceptableOrUnknown(data['content']!, _contentMeta));
    } else if (isInserting) {
      context.missing(_contentMeta);
    }
    if (data.containsKey('token_count')) {
      context.handle(
          _tokenCountMeta,
          tokenCount.isAcceptableOrUnknown(
              data['token_count']!, _tokenCountMeta));
    }
    if (data.containsKey('response_output_tokens')) {
      context.handle(
          _responseOutputTokensMeta,
          responseOutputTokens.isAcceptableOrUnknown(
              data['response_output_tokens']!, _responseOutputTokensMeta));
    }
    if (data.containsKey('response_context_tokens')) {
      context.handle(
          _responseContextTokensMeta,
          responseContextTokens.isAcceptableOrUnknown(
              data['response_context_tokens']!, _responseContextTokensMeta));
    }
    if (data.containsKey('response_max_output_tokens')) {
      context.handle(
          _responseMaxOutputTokensMeta,
          responseMaxOutputTokens.isAcceptableOrUnknown(
              data['response_max_output_tokens']!,
              _responseMaxOutputTokensMeta));
    }
    if (data.containsKey('response_duration_ms')) {
      context.handle(
          _responseDurationMsMeta,
          responseDurationMs.isAcceptableOrUnknown(
              data['response_duration_ms']!, _responseDurationMsMeta));
    }
    if (data.containsKey('image_bytes')) {
      context.handle(
          _imageBytesMeta,
          imageBytes.isAcceptableOrUnknown(
              data['image_bytes']!, _imageBytesMeta));
    }
    if (data.containsKey('tool_name')) {
      context.handle(_toolNameMeta,
          toolName.isAcceptableOrUnknown(data['tool_name']!, _toolNameMeta));
    }
    if (data.containsKey('timestamp')) {
      context.handle(_timestampMeta,
          timestamp.isAcceptableOrUnknown(data['timestamp']!, _timestampMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ChatMessageTableData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ChatMessageTableData(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      conversationId: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}conversation_id'])!,
      role: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}role'])!,
      content: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}content'])!,
      tokenCount: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}token_count']),
      responseOutputTokens: attachedDatabase.typeMapping.read(
          DriftSqlType.int, data['${effectivePrefix}response_output_tokens']),
      responseContextTokens: attachedDatabase.typeMapping.read(
          DriftSqlType.int, data['${effectivePrefix}response_context_tokens']),
      responseMaxOutputTokens: attachedDatabase.typeMapping.read(
          DriftSqlType.int,
          data['${effectivePrefix}response_max_output_tokens']),
      responseDurationMs: attachedDatabase.typeMapping.read(
          DriftSqlType.int, data['${effectivePrefix}response_duration_ms']),
      imageBytes: attachedDatabase.typeMapping
          .read(DriftSqlType.blob, data['${effectivePrefix}image_bytes']),
      toolName: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}tool_name']),
      timestamp: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}timestamp'])!,
    );
  }

  @override
  $ChatMessageTableTable createAlias(String alias) {
    return $ChatMessageTableTable(attachedDatabase, alias);
  }
}

class ChatMessageTableData extends DataClass
    implements Insertable<ChatMessageTableData> {
  /// Primary key (UUID string).
  final String id;

  /// Foreign key to the conversation.
  final String conversationId;

  /// The role of the message sender (user, assistant, system).
  final String role;

  /// The text content of the message.
  final String content;

  /// Number of tokens in the message (null if not computed).
  final int? tokenCount;

  /// Generated output token count for assistant responses.
  final int? responseOutputTokens;

  /// Approximate input context size in tokens for assistant responses.
  final int? responseContextTokens;

  /// Configured maximum output tokens for assistant responses.
  final int? responseMaxOutputTokens;

  /// Wall-clock generation duration in milliseconds for assistant responses.
  final int? responseDurationMs;

  /// Image data for multimodal user messages (null for text-only).
  final Uint8List? imageBytes;

  /// Tool name for tool_response messages (null for other roles).
  final String? toolName;

  /// Timestamp when the message was created.
  final DateTime timestamp;
  const ChatMessageTableData(
      {required this.id,
      required this.conversationId,
      required this.role,
      required this.content,
      this.tokenCount,
      this.responseOutputTokens,
      this.responseContextTokens,
      this.responseMaxOutputTokens,
      this.responseDurationMs,
      this.imageBytes,
      this.toolName,
      required this.timestamp});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['conversation_id'] = Variable<String>(conversationId);
    map['role'] = Variable<String>(role);
    map['content'] = Variable<String>(content);
    if (!nullToAbsent || tokenCount != null) {
      map['token_count'] = Variable<int>(tokenCount);
    }
    if (!nullToAbsent || responseOutputTokens != null) {
      map['response_output_tokens'] = Variable<int>(responseOutputTokens);
    }
    if (!nullToAbsent || responseContextTokens != null) {
      map['response_context_tokens'] = Variable<int>(responseContextTokens);
    }
    if (!nullToAbsent || responseMaxOutputTokens != null) {
      map['response_max_output_tokens'] =
          Variable<int>(responseMaxOutputTokens);
    }
    if (!nullToAbsent || responseDurationMs != null) {
      map['response_duration_ms'] = Variable<int>(responseDurationMs);
    }
    if (!nullToAbsent || imageBytes != null) {
      map['image_bytes'] = Variable<Uint8List>(imageBytes);
    }
    if (!nullToAbsent || toolName != null) {
      map['tool_name'] = Variable<String>(toolName);
    }
    map['timestamp'] = Variable<DateTime>(timestamp);
    return map;
  }

  ChatMessageTableCompanion toCompanion(bool nullToAbsent) {
    return ChatMessageTableCompanion(
      id: Value(id),
      conversationId: Value(conversationId),
      role: Value(role),
      content: Value(content),
      tokenCount: tokenCount == null && nullToAbsent
          ? const Value.absent()
          : Value(tokenCount),
      responseOutputTokens: responseOutputTokens == null && nullToAbsent
          ? const Value.absent()
          : Value(responseOutputTokens),
      responseContextTokens: responseContextTokens == null && nullToAbsent
          ? const Value.absent()
          : Value(responseContextTokens),
      responseMaxOutputTokens: responseMaxOutputTokens == null && nullToAbsent
          ? const Value.absent()
          : Value(responseMaxOutputTokens),
      responseDurationMs: responseDurationMs == null && nullToAbsent
          ? const Value.absent()
          : Value(responseDurationMs),
      imageBytes: imageBytes == null && nullToAbsent
          ? const Value.absent()
          : Value(imageBytes),
      toolName: toolName == null && nullToAbsent
          ? const Value.absent()
          : Value(toolName),
      timestamp: Value(timestamp),
    );
  }

  factory ChatMessageTableData.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ChatMessageTableData(
      id: serializer.fromJson<String>(json['id']),
      conversationId: serializer.fromJson<String>(json['conversationId']),
      role: serializer.fromJson<String>(json['role']),
      content: serializer.fromJson<String>(json['content']),
      tokenCount: serializer.fromJson<int?>(json['tokenCount']),
      responseOutputTokens:
          serializer.fromJson<int?>(json['responseOutputTokens']),
      responseContextTokens:
          serializer.fromJson<int?>(json['responseContextTokens']),
      responseMaxOutputTokens:
          serializer.fromJson<int?>(json['responseMaxOutputTokens']),
      responseDurationMs: serializer.fromJson<int?>(json['responseDurationMs']),
      imageBytes: serializer.fromJson<Uint8List?>(json['imageBytes']),
      toolName: serializer.fromJson<String?>(json['toolName']),
      timestamp: serializer.fromJson<DateTime>(json['timestamp']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'conversationId': serializer.toJson<String>(conversationId),
      'role': serializer.toJson<String>(role),
      'content': serializer.toJson<String>(content),
      'tokenCount': serializer.toJson<int?>(tokenCount),
      'responseOutputTokens': serializer.toJson<int?>(responseOutputTokens),
      'responseContextTokens': serializer.toJson<int?>(responseContextTokens),
      'responseMaxOutputTokens':
          serializer.toJson<int?>(responseMaxOutputTokens),
      'responseDurationMs': serializer.toJson<int?>(responseDurationMs),
      'imageBytes': serializer.toJson<Uint8List?>(imageBytes),
      'toolName': serializer.toJson<String?>(toolName),
      'timestamp': serializer.toJson<DateTime>(timestamp),
    };
  }

  ChatMessageTableData copyWith(
          {String? id,
          String? conversationId,
          String? role,
          String? content,
          Value<int?> tokenCount = const Value.absent(),
          Value<int?> responseOutputTokens = const Value.absent(),
          Value<int?> responseContextTokens = const Value.absent(),
          Value<int?> responseMaxOutputTokens = const Value.absent(),
          Value<int?> responseDurationMs = const Value.absent(),
          Value<Uint8List?> imageBytes = const Value.absent(),
          Value<String?> toolName = const Value.absent(),
          DateTime? timestamp}) =>
      ChatMessageTableData(
        id: id ?? this.id,
        conversationId: conversationId ?? this.conversationId,
        role: role ?? this.role,
        content: content ?? this.content,
        tokenCount: tokenCount.present ? tokenCount.value : this.tokenCount,
        responseOutputTokens: responseOutputTokens.present
            ? responseOutputTokens.value
            : this.responseOutputTokens,
        responseContextTokens: responseContextTokens.present
            ? responseContextTokens.value
            : this.responseContextTokens,
        responseMaxOutputTokens: responseMaxOutputTokens.present
            ? responseMaxOutputTokens.value
            : this.responseMaxOutputTokens,
        responseDurationMs: responseDurationMs.present
            ? responseDurationMs.value
            : this.responseDurationMs,
        imageBytes: imageBytes.present ? imageBytes.value : this.imageBytes,
        toolName: toolName.present ? toolName.value : this.toolName,
        timestamp: timestamp ?? this.timestamp,
      );
  ChatMessageTableData copyWithCompanion(ChatMessageTableCompanion data) {
    return ChatMessageTableData(
      id: data.id.present ? data.id.value : this.id,
      conversationId: data.conversationId.present
          ? data.conversationId.value
          : this.conversationId,
      role: data.role.present ? data.role.value : this.role,
      content: data.content.present ? data.content.value : this.content,
      tokenCount:
          data.tokenCount.present ? data.tokenCount.value : this.tokenCount,
      responseOutputTokens: data.responseOutputTokens.present
          ? data.responseOutputTokens.value
          : this.responseOutputTokens,
      responseContextTokens: data.responseContextTokens.present
          ? data.responseContextTokens.value
          : this.responseContextTokens,
      responseMaxOutputTokens: data.responseMaxOutputTokens.present
          ? data.responseMaxOutputTokens.value
          : this.responseMaxOutputTokens,
      responseDurationMs: data.responseDurationMs.present
          ? data.responseDurationMs.value
          : this.responseDurationMs,
      imageBytes:
          data.imageBytes.present ? data.imageBytes.value : this.imageBytes,
      toolName: data.toolName.present ? data.toolName.value : this.toolName,
      timestamp: data.timestamp.present ? data.timestamp.value : this.timestamp,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ChatMessageTableData(')
          ..write('id: $id, ')
          ..write('conversationId: $conversationId, ')
          ..write('role: $role, ')
          ..write('content: $content, ')
          ..write('tokenCount: $tokenCount, ')
          ..write('responseOutputTokens: $responseOutputTokens, ')
          ..write('responseContextTokens: $responseContextTokens, ')
          ..write('responseMaxOutputTokens: $responseMaxOutputTokens, ')
          ..write('responseDurationMs: $responseDurationMs, ')
          ..write('imageBytes: $imageBytes, ')
          ..write('toolName: $toolName, ')
          ..write('timestamp: $timestamp')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id,
      conversationId,
      role,
      content,
      tokenCount,
      responseOutputTokens,
      responseContextTokens,
      responseMaxOutputTokens,
      responseDurationMs,
      $driftBlobEquality.hash(imageBytes),
      toolName,
      timestamp);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ChatMessageTableData &&
          other.id == this.id &&
          other.conversationId == this.conversationId &&
          other.role == this.role &&
          other.content == this.content &&
          other.tokenCount == this.tokenCount &&
          other.responseOutputTokens == this.responseOutputTokens &&
          other.responseContextTokens == this.responseContextTokens &&
          other.responseMaxOutputTokens == this.responseMaxOutputTokens &&
          other.responseDurationMs == this.responseDurationMs &&
          $driftBlobEquality.equals(other.imageBytes, this.imageBytes) &&
          other.toolName == this.toolName &&
          other.timestamp == this.timestamp);
}

class ChatMessageTableCompanion extends UpdateCompanion<ChatMessageTableData> {
  final Value<String> id;
  final Value<String> conversationId;
  final Value<String> role;
  final Value<String> content;
  final Value<int?> tokenCount;
  final Value<int?> responseOutputTokens;
  final Value<int?> responseContextTokens;
  final Value<int?> responseMaxOutputTokens;
  final Value<int?> responseDurationMs;
  final Value<Uint8List?> imageBytes;
  final Value<String?> toolName;
  final Value<DateTime> timestamp;
  final Value<int> rowid;
  const ChatMessageTableCompanion({
    this.id = const Value.absent(),
    this.conversationId = const Value.absent(),
    this.role = const Value.absent(),
    this.content = const Value.absent(),
    this.tokenCount = const Value.absent(),
    this.responseOutputTokens = const Value.absent(),
    this.responseContextTokens = const Value.absent(),
    this.responseMaxOutputTokens = const Value.absent(),
    this.responseDurationMs = const Value.absent(),
    this.imageBytes = const Value.absent(),
    this.toolName = const Value.absent(),
    this.timestamp = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ChatMessageTableCompanion.insert({
    required String id,
    required String conversationId,
    required String role,
    required String content,
    this.tokenCount = const Value.absent(),
    this.responseOutputTokens = const Value.absent(),
    this.responseContextTokens = const Value.absent(),
    this.responseMaxOutputTokens = const Value.absent(),
    this.responseDurationMs = const Value.absent(),
    this.imageBytes = const Value.absent(),
    this.toolName = const Value.absent(),
    this.timestamp = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        conversationId = Value(conversationId),
        role = Value(role),
        content = Value(content);
  static Insertable<ChatMessageTableData> custom({
    Expression<String>? id,
    Expression<String>? conversationId,
    Expression<String>? role,
    Expression<String>? content,
    Expression<int>? tokenCount,
    Expression<int>? responseOutputTokens,
    Expression<int>? responseContextTokens,
    Expression<int>? responseMaxOutputTokens,
    Expression<int>? responseDurationMs,
    Expression<Uint8List>? imageBytes,
    Expression<String>? toolName,
    Expression<DateTime>? timestamp,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (conversationId != null) 'conversation_id': conversationId,
      if (role != null) 'role': role,
      if (content != null) 'content': content,
      if (tokenCount != null) 'token_count': tokenCount,
      if (responseOutputTokens != null)
        'response_output_tokens': responseOutputTokens,
      if (responseContextTokens != null)
        'response_context_tokens': responseContextTokens,
      if (responseMaxOutputTokens != null)
        'response_max_output_tokens': responseMaxOutputTokens,
      if (responseDurationMs != null)
        'response_duration_ms': responseDurationMs,
      if (imageBytes != null) 'image_bytes': imageBytes,
      if (toolName != null) 'tool_name': toolName,
      if (timestamp != null) 'timestamp': timestamp,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ChatMessageTableCompanion copyWith(
      {Value<String>? id,
      Value<String>? conversationId,
      Value<String>? role,
      Value<String>? content,
      Value<int?>? tokenCount,
      Value<int?>? responseOutputTokens,
      Value<int?>? responseContextTokens,
      Value<int?>? responseMaxOutputTokens,
      Value<int?>? responseDurationMs,
      Value<Uint8List?>? imageBytes,
      Value<String?>? toolName,
      Value<DateTime>? timestamp,
      Value<int>? rowid}) {
    return ChatMessageTableCompanion(
      id: id ?? this.id,
      conversationId: conversationId ?? this.conversationId,
      role: role ?? this.role,
      content: content ?? this.content,
      tokenCount: tokenCount ?? this.tokenCount,
      responseOutputTokens: responseOutputTokens ?? this.responseOutputTokens,
      responseContextTokens:
          responseContextTokens ?? this.responseContextTokens,
      responseMaxOutputTokens:
          responseMaxOutputTokens ?? this.responseMaxOutputTokens,
      responseDurationMs: responseDurationMs ?? this.responseDurationMs,
      imageBytes: imageBytes ?? this.imageBytes,
      toolName: toolName ?? this.toolName,
      timestamp: timestamp ?? this.timestamp,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (conversationId.present) {
      map['conversation_id'] = Variable<String>(conversationId.value);
    }
    if (role.present) {
      map['role'] = Variable<String>(role.value);
    }
    if (content.present) {
      map['content'] = Variable<String>(content.value);
    }
    if (tokenCount.present) {
      map['token_count'] = Variable<int>(tokenCount.value);
    }
    if (responseOutputTokens.present) {
      map['response_output_tokens'] = Variable<int>(responseOutputTokens.value);
    }
    if (responseContextTokens.present) {
      map['response_context_tokens'] =
          Variable<int>(responseContextTokens.value);
    }
    if (responseMaxOutputTokens.present) {
      map['response_max_output_tokens'] =
          Variable<int>(responseMaxOutputTokens.value);
    }
    if (responseDurationMs.present) {
      map['response_duration_ms'] = Variable<int>(responseDurationMs.value);
    }
    if (imageBytes.present) {
      map['image_bytes'] = Variable<Uint8List>(imageBytes.value);
    }
    if (toolName.present) {
      map['tool_name'] = Variable<String>(toolName.value);
    }
    if (timestamp.present) {
      map['timestamp'] = Variable<DateTime>(timestamp.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ChatMessageTableCompanion(')
          ..write('id: $id, ')
          ..write('conversationId: $conversationId, ')
          ..write('role: $role, ')
          ..write('content: $content, ')
          ..write('tokenCount: $tokenCount, ')
          ..write('responseOutputTokens: $responseOutputTokens, ')
          ..write('responseContextTokens: $responseContextTokens, ')
          ..write('responseMaxOutputTokens: $responseMaxOutputTokens, ')
          ..write('responseDurationMs: $responseDurationMs, ')
          ..write('imageBytes: $imageBytes, ')
          ..write('toolName: $toolName, ')
          ..write('timestamp: $timestamp, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ChatSettingsTableTable extends ChatSettingsTable
    with TableInfo<$ChatSettingsTableTable, ChatSettingsTableData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ChatSettingsTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _keyMeta = const VerificationMeta('key');
  @override
  late final GeneratedColumn<String> key = GeneratedColumn<String>(
      'key', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('default'));
  static const VerificationMeta _inferenceModeMeta =
      const VerificationMeta('inferenceMode');
  @override
  late final GeneratedColumn<String> inferenceMode = GeneratedColumn<String>(
      'inference_mode', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('local'));
  static const VerificationMeta _modelTypeMeta =
      const VerificationMeta('modelType');
  @override
  late final GeneratedColumn<String> modelType = GeneratedColumn<String>(
      'model_type', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('gemma2bIt'));
  static const VerificationMeta _customModelPathMeta =
      const VerificationMeta('customModelPath');
  @override
  late final GeneratedColumn<String> customModelPath = GeneratedColumn<String>(
      'custom_model_path', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _maxTokensMeta =
      const VerificationMeta('maxTokens');
  @override
  late final GeneratedColumn<int> maxTokens = GeneratedColumn<int>(
      'max_tokens', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(2048));
  static const VerificationMeta _temperatureX100Meta =
      const VerificationMeta('temperatureX100');
  @override
  late final GeneratedColumn<int> temperatureX100 = GeneratedColumn<int>(
      'temperature_x100', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(80));
  static const VerificationMeta _topKMeta = const VerificationMeta('topK');
  @override
  late final GeneratedColumn<int> topK = GeneratedColumn<int>(
      'top_k', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(40));
  static const VerificationMeta _backendMeta =
      const VerificationMeta('backend');
  @override
  late final GeneratedColumn<String> backend = GeneratedColumn<String>(
      'backend', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('gpu'));
  static const VerificationMeta _remoteProviderMeta =
      const VerificationMeta('remoteProvider');
  @override
  late final GeneratedColumn<String> remoteProvider = GeneratedColumn<String>(
      'remote_provider', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('openAiCompatible'));
  static const VerificationMeta _remoteApiTypeMeta =
      const VerificationMeta('remoteApiType');
  @override
  late final GeneratedColumn<String> remoteApiType = GeneratedColumn<String>(
      'remote_api_type', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('openAiChatCompletions'));
  static const VerificationMeta _remoteAccountIdMeta =
      const VerificationMeta('remoteAccountId');
  @override
  late final GeneratedColumn<int> remoteAccountId = GeneratedColumn<int>(
      'remote_account_id', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _remoteBaseUrlMeta =
      const VerificationMeta('remoteBaseUrl');
  @override
  late final GeneratedColumn<String> remoteBaseUrl = GeneratedColumn<String>(
      'remote_base_url', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('https://api.openai.com/v1'));
  static const VerificationMeta _remoteModelMeta =
      const VerificationMeta('remoteModel');
  @override
  late final GeneratedColumn<String> remoteModel = GeneratedColumn<String>(
      'remote_model', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('gpt-4.1-mini'));
  static const VerificationMeta _remoteAuthTypeMeta =
      const VerificationMeta('remoteAuthType');
  @override
  late final GeneratedColumn<String> remoteAuthType = GeneratedColumn<String>(
      'remote_auth_type', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('providerDefault'));
  static const VerificationMeta _remoteAuthHeaderNameMeta =
      const VerificationMeta('remoteAuthHeaderName');
  @override
  late final GeneratedColumn<String> remoteAuthHeaderName =
      GeneratedColumn<String>('remote_auth_header_name', aliasedName, true,
          type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _remoteStreamingEnabledMeta =
      const VerificationMeta('remoteStreamingEnabled');
  @override
  late final GeneratedColumn<bool> remoteStreamingEnabled =
      GeneratedColumn<bool>('remote_streaming_enabled', aliasedName, false,
          type: DriftSqlType.bool,
          requiredDuringInsert: false,
          defaultConstraints: GeneratedColumn.constraintIsAlways(
              'CHECK ("remote_streaming_enabled" IN (0, 1))'),
          defaultValue: const Constant(true));
  static const VerificationMeta _remoteThinkingEffortMeta =
      const VerificationMeta('remoteThinkingEffort');
  @override
  late final GeneratedColumn<String> remoteThinkingEffort =
      GeneratedColumn<String>('remote_thinking_effort', aliasedName, false,
          type: DriftSqlType.string,
          requiredDuringInsert: false,
          defaultValue: const Constant('off'));
  static const VerificationMeta _defaultSystemPromptMeta =
      const VerificationMeta('defaultSystemPrompt');
  @override
  late final GeneratedColumn<String> defaultSystemPrompt =
      GeneratedColumn<String>('default_system_prompt', aliasedName, true,
          type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _localModelIdMeta =
      const VerificationMeta('localModelId');
  @override
  late final GeneratedColumn<String> localModelId = GeneratedColumn<String>(
      'local_model_id', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns => [
        key,
        inferenceMode,
        modelType,
        customModelPath,
        maxTokens,
        temperatureX100,
        topK,
        backend,
        remoteProvider,
        remoteApiType,
        remoteAccountId,
        remoteBaseUrl,
        remoteModel,
        remoteAuthType,
        remoteAuthHeaderName,
        remoteStreamingEnabled,
        remoteThinkingEffort,
        defaultSystemPrompt,
        localModelId
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'chat_settings_table';
  @override
  VerificationContext validateIntegrity(
      Insertable<ChatSettingsTableData> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('key')) {
      context.handle(
          _keyMeta, key.isAcceptableOrUnknown(data['key']!, _keyMeta));
    }
    if (data.containsKey('inference_mode')) {
      context.handle(
          _inferenceModeMeta,
          inferenceMode.isAcceptableOrUnknown(
              data['inference_mode']!, _inferenceModeMeta));
    }
    if (data.containsKey('model_type')) {
      context.handle(_modelTypeMeta,
          modelType.isAcceptableOrUnknown(data['model_type']!, _modelTypeMeta));
    }
    if (data.containsKey('custom_model_path')) {
      context.handle(
          _customModelPathMeta,
          customModelPath.isAcceptableOrUnknown(
              data['custom_model_path']!, _customModelPathMeta));
    }
    if (data.containsKey('max_tokens')) {
      context.handle(_maxTokensMeta,
          maxTokens.isAcceptableOrUnknown(data['max_tokens']!, _maxTokensMeta));
    }
    if (data.containsKey('temperature_x100')) {
      context.handle(
          _temperatureX100Meta,
          temperatureX100.isAcceptableOrUnknown(
              data['temperature_x100']!, _temperatureX100Meta));
    }
    if (data.containsKey('top_k')) {
      context.handle(
          _topKMeta, topK.isAcceptableOrUnknown(data['top_k']!, _topKMeta));
    }
    if (data.containsKey('backend')) {
      context.handle(_backendMeta,
          backend.isAcceptableOrUnknown(data['backend']!, _backendMeta));
    }
    if (data.containsKey('remote_provider')) {
      context.handle(
          _remoteProviderMeta,
          remoteProvider.isAcceptableOrUnknown(
              data['remote_provider']!, _remoteProviderMeta));
    }
    if (data.containsKey('remote_api_type')) {
      context.handle(
          _remoteApiTypeMeta,
          remoteApiType.isAcceptableOrUnknown(
              data['remote_api_type']!, _remoteApiTypeMeta));
    }
    if (data.containsKey('remote_account_id')) {
      context.handle(
          _remoteAccountIdMeta,
          remoteAccountId.isAcceptableOrUnknown(
              data['remote_account_id']!, _remoteAccountIdMeta));
    }
    if (data.containsKey('remote_base_url')) {
      context.handle(
          _remoteBaseUrlMeta,
          remoteBaseUrl.isAcceptableOrUnknown(
              data['remote_base_url']!, _remoteBaseUrlMeta));
    }
    if (data.containsKey('remote_model')) {
      context.handle(
          _remoteModelMeta,
          remoteModel.isAcceptableOrUnknown(
              data['remote_model']!, _remoteModelMeta));
    }
    if (data.containsKey('remote_auth_type')) {
      context.handle(
          _remoteAuthTypeMeta,
          remoteAuthType.isAcceptableOrUnknown(
              data['remote_auth_type']!, _remoteAuthTypeMeta));
    }
    if (data.containsKey('remote_auth_header_name')) {
      context.handle(
          _remoteAuthHeaderNameMeta,
          remoteAuthHeaderName.isAcceptableOrUnknown(
              data['remote_auth_header_name']!, _remoteAuthHeaderNameMeta));
    }
    if (data.containsKey('remote_streaming_enabled')) {
      context.handle(
          _remoteStreamingEnabledMeta,
          remoteStreamingEnabled.isAcceptableOrUnknown(
              data['remote_streaming_enabled']!, _remoteStreamingEnabledMeta));
    }
    if (data.containsKey('remote_thinking_effort')) {
      context.handle(
          _remoteThinkingEffortMeta,
          remoteThinkingEffort.isAcceptableOrUnknown(
              data['remote_thinking_effort']!, _remoteThinkingEffortMeta));
    }
    if (data.containsKey('default_system_prompt')) {
      context.handle(
          _defaultSystemPromptMeta,
          defaultSystemPrompt.isAcceptableOrUnknown(
              data['default_system_prompt']!, _defaultSystemPromptMeta));
    }
    if (data.containsKey('local_model_id')) {
      context.handle(
          _localModelIdMeta,
          localModelId.isAcceptableOrUnknown(
              data['local_model_id']!, _localModelIdMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {key};
  @override
  ChatSettingsTableData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ChatSettingsTableData(
      key: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}key'])!,
      inferenceMode: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}inference_mode'])!,
      modelType: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}model_type'])!,
      customModelPath: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}custom_model_path']),
      maxTokens: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}max_tokens'])!,
      temperatureX100: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}temperature_x100'])!,
      topK: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}top_k'])!,
      backend: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}backend'])!,
      remoteProvider: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}remote_provider'])!,
      remoteApiType: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}remote_api_type'])!,
      remoteAccountId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}remote_account_id']),
      remoteBaseUrl: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}remote_base_url'])!,
      remoteModel: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}remote_model'])!,
      remoteAuthType: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}remote_auth_type'])!,
      remoteAuthHeaderName: attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}remote_auth_header_name']),
      remoteStreamingEnabled: attachedDatabase.typeMapping.read(
          DriftSqlType.bool,
          data['${effectivePrefix}remote_streaming_enabled'])!,
      remoteThinkingEffort: attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}remote_thinking_effort'])!,
      defaultSystemPrompt: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}default_system_prompt']),
      localModelId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}local_model_id']),
    );
  }

  @override
  $ChatSettingsTableTable createAlias(String alias) {
    return $ChatSettingsTableTable(attachedDatabase, alias);
  }
}

class ChatSettingsTableData extends DataClass
    implements Insertable<ChatSettingsTableData> {
  /// Singleton key (always 'default').
  final String key;

  /// Inference mode: local or remote.
  final String inferenceMode;

  /// Model type: gemma2bIt, gemma7bIt, or custom.
  final String modelType;

  /// Path to custom model file (nullable).
  final String? customModelPath;

  /// Maximum number of tokens to generate.
  final int maxTokens;

  /// Temperature for sampling (stored as integer * 100).
  final int temperatureX100;

  /// Top-K sampling parameter.
  final int topK;

  /// Backend to use: gpu or cpu.
  final String backend;

  /// Remote provider type.
  final String remoteProvider;

  /// Remote API protocol type.
  final String remoteApiType;

  /// Service account ID containing the remote provider API key.
  final int? remoteAccountId;

  /// Remote API base URL.
  final String remoteBaseUrl;

  /// Remote model identifier.
  final String remoteModel;

  /// Remote auth header strategy.
  final String remoteAuthType;

  /// Custom remote auth header name.
  final String? remoteAuthHeaderName;

  /// Whether remote responses should be streamed.
  final bool remoteStreamingEnabled;

  /// Remote provider thinking effort: off, high, or max.
  final String remoteThinkingEffort;

  /// Default system prompt for new conversations.
  final String? defaultSystemPrompt;

  /// The local model ID.
  final String? localModelId;
  const ChatSettingsTableData(
      {required this.key,
      required this.inferenceMode,
      required this.modelType,
      this.customModelPath,
      required this.maxTokens,
      required this.temperatureX100,
      required this.topK,
      required this.backend,
      required this.remoteProvider,
      required this.remoteApiType,
      this.remoteAccountId,
      required this.remoteBaseUrl,
      required this.remoteModel,
      required this.remoteAuthType,
      this.remoteAuthHeaderName,
      required this.remoteStreamingEnabled,
      required this.remoteThinkingEffort,
      this.defaultSystemPrompt,
      this.localModelId});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['key'] = Variable<String>(key);
    map['inference_mode'] = Variable<String>(inferenceMode);
    map['model_type'] = Variable<String>(modelType);
    if (!nullToAbsent || customModelPath != null) {
      map['custom_model_path'] = Variable<String>(customModelPath);
    }
    map['max_tokens'] = Variable<int>(maxTokens);
    map['temperature_x100'] = Variable<int>(temperatureX100);
    map['top_k'] = Variable<int>(topK);
    map['backend'] = Variable<String>(backend);
    map['remote_provider'] = Variable<String>(remoteProvider);
    map['remote_api_type'] = Variable<String>(remoteApiType);
    if (!nullToAbsent || remoteAccountId != null) {
      map['remote_account_id'] = Variable<int>(remoteAccountId);
    }
    map['remote_base_url'] = Variable<String>(remoteBaseUrl);
    map['remote_model'] = Variable<String>(remoteModel);
    map['remote_auth_type'] = Variable<String>(remoteAuthType);
    if (!nullToAbsent || remoteAuthHeaderName != null) {
      map['remote_auth_header_name'] = Variable<String>(remoteAuthHeaderName);
    }
    map['remote_streaming_enabled'] = Variable<bool>(remoteStreamingEnabled);
    map['remote_thinking_effort'] = Variable<String>(remoteThinkingEffort);
    if (!nullToAbsent || defaultSystemPrompt != null) {
      map['default_system_prompt'] = Variable<String>(defaultSystemPrompt);
    }
    if (!nullToAbsent || localModelId != null) {
      map['local_model_id'] = Variable<String>(localModelId);
    }
    return map;
  }

  ChatSettingsTableCompanion toCompanion(bool nullToAbsent) {
    return ChatSettingsTableCompanion(
      key: Value(key),
      inferenceMode: Value(inferenceMode),
      modelType: Value(modelType),
      customModelPath: customModelPath == null && nullToAbsent
          ? const Value.absent()
          : Value(customModelPath),
      maxTokens: Value(maxTokens),
      temperatureX100: Value(temperatureX100),
      topK: Value(topK),
      backend: Value(backend),
      remoteProvider: Value(remoteProvider),
      remoteApiType: Value(remoteApiType),
      remoteAccountId: remoteAccountId == null && nullToAbsent
          ? const Value.absent()
          : Value(remoteAccountId),
      remoteBaseUrl: Value(remoteBaseUrl),
      remoteModel: Value(remoteModel),
      remoteAuthType: Value(remoteAuthType),
      remoteAuthHeaderName: remoteAuthHeaderName == null && nullToAbsent
          ? const Value.absent()
          : Value(remoteAuthHeaderName),
      remoteStreamingEnabled: Value(remoteStreamingEnabled),
      remoteThinkingEffort: Value(remoteThinkingEffort),
      defaultSystemPrompt: defaultSystemPrompt == null && nullToAbsent
          ? const Value.absent()
          : Value(defaultSystemPrompt),
      localModelId: localModelId == null && nullToAbsent
          ? const Value.absent()
          : Value(localModelId),
    );
  }

  factory ChatSettingsTableData.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ChatSettingsTableData(
      key: serializer.fromJson<String>(json['key']),
      inferenceMode: serializer.fromJson<String>(json['inferenceMode']),
      modelType: serializer.fromJson<String>(json['modelType']),
      customModelPath: serializer.fromJson<String?>(json['customModelPath']),
      maxTokens: serializer.fromJson<int>(json['maxTokens']),
      temperatureX100: serializer.fromJson<int>(json['temperatureX100']),
      topK: serializer.fromJson<int>(json['topK']),
      backend: serializer.fromJson<String>(json['backend']),
      remoteProvider: serializer.fromJson<String>(json['remoteProvider']),
      remoteApiType: serializer.fromJson<String>(json['remoteApiType']),
      remoteAccountId: serializer.fromJson<int?>(json['remoteAccountId']),
      remoteBaseUrl: serializer.fromJson<String>(json['remoteBaseUrl']),
      remoteModel: serializer.fromJson<String>(json['remoteModel']),
      remoteAuthType: serializer.fromJson<String>(json['remoteAuthType']),
      remoteAuthHeaderName:
          serializer.fromJson<String?>(json['remoteAuthHeaderName']),
      remoteStreamingEnabled:
          serializer.fromJson<bool>(json['remoteStreamingEnabled']),
      remoteThinkingEffort:
          serializer.fromJson<String>(json['remoteThinkingEffort']),
      defaultSystemPrompt:
          serializer.fromJson<String?>(json['defaultSystemPrompt']),
      localModelId: serializer.fromJson<String?>(json['localModelId']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'key': serializer.toJson<String>(key),
      'inferenceMode': serializer.toJson<String>(inferenceMode),
      'modelType': serializer.toJson<String>(modelType),
      'customModelPath': serializer.toJson<String?>(customModelPath),
      'maxTokens': serializer.toJson<int>(maxTokens),
      'temperatureX100': serializer.toJson<int>(temperatureX100),
      'topK': serializer.toJson<int>(topK),
      'backend': serializer.toJson<String>(backend),
      'remoteProvider': serializer.toJson<String>(remoteProvider),
      'remoteApiType': serializer.toJson<String>(remoteApiType),
      'remoteAccountId': serializer.toJson<int?>(remoteAccountId),
      'remoteBaseUrl': serializer.toJson<String>(remoteBaseUrl),
      'remoteModel': serializer.toJson<String>(remoteModel),
      'remoteAuthType': serializer.toJson<String>(remoteAuthType),
      'remoteAuthHeaderName': serializer.toJson<String?>(remoteAuthHeaderName),
      'remoteStreamingEnabled': serializer.toJson<bool>(remoteStreamingEnabled),
      'remoteThinkingEffort': serializer.toJson<String>(remoteThinkingEffort),
      'defaultSystemPrompt': serializer.toJson<String?>(defaultSystemPrompt),
      'localModelId': serializer.toJson<String?>(localModelId),
    };
  }

  ChatSettingsTableData copyWith(
          {String? key,
          String? inferenceMode,
          String? modelType,
          Value<String?> customModelPath = const Value.absent(),
          int? maxTokens,
          int? temperatureX100,
          int? topK,
          String? backend,
          String? remoteProvider,
          String? remoteApiType,
          Value<int?> remoteAccountId = const Value.absent(),
          String? remoteBaseUrl,
          String? remoteModel,
          String? remoteAuthType,
          Value<String?> remoteAuthHeaderName = const Value.absent(),
          bool? remoteStreamingEnabled,
          String? remoteThinkingEffort,
          Value<String?> defaultSystemPrompt = const Value.absent(),
          Value<String?> localModelId = const Value.absent()}) =>
      ChatSettingsTableData(
        key: key ?? this.key,
        inferenceMode: inferenceMode ?? this.inferenceMode,
        modelType: modelType ?? this.modelType,
        customModelPath: customModelPath.present
            ? customModelPath.value
            : this.customModelPath,
        maxTokens: maxTokens ?? this.maxTokens,
        temperatureX100: temperatureX100 ?? this.temperatureX100,
        topK: topK ?? this.topK,
        backend: backend ?? this.backend,
        remoteProvider: remoteProvider ?? this.remoteProvider,
        remoteApiType: remoteApiType ?? this.remoteApiType,
        remoteAccountId: remoteAccountId.present
            ? remoteAccountId.value
            : this.remoteAccountId,
        remoteBaseUrl: remoteBaseUrl ?? this.remoteBaseUrl,
        remoteModel: remoteModel ?? this.remoteModel,
        remoteAuthType: remoteAuthType ?? this.remoteAuthType,
        remoteAuthHeaderName: remoteAuthHeaderName.present
            ? remoteAuthHeaderName.value
            : this.remoteAuthHeaderName,
        remoteStreamingEnabled:
            remoteStreamingEnabled ?? this.remoteStreamingEnabled,
        remoteThinkingEffort: remoteThinkingEffort ?? this.remoteThinkingEffort,
        defaultSystemPrompt: defaultSystemPrompt.present
            ? defaultSystemPrompt.value
            : this.defaultSystemPrompt,
        localModelId:
            localModelId.present ? localModelId.value : this.localModelId,
      );
  ChatSettingsTableData copyWithCompanion(ChatSettingsTableCompanion data) {
    return ChatSettingsTableData(
      key: data.key.present ? data.key.value : this.key,
      inferenceMode: data.inferenceMode.present
          ? data.inferenceMode.value
          : this.inferenceMode,
      modelType: data.modelType.present ? data.modelType.value : this.modelType,
      customModelPath: data.customModelPath.present
          ? data.customModelPath.value
          : this.customModelPath,
      maxTokens: data.maxTokens.present ? data.maxTokens.value : this.maxTokens,
      temperatureX100: data.temperatureX100.present
          ? data.temperatureX100.value
          : this.temperatureX100,
      topK: data.topK.present ? data.topK.value : this.topK,
      backend: data.backend.present ? data.backend.value : this.backend,
      remoteProvider: data.remoteProvider.present
          ? data.remoteProvider.value
          : this.remoteProvider,
      remoteApiType: data.remoteApiType.present
          ? data.remoteApiType.value
          : this.remoteApiType,
      remoteAccountId: data.remoteAccountId.present
          ? data.remoteAccountId.value
          : this.remoteAccountId,
      remoteBaseUrl: data.remoteBaseUrl.present
          ? data.remoteBaseUrl.value
          : this.remoteBaseUrl,
      remoteModel:
          data.remoteModel.present ? data.remoteModel.value : this.remoteModel,
      remoteAuthType: data.remoteAuthType.present
          ? data.remoteAuthType.value
          : this.remoteAuthType,
      remoteAuthHeaderName: data.remoteAuthHeaderName.present
          ? data.remoteAuthHeaderName.value
          : this.remoteAuthHeaderName,
      remoteStreamingEnabled: data.remoteStreamingEnabled.present
          ? data.remoteStreamingEnabled.value
          : this.remoteStreamingEnabled,
      remoteThinkingEffort: data.remoteThinkingEffort.present
          ? data.remoteThinkingEffort.value
          : this.remoteThinkingEffort,
      defaultSystemPrompt: data.defaultSystemPrompt.present
          ? data.defaultSystemPrompt.value
          : this.defaultSystemPrompt,
      localModelId: data.localModelId.present
          ? data.localModelId.value
          : this.localModelId,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ChatSettingsTableData(')
          ..write('key: $key, ')
          ..write('inferenceMode: $inferenceMode, ')
          ..write('modelType: $modelType, ')
          ..write('customModelPath: $customModelPath, ')
          ..write('maxTokens: $maxTokens, ')
          ..write('temperatureX100: $temperatureX100, ')
          ..write('topK: $topK, ')
          ..write('backend: $backend, ')
          ..write('remoteProvider: $remoteProvider, ')
          ..write('remoteApiType: $remoteApiType, ')
          ..write('remoteAccountId: $remoteAccountId, ')
          ..write('remoteBaseUrl: $remoteBaseUrl, ')
          ..write('remoteModel: $remoteModel, ')
          ..write('remoteAuthType: $remoteAuthType, ')
          ..write('remoteAuthHeaderName: $remoteAuthHeaderName, ')
          ..write('remoteStreamingEnabled: $remoteStreamingEnabled, ')
          ..write('remoteThinkingEffort: $remoteThinkingEffort, ')
          ..write('defaultSystemPrompt: $defaultSystemPrompt, ')
          ..write('localModelId: $localModelId')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      key,
      inferenceMode,
      modelType,
      customModelPath,
      maxTokens,
      temperatureX100,
      topK,
      backend,
      remoteProvider,
      remoteApiType,
      remoteAccountId,
      remoteBaseUrl,
      remoteModel,
      remoteAuthType,
      remoteAuthHeaderName,
      remoteStreamingEnabled,
      remoteThinkingEffort,
      defaultSystemPrompt,
      localModelId);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ChatSettingsTableData &&
          other.key == this.key &&
          other.inferenceMode == this.inferenceMode &&
          other.modelType == this.modelType &&
          other.customModelPath == this.customModelPath &&
          other.maxTokens == this.maxTokens &&
          other.temperatureX100 == this.temperatureX100 &&
          other.topK == this.topK &&
          other.backend == this.backend &&
          other.remoteProvider == this.remoteProvider &&
          other.remoteApiType == this.remoteApiType &&
          other.remoteAccountId == this.remoteAccountId &&
          other.remoteBaseUrl == this.remoteBaseUrl &&
          other.remoteModel == this.remoteModel &&
          other.remoteAuthType == this.remoteAuthType &&
          other.remoteAuthHeaderName == this.remoteAuthHeaderName &&
          other.remoteStreamingEnabled == this.remoteStreamingEnabled &&
          other.remoteThinkingEffort == this.remoteThinkingEffort &&
          other.defaultSystemPrompt == this.defaultSystemPrompt &&
          other.localModelId == this.localModelId);
}

class ChatSettingsTableCompanion
    extends UpdateCompanion<ChatSettingsTableData> {
  final Value<String> key;
  final Value<String> inferenceMode;
  final Value<String> modelType;
  final Value<String?> customModelPath;
  final Value<int> maxTokens;
  final Value<int> temperatureX100;
  final Value<int> topK;
  final Value<String> backend;
  final Value<String> remoteProvider;
  final Value<String> remoteApiType;
  final Value<int?> remoteAccountId;
  final Value<String> remoteBaseUrl;
  final Value<String> remoteModel;
  final Value<String> remoteAuthType;
  final Value<String?> remoteAuthHeaderName;
  final Value<bool> remoteStreamingEnabled;
  final Value<String> remoteThinkingEffort;
  final Value<String?> defaultSystemPrompt;
  final Value<String?> localModelId;
  final Value<int> rowid;
  const ChatSettingsTableCompanion({
    this.key = const Value.absent(),
    this.inferenceMode = const Value.absent(),
    this.modelType = const Value.absent(),
    this.customModelPath = const Value.absent(),
    this.maxTokens = const Value.absent(),
    this.temperatureX100 = const Value.absent(),
    this.topK = const Value.absent(),
    this.backend = const Value.absent(),
    this.remoteProvider = const Value.absent(),
    this.remoteApiType = const Value.absent(),
    this.remoteAccountId = const Value.absent(),
    this.remoteBaseUrl = const Value.absent(),
    this.remoteModel = const Value.absent(),
    this.remoteAuthType = const Value.absent(),
    this.remoteAuthHeaderName = const Value.absent(),
    this.remoteStreamingEnabled = const Value.absent(),
    this.remoteThinkingEffort = const Value.absent(),
    this.defaultSystemPrompt = const Value.absent(),
    this.localModelId = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ChatSettingsTableCompanion.insert({
    this.key = const Value.absent(),
    this.inferenceMode = const Value.absent(),
    this.modelType = const Value.absent(),
    this.customModelPath = const Value.absent(),
    this.maxTokens = const Value.absent(),
    this.temperatureX100 = const Value.absent(),
    this.topK = const Value.absent(),
    this.backend = const Value.absent(),
    this.remoteProvider = const Value.absent(),
    this.remoteApiType = const Value.absent(),
    this.remoteAccountId = const Value.absent(),
    this.remoteBaseUrl = const Value.absent(),
    this.remoteModel = const Value.absent(),
    this.remoteAuthType = const Value.absent(),
    this.remoteAuthHeaderName = const Value.absent(),
    this.remoteStreamingEnabled = const Value.absent(),
    this.remoteThinkingEffort = const Value.absent(),
    this.defaultSystemPrompt = const Value.absent(),
    this.localModelId = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  static Insertable<ChatSettingsTableData> custom({
    Expression<String>? key,
    Expression<String>? inferenceMode,
    Expression<String>? modelType,
    Expression<String>? customModelPath,
    Expression<int>? maxTokens,
    Expression<int>? temperatureX100,
    Expression<int>? topK,
    Expression<String>? backend,
    Expression<String>? remoteProvider,
    Expression<String>? remoteApiType,
    Expression<int>? remoteAccountId,
    Expression<String>? remoteBaseUrl,
    Expression<String>? remoteModel,
    Expression<String>? remoteAuthType,
    Expression<String>? remoteAuthHeaderName,
    Expression<bool>? remoteStreamingEnabled,
    Expression<String>? remoteThinkingEffort,
    Expression<String>? defaultSystemPrompt,
    Expression<String>? localModelId,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (key != null) 'key': key,
      if (inferenceMode != null) 'inference_mode': inferenceMode,
      if (modelType != null) 'model_type': modelType,
      if (customModelPath != null) 'custom_model_path': customModelPath,
      if (maxTokens != null) 'max_tokens': maxTokens,
      if (temperatureX100 != null) 'temperature_x100': temperatureX100,
      if (topK != null) 'top_k': topK,
      if (backend != null) 'backend': backend,
      if (remoteProvider != null) 'remote_provider': remoteProvider,
      if (remoteApiType != null) 'remote_api_type': remoteApiType,
      if (remoteAccountId != null) 'remote_account_id': remoteAccountId,
      if (remoteBaseUrl != null) 'remote_base_url': remoteBaseUrl,
      if (remoteModel != null) 'remote_model': remoteModel,
      if (remoteAuthType != null) 'remote_auth_type': remoteAuthType,
      if (remoteAuthHeaderName != null)
        'remote_auth_header_name': remoteAuthHeaderName,
      if (remoteStreamingEnabled != null)
        'remote_streaming_enabled': remoteStreamingEnabled,
      if (remoteThinkingEffort != null)
        'remote_thinking_effort': remoteThinkingEffort,
      if (defaultSystemPrompt != null)
        'default_system_prompt': defaultSystemPrompt,
      if (localModelId != null) 'local_model_id': localModelId,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ChatSettingsTableCompanion copyWith(
      {Value<String>? key,
      Value<String>? inferenceMode,
      Value<String>? modelType,
      Value<String?>? customModelPath,
      Value<int>? maxTokens,
      Value<int>? temperatureX100,
      Value<int>? topK,
      Value<String>? backend,
      Value<String>? remoteProvider,
      Value<String>? remoteApiType,
      Value<int?>? remoteAccountId,
      Value<String>? remoteBaseUrl,
      Value<String>? remoteModel,
      Value<String>? remoteAuthType,
      Value<String?>? remoteAuthHeaderName,
      Value<bool>? remoteStreamingEnabled,
      Value<String>? remoteThinkingEffort,
      Value<String?>? defaultSystemPrompt,
      Value<String?>? localModelId,
      Value<int>? rowid}) {
    return ChatSettingsTableCompanion(
      key: key ?? this.key,
      inferenceMode: inferenceMode ?? this.inferenceMode,
      modelType: modelType ?? this.modelType,
      customModelPath: customModelPath ?? this.customModelPath,
      maxTokens: maxTokens ?? this.maxTokens,
      temperatureX100: temperatureX100 ?? this.temperatureX100,
      topK: topK ?? this.topK,
      backend: backend ?? this.backend,
      remoteProvider: remoteProvider ?? this.remoteProvider,
      remoteApiType: remoteApiType ?? this.remoteApiType,
      remoteAccountId: remoteAccountId ?? this.remoteAccountId,
      remoteBaseUrl: remoteBaseUrl ?? this.remoteBaseUrl,
      remoteModel: remoteModel ?? this.remoteModel,
      remoteAuthType: remoteAuthType ?? this.remoteAuthType,
      remoteAuthHeaderName: remoteAuthHeaderName ?? this.remoteAuthHeaderName,
      remoteStreamingEnabled:
          remoteStreamingEnabled ?? this.remoteStreamingEnabled,
      remoteThinkingEffort: remoteThinkingEffort ?? this.remoteThinkingEffort,
      defaultSystemPrompt: defaultSystemPrompt ?? this.defaultSystemPrompt,
      localModelId: localModelId ?? this.localModelId,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (key.present) {
      map['key'] = Variable<String>(key.value);
    }
    if (inferenceMode.present) {
      map['inference_mode'] = Variable<String>(inferenceMode.value);
    }
    if (modelType.present) {
      map['model_type'] = Variable<String>(modelType.value);
    }
    if (customModelPath.present) {
      map['custom_model_path'] = Variable<String>(customModelPath.value);
    }
    if (maxTokens.present) {
      map['max_tokens'] = Variable<int>(maxTokens.value);
    }
    if (temperatureX100.present) {
      map['temperature_x100'] = Variable<int>(temperatureX100.value);
    }
    if (topK.present) {
      map['top_k'] = Variable<int>(topK.value);
    }
    if (backend.present) {
      map['backend'] = Variable<String>(backend.value);
    }
    if (remoteProvider.present) {
      map['remote_provider'] = Variable<String>(remoteProvider.value);
    }
    if (remoteApiType.present) {
      map['remote_api_type'] = Variable<String>(remoteApiType.value);
    }
    if (remoteAccountId.present) {
      map['remote_account_id'] = Variable<int>(remoteAccountId.value);
    }
    if (remoteBaseUrl.present) {
      map['remote_base_url'] = Variable<String>(remoteBaseUrl.value);
    }
    if (remoteModel.present) {
      map['remote_model'] = Variable<String>(remoteModel.value);
    }
    if (remoteAuthType.present) {
      map['remote_auth_type'] = Variable<String>(remoteAuthType.value);
    }
    if (remoteAuthHeaderName.present) {
      map['remote_auth_header_name'] =
          Variable<String>(remoteAuthHeaderName.value);
    }
    if (remoteStreamingEnabled.present) {
      map['remote_streaming_enabled'] =
          Variable<bool>(remoteStreamingEnabled.value);
    }
    if (remoteThinkingEffort.present) {
      map['remote_thinking_effort'] =
          Variable<String>(remoteThinkingEffort.value);
    }
    if (defaultSystemPrompt.present) {
      map['default_system_prompt'] =
          Variable<String>(defaultSystemPrompt.value);
    }
    if (localModelId.present) {
      map['local_model_id'] = Variable<String>(localModelId.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ChatSettingsTableCompanion(')
          ..write('key: $key, ')
          ..write('inferenceMode: $inferenceMode, ')
          ..write('modelType: $modelType, ')
          ..write('customModelPath: $customModelPath, ')
          ..write('maxTokens: $maxTokens, ')
          ..write('temperatureX100: $temperatureX100, ')
          ..write('topK: $topK, ')
          ..write('backend: $backend, ')
          ..write('remoteProvider: $remoteProvider, ')
          ..write('remoteApiType: $remoteApiType, ')
          ..write('remoteAccountId: $remoteAccountId, ')
          ..write('remoteBaseUrl: $remoteBaseUrl, ')
          ..write('remoteModel: $remoteModel, ')
          ..write('remoteAuthType: $remoteAuthType, ')
          ..write('remoteAuthHeaderName: $remoteAuthHeaderName, ')
          ..write('remoteStreamingEnabled: $remoteStreamingEnabled, ')
          ..write('remoteThinkingEffort: $remoteThinkingEffort, ')
          ..write('defaultSystemPrompt: $defaultSystemPrompt, ')
          ..write('localModelId: $localModelId, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ServiceAccountTableTable extends ServiceAccountTable
    with TableInfo<$ServiceAccountTableTable, ServiceAccountTableData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ServiceAccountTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  @override
  late final GeneratedColumnWithTypeConverter<ServiceProvider, String>
      provider = GeneratedColumn<String>('provider', aliasedName, false,
              type: DriftSqlType.string, requiredDuringInsert: true)
          .withConverter<ServiceProvider>(
              $ServiceAccountTableTable.$converterprovider);
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
      'name', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _descriptionMeta =
      const VerificationMeta('description');
  @override
  late final GeneratedColumn<String> description = GeneratedColumn<String>(
      'description', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant(''));
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  static const VerificationMeta _updatedAtMeta =
      const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
      'updated_at', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  @override
  List<GeneratedColumn> get $columns =>
      [id, provider, name, description, createdAt, updatedAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'service_account_table';
  @override
  VerificationContext validateIntegrity(
      Insertable<ServiceAccountTableData> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('name')) {
      context.handle(
          _nameMeta, name.isAcceptableOrUnknown(data['name']!, _nameMeta));
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('description')) {
      context.handle(
          _descriptionMeta,
          description.isAcceptableOrUnknown(
              data['description']!, _descriptionMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    }
    if (data.containsKey('updated_at')) {
      context.handle(_updatedAtMeta,
          updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ServiceAccountTableData map(Map<String, dynamic> data,
      {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ServiceAccountTableData(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      provider: $ServiceAccountTableTable.$converterprovider.fromSql(
          attachedDatabase.typeMapping
              .read(DriftSqlType.string, data['${effectivePrefix}provider'])!),
      name: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}name'])!,
      description: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}description'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}updated_at'])!,
    );
  }

  @override
  $ServiceAccountTableTable createAlias(String alias) {
    return $ServiceAccountTableTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<ServiceProvider, String, String>
      $converterprovider =
      const EnumNameConverter<ServiceProvider>(ServiceProvider.values);
}

class ServiceAccountTableData extends DataClass
    implements Insertable<ServiceAccountTableData> {
  /// Auto-incrementing primary key.
  final int id;

  /// Service provider type.
  final ServiceProvider provider;

  /// User-friendly name for this account.
  final String name;

  /// Optional description for this account.
  final String description;

  /// Timestamp when the record was created.
  final DateTime createdAt;

  /// Timestamp when the record was last updated.
  final DateTime updatedAt;
  const ServiceAccountTableData(
      {required this.id,
      required this.provider,
      required this.name,
      required this.description,
      required this.createdAt,
      required this.updatedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    {
      map['provider'] = Variable<String>(
          $ServiceAccountTableTable.$converterprovider.toSql(provider));
    }
    map['name'] = Variable<String>(name);
    map['description'] = Variable<String>(description);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  ServiceAccountTableCompanion toCompanion(bool nullToAbsent) {
    return ServiceAccountTableCompanion(
      id: Value(id),
      provider: Value(provider),
      name: Value(name),
      description: Value(description),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory ServiceAccountTableData.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ServiceAccountTableData(
      id: serializer.fromJson<int>(json['id']),
      provider: $ServiceAccountTableTable.$converterprovider
          .fromJson(serializer.fromJson<String>(json['provider'])),
      name: serializer.fromJson<String>(json['name']),
      description: serializer.fromJson<String>(json['description']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'provider': serializer.toJson<String>(
          $ServiceAccountTableTable.$converterprovider.toJson(provider)),
      'name': serializer.toJson<String>(name),
      'description': serializer.toJson<String>(description),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  ServiceAccountTableData copyWith(
          {int? id,
          ServiceProvider? provider,
          String? name,
          String? description,
          DateTime? createdAt,
          DateTime? updatedAt}) =>
      ServiceAccountTableData(
        id: id ?? this.id,
        provider: provider ?? this.provider,
        name: name ?? this.name,
        description: description ?? this.description,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
      );
  ServiceAccountTableData copyWithCompanion(ServiceAccountTableCompanion data) {
    return ServiceAccountTableData(
      id: data.id.present ? data.id.value : this.id,
      provider: data.provider.present ? data.provider.value : this.provider,
      name: data.name.present ? data.name.value : this.name,
      description:
          data.description.present ? data.description.value : this.description,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ServiceAccountTableData(')
          ..write('id: $id, ')
          ..write('provider: $provider, ')
          ..write('name: $name, ')
          ..write('description: $description, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, provider, name, description, createdAt, updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ServiceAccountTableData &&
          other.id == this.id &&
          other.provider == this.provider &&
          other.name == this.name &&
          other.description == this.description &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class ServiceAccountTableCompanion
    extends UpdateCompanion<ServiceAccountTableData> {
  final Value<int> id;
  final Value<ServiceProvider> provider;
  final Value<String> name;
  final Value<String> description;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  const ServiceAccountTableCompanion({
    this.id = const Value.absent(),
    this.provider = const Value.absent(),
    this.name = const Value.absent(),
    this.description = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
  });
  ServiceAccountTableCompanion.insert({
    this.id = const Value.absent(),
    required ServiceProvider provider,
    required String name,
    this.description = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
  })  : provider = Value(provider),
        name = Value(name);
  static Insertable<ServiceAccountTableData> custom({
    Expression<int>? id,
    Expression<String>? provider,
    Expression<String>? name,
    Expression<String>? description,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (provider != null) 'provider': provider,
      if (name != null) 'name': name,
      if (description != null) 'description': description,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
    });
  }

  ServiceAccountTableCompanion copyWith(
      {Value<int>? id,
      Value<ServiceProvider>? provider,
      Value<String>? name,
      Value<String>? description,
      Value<DateTime>? createdAt,
      Value<DateTime>? updatedAt}) {
    return ServiceAccountTableCompanion(
      id: id ?? this.id,
      provider: provider ?? this.provider,
      name: name ?? this.name,
      description: description ?? this.description,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (provider.present) {
      map['provider'] = Variable<String>(
          $ServiceAccountTableTable.$converterprovider.toSql(provider.value));
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (description.present) {
      map['description'] = Variable<String>(description.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ServiceAccountTableCompanion(')
          ..write('id: $id, ')
          ..write('provider: $provider, ')
          ..write('name: $name, ')
          ..write('description: $description, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }
}

class $MonitorHostTableTable extends MonitorHostTable
    with TableInfo<$MonitorHostTableTable, MonitorHostTableData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $MonitorHostTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _ipMeta = const VerificationMeta('ip');
  @override
  late final GeneratedColumn<String> ip = GeneratedColumn<String>(
      'ip', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _portMeta = const VerificationMeta('port');
  @override
  late final GeneratedColumn<int> port = GeneratedColumn<int>(
      'port', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _labelMeta = const VerificationMeta('label');
  @override
  late final GeneratedColumn<String> label = GeneratedColumn<String>(
      'label', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _isManualMeta =
      const VerificationMeta('isManual');
  @override
  late final GeneratedColumn<bool> isManual = GeneratedColumn<bool>(
      'is_manual', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("is_manual" IN (0, 1))'),
      defaultValue: const Constant(true));
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  @override
  List<GeneratedColumn> get $columns =>
      [id, ip, port, label, isManual, createdAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'monitor_host_table';
  @override
  VerificationContext validateIntegrity(
      Insertable<MonitorHostTableData> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('ip')) {
      context.handle(_ipMeta, ip.isAcceptableOrUnknown(data['ip']!, _ipMeta));
    } else if (isInserting) {
      context.missing(_ipMeta);
    }
    if (data.containsKey('port')) {
      context.handle(
          _portMeta, port.isAcceptableOrUnknown(data['port']!, _portMeta));
    } else if (isInserting) {
      context.missing(_portMeta);
    }
    if (data.containsKey('label')) {
      context.handle(
          _labelMeta, label.isAcceptableOrUnknown(data['label']!, _labelMeta));
    }
    if (data.containsKey('is_manual')) {
      context.handle(_isManualMeta,
          isManual.isAcceptableOrUnknown(data['is_manual']!, _isManualMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  MonitorHostTableData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return MonitorHostTableData(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      ip: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}ip'])!,
      port: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}port'])!,
      label: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}label']),
      isManual: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_manual'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
    );
  }

  @override
  $MonitorHostTableTable createAlias(String alias) {
    return $MonitorHostTableTable(attachedDatabase, alias);
  }
}

class MonitorHostTableData extends DataClass
    implements Insertable<MonitorHostTableData> {
  /// Primary key: "ip:port".
  final String id;

  /// IP address of the host.
  final String ip;

  /// Port number.
  final int port;

  /// Optional human-readable label.
  final String? label;

  /// Whether this host was added manually (vs discovered via mDNS).
  final bool isManual;

  /// Timestamp when the host was first added.
  final DateTime createdAt;
  const MonitorHostTableData(
      {required this.id,
      required this.ip,
      required this.port,
      this.label,
      required this.isManual,
      required this.createdAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['ip'] = Variable<String>(ip);
    map['port'] = Variable<int>(port);
    if (!nullToAbsent || label != null) {
      map['label'] = Variable<String>(label);
    }
    map['is_manual'] = Variable<bool>(isManual);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  MonitorHostTableCompanion toCompanion(bool nullToAbsent) {
    return MonitorHostTableCompanion(
      id: Value(id),
      ip: Value(ip),
      port: Value(port),
      label:
          label == null && nullToAbsent ? const Value.absent() : Value(label),
      isManual: Value(isManual),
      createdAt: Value(createdAt),
    );
  }

  factory MonitorHostTableData.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return MonitorHostTableData(
      id: serializer.fromJson<String>(json['id']),
      ip: serializer.fromJson<String>(json['ip']),
      port: serializer.fromJson<int>(json['port']),
      label: serializer.fromJson<String?>(json['label']),
      isManual: serializer.fromJson<bool>(json['isManual']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'ip': serializer.toJson<String>(ip),
      'port': serializer.toJson<int>(port),
      'label': serializer.toJson<String?>(label),
      'isManual': serializer.toJson<bool>(isManual),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  MonitorHostTableData copyWith(
          {String? id,
          String? ip,
          int? port,
          Value<String?> label = const Value.absent(),
          bool? isManual,
          DateTime? createdAt}) =>
      MonitorHostTableData(
        id: id ?? this.id,
        ip: ip ?? this.ip,
        port: port ?? this.port,
        label: label.present ? label.value : this.label,
        isManual: isManual ?? this.isManual,
        createdAt: createdAt ?? this.createdAt,
      );
  MonitorHostTableData copyWithCompanion(MonitorHostTableCompanion data) {
    return MonitorHostTableData(
      id: data.id.present ? data.id.value : this.id,
      ip: data.ip.present ? data.ip.value : this.ip,
      port: data.port.present ? data.port.value : this.port,
      label: data.label.present ? data.label.value : this.label,
      isManual: data.isManual.present ? data.isManual.value : this.isManual,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('MonitorHostTableData(')
          ..write('id: $id, ')
          ..write('ip: $ip, ')
          ..write('port: $port, ')
          ..write('label: $label, ')
          ..write('isManual: $isManual, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, ip, port, label, isManual, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is MonitorHostTableData &&
          other.id == this.id &&
          other.ip == this.ip &&
          other.port == this.port &&
          other.label == this.label &&
          other.isManual == this.isManual &&
          other.createdAt == this.createdAt);
}

class MonitorHostTableCompanion extends UpdateCompanion<MonitorHostTableData> {
  final Value<String> id;
  final Value<String> ip;
  final Value<int> port;
  final Value<String?> label;
  final Value<bool> isManual;
  final Value<DateTime> createdAt;
  final Value<int> rowid;
  const MonitorHostTableCompanion({
    this.id = const Value.absent(),
    this.ip = const Value.absent(),
    this.port = const Value.absent(),
    this.label = const Value.absent(),
    this.isManual = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  MonitorHostTableCompanion.insert({
    required String id,
    required String ip,
    required int port,
    this.label = const Value.absent(),
    this.isManual = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        ip = Value(ip),
        port = Value(port);
  static Insertable<MonitorHostTableData> custom({
    Expression<String>? id,
    Expression<String>? ip,
    Expression<int>? port,
    Expression<String>? label,
    Expression<bool>? isManual,
    Expression<DateTime>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (ip != null) 'ip': ip,
      if (port != null) 'port': port,
      if (label != null) 'label': label,
      if (isManual != null) 'is_manual': isManual,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  MonitorHostTableCompanion copyWith(
      {Value<String>? id,
      Value<String>? ip,
      Value<int>? port,
      Value<String?>? label,
      Value<bool>? isManual,
      Value<DateTime>? createdAt,
      Value<int>? rowid}) {
    return MonitorHostTableCompanion(
      id: id ?? this.id,
      ip: ip ?? this.ip,
      port: port ?? this.port,
      label: label ?? this.label,
      isManual: isManual ?? this.isManual,
      createdAt: createdAt ?? this.createdAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (ip.present) {
      map['ip'] = Variable<String>(ip.value);
    }
    if (port.present) {
      map['port'] = Variable<int>(port.value);
    }
    if (label.present) {
      map['label'] = Variable<String>(label.value);
    }
    if (isManual.present) {
      map['is_manual'] = Variable<bool>(isManual.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('MonitorHostTableCompanion(')
          ..write('id: $id, ')
          ..write('ip: $ip, ')
          ..write('port: $port, ')
          ..write('label: $label, ')
          ..write('isManual: $isManual, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $MonitorTrustedCertTableTable extends MonitorTrustedCertTable
    with TableInfo<$MonitorTrustedCertTableTable, MonitorTrustedCertTableData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $MonitorTrustedCertTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _hostIdMeta = const VerificationMeta('hostId');
  @override
  late final GeneratedColumn<String> hostId = GeneratedColumn<String>(
      'host_id', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: true,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'REFERENCES monitor_host_table (id)'));
  static const VerificationMeta _fingerprintMeta =
      const VerificationMeta('fingerprint');
  @override
  late final GeneratedColumn<String> fingerprint = GeneratedColumn<String>(
      'fingerprint', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _firstTrustedAtMeta =
      const VerificationMeta('firstTrustedAt');
  @override
  late final GeneratedColumn<DateTime> firstTrustedAt =
      GeneratedColumn<DateTime>('first_trusted_at', aliasedName, false,
          type: DriftSqlType.dateTime,
          requiredDuringInsert: false,
          defaultValue: currentDateAndTime);
  static const VerificationMeta _lastVerifiedAtMeta =
      const VerificationMeta('lastVerifiedAt');
  @override
  late final GeneratedColumn<DateTime> lastVerifiedAt =
      GeneratedColumn<DateTime>('last_verified_at', aliasedName, false,
          type: DriftSqlType.dateTime,
          requiredDuringInsert: false,
          defaultValue: currentDateAndTime);
  @override
  List<GeneratedColumn> get $columns =>
      [hostId, fingerprint, firstTrustedAt, lastVerifiedAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'monitor_trusted_cert_table';
  @override
  VerificationContext validateIntegrity(
      Insertable<MonitorTrustedCertTableData> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('host_id')) {
      context.handle(_hostIdMeta,
          hostId.isAcceptableOrUnknown(data['host_id']!, _hostIdMeta));
    } else if (isInserting) {
      context.missing(_hostIdMeta);
    }
    if (data.containsKey('fingerprint')) {
      context.handle(
          _fingerprintMeta,
          fingerprint.isAcceptableOrUnknown(
              data['fingerprint']!, _fingerprintMeta));
    } else if (isInserting) {
      context.missing(_fingerprintMeta);
    }
    if (data.containsKey('first_trusted_at')) {
      context.handle(
          _firstTrustedAtMeta,
          firstTrustedAt.isAcceptableOrUnknown(
              data['first_trusted_at']!, _firstTrustedAtMeta));
    }
    if (data.containsKey('last_verified_at')) {
      context.handle(
          _lastVerifiedAtMeta,
          lastVerifiedAt.isAcceptableOrUnknown(
              data['last_verified_at']!, _lastVerifiedAtMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {hostId};
  @override
  MonitorTrustedCertTableData map(Map<String, dynamic> data,
      {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return MonitorTrustedCertTableData(
      hostId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}host_id'])!,
      fingerprint: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}fingerprint'])!,
      firstTrustedAt: attachedDatabase.typeMapping.read(
          DriftSqlType.dateTime, data['${effectivePrefix}first_trusted_at'])!,
      lastVerifiedAt: attachedDatabase.typeMapping.read(
          DriftSqlType.dateTime, data['${effectivePrefix}last_verified_at'])!,
    );
  }

  @override
  $MonitorTrustedCertTableTable createAlias(String alias) {
    return $MonitorTrustedCertTableTable(attachedDatabase, alias);
  }
}

class MonitorTrustedCertTableData extends DataClass
    implements Insertable<MonitorTrustedCertTableData> {
  /// Foreign key referencing [MonitorHostTable.id].
  final String hostId;

  /// SHA-256 fingerprint of the pinned certificate.
  final String fingerprint;

  /// When the fingerprint was first trusted.
  final DateTime firstTrustedAt;

  /// When the fingerprint was last verified against a live connection.
  final DateTime lastVerifiedAt;
  const MonitorTrustedCertTableData(
      {required this.hostId,
      required this.fingerprint,
      required this.firstTrustedAt,
      required this.lastVerifiedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['host_id'] = Variable<String>(hostId);
    map['fingerprint'] = Variable<String>(fingerprint);
    map['first_trusted_at'] = Variable<DateTime>(firstTrustedAt);
    map['last_verified_at'] = Variable<DateTime>(lastVerifiedAt);
    return map;
  }

  MonitorTrustedCertTableCompanion toCompanion(bool nullToAbsent) {
    return MonitorTrustedCertTableCompanion(
      hostId: Value(hostId),
      fingerprint: Value(fingerprint),
      firstTrustedAt: Value(firstTrustedAt),
      lastVerifiedAt: Value(lastVerifiedAt),
    );
  }

  factory MonitorTrustedCertTableData.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return MonitorTrustedCertTableData(
      hostId: serializer.fromJson<String>(json['hostId']),
      fingerprint: serializer.fromJson<String>(json['fingerprint']),
      firstTrustedAt: serializer.fromJson<DateTime>(json['firstTrustedAt']),
      lastVerifiedAt: serializer.fromJson<DateTime>(json['lastVerifiedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'hostId': serializer.toJson<String>(hostId),
      'fingerprint': serializer.toJson<String>(fingerprint),
      'firstTrustedAt': serializer.toJson<DateTime>(firstTrustedAt),
      'lastVerifiedAt': serializer.toJson<DateTime>(lastVerifiedAt),
    };
  }

  MonitorTrustedCertTableData copyWith(
          {String? hostId,
          String? fingerprint,
          DateTime? firstTrustedAt,
          DateTime? lastVerifiedAt}) =>
      MonitorTrustedCertTableData(
        hostId: hostId ?? this.hostId,
        fingerprint: fingerprint ?? this.fingerprint,
        firstTrustedAt: firstTrustedAt ?? this.firstTrustedAt,
        lastVerifiedAt: lastVerifiedAt ?? this.lastVerifiedAt,
      );
  MonitorTrustedCertTableData copyWithCompanion(
      MonitorTrustedCertTableCompanion data) {
    return MonitorTrustedCertTableData(
      hostId: data.hostId.present ? data.hostId.value : this.hostId,
      fingerprint:
          data.fingerprint.present ? data.fingerprint.value : this.fingerprint,
      firstTrustedAt: data.firstTrustedAt.present
          ? data.firstTrustedAt.value
          : this.firstTrustedAt,
      lastVerifiedAt: data.lastVerifiedAt.present
          ? data.lastVerifiedAt.value
          : this.lastVerifiedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('MonitorTrustedCertTableData(')
          ..write('hostId: $hostId, ')
          ..write('fingerprint: $fingerprint, ')
          ..write('firstTrustedAt: $firstTrustedAt, ')
          ..write('lastVerifiedAt: $lastVerifiedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(hostId, fingerprint, firstTrustedAt, lastVerifiedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is MonitorTrustedCertTableData &&
          other.hostId == this.hostId &&
          other.fingerprint == this.fingerprint &&
          other.firstTrustedAt == this.firstTrustedAt &&
          other.lastVerifiedAt == this.lastVerifiedAt);
}

class MonitorTrustedCertTableCompanion
    extends UpdateCompanion<MonitorTrustedCertTableData> {
  final Value<String> hostId;
  final Value<String> fingerprint;
  final Value<DateTime> firstTrustedAt;
  final Value<DateTime> lastVerifiedAt;
  final Value<int> rowid;
  const MonitorTrustedCertTableCompanion({
    this.hostId = const Value.absent(),
    this.fingerprint = const Value.absent(),
    this.firstTrustedAt = const Value.absent(),
    this.lastVerifiedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  MonitorTrustedCertTableCompanion.insert({
    required String hostId,
    required String fingerprint,
    this.firstTrustedAt = const Value.absent(),
    this.lastVerifiedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : hostId = Value(hostId),
        fingerprint = Value(fingerprint);
  static Insertable<MonitorTrustedCertTableData> custom({
    Expression<String>? hostId,
    Expression<String>? fingerprint,
    Expression<DateTime>? firstTrustedAt,
    Expression<DateTime>? lastVerifiedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (hostId != null) 'host_id': hostId,
      if (fingerprint != null) 'fingerprint': fingerprint,
      if (firstTrustedAt != null) 'first_trusted_at': firstTrustedAt,
      if (lastVerifiedAt != null) 'last_verified_at': lastVerifiedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  MonitorTrustedCertTableCompanion copyWith(
      {Value<String>? hostId,
      Value<String>? fingerprint,
      Value<DateTime>? firstTrustedAt,
      Value<DateTime>? lastVerifiedAt,
      Value<int>? rowid}) {
    return MonitorTrustedCertTableCompanion(
      hostId: hostId ?? this.hostId,
      fingerprint: fingerprint ?? this.fingerprint,
      firstTrustedAt: firstTrustedAt ?? this.firstTrustedAt,
      lastVerifiedAt: lastVerifiedAt ?? this.lastVerifiedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (hostId.present) {
      map['host_id'] = Variable<String>(hostId.value);
    }
    if (fingerprint.present) {
      map['fingerprint'] = Variable<String>(fingerprint.value);
    }
    if (firstTrustedAt.present) {
      map['first_trusted_at'] = Variable<DateTime>(firstTrustedAt.value);
    }
    if (lastVerifiedAt.present) {
      map['last_verified_at'] = Variable<DateTime>(lastVerifiedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('MonitorTrustedCertTableCompanion(')
          ..write('hostId: $hostId, ')
          ..write('fingerprint: $fingerprint, ')
          ..write('firstTrustedAt: $firstTrustedAt, ')
          ..write('lastVerifiedAt: $lastVerifiedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $TtsDatasetProjectTableTable extends TtsDatasetProjectTable
    with TableInfo<$TtsDatasetProjectTableTable, TtsDatasetProjectTableData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TtsDatasetProjectTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
      'name', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _targetProfileMeta =
      const VerificationMeta('targetProfile');
  @override
  late final GeneratedColumn<String> targetProfile = GeneratedColumn<String>(
      'target_profile', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _languageMeta =
      const VerificationMeta('language');
  @override
  late final GeneratedColumn<String> language = GeneratedColumn<String>(
      'language', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _speakerIdMeta =
      const VerificationMeta('speakerId');
  @override
  late final GeneratedColumn<String> speakerId = GeneratedColumn<String>(
      'speaker_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _rootPathMeta =
      const VerificationMeta('rootPath');
  @override
  late final GeneratedColumn<String> rootPath = GeneratedColumn<String>(
      'root_path', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
      'status', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  static const VerificationMeta _updatedAtMeta =
      const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
      'updated_at', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        name,
        targetProfile,
        language,
        speakerId,
        rootPath,
        status,
        createdAt,
        updatedAt
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'tts_dataset_project_table';
  @override
  VerificationContext validateIntegrity(
      Insertable<TtsDatasetProjectTableData> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
          _nameMeta, name.isAcceptableOrUnknown(data['name']!, _nameMeta));
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('target_profile')) {
      context.handle(
          _targetProfileMeta,
          targetProfile.isAcceptableOrUnknown(
              data['target_profile']!, _targetProfileMeta));
    } else if (isInserting) {
      context.missing(_targetProfileMeta);
    }
    if (data.containsKey('language')) {
      context.handle(_languageMeta,
          language.isAcceptableOrUnknown(data['language']!, _languageMeta));
    } else if (isInserting) {
      context.missing(_languageMeta);
    }
    if (data.containsKey('speaker_id')) {
      context.handle(_speakerIdMeta,
          speakerId.isAcceptableOrUnknown(data['speaker_id']!, _speakerIdMeta));
    } else if (isInserting) {
      context.missing(_speakerIdMeta);
    }
    if (data.containsKey('root_path')) {
      context.handle(_rootPathMeta,
          rootPath.isAcceptableOrUnknown(data['root_path']!, _rootPathMeta));
    } else if (isInserting) {
      context.missing(_rootPathMeta);
    }
    if (data.containsKey('status')) {
      context.handle(_statusMeta,
          status.isAcceptableOrUnknown(data['status']!, _statusMeta));
    } else if (isInserting) {
      context.missing(_statusMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    }
    if (data.containsKey('updated_at')) {
      context.handle(_updatedAtMeta,
          updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  TtsDatasetProjectTableData map(Map<String, dynamic> data,
      {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return TtsDatasetProjectTableData(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      name: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}name'])!,
      targetProfile: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}target_profile'])!,
      language: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}language'])!,
      speakerId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}speaker_id'])!,
      rootPath: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}root_path'])!,
      status: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}status'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}updated_at'])!,
    );
  }

  @override
  $TtsDatasetProjectTableTable createAlias(String alias) {
    return $TtsDatasetProjectTableTable(attachedDatabase, alias);
  }
}

class TtsDatasetProjectTableData extends DataClass
    implements Insertable<TtsDatasetProjectTableData> {
  /// Primary key.
  final String id;

  /// Display name of the dataset project.
  final String name;

  /// Export target profile, such as qwen3_tts_12hz_raw.
  final String targetProfile;

  /// Dataset language label.
  final String language;

  /// Primary speaker id for the single-speaker MVP.
  final String speakerId;

  /// Local project root path.
  final String rootPath;

  /// Project lifecycle status.
  final String status;

  /// Timestamp when the project was created.
  final DateTime createdAt;

  /// Timestamp when the project was last updated.
  final DateTime updatedAt;
  const TtsDatasetProjectTableData(
      {required this.id,
      required this.name,
      required this.targetProfile,
      required this.language,
      required this.speakerId,
      required this.rootPath,
      required this.status,
      required this.createdAt,
      required this.updatedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['name'] = Variable<String>(name);
    map['target_profile'] = Variable<String>(targetProfile);
    map['language'] = Variable<String>(language);
    map['speaker_id'] = Variable<String>(speakerId);
    map['root_path'] = Variable<String>(rootPath);
    map['status'] = Variable<String>(status);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  TtsDatasetProjectTableCompanion toCompanion(bool nullToAbsent) {
    return TtsDatasetProjectTableCompanion(
      id: Value(id),
      name: Value(name),
      targetProfile: Value(targetProfile),
      language: Value(language),
      speakerId: Value(speakerId),
      rootPath: Value(rootPath),
      status: Value(status),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory TtsDatasetProjectTableData.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return TtsDatasetProjectTableData(
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      targetProfile: serializer.fromJson<String>(json['targetProfile']),
      language: serializer.fromJson<String>(json['language']),
      speakerId: serializer.fromJson<String>(json['speakerId']),
      rootPath: serializer.fromJson<String>(json['rootPath']),
      status: serializer.fromJson<String>(json['status']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'name': serializer.toJson<String>(name),
      'targetProfile': serializer.toJson<String>(targetProfile),
      'language': serializer.toJson<String>(language),
      'speakerId': serializer.toJson<String>(speakerId),
      'rootPath': serializer.toJson<String>(rootPath),
      'status': serializer.toJson<String>(status),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  TtsDatasetProjectTableData copyWith(
          {String? id,
          String? name,
          String? targetProfile,
          String? language,
          String? speakerId,
          String? rootPath,
          String? status,
          DateTime? createdAt,
          DateTime? updatedAt}) =>
      TtsDatasetProjectTableData(
        id: id ?? this.id,
        name: name ?? this.name,
        targetProfile: targetProfile ?? this.targetProfile,
        language: language ?? this.language,
        speakerId: speakerId ?? this.speakerId,
        rootPath: rootPath ?? this.rootPath,
        status: status ?? this.status,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
      );
  TtsDatasetProjectTableData copyWithCompanion(
      TtsDatasetProjectTableCompanion data) {
    return TtsDatasetProjectTableData(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      targetProfile: data.targetProfile.present
          ? data.targetProfile.value
          : this.targetProfile,
      language: data.language.present ? data.language.value : this.language,
      speakerId: data.speakerId.present ? data.speakerId.value : this.speakerId,
      rootPath: data.rootPath.present ? data.rootPath.value : this.rootPath,
      status: data.status.present ? data.status.value : this.status,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('TtsDatasetProjectTableData(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('targetProfile: $targetProfile, ')
          ..write('language: $language, ')
          ..write('speakerId: $speakerId, ')
          ..write('rootPath: $rootPath, ')
          ..write('status: $status, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, name, targetProfile, language, speakerId,
      rootPath, status, createdAt, updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is TtsDatasetProjectTableData &&
          other.id == this.id &&
          other.name == this.name &&
          other.targetProfile == this.targetProfile &&
          other.language == this.language &&
          other.speakerId == this.speakerId &&
          other.rootPath == this.rootPath &&
          other.status == this.status &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class TtsDatasetProjectTableCompanion
    extends UpdateCompanion<TtsDatasetProjectTableData> {
  final Value<String> id;
  final Value<String> name;
  final Value<String> targetProfile;
  final Value<String> language;
  final Value<String> speakerId;
  final Value<String> rootPath;
  final Value<String> status;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const TtsDatasetProjectTableCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.targetProfile = const Value.absent(),
    this.language = const Value.absent(),
    this.speakerId = const Value.absent(),
    this.rootPath = const Value.absent(),
    this.status = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  TtsDatasetProjectTableCompanion.insert({
    required String id,
    required String name,
    required String targetProfile,
    required String language,
    required String speakerId,
    required String rootPath,
    required String status,
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        name = Value(name),
        targetProfile = Value(targetProfile),
        language = Value(language),
        speakerId = Value(speakerId),
        rootPath = Value(rootPath),
        status = Value(status);
  static Insertable<TtsDatasetProjectTableData> custom({
    Expression<String>? id,
    Expression<String>? name,
    Expression<String>? targetProfile,
    Expression<String>? language,
    Expression<String>? speakerId,
    Expression<String>? rootPath,
    Expression<String>? status,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (targetProfile != null) 'target_profile': targetProfile,
      if (language != null) 'language': language,
      if (speakerId != null) 'speaker_id': speakerId,
      if (rootPath != null) 'root_path': rootPath,
      if (status != null) 'status': status,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  TtsDatasetProjectTableCompanion copyWith(
      {Value<String>? id,
      Value<String>? name,
      Value<String>? targetProfile,
      Value<String>? language,
      Value<String>? speakerId,
      Value<String>? rootPath,
      Value<String>? status,
      Value<DateTime>? createdAt,
      Value<DateTime>? updatedAt,
      Value<int>? rowid}) {
    return TtsDatasetProjectTableCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      targetProfile: targetProfile ?? this.targetProfile,
      language: language ?? this.language,
      speakerId: speakerId ?? this.speakerId,
      rootPath: rootPath ?? this.rootPath,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (targetProfile.present) {
      map['target_profile'] = Variable<String>(targetProfile.value);
    }
    if (language.present) {
      map['language'] = Variable<String>(language.value);
    }
    if (speakerId.present) {
      map['speaker_id'] = Variable<String>(speakerId.value);
    }
    if (rootPath.present) {
      map['root_path'] = Variable<String>(rootPath.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TtsDatasetProjectTableCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('targetProfile: $targetProfile, ')
          ..write('language: $language, ')
          ..write('speakerId: $speakerId, ')
          ..write('rootPath: $rootPath, ')
          ..write('status: $status, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $TtsDatasetSpeakerTableTable extends TtsDatasetSpeakerTable
    with TableInfo<$TtsDatasetSpeakerTableTable, TtsDatasetSpeakerTableData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TtsDatasetSpeakerTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _projectIdMeta =
      const VerificationMeta('projectId');
  @override
  late final GeneratedColumn<String> projectId = GeneratedColumn<String>(
      'project_id', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: true,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'REFERENCES tts_dataset_project_table (id)'));
  static const VerificationMeta _displayNameMeta =
      const VerificationMeta('displayName');
  @override
  late final GeneratedColumn<String> displayName = GeneratedColumn<String>(
      'display_name', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _consentStatusMeta =
      const VerificationMeta('consentStatus');
  @override
  late final GeneratedColumn<String> consentStatus = GeneratedColumn<String>(
      'consent_status', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _allowedUseMeta =
      const VerificationMeta('allowedUse');
  @override
  late final GeneratedColumn<String> allowedUse = GeneratedColumn<String>(
      'allowed_use', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _datasetLicenseMeta =
      const VerificationMeta('datasetLicense');
  @override
  late final GeneratedColumn<String> datasetLicense = GeneratedColumn<String>(
      'dataset_license', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _consentDocumentPathMeta =
      const VerificationMeta('consentDocumentPath');
  @override
  late final GeneratedColumn<String> consentDocumentPath =
      GeneratedColumn<String>('consent_document_path', aliasedName, true,
          type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _referenceClipIdMeta =
      const VerificationMeta('referenceClipId');
  @override
  late final GeneratedColumn<String> referenceClipId = GeneratedColumn<String>(
      'reference_clip_id', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  static const VerificationMeta _updatedAtMeta =
      const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
      'updated_at', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        projectId,
        displayName,
        consentStatus,
        allowedUse,
        datasetLicense,
        consentDocumentPath,
        referenceClipId,
        createdAt,
        updatedAt
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'tts_dataset_speaker_table';
  @override
  VerificationContext validateIntegrity(
      Insertable<TtsDatasetSpeakerTableData> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('project_id')) {
      context.handle(_projectIdMeta,
          projectId.isAcceptableOrUnknown(data['project_id']!, _projectIdMeta));
    } else if (isInserting) {
      context.missing(_projectIdMeta);
    }
    if (data.containsKey('display_name')) {
      context.handle(
          _displayNameMeta,
          displayName.isAcceptableOrUnknown(
              data['display_name']!, _displayNameMeta));
    } else if (isInserting) {
      context.missing(_displayNameMeta);
    }
    if (data.containsKey('consent_status')) {
      context.handle(
          _consentStatusMeta,
          consentStatus.isAcceptableOrUnknown(
              data['consent_status']!, _consentStatusMeta));
    } else if (isInserting) {
      context.missing(_consentStatusMeta);
    }
    if (data.containsKey('allowed_use')) {
      context.handle(
          _allowedUseMeta,
          allowedUse.isAcceptableOrUnknown(
              data['allowed_use']!, _allowedUseMeta));
    } else if (isInserting) {
      context.missing(_allowedUseMeta);
    }
    if (data.containsKey('dataset_license')) {
      context.handle(
          _datasetLicenseMeta,
          datasetLicense.isAcceptableOrUnknown(
              data['dataset_license']!, _datasetLicenseMeta));
    } else if (isInserting) {
      context.missing(_datasetLicenseMeta);
    }
    if (data.containsKey('consent_document_path')) {
      context.handle(
          _consentDocumentPathMeta,
          consentDocumentPath.isAcceptableOrUnknown(
              data['consent_document_path']!, _consentDocumentPathMeta));
    }
    if (data.containsKey('reference_clip_id')) {
      context.handle(
          _referenceClipIdMeta,
          referenceClipId.isAcceptableOrUnknown(
              data['reference_clip_id']!, _referenceClipIdMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    }
    if (data.containsKey('updated_at')) {
      context.handle(_updatedAtMeta,
          updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  TtsDatasetSpeakerTableData map(Map<String, dynamic> data,
      {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return TtsDatasetSpeakerTableData(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      projectId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}project_id'])!,
      displayName: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}display_name'])!,
      consentStatus: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}consent_status'])!,
      allowedUse: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}allowed_use'])!,
      datasetLicense: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}dataset_license'])!,
      consentDocumentPath: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}consent_document_path']),
      referenceClipId: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}reference_clip_id']),
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}updated_at'])!,
    );
  }

  @override
  $TtsDatasetSpeakerTableTable createAlias(String alias) {
    return $TtsDatasetSpeakerTableTable(attachedDatabase, alias);
  }
}

class TtsDatasetSpeakerTableData extends DataClass
    implements Insertable<TtsDatasetSpeakerTableData> {
  /// Primary key.
  final String id;

  /// Owning dataset project.
  final String projectId;

  /// Human-readable speaker name.
  final String displayName;

  /// Consent status: pending, granted, or revoked.
  final String consentStatus;

  /// Allowed use category, such as fine_tune_tts.
  final String allowedUse;

  /// Dataset license label.
  final String datasetLicense;

  /// Optional local consent document path.
  final String? consentDocumentPath;

  /// Selected reference clip id.
  final String? referenceClipId;

  /// Timestamp when the speaker profile was created.
  final DateTime createdAt;

  /// Timestamp when the speaker profile was last updated.
  final DateTime updatedAt;
  const TtsDatasetSpeakerTableData(
      {required this.id,
      required this.projectId,
      required this.displayName,
      required this.consentStatus,
      required this.allowedUse,
      required this.datasetLicense,
      this.consentDocumentPath,
      this.referenceClipId,
      required this.createdAt,
      required this.updatedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['project_id'] = Variable<String>(projectId);
    map['display_name'] = Variable<String>(displayName);
    map['consent_status'] = Variable<String>(consentStatus);
    map['allowed_use'] = Variable<String>(allowedUse);
    map['dataset_license'] = Variable<String>(datasetLicense);
    if (!nullToAbsent || consentDocumentPath != null) {
      map['consent_document_path'] = Variable<String>(consentDocumentPath);
    }
    if (!nullToAbsent || referenceClipId != null) {
      map['reference_clip_id'] = Variable<String>(referenceClipId);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  TtsDatasetSpeakerTableCompanion toCompanion(bool nullToAbsent) {
    return TtsDatasetSpeakerTableCompanion(
      id: Value(id),
      projectId: Value(projectId),
      displayName: Value(displayName),
      consentStatus: Value(consentStatus),
      allowedUse: Value(allowedUse),
      datasetLicense: Value(datasetLicense),
      consentDocumentPath: consentDocumentPath == null && nullToAbsent
          ? const Value.absent()
          : Value(consentDocumentPath),
      referenceClipId: referenceClipId == null && nullToAbsent
          ? const Value.absent()
          : Value(referenceClipId),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory TtsDatasetSpeakerTableData.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return TtsDatasetSpeakerTableData(
      id: serializer.fromJson<String>(json['id']),
      projectId: serializer.fromJson<String>(json['projectId']),
      displayName: serializer.fromJson<String>(json['displayName']),
      consentStatus: serializer.fromJson<String>(json['consentStatus']),
      allowedUse: serializer.fromJson<String>(json['allowedUse']),
      datasetLicense: serializer.fromJson<String>(json['datasetLicense']),
      consentDocumentPath:
          serializer.fromJson<String?>(json['consentDocumentPath']),
      referenceClipId: serializer.fromJson<String?>(json['referenceClipId']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'projectId': serializer.toJson<String>(projectId),
      'displayName': serializer.toJson<String>(displayName),
      'consentStatus': serializer.toJson<String>(consentStatus),
      'allowedUse': serializer.toJson<String>(allowedUse),
      'datasetLicense': serializer.toJson<String>(datasetLicense),
      'consentDocumentPath': serializer.toJson<String?>(consentDocumentPath),
      'referenceClipId': serializer.toJson<String?>(referenceClipId),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  TtsDatasetSpeakerTableData copyWith(
          {String? id,
          String? projectId,
          String? displayName,
          String? consentStatus,
          String? allowedUse,
          String? datasetLicense,
          Value<String?> consentDocumentPath = const Value.absent(),
          Value<String?> referenceClipId = const Value.absent(),
          DateTime? createdAt,
          DateTime? updatedAt}) =>
      TtsDatasetSpeakerTableData(
        id: id ?? this.id,
        projectId: projectId ?? this.projectId,
        displayName: displayName ?? this.displayName,
        consentStatus: consentStatus ?? this.consentStatus,
        allowedUse: allowedUse ?? this.allowedUse,
        datasetLicense: datasetLicense ?? this.datasetLicense,
        consentDocumentPath: consentDocumentPath.present
            ? consentDocumentPath.value
            : this.consentDocumentPath,
        referenceClipId: referenceClipId.present
            ? referenceClipId.value
            : this.referenceClipId,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
      );
  TtsDatasetSpeakerTableData copyWithCompanion(
      TtsDatasetSpeakerTableCompanion data) {
    return TtsDatasetSpeakerTableData(
      id: data.id.present ? data.id.value : this.id,
      projectId: data.projectId.present ? data.projectId.value : this.projectId,
      displayName:
          data.displayName.present ? data.displayName.value : this.displayName,
      consentStatus: data.consentStatus.present
          ? data.consentStatus.value
          : this.consentStatus,
      allowedUse:
          data.allowedUse.present ? data.allowedUse.value : this.allowedUse,
      datasetLicense: data.datasetLicense.present
          ? data.datasetLicense.value
          : this.datasetLicense,
      consentDocumentPath: data.consentDocumentPath.present
          ? data.consentDocumentPath.value
          : this.consentDocumentPath,
      referenceClipId: data.referenceClipId.present
          ? data.referenceClipId.value
          : this.referenceClipId,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('TtsDatasetSpeakerTableData(')
          ..write('id: $id, ')
          ..write('projectId: $projectId, ')
          ..write('displayName: $displayName, ')
          ..write('consentStatus: $consentStatus, ')
          ..write('allowedUse: $allowedUse, ')
          ..write('datasetLicense: $datasetLicense, ')
          ..write('consentDocumentPath: $consentDocumentPath, ')
          ..write('referenceClipId: $referenceClipId, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id,
      projectId,
      displayName,
      consentStatus,
      allowedUse,
      datasetLicense,
      consentDocumentPath,
      referenceClipId,
      createdAt,
      updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is TtsDatasetSpeakerTableData &&
          other.id == this.id &&
          other.projectId == this.projectId &&
          other.displayName == this.displayName &&
          other.consentStatus == this.consentStatus &&
          other.allowedUse == this.allowedUse &&
          other.datasetLicense == this.datasetLicense &&
          other.consentDocumentPath == this.consentDocumentPath &&
          other.referenceClipId == this.referenceClipId &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class TtsDatasetSpeakerTableCompanion
    extends UpdateCompanion<TtsDatasetSpeakerTableData> {
  final Value<String> id;
  final Value<String> projectId;
  final Value<String> displayName;
  final Value<String> consentStatus;
  final Value<String> allowedUse;
  final Value<String> datasetLicense;
  final Value<String?> consentDocumentPath;
  final Value<String?> referenceClipId;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const TtsDatasetSpeakerTableCompanion({
    this.id = const Value.absent(),
    this.projectId = const Value.absent(),
    this.displayName = const Value.absent(),
    this.consentStatus = const Value.absent(),
    this.allowedUse = const Value.absent(),
    this.datasetLicense = const Value.absent(),
    this.consentDocumentPath = const Value.absent(),
    this.referenceClipId = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  TtsDatasetSpeakerTableCompanion.insert({
    required String id,
    required String projectId,
    required String displayName,
    required String consentStatus,
    required String allowedUse,
    required String datasetLicense,
    this.consentDocumentPath = const Value.absent(),
    this.referenceClipId = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        projectId = Value(projectId),
        displayName = Value(displayName),
        consentStatus = Value(consentStatus),
        allowedUse = Value(allowedUse),
        datasetLicense = Value(datasetLicense);
  static Insertable<TtsDatasetSpeakerTableData> custom({
    Expression<String>? id,
    Expression<String>? projectId,
    Expression<String>? displayName,
    Expression<String>? consentStatus,
    Expression<String>? allowedUse,
    Expression<String>? datasetLicense,
    Expression<String>? consentDocumentPath,
    Expression<String>? referenceClipId,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (projectId != null) 'project_id': projectId,
      if (displayName != null) 'display_name': displayName,
      if (consentStatus != null) 'consent_status': consentStatus,
      if (allowedUse != null) 'allowed_use': allowedUse,
      if (datasetLicense != null) 'dataset_license': datasetLicense,
      if (consentDocumentPath != null)
        'consent_document_path': consentDocumentPath,
      if (referenceClipId != null) 'reference_clip_id': referenceClipId,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  TtsDatasetSpeakerTableCompanion copyWith(
      {Value<String>? id,
      Value<String>? projectId,
      Value<String>? displayName,
      Value<String>? consentStatus,
      Value<String>? allowedUse,
      Value<String>? datasetLicense,
      Value<String?>? consentDocumentPath,
      Value<String?>? referenceClipId,
      Value<DateTime>? createdAt,
      Value<DateTime>? updatedAt,
      Value<int>? rowid}) {
    return TtsDatasetSpeakerTableCompanion(
      id: id ?? this.id,
      projectId: projectId ?? this.projectId,
      displayName: displayName ?? this.displayName,
      consentStatus: consentStatus ?? this.consentStatus,
      allowedUse: allowedUse ?? this.allowedUse,
      datasetLicense: datasetLicense ?? this.datasetLicense,
      consentDocumentPath: consentDocumentPath ?? this.consentDocumentPath,
      referenceClipId: referenceClipId ?? this.referenceClipId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (projectId.present) {
      map['project_id'] = Variable<String>(projectId.value);
    }
    if (displayName.present) {
      map['display_name'] = Variable<String>(displayName.value);
    }
    if (consentStatus.present) {
      map['consent_status'] = Variable<String>(consentStatus.value);
    }
    if (allowedUse.present) {
      map['allowed_use'] = Variable<String>(allowedUse.value);
    }
    if (datasetLicense.present) {
      map['dataset_license'] = Variable<String>(datasetLicense.value);
    }
    if (consentDocumentPath.present) {
      map['consent_document_path'] =
          Variable<String>(consentDocumentPath.value);
    }
    if (referenceClipId.present) {
      map['reference_clip_id'] = Variable<String>(referenceClipId.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TtsDatasetSpeakerTableCompanion(')
          ..write('id: $id, ')
          ..write('projectId: $projectId, ')
          ..write('displayName: $displayName, ')
          ..write('consentStatus: $consentStatus, ')
          ..write('allowedUse: $allowedUse, ')
          ..write('datasetLicense: $datasetLicense, ')
          ..write('consentDocumentPath: $consentDocumentPath, ')
          ..write('referenceClipId: $referenceClipId, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $TtsDatasetPromptTableTable extends TtsDatasetPromptTable
    with TableInfo<$TtsDatasetPromptTableTable, TtsDatasetPromptTableData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TtsDatasetPromptTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _projectIdMeta =
      const VerificationMeta('projectId');
  @override
  late final GeneratedColumn<String> projectId = GeneratedColumn<String>(
      'project_id', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: true,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'REFERENCES tts_dataset_project_table (id)'));
  static const VerificationMeta _rawTextMeta =
      const VerificationMeta('rawText');
  @override
  late final GeneratedColumn<String> rawText = GeneratedColumn<String>(
      'raw_text', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _normalizedTextMeta =
      const VerificationMeta('normalizedText');
  @override
  late final GeneratedColumn<String> normalizedText = GeneratedColumn<String>(
      'normalized_text', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _languageMeta =
      const VerificationMeta('language');
  @override
  late final GeneratedColumn<String> language = GeneratedColumn<String>(
      'language', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  @override
  late final GeneratedColumnWithTypeConverter<List<String>, String> tags =
      GeneratedColumn<String>('tags', aliasedName, false,
              type: DriftSqlType.string, requiredDuringInsert: true)
          .withConverter<List<String>>(
              $TtsDatasetPromptTableTable.$convertertags);
  static const VerificationMeta _sortOrderMeta =
      const VerificationMeta('sortOrder');
  @override
  late final GeneratedColumn<int> sortOrder = GeneratedColumn<int>(
      'sort_order', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
      'status', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  static const VerificationMeta _updatedAtMeta =
      const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
      'updated_at', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        projectId,
        rawText,
        normalizedText,
        language,
        tags,
        sortOrder,
        status,
        createdAt,
        updatedAt
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'tts_dataset_prompt_table';
  @override
  VerificationContext validateIntegrity(
      Insertable<TtsDatasetPromptTableData> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('project_id')) {
      context.handle(_projectIdMeta,
          projectId.isAcceptableOrUnknown(data['project_id']!, _projectIdMeta));
    } else if (isInserting) {
      context.missing(_projectIdMeta);
    }
    if (data.containsKey('raw_text')) {
      context.handle(_rawTextMeta,
          rawText.isAcceptableOrUnknown(data['raw_text']!, _rawTextMeta));
    } else if (isInserting) {
      context.missing(_rawTextMeta);
    }
    if (data.containsKey('normalized_text')) {
      context.handle(
          _normalizedTextMeta,
          normalizedText.isAcceptableOrUnknown(
              data['normalized_text']!, _normalizedTextMeta));
    } else if (isInserting) {
      context.missing(_normalizedTextMeta);
    }
    if (data.containsKey('language')) {
      context.handle(_languageMeta,
          language.isAcceptableOrUnknown(data['language']!, _languageMeta));
    } else if (isInserting) {
      context.missing(_languageMeta);
    }
    if (data.containsKey('sort_order')) {
      context.handle(_sortOrderMeta,
          sortOrder.isAcceptableOrUnknown(data['sort_order']!, _sortOrderMeta));
    } else if (isInserting) {
      context.missing(_sortOrderMeta);
    }
    if (data.containsKey('status')) {
      context.handle(_statusMeta,
          status.isAcceptableOrUnknown(data['status']!, _statusMeta));
    } else if (isInserting) {
      context.missing(_statusMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    }
    if (data.containsKey('updated_at')) {
      context.handle(_updatedAtMeta,
          updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  TtsDatasetPromptTableData map(Map<String, dynamic> data,
      {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return TtsDatasetPromptTableData(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      projectId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}project_id'])!,
      rawText: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}raw_text'])!,
      normalizedText: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}normalized_text'])!,
      language: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}language'])!,
      tags: $TtsDatasetPromptTableTable.$convertertags.fromSql(attachedDatabase
          .typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}tags'])!),
      sortOrder: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}sort_order'])!,
      status: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}status'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}updated_at'])!,
    );
  }

  @override
  $TtsDatasetPromptTableTable createAlias(String alias) {
    return $TtsDatasetPromptTableTable(attachedDatabase, alias);
  }

  static TypeConverter<List<String>, String> $convertertags =
      const StringListConverter();
}

class TtsDatasetPromptTableData extends DataClass
    implements Insertable<TtsDatasetPromptTableData> {
  /// Primary key.
  final String id;

  /// Owning dataset project.
  final String projectId;

  /// Original prompt text.
  final String rawText;

  /// Normalized prompt text for export.
  final String normalizedText;

  /// Prompt language label.
  final String language;

  /// Prompt tags encoded as JSON.
  final List<String> tags;

  /// Manual sort order.
  final int sortOrder;

  /// Prompt status: new, recorded, skipped, or retired.
  final String status;

  /// Timestamp when the prompt was created.
  final DateTime createdAt;

  /// Timestamp when the prompt was last updated.
  final DateTime updatedAt;
  const TtsDatasetPromptTableData(
      {required this.id,
      required this.projectId,
      required this.rawText,
      required this.normalizedText,
      required this.language,
      required this.tags,
      required this.sortOrder,
      required this.status,
      required this.createdAt,
      required this.updatedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['project_id'] = Variable<String>(projectId);
    map['raw_text'] = Variable<String>(rawText);
    map['normalized_text'] = Variable<String>(normalizedText);
    map['language'] = Variable<String>(language);
    {
      map['tags'] = Variable<String>(
          $TtsDatasetPromptTableTable.$convertertags.toSql(tags));
    }
    map['sort_order'] = Variable<int>(sortOrder);
    map['status'] = Variable<String>(status);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  TtsDatasetPromptTableCompanion toCompanion(bool nullToAbsent) {
    return TtsDatasetPromptTableCompanion(
      id: Value(id),
      projectId: Value(projectId),
      rawText: Value(rawText),
      normalizedText: Value(normalizedText),
      language: Value(language),
      tags: Value(tags),
      sortOrder: Value(sortOrder),
      status: Value(status),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory TtsDatasetPromptTableData.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return TtsDatasetPromptTableData(
      id: serializer.fromJson<String>(json['id']),
      projectId: serializer.fromJson<String>(json['projectId']),
      rawText: serializer.fromJson<String>(json['rawText']),
      normalizedText: serializer.fromJson<String>(json['normalizedText']),
      language: serializer.fromJson<String>(json['language']),
      tags: serializer.fromJson<List<String>>(json['tags']),
      sortOrder: serializer.fromJson<int>(json['sortOrder']),
      status: serializer.fromJson<String>(json['status']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'projectId': serializer.toJson<String>(projectId),
      'rawText': serializer.toJson<String>(rawText),
      'normalizedText': serializer.toJson<String>(normalizedText),
      'language': serializer.toJson<String>(language),
      'tags': serializer.toJson<List<String>>(tags),
      'sortOrder': serializer.toJson<int>(sortOrder),
      'status': serializer.toJson<String>(status),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  TtsDatasetPromptTableData copyWith(
          {String? id,
          String? projectId,
          String? rawText,
          String? normalizedText,
          String? language,
          List<String>? tags,
          int? sortOrder,
          String? status,
          DateTime? createdAt,
          DateTime? updatedAt}) =>
      TtsDatasetPromptTableData(
        id: id ?? this.id,
        projectId: projectId ?? this.projectId,
        rawText: rawText ?? this.rawText,
        normalizedText: normalizedText ?? this.normalizedText,
        language: language ?? this.language,
        tags: tags ?? this.tags,
        sortOrder: sortOrder ?? this.sortOrder,
        status: status ?? this.status,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
      );
  TtsDatasetPromptTableData copyWithCompanion(
      TtsDatasetPromptTableCompanion data) {
    return TtsDatasetPromptTableData(
      id: data.id.present ? data.id.value : this.id,
      projectId: data.projectId.present ? data.projectId.value : this.projectId,
      rawText: data.rawText.present ? data.rawText.value : this.rawText,
      normalizedText: data.normalizedText.present
          ? data.normalizedText.value
          : this.normalizedText,
      language: data.language.present ? data.language.value : this.language,
      tags: data.tags.present ? data.tags.value : this.tags,
      sortOrder: data.sortOrder.present ? data.sortOrder.value : this.sortOrder,
      status: data.status.present ? data.status.value : this.status,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('TtsDatasetPromptTableData(')
          ..write('id: $id, ')
          ..write('projectId: $projectId, ')
          ..write('rawText: $rawText, ')
          ..write('normalizedText: $normalizedText, ')
          ..write('language: $language, ')
          ..write('tags: $tags, ')
          ..write('sortOrder: $sortOrder, ')
          ..write('status: $status, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, projectId, rawText, normalizedText,
      language, tags, sortOrder, status, createdAt, updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is TtsDatasetPromptTableData &&
          other.id == this.id &&
          other.projectId == this.projectId &&
          other.rawText == this.rawText &&
          other.normalizedText == this.normalizedText &&
          other.language == this.language &&
          other.tags == this.tags &&
          other.sortOrder == this.sortOrder &&
          other.status == this.status &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class TtsDatasetPromptTableCompanion
    extends UpdateCompanion<TtsDatasetPromptTableData> {
  final Value<String> id;
  final Value<String> projectId;
  final Value<String> rawText;
  final Value<String> normalizedText;
  final Value<String> language;
  final Value<List<String>> tags;
  final Value<int> sortOrder;
  final Value<String> status;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const TtsDatasetPromptTableCompanion({
    this.id = const Value.absent(),
    this.projectId = const Value.absent(),
    this.rawText = const Value.absent(),
    this.normalizedText = const Value.absent(),
    this.language = const Value.absent(),
    this.tags = const Value.absent(),
    this.sortOrder = const Value.absent(),
    this.status = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  TtsDatasetPromptTableCompanion.insert({
    required String id,
    required String projectId,
    required String rawText,
    required String normalizedText,
    required String language,
    required List<String> tags,
    required int sortOrder,
    required String status,
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        projectId = Value(projectId),
        rawText = Value(rawText),
        normalizedText = Value(normalizedText),
        language = Value(language),
        tags = Value(tags),
        sortOrder = Value(sortOrder),
        status = Value(status);
  static Insertable<TtsDatasetPromptTableData> custom({
    Expression<String>? id,
    Expression<String>? projectId,
    Expression<String>? rawText,
    Expression<String>? normalizedText,
    Expression<String>? language,
    Expression<String>? tags,
    Expression<int>? sortOrder,
    Expression<String>? status,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (projectId != null) 'project_id': projectId,
      if (rawText != null) 'raw_text': rawText,
      if (normalizedText != null) 'normalized_text': normalizedText,
      if (language != null) 'language': language,
      if (tags != null) 'tags': tags,
      if (sortOrder != null) 'sort_order': sortOrder,
      if (status != null) 'status': status,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  TtsDatasetPromptTableCompanion copyWith(
      {Value<String>? id,
      Value<String>? projectId,
      Value<String>? rawText,
      Value<String>? normalizedText,
      Value<String>? language,
      Value<List<String>>? tags,
      Value<int>? sortOrder,
      Value<String>? status,
      Value<DateTime>? createdAt,
      Value<DateTime>? updatedAt,
      Value<int>? rowid}) {
    return TtsDatasetPromptTableCompanion(
      id: id ?? this.id,
      projectId: projectId ?? this.projectId,
      rawText: rawText ?? this.rawText,
      normalizedText: normalizedText ?? this.normalizedText,
      language: language ?? this.language,
      tags: tags ?? this.tags,
      sortOrder: sortOrder ?? this.sortOrder,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (projectId.present) {
      map['project_id'] = Variable<String>(projectId.value);
    }
    if (rawText.present) {
      map['raw_text'] = Variable<String>(rawText.value);
    }
    if (normalizedText.present) {
      map['normalized_text'] = Variable<String>(normalizedText.value);
    }
    if (language.present) {
      map['language'] = Variable<String>(language.value);
    }
    if (tags.present) {
      map['tags'] = Variable<String>(
          $TtsDatasetPromptTableTable.$convertertags.toSql(tags.value));
    }
    if (sortOrder.present) {
      map['sort_order'] = Variable<int>(sortOrder.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TtsDatasetPromptTableCompanion(')
          ..write('id: $id, ')
          ..write('projectId: $projectId, ')
          ..write('rawText: $rawText, ')
          ..write('normalizedText: $normalizedText, ')
          ..write('language: $language, ')
          ..write('tags: $tags, ')
          ..write('sortOrder: $sortOrder, ')
          ..write('status: $status, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $TtsDatasetClipTableTable extends TtsDatasetClipTable
    with TableInfo<$TtsDatasetClipTableTable, TtsDatasetClipTableData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TtsDatasetClipTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _projectIdMeta =
      const VerificationMeta('projectId');
  @override
  late final GeneratedColumn<String> projectId = GeneratedColumn<String>(
      'project_id', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: true,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'REFERENCES tts_dataset_project_table (id)'));
  static const VerificationMeta _speakerIdMeta =
      const VerificationMeta('speakerId');
  @override
  late final GeneratedColumn<String> speakerId = GeneratedColumn<String>(
      'speaker_id', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: true,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'REFERENCES tts_dataset_speaker_table (id)'));
  static const VerificationMeta _promptIdMeta =
      const VerificationMeta('promptId');
  @override
  late final GeneratedColumn<String> promptId = GeneratedColumn<String>(
      'prompt_id', aliasedName, true,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'REFERENCES tts_dataset_prompt_table (id)'));
  static const VerificationMeta _rawPathMeta =
      const VerificationMeta('rawPath');
  @override
  late final GeneratedColumn<String> rawPath = GeneratedColumn<String>(
      'raw_path', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _processedPathMeta =
      const VerificationMeta('processedPath');
  @override
  late final GeneratedColumn<String> processedPath = GeneratedColumn<String>(
      'processed_path', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _exportWavPathMeta =
      const VerificationMeta('exportWavPath');
  @override
  late final GeneratedColumn<String> exportWavPath = GeneratedColumn<String>(
      'export_wav_path', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _rawTextMeta =
      const VerificationMeta('rawText');
  @override
  late final GeneratedColumn<String> rawText = GeneratedColumn<String>(
      'raw_text', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _normalizedTextMeta =
      const VerificationMeta('normalizedText');
  @override
  late final GeneratedColumn<String> normalizedText = GeneratedColumn<String>(
      'normalized_text', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _languageMeta =
      const VerificationMeta('language');
  @override
  late final GeneratedColumn<String> language = GeneratedColumn<String>(
      'language', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _durationMsMeta =
      const VerificationMeta('durationMs');
  @override
  late final GeneratedColumn<int> durationMs = GeneratedColumn<int>(
      'duration_ms', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _sampleRateMeta =
      const VerificationMeta('sampleRate');
  @override
  late final GeneratedColumn<int> sampleRate = GeneratedColumn<int>(
      'sample_rate', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _channelsMeta =
      const VerificationMeta('channels');
  @override
  late final GeneratedColumn<int> channels = GeneratedColumn<int>(
      'channels', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _bitDepthMeta =
      const VerificationMeta('bitDepth');
  @override
  late final GeneratedColumn<int> bitDepth = GeneratedColumn<int>(
      'bit_depth', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _peakDbMeta = const VerificationMeta('peakDb');
  @override
  late final GeneratedColumn<double> peakDb = GeneratedColumn<double>(
      'peak_db', aliasedName, true,
      type: DriftSqlType.double, requiredDuringInsert: false);
  static const VerificationMeta _rmsDbMeta = const VerificationMeta('rmsDb');
  @override
  late final GeneratedColumn<double> rmsDb = GeneratedColumn<double>(
      'rms_db', aliasedName, true,
      type: DriftSqlType.double, requiredDuringInsert: false);
  static const VerificationMeta _noiseFloorDbMeta =
      const VerificationMeta('noiseFloorDb');
  @override
  late final GeneratedColumn<double> noiseFloorDb = GeneratedColumn<double>(
      'noise_floor_db', aliasedName, true,
      type: DriftSqlType.double, requiredDuringInsert: false);
  static const VerificationMeta _snrEstimateDbMeta =
      const VerificationMeta('snrEstimateDb');
  @override
  late final GeneratedColumn<double> snrEstimateDb = GeneratedColumn<double>(
      'snr_estimate_db', aliasedName, true,
      type: DriftSqlType.double, requiredDuringInsert: false);
  static const VerificationMeta _clippingCountMeta =
      const VerificationMeta('clippingCount');
  @override
  late final GeneratedColumn<int> clippingCount = GeneratedColumn<int>(
      'clipping_count', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _leadingSilenceMsMeta =
      const VerificationMeta('leadingSilenceMs');
  @override
  late final GeneratedColumn<int> leadingSilenceMs = GeneratedColumn<int>(
      'leading_silence_ms', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _trailingSilenceMsMeta =
      const VerificationMeta('trailingSilenceMs');
  @override
  late final GeneratedColumn<int> trailingSilenceMs = GeneratedColumn<int>(
      'trailing_silence_ms', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _noiseReductionModeMeta =
      const VerificationMeta('noiseReductionMode');
  @override
  late final GeneratedColumn<String> noiseReductionMode =
      GeneratedColumn<String>('noise_reduction_mode', aliasedName, false,
          type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _noiseReductionEngineMeta =
      const VerificationMeta('noiseReductionEngine');
  @override
  late final GeneratedColumn<String> noiseReductionEngine =
      GeneratedColumn<String>('noise_reduction_engine', aliasedName, true,
          type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _processingProfileIdMeta =
      const VerificationMeta('processingProfileId');
  @override
  late final GeneratedColumn<String> processingProfileId =
      GeneratedColumn<String>('processing_profile_id', aliasedName, true,
          type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
      'status', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _rejectionReasonMeta =
      const VerificationMeta('rejectionReason');
  @override
  late final GeneratedColumn<String> rejectionReason = GeneratedColumn<String>(
      'rejection_reason', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  static const VerificationMeta _updatedAtMeta =
      const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
      'updated_at', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        projectId,
        speakerId,
        promptId,
        rawPath,
        processedPath,
        exportWavPath,
        rawText,
        normalizedText,
        language,
        durationMs,
        sampleRate,
        channels,
        bitDepth,
        peakDb,
        rmsDb,
        noiseFloorDb,
        snrEstimateDb,
        clippingCount,
        leadingSilenceMs,
        trailingSilenceMs,
        noiseReductionMode,
        noiseReductionEngine,
        processingProfileId,
        status,
        rejectionReason,
        createdAt,
        updatedAt
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'tts_dataset_clip_table';
  @override
  VerificationContext validateIntegrity(
      Insertable<TtsDatasetClipTableData> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('project_id')) {
      context.handle(_projectIdMeta,
          projectId.isAcceptableOrUnknown(data['project_id']!, _projectIdMeta));
    } else if (isInserting) {
      context.missing(_projectIdMeta);
    }
    if (data.containsKey('speaker_id')) {
      context.handle(_speakerIdMeta,
          speakerId.isAcceptableOrUnknown(data['speaker_id']!, _speakerIdMeta));
    } else if (isInserting) {
      context.missing(_speakerIdMeta);
    }
    if (data.containsKey('prompt_id')) {
      context.handle(_promptIdMeta,
          promptId.isAcceptableOrUnknown(data['prompt_id']!, _promptIdMeta));
    }
    if (data.containsKey('raw_path')) {
      context.handle(_rawPathMeta,
          rawPath.isAcceptableOrUnknown(data['raw_path']!, _rawPathMeta));
    } else if (isInserting) {
      context.missing(_rawPathMeta);
    }
    if (data.containsKey('processed_path')) {
      context.handle(
          _processedPathMeta,
          processedPath.isAcceptableOrUnknown(
              data['processed_path']!, _processedPathMeta));
    } else if (isInserting) {
      context.missing(_processedPathMeta);
    }
    if (data.containsKey('export_wav_path')) {
      context.handle(
          _exportWavPathMeta,
          exportWavPath.isAcceptableOrUnknown(
              data['export_wav_path']!, _exportWavPathMeta));
    } else if (isInserting) {
      context.missing(_exportWavPathMeta);
    }
    if (data.containsKey('raw_text')) {
      context.handle(_rawTextMeta,
          rawText.isAcceptableOrUnknown(data['raw_text']!, _rawTextMeta));
    } else if (isInserting) {
      context.missing(_rawTextMeta);
    }
    if (data.containsKey('normalized_text')) {
      context.handle(
          _normalizedTextMeta,
          normalizedText.isAcceptableOrUnknown(
              data['normalized_text']!, _normalizedTextMeta));
    } else if (isInserting) {
      context.missing(_normalizedTextMeta);
    }
    if (data.containsKey('language')) {
      context.handle(_languageMeta,
          language.isAcceptableOrUnknown(data['language']!, _languageMeta));
    } else if (isInserting) {
      context.missing(_languageMeta);
    }
    if (data.containsKey('duration_ms')) {
      context.handle(
          _durationMsMeta,
          durationMs.isAcceptableOrUnknown(
              data['duration_ms']!, _durationMsMeta));
    } else if (isInserting) {
      context.missing(_durationMsMeta);
    }
    if (data.containsKey('sample_rate')) {
      context.handle(
          _sampleRateMeta,
          sampleRate.isAcceptableOrUnknown(
              data['sample_rate']!, _sampleRateMeta));
    } else if (isInserting) {
      context.missing(_sampleRateMeta);
    }
    if (data.containsKey('channels')) {
      context.handle(_channelsMeta,
          channels.isAcceptableOrUnknown(data['channels']!, _channelsMeta));
    } else if (isInserting) {
      context.missing(_channelsMeta);
    }
    if (data.containsKey('bit_depth')) {
      context.handle(_bitDepthMeta,
          bitDepth.isAcceptableOrUnknown(data['bit_depth']!, _bitDepthMeta));
    } else if (isInserting) {
      context.missing(_bitDepthMeta);
    }
    if (data.containsKey('peak_db')) {
      context.handle(_peakDbMeta,
          peakDb.isAcceptableOrUnknown(data['peak_db']!, _peakDbMeta));
    }
    if (data.containsKey('rms_db')) {
      context.handle(
          _rmsDbMeta, rmsDb.isAcceptableOrUnknown(data['rms_db']!, _rmsDbMeta));
    }
    if (data.containsKey('noise_floor_db')) {
      context.handle(
          _noiseFloorDbMeta,
          noiseFloorDb.isAcceptableOrUnknown(
              data['noise_floor_db']!, _noiseFloorDbMeta));
    }
    if (data.containsKey('snr_estimate_db')) {
      context.handle(
          _snrEstimateDbMeta,
          snrEstimateDb.isAcceptableOrUnknown(
              data['snr_estimate_db']!, _snrEstimateDbMeta));
    }
    if (data.containsKey('clipping_count')) {
      context.handle(
          _clippingCountMeta,
          clippingCount.isAcceptableOrUnknown(
              data['clipping_count']!, _clippingCountMeta));
    }
    if (data.containsKey('leading_silence_ms')) {
      context.handle(
          _leadingSilenceMsMeta,
          leadingSilenceMs.isAcceptableOrUnknown(
              data['leading_silence_ms']!, _leadingSilenceMsMeta));
    }
    if (data.containsKey('trailing_silence_ms')) {
      context.handle(
          _trailingSilenceMsMeta,
          trailingSilenceMs.isAcceptableOrUnknown(
              data['trailing_silence_ms']!, _trailingSilenceMsMeta));
    }
    if (data.containsKey('noise_reduction_mode')) {
      context.handle(
          _noiseReductionModeMeta,
          noiseReductionMode.isAcceptableOrUnknown(
              data['noise_reduction_mode']!, _noiseReductionModeMeta));
    } else if (isInserting) {
      context.missing(_noiseReductionModeMeta);
    }
    if (data.containsKey('noise_reduction_engine')) {
      context.handle(
          _noiseReductionEngineMeta,
          noiseReductionEngine.isAcceptableOrUnknown(
              data['noise_reduction_engine']!, _noiseReductionEngineMeta));
    }
    if (data.containsKey('processing_profile_id')) {
      context.handle(
          _processingProfileIdMeta,
          processingProfileId.isAcceptableOrUnknown(
              data['processing_profile_id']!, _processingProfileIdMeta));
    }
    if (data.containsKey('status')) {
      context.handle(_statusMeta,
          status.isAcceptableOrUnknown(data['status']!, _statusMeta));
    } else if (isInserting) {
      context.missing(_statusMeta);
    }
    if (data.containsKey('rejection_reason')) {
      context.handle(
          _rejectionReasonMeta,
          rejectionReason.isAcceptableOrUnknown(
              data['rejection_reason']!, _rejectionReasonMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    }
    if (data.containsKey('updated_at')) {
      context.handle(_updatedAtMeta,
          updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  TtsDatasetClipTableData map(Map<String, dynamic> data,
      {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return TtsDatasetClipTableData(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      projectId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}project_id'])!,
      speakerId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}speaker_id'])!,
      promptId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}prompt_id']),
      rawPath: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}raw_path'])!,
      processedPath: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}processed_path'])!,
      exportWavPath: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}export_wav_path'])!,
      rawText: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}raw_text'])!,
      normalizedText: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}normalized_text'])!,
      language: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}language'])!,
      durationMs: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}duration_ms'])!,
      sampleRate: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}sample_rate'])!,
      channels: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}channels'])!,
      bitDepth: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}bit_depth'])!,
      peakDb: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}peak_db']),
      rmsDb: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}rms_db']),
      noiseFloorDb: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}noise_floor_db']),
      snrEstimateDb: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}snr_estimate_db']),
      clippingCount: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}clipping_count']),
      leadingSilenceMs: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}leading_silence_ms']),
      trailingSilenceMs: attachedDatabase.typeMapping.read(
          DriftSqlType.int, data['${effectivePrefix}trailing_silence_ms']),
      noiseReductionMode: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}noise_reduction_mode'])!,
      noiseReductionEngine: attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}noise_reduction_engine']),
      processingProfileId: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}processing_profile_id']),
      status: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}status'])!,
      rejectionReason: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}rejection_reason']),
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}updated_at'])!,
    );
  }

  @override
  $TtsDatasetClipTableTable createAlias(String alias) {
    return $TtsDatasetClipTableTable(attachedDatabase, alias);
  }
}

class TtsDatasetClipTableData extends DataClass
    implements Insertable<TtsDatasetClipTableData> {
  /// Primary key.
  final String id;

  /// Owning dataset project.
  final String projectId;

  /// Speaker for this clip.
  final String speakerId;

  /// Optional linked prompt.
  final String? promptId;

  /// Project-relative raw recording path.
  final String rawPath;

  /// Project-relative processed recording path.
  final String processedPath;

  /// Project-relative training WAV path used for export.
  final String exportWavPath;

  /// Original transcript text.
  final String rawText;

  /// Normalized transcript text for export.
  final String normalizedText;

  /// Clip language label.
  final String language;

  /// Duration in milliseconds.
  final int durationMs;

  /// Sample rate in hertz.
  final int sampleRate;

  /// Channel count.
  final int channels;

  /// Bit depth.
  final int bitDepth;

  /// Peak level in dB.
  final double? peakDb;

  /// RMS level in dB.
  final double? rmsDb;

  /// Estimated noise floor in dB.
  final double? noiseFloorDb;

  /// Estimated SNR in dB.
  final double? snrEstimateDb;

  /// Count of clipped samples or frames.
  final int? clippingCount;

  /// Leading silence estimate in milliseconds.
  final int? leadingSilenceMs;

  /// Trailing silence estimate in milliseconds.
  final int? trailingSilenceMs;

  /// Noise reduction mode: off, low, medium, or high.
  final String noiseReductionMode;

  /// Optional processing engine label.
  final String? noiseReductionEngine;

  /// Optional processing profile id.
  final String? processingProfileId;

  /// Clip review status.
  final String status;

  /// Optional rejection reason.
  final String? rejectionReason;

  /// Timestamp when the clip was created.
  final DateTime createdAt;

  /// Timestamp when the clip was last updated.
  final DateTime updatedAt;
  const TtsDatasetClipTableData(
      {required this.id,
      required this.projectId,
      required this.speakerId,
      this.promptId,
      required this.rawPath,
      required this.processedPath,
      required this.exportWavPath,
      required this.rawText,
      required this.normalizedText,
      required this.language,
      required this.durationMs,
      required this.sampleRate,
      required this.channels,
      required this.bitDepth,
      this.peakDb,
      this.rmsDb,
      this.noiseFloorDb,
      this.snrEstimateDb,
      this.clippingCount,
      this.leadingSilenceMs,
      this.trailingSilenceMs,
      required this.noiseReductionMode,
      this.noiseReductionEngine,
      this.processingProfileId,
      required this.status,
      this.rejectionReason,
      required this.createdAt,
      required this.updatedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['project_id'] = Variable<String>(projectId);
    map['speaker_id'] = Variable<String>(speakerId);
    if (!nullToAbsent || promptId != null) {
      map['prompt_id'] = Variable<String>(promptId);
    }
    map['raw_path'] = Variable<String>(rawPath);
    map['processed_path'] = Variable<String>(processedPath);
    map['export_wav_path'] = Variable<String>(exportWavPath);
    map['raw_text'] = Variable<String>(rawText);
    map['normalized_text'] = Variable<String>(normalizedText);
    map['language'] = Variable<String>(language);
    map['duration_ms'] = Variable<int>(durationMs);
    map['sample_rate'] = Variable<int>(sampleRate);
    map['channels'] = Variable<int>(channels);
    map['bit_depth'] = Variable<int>(bitDepth);
    if (!nullToAbsent || peakDb != null) {
      map['peak_db'] = Variable<double>(peakDb);
    }
    if (!nullToAbsent || rmsDb != null) {
      map['rms_db'] = Variable<double>(rmsDb);
    }
    if (!nullToAbsent || noiseFloorDb != null) {
      map['noise_floor_db'] = Variable<double>(noiseFloorDb);
    }
    if (!nullToAbsent || snrEstimateDb != null) {
      map['snr_estimate_db'] = Variable<double>(snrEstimateDb);
    }
    if (!nullToAbsent || clippingCount != null) {
      map['clipping_count'] = Variable<int>(clippingCount);
    }
    if (!nullToAbsent || leadingSilenceMs != null) {
      map['leading_silence_ms'] = Variable<int>(leadingSilenceMs);
    }
    if (!nullToAbsent || trailingSilenceMs != null) {
      map['trailing_silence_ms'] = Variable<int>(trailingSilenceMs);
    }
    map['noise_reduction_mode'] = Variable<String>(noiseReductionMode);
    if (!nullToAbsent || noiseReductionEngine != null) {
      map['noise_reduction_engine'] = Variable<String>(noiseReductionEngine);
    }
    if (!nullToAbsent || processingProfileId != null) {
      map['processing_profile_id'] = Variable<String>(processingProfileId);
    }
    map['status'] = Variable<String>(status);
    if (!nullToAbsent || rejectionReason != null) {
      map['rejection_reason'] = Variable<String>(rejectionReason);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  TtsDatasetClipTableCompanion toCompanion(bool nullToAbsent) {
    return TtsDatasetClipTableCompanion(
      id: Value(id),
      projectId: Value(projectId),
      speakerId: Value(speakerId),
      promptId: promptId == null && nullToAbsent
          ? const Value.absent()
          : Value(promptId),
      rawPath: Value(rawPath),
      processedPath: Value(processedPath),
      exportWavPath: Value(exportWavPath),
      rawText: Value(rawText),
      normalizedText: Value(normalizedText),
      language: Value(language),
      durationMs: Value(durationMs),
      sampleRate: Value(sampleRate),
      channels: Value(channels),
      bitDepth: Value(bitDepth),
      peakDb:
          peakDb == null && nullToAbsent ? const Value.absent() : Value(peakDb),
      rmsDb:
          rmsDb == null && nullToAbsent ? const Value.absent() : Value(rmsDb),
      noiseFloorDb: noiseFloorDb == null && nullToAbsent
          ? const Value.absent()
          : Value(noiseFloorDb),
      snrEstimateDb: snrEstimateDb == null && nullToAbsent
          ? const Value.absent()
          : Value(snrEstimateDb),
      clippingCount: clippingCount == null && nullToAbsent
          ? const Value.absent()
          : Value(clippingCount),
      leadingSilenceMs: leadingSilenceMs == null && nullToAbsent
          ? const Value.absent()
          : Value(leadingSilenceMs),
      trailingSilenceMs: trailingSilenceMs == null && nullToAbsent
          ? const Value.absent()
          : Value(trailingSilenceMs),
      noiseReductionMode: Value(noiseReductionMode),
      noiseReductionEngine: noiseReductionEngine == null && nullToAbsent
          ? const Value.absent()
          : Value(noiseReductionEngine),
      processingProfileId: processingProfileId == null && nullToAbsent
          ? const Value.absent()
          : Value(processingProfileId),
      status: Value(status),
      rejectionReason: rejectionReason == null && nullToAbsent
          ? const Value.absent()
          : Value(rejectionReason),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory TtsDatasetClipTableData.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return TtsDatasetClipTableData(
      id: serializer.fromJson<String>(json['id']),
      projectId: serializer.fromJson<String>(json['projectId']),
      speakerId: serializer.fromJson<String>(json['speakerId']),
      promptId: serializer.fromJson<String?>(json['promptId']),
      rawPath: serializer.fromJson<String>(json['rawPath']),
      processedPath: serializer.fromJson<String>(json['processedPath']),
      exportWavPath: serializer.fromJson<String>(json['exportWavPath']),
      rawText: serializer.fromJson<String>(json['rawText']),
      normalizedText: serializer.fromJson<String>(json['normalizedText']),
      language: serializer.fromJson<String>(json['language']),
      durationMs: serializer.fromJson<int>(json['durationMs']),
      sampleRate: serializer.fromJson<int>(json['sampleRate']),
      channels: serializer.fromJson<int>(json['channels']),
      bitDepth: serializer.fromJson<int>(json['bitDepth']),
      peakDb: serializer.fromJson<double?>(json['peakDb']),
      rmsDb: serializer.fromJson<double?>(json['rmsDb']),
      noiseFloorDb: serializer.fromJson<double?>(json['noiseFloorDb']),
      snrEstimateDb: serializer.fromJson<double?>(json['snrEstimateDb']),
      clippingCount: serializer.fromJson<int?>(json['clippingCount']),
      leadingSilenceMs: serializer.fromJson<int?>(json['leadingSilenceMs']),
      trailingSilenceMs: serializer.fromJson<int?>(json['trailingSilenceMs']),
      noiseReductionMode:
          serializer.fromJson<String>(json['noiseReductionMode']),
      noiseReductionEngine:
          serializer.fromJson<String?>(json['noiseReductionEngine']),
      processingProfileId:
          serializer.fromJson<String?>(json['processingProfileId']),
      status: serializer.fromJson<String>(json['status']),
      rejectionReason: serializer.fromJson<String?>(json['rejectionReason']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'projectId': serializer.toJson<String>(projectId),
      'speakerId': serializer.toJson<String>(speakerId),
      'promptId': serializer.toJson<String?>(promptId),
      'rawPath': serializer.toJson<String>(rawPath),
      'processedPath': serializer.toJson<String>(processedPath),
      'exportWavPath': serializer.toJson<String>(exportWavPath),
      'rawText': serializer.toJson<String>(rawText),
      'normalizedText': serializer.toJson<String>(normalizedText),
      'language': serializer.toJson<String>(language),
      'durationMs': serializer.toJson<int>(durationMs),
      'sampleRate': serializer.toJson<int>(sampleRate),
      'channels': serializer.toJson<int>(channels),
      'bitDepth': serializer.toJson<int>(bitDepth),
      'peakDb': serializer.toJson<double?>(peakDb),
      'rmsDb': serializer.toJson<double?>(rmsDb),
      'noiseFloorDb': serializer.toJson<double?>(noiseFloorDb),
      'snrEstimateDb': serializer.toJson<double?>(snrEstimateDb),
      'clippingCount': serializer.toJson<int?>(clippingCount),
      'leadingSilenceMs': serializer.toJson<int?>(leadingSilenceMs),
      'trailingSilenceMs': serializer.toJson<int?>(trailingSilenceMs),
      'noiseReductionMode': serializer.toJson<String>(noiseReductionMode),
      'noiseReductionEngine': serializer.toJson<String?>(noiseReductionEngine),
      'processingProfileId': serializer.toJson<String?>(processingProfileId),
      'status': serializer.toJson<String>(status),
      'rejectionReason': serializer.toJson<String?>(rejectionReason),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  TtsDatasetClipTableData copyWith(
          {String? id,
          String? projectId,
          String? speakerId,
          Value<String?> promptId = const Value.absent(),
          String? rawPath,
          String? processedPath,
          String? exportWavPath,
          String? rawText,
          String? normalizedText,
          String? language,
          int? durationMs,
          int? sampleRate,
          int? channels,
          int? bitDepth,
          Value<double?> peakDb = const Value.absent(),
          Value<double?> rmsDb = const Value.absent(),
          Value<double?> noiseFloorDb = const Value.absent(),
          Value<double?> snrEstimateDb = const Value.absent(),
          Value<int?> clippingCount = const Value.absent(),
          Value<int?> leadingSilenceMs = const Value.absent(),
          Value<int?> trailingSilenceMs = const Value.absent(),
          String? noiseReductionMode,
          Value<String?> noiseReductionEngine = const Value.absent(),
          Value<String?> processingProfileId = const Value.absent(),
          String? status,
          Value<String?> rejectionReason = const Value.absent(),
          DateTime? createdAt,
          DateTime? updatedAt}) =>
      TtsDatasetClipTableData(
        id: id ?? this.id,
        projectId: projectId ?? this.projectId,
        speakerId: speakerId ?? this.speakerId,
        promptId: promptId.present ? promptId.value : this.promptId,
        rawPath: rawPath ?? this.rawPath,
        processedPath: processedPath ?? this.processedPath,
        exportWavPath: exportWavPath ?? this.exportWavPath,
        rawText: rawText ?? this.rawText,
        normalizedText: normalizedText ?? this.normalizedText,
        language: language ?? this.language,
        durationMs: durationMs ?? this.durationMs,
        sampleRate: sampleRate ?? this.sampleRate,
        channels: channels ?? this.channels,
        bitDepth: bitDepth ?? this.bitDepth,
        peakDb: peakDb.present ? peakDb.value : this.peakDb,
        rmsDb: rmsDb.present ? rmsDb.value : this.rmsDb,
        noiseFloorDb:
            noiseFloorDb.present ? noiseFloorDb.value : this.noiseFloorDb,
        snrEstimateDb:
            snrEstimateDb.present ? snrEstimateDb.value : this.snrEstimateDb,
        clippingCount:
            clippingCount.present ? clippingCount.value : this.clippingCount,
        leadingSilenceMs: leadingSilenceMs.present
            ? leadingSilenceMs.value
            : this.leadingSilenceMs,
        trailingSilenceMs: trailingSilenceMs.present
            ? trailingSilenceMs.value
            : this.trailingSilenceMs,
        noiseReductionMode: noiseReductionMode ?? this.noiseReductionMode,
        noiseReductionEngine: noiseReductionEngine.present
            ? noiseReductionEngine.value
            : this.noiseReductionEngine,
        processingProfileId: processingProfileId.present
            ? processingProfileId.value
            : this.processingProfileId,
        status: status ?? this.status,
        rejectionReason: rejectionReason.present
            ? rejectionReason.value
            : this.rejectionReason,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
      );
  TtsDatasetClipTableData copyWithCompanion(TtsDatasetClipTableCompanion data) {
    return TtsDatasetClipTableData(
      id: data.id.present ? data.id.value : this.id,
      projectId: data.projectId.present ? data.projectId.value : this.projectId,
      speakerId: data.speakerId.present ? data.speakerId.value : this.speakerId,
      promptId: data.promptId.present ? data.promptId.value : this.promptId,
      rawPath: data.rawPath.present ? data.rawPath.value : this.rawPath,
      processedPath: data.processedPath.present
          ? data.processedPath.value
          : this.processedPath,
      exportWavPath: data.exportWavPath.present
          ? data.exportWavPath.value
          : this.exportWavPath,
      rawText: data.rawText.present ? data.rawText.value : this.rawText,
      normalizedText: data.normalizedText.present
          ? data.normalizedText.value
          : this.normalizedText,
      language: data.language.present ? data.language.value : this.language,
      durationMs:
          data.durationMs.present ? data.durationMs.value : this.durationMs,
      sampleRate:
          data.sampleRate.present ? data.sampleRate.value : this.sampleRate,
      channels: data.channels.present ? data.channels.value : this.channels,
      bitDepth: data.bitDepth.present ? data.bitDepth.value : this.bitDepth,
      peakDb: data.peakDb.present ? data.peakDb.value : this.peakDb,
      rmsDb: data.rmsDb.present ? data.rmsDb.value : this.rmsDb,
      noiseFloorDb: data.noiseFloorDb.present
          ? data.noiseFloorDb.value
          : this.noiseFloorDb,
      snrEstimateDb: data.snrEstimateDb.present
          ? data.snrEstimateDb.value
          : this.snrEstimateDb,
      clippingCount: data.clippingCount.present
          ? data.clippingCount.value
          : this.clippingCount,
      leadingSilenceMs: data.leadingSilenceMs.present
          ? data.leadingSilenceMs.value
          : this.leadingSilenceMs,
      trailingSilenceMs: data.trailingSilenceMs.present
          ? data.trailingSilenceMs.value
          : this.trailingSilenceMs,
      noiseReductionMode: data.noiseReductionMode.present
          ? data.noiseReductionMode.value
          : this.noiseReductionMode,
      noiseReductionEngine: data.noiseReductionEngine.present
          ? data.noiseReductionEngine.value
          : this.noiseReductionEngine,
      processingProfileId: data.processingProfileId.present
          ? data.processingProfileId.value
          : this.processingProfileId,
      status: data.status.present ? data.status.value : this.status,
      rejectionReason: data.rejectionReason.present
          ? data.rejectionReason.value
          : this.rejectionReason,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('TtsDatasetClipTableData(')
          ..write('id: $id, ')
          ..write('projectId: $projectId, ')
          ..write('speakerId: $speakerId, ')
          ..write('promptId: $promptId, ')
          ..write('rawPath: $rawPath, ')
          ..write('processedPath: $processedPath, ')
          ..write('exportWavPath: $exportWavPath, ')
          ..write('rawText: $rawText, ')
          ..write('normalizedText: $normalizedText, ')
          ..write('language: $language, ')
          ..write('durationMs: $durationMs, ')
          ..write('sampleRate: $sampleRate, ')
          ..write('channels: $channels, ')
          ..write('bitDepth: $bitDepth, ')
          ..write('peakDb: $peakDb, ')
          ..write('rmsDb: $rmsDb, ')
          ..write('noiseFloorDb: $noiseFloorDb, ')
          ..write('snrEstimateDb: $snrEstimateDb, ')
          ..write('clippingCount: $clippingCount, ')
          ..write('leadingSilenceMs: $leadingSilenceMs, ')
          ..write('trailingSilenceMs: $trailingSilenceMs, ')
          ..write('noiseReductionMode: $noiseReductionMode, ')
          ..write('noiseReductionEngine: $noiseReductionEngine, ')
          ..write('processingProfileId: $processingProfileId, ')
          ..write('status: $status, ')
          ..write('rejectionReason: $rejectionReason, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hashAll([
        id,
        projectId,
        speakerId,
        promptId,
        rawPath,
        processedPath,
        exportWavPath,
        rawText,
        normalizedText,
        language,
        durationMs,
        sampleRate,
        channels,
        bitDepth,
        peakDb,
        rmsDb,
        noiseFloorDb,
        snrEstimateDb,
        clippingCount,
        leadingSilenceMs,
        trailingSilenceMs,
        noiseReductionMode,
        noiseReductionEngine,
        processingProfileId,
        status,
        rejectionReason,
        createdAt,
        updatedAt
      ]);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is TtsDatasetClipTableData &&
          other.id == this.id &&
          other.projectId == this.projectId &&
          other.speakerId == this.speakerId &&
          other.promptId == this.promptId &&
          other.rawPath == this.rawPath &&
          other.processedPath == this.processedPath &&
          other.exportWavPath == this.exportWavPath &&
          other.rawText == this.rawText &&
          other.normalizedText == this.normalizedText &&
          other.language == this.language &&
          other.durationMs == this.durationMs &&
          other.sampleRate == this.sampleRate &&
          other.channels == this.channels &&
          other.bitDepth == this.bitDepth &&
          other.peakDb == this.peakDb &&
          other.rmsDb == this.rmsDb &&
          other.noiseFloorDb == this.noiseFloorDb &&
          other.snrEstimateDb == this.snrEstimateDb &&
          other.clippingCount == this.clippingCount &&
          other.leadingSilenceMs == this.leadingSilenceMs &&
          other.trailingSilenceMs == this.trailingSilenceMs &&
          other.noiseReductionMode == this.noiseReductionMode &&
          other.noiseReductionEngine == this.noiseReductionEngine &&
          other.processingProfileId == this.processingProfileId &&
          other.status == this.status &&
          other.rejectionReason == this.rejectionReason &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class TtsDatasetClipTableCompanion
    extends UpdateCompanion<TtsDatasetClipTableData> {
  final Value<String> id;
  final Value<String> projectId;
  final Value<String> speakerId;
  final Value<String?> promptId;
  final Value<String> rawPath;
  final Value<String> processedPath;
  final Value<String> exportWavPath;
  final Value<String> rawText;
  final Value<String> normalizedText;
  final Value<String> language;
  final Value<int> durationMs;
  final Value<int> sampleRate;
  final Value<int> channels;
  final Value<int> bitDepth;
  final Value<double?> peakDb;
  final Value<double?> rmsDb;
  final Value<double?> noiseFloorDb;
  final Value<double?> snrEstimateDb;
  final Value<int?> clippingCount;
  final Value<int?> leadingSilenceMs;
  final Value<int?> trailingSilenceMs;
  final Value<String> noiseReductionMode;
  final Value<String?> noiseReductionEngine;
  final Value<String?> processingProfileId;
  final Value<String> status;
  final Value<String?> rejectionReason;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const TtsDatasetClipTableCompanion({
    this.id = const Value.absent(),
    this.projectId = const Value.absent(),
    this.speakerId = const Value.absent(),
    this.promptId = const Value.absent(),
    this.rawPath = const Value.absent(),
    this.processedPath = const Value.absent(),
    this.exportWavPath = const Value.absent(),
    this.rawText = const Value.absent(),
    this.normalizedText = const Value.absent(),
    this.language = const Value.absent(),
    this.durationMs = const Value.absent(),
    this.sampleRate = const Value.absent(),
    this.channels = const Value.absent(),
    this.bitDepth = const Value.absent(),
    this.peakDb = const Value.absent(),
    this.rmsDb = const Value.absent(),
    this.noiseFloorDb = const Value.absent(),
    this.snrEstimateDb = const Value.absent(),
    this.clippingCount = const Value.absent(),
    this.leadingSilenceMs = const Value.absent(),
    this.trailingSilenceMs = const Value.absent(),
    this.noiseReductionMode = const Value.absent(),
    this.noiseReductionEngine = const Value.absent(),
    this.processingProfileId = const Value.absent(),
    this.status = const Value.absent(),
    this.rejectionReason = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  TtsDatasetClipTableCompanion.insert({
    required String id,
    required String projectId,
    required String speakerId,
    this.promptId = const Value.absent(),
    required String rawPath,
    required String processedPath,
    required String exportWavPath,
    required String rawText,
    required String normalizedText,
    required String language,
    required int durationMs,
    required int sampleRate,
    required int channels,
    required int bitDepth,
    this.peakDb = const Value.absent(),
    this.rmsDb = const Value.absent(),
    this.noiseFloorDb = const Value.absent(),
    this.snrEstimateDb = const Value.absent(),
    this.clippingCount = const Value.absent(),
    this.leadingSilenceMs = const Value.absent(),
    this.trailingSilenceMs = const Value.absent(),
    required String noiseReductionMode,
    this.noiseReductionEngine = const Value.absent(),
    this.processingProfileId = const Value.absent(),
    required String status,
    this.rejectionReason = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        projectId = Value(projectId),
        speakerId = Value(speakerId),
        rawPath = Value(rawPath),
        processedPath = Value(processedPath),
        exportWavPath = Value(exportWavPath),
        rawText = Value(rawText),
        normalizedText = Value(normalizedText),
        language = Value(language),
        durationMs = Value(durationMs),
        sampleRate = Value(sampleRate),
        channels = Value(channels),
        bitDepth = Value(bitDepth),
        noiseReductionMode = Value(noiseReductionMode),
        status = Value(status);
  static Insertable<TtsDatasetClipTableData> custom({
    Expression<String>? id,
    Expression<String>? projectId,
    Expression<String>? speakerId,
    Expression<String>? promptId,
    Expression<String>? rawPath,
    Expression<String>? processedPath,
    Expression<String>? exportWavPath,
    Expression<String>? rawText,
    Expression<String>? normalizedText,
    Expression<String>? language,
    Expression<int>? durationMs,
    Expression<int>? sampleRate,
    Expression<int>? channels,
    Expression<int>? bitDepth,
    Expression<double>? peakDb,
    Expression<double>? rmsDb,
    Expression<double>? noiseFloorDb,
    Expression<double>? snrEstimateDb,
    Expression<int>? clippingCount,
    Expression<int>? leadingSilenceMs,
    Expression<int>? trailingSilenceMs,
    Expression<String>? noiseReductionMode,
    Expression<String>? noiseReductionEngine,
    Expression<String>? processingProfileId,
    Expression<String>? status,
    Expression<String>? rejectionReason,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (projectId != null) 'project_id': projectId,
      if (speakerId != null) 'speaker_id': speakerId,
      if (promptId != null) 'prompt_id': promptId,
      if (rawPath != null) 'raw_path': rawPath,
      if (processedPath != null) 'processed_path': processedPath,
      if (exportWavPath != null) 'export_wav_path': exportWavPath,
      if (rawText != null) 'raw_text': rawText,
      if (normalizedText != null) 'normalized_text': normalizedText,
      if (language != null) 'language': language,
      if (durationMs != null) 'duration_ms': durationMs,
      if (sampleRate != null) 'sample_rate': sampleRate,
      if (channels != null) 'channels': channels,
      if (bitDepth != null) 'bit_depth': bitDepth,
      if (peakDb != null) 'peak_db': peakDb,
      if (rmsDb != null) 'rms_db': rmsDb,
      if (noiseFloorDb != null) 'noise_floor_db': noiseFloorDb,
      if (snrEstimateDb != null) 'snr_estimate_db': snrEstimateDb,
      if (clippingCount != null) 'clipping_count': clippingCount,
      if (leadingSilenceMs != null) 'leading_silence_ms': leadingSilenceMs,
      if (trailingSilenceMs != null) 'trailing_silence_ms': trailingSilenceMs,
      if (noiseReductionMode != null)
        'noise_reduction_mode': noiseReductionMode,
      if (noiseReductionEngine != null)
        'noise_reduction_engine': noiseReductionEngine,
      if (processingProfileId != null)
        'processing_profile_id': processingProfileId,
      if (status != null) 'status': status,
      if (rejectionReason != null) 'rejection_reason': rejectionReason,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  TtsDatasetClipTableCompanion copyWith(
      {Value<String>? id,
      Value<String>? projectId,
      Value<String>? speakerId,
      Value<String?>? promptId,
      Value<String>? rawPath,
      Value<String>? processedPath,
      Value<String>? exportWavPath,
      Value<String>? rawText,
      Value<String>? normalizedText,
      Value<String>? language,
      Value<int>? durationMs,
      Value<int>? sampleRate,
      Value<int>? channels,
      Value<int>? bitDepth,
      Value<double?>? peakDb,
      Value<double?>? rmsDb,
      Value<double?>? noiseFloorDb,
      Value<double?>? snrEstimateDb,
      Value<int?>? clippingCount,
      Value<int?>? leadingSilenceMs,
      Value<int?>? trailingSilenceMs,
      Value<String>? noiseReductionMode,
      Value<String?>? noiseReductionEngine,
      Value<String?>? processingProfileId,
      Value<String>? status,
      Value<String?>? rejectionReason,
      Value<DateTime>? createdAt,
      Value<DateTime>? updatedAt,
      Value<int>? rowid}) {
    return TtsDatasetClipTableCompanion(
      id: id ?? this.id,
      projectId: projectId ?? this.projectId,
      speakerId: speakerId ?? this.speakerId,
      promptId: promptId ?? this.promptId,
      rawPath: rawPath ?? this.rawPath,
      processedPath: processedPath ?? this.processedPath,
      exportWavPath: exportWavPath ?? this.exportWavPath,
      rawText: rawText ?? this.rawText,
      normalizedText: normalizedText ?? this.normalizedText,
      language: language ?? this.language,
      durationMs: durationMs ?? this.durationMs,
      sampleRate: sampleRate ?? this.sampleRate,
      channels: channels ?? this.channels,
      bitDepth: bitDepth ?? this.bitDepth,
      peakDb: peakDb ?? this.peakDb,
      rmsDb: rmsDb ?? this.rmsDb,
      noiseFloorDb: noiseFloorDb ?? this.noiseFloorDb,
      snrEstimateDb: snrEstimateDb ?? this.snrEstimateDb,
      clippingCount: clippingCount ?? this.clippingCount,
      leadingSilenceMs: leadingSilenceMs ?? this.leadingSilenceMs,
      trailingSilenceMs: trailingSilenceMs ?? this.trailingSilenceMs,
      noiseReductionMode: noiseReductionMode ?? this.noiseReductionMode,
      noiseReductionEngine: noiseReductionEngine ?? this.noiseReductionEngine,
      processingProfileId: processingProfileId ?? this.processingProfileId,
      status: status ?? this.status,
      rejectionReason: rejectionReason ?? this.rejectionReason,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (projectId.present) {
      map['project_id'] = Variable<String>(projectId.value);
    }
    if (speakerId.present) {
      map['speaker_id'] = Variable<String>(speakerId.value);
    }
    if (promptId.present) {
      map['prompt_id'] = Variable<String>(promptId.value);
    }
    if (rawPath.present) {
      map['raw_path'] = Variable<String>(rawPath.value);
    }
    if (processedPath.present) {
      map['processed_path'] = Variable<String>(processedPath.value);
    }
    if (exportWavPath.present) {
      map['export_wav_path'] = Variable<String>(exportWavPath.value);
    }
    if (rawText.present) {
      map['raw_text'] = Variable<String>(rawText.value);
    }
    if (normalizedText.present) {
      map['normalized_text'] = Variable<String>(normalizedText.value);
    }
    if (language.present) {
      map['language'] = Variable<String>(language.value);
    }
    if (durationMs.present) {
      map['duration_ms'] = Variable<int>(durationMs.value);
    }
    if (sampleRate.present) {
      map['sample_rate'] = Variable<int>(sampleRate.value);
    }
    if (channels.present) {
      map['channels'] = Variable<int>(channels.value);
    }
    if (bitDepth.present) {
      map['bit_depth'] = Variable<int>(bitDepth.value);
    }
    if (peakDb.present) {
      map['peak_db'] = Variable<double>(peakDb.value);
    }
    if (rmsDb.present) {
      map['rms_db'] = Variable<double>(rmsDb.value);
    }
    if (noiseFloorDb.present) {
      map['noise_floor_db'] = Variable<double>(noiseFloorDb.value);
    }
    if (snrEstimateDb.present) {
      map['snr_estimate_db'] = Variable<double>(snrEstimateDb.value);
    }
    if (clippingCount.present) {
      map['clipping_count'] = Variable<int>(clippingCount.value);
    }
    if (leadingSilenceMs.present) {
      map['leading_silence_ms'] = Variable<int>(leadingSilenceMs.value);
    }
    if (trailingSilenceMs.present) {
      map['trailing_silence_ms'] = Variable<int>(trailingSilenceMs.value);
    }
    if (noiseReductionMode.present) {
      map['noise_reduction_mode'] = Variable<String>(noiseReductionMode.value);
    }
    if (noiseReductionEngine.present) {
      map['noise_reduction_engine'] =
          Variable<String>(noiseReductionEngine.value);
    }
    if (processingProfileId.present) {
      map['processing_profile_id'] =
          Variable<String>(processingProfileId.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (rejectionReason.present) {
      map['rejection_reason'] = Variable<String>(rejectionReason.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TtsDatasetClipTableCompanion(')
          ..write('id: $id, ')
          ..write('projectId: $projectId, ')
          ..write('speakerId: $speakerId, ')
          ..write('promptId: $promptId, ')
          ..write('rawPath: $rawPath, ')
          ..write('processedPath: $processedPath, ')
          ..write('exportWavPath: $exportWavPath, ')
          ..write('rawText: $rawText, ')
          ..write('normalizedText: $normalizedText, ')
          ..write('language: $language, ')
          ..write('durationMs: $durationMs, ')
          ..write('sampleRate: $sampleRate, ')
          ..write('channels: $channels, ')
          ..write('bitDepth: $bitDepth, ')
          ..write('peakDb: $peakDb, ')
          ..write('rmsDb: $rmsDb, ')
          ..write('noiseFloorDb: $noiseFloorDb, ')
          ..write('snrEstimateDb: $snrEstimateDb, ')
          ..write('clippingCount: $clippingCount, ')
          ..write('leadingSilenceMs: $leadingSilenceMs, ')
          ..write('trailingSilenceMs: $trailingSilenceMs, ')
          ..write('noiseReductionMode: $noiseReductionMode, ')
          ..write('noiseReductionEngine: $noiseReductionEngine, ')
          ..write('processingProfileId: $processingProfileId, ')
          ..write('status: $status, ')
          ..write('rejectionReason: $rejectionReason, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $TtsDatasetValidationIssueTableTable
    extends TtsDatasetValidationIssueTable
    with
        TableInfo<$TtsDatasetValidationIssueTableTable,
            TtsDatasetValidationIssueTableData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TtsDatasetValidationIssueTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _projectIdMeta =
      const VerificationMeta('projectId');
  @override
  late final GeneratedColumn<String> projectId = GeneratedColumn<String>(
      'project_id', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: true,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'REFERENCES tts_dataset_project_table (id)'));
  static const VerificationMeta _clipIdMeta = const VerificationMeta('clipId');
  @override
  late final GeneratedColumn<String> clipId = GeneratedColumn<String>(
      'clip_id', aliasedName, true,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'REFERENCES tts_dataset_clip_table (id)'));
  static const VerificationMeta _categoryMeta =
      const VerificationMeta('category');
  @override
  late final GeneratedColumn<String> category = GeneratedColumn<String>(
      'category', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _severityMeta =
      const VerificationMeta('severity');
  @override
  late final GeneratedColumn<String> severity = GeneratedColumn<String>(
      'severity', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _codeMeta = const VerificationMeta('code');
  @override
  late final GeneratedColumn<String> code = GeneratedColumn<String>(
      'code', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _messageMeta =
      const VerificationMeta('message');
  @override
  late final GeneratedColumn<String> message = GeneratedColumn<String>(
      'message', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _suggestedFixMeta =
      const VerificationMeta('suggestedFix');
  @override
  late final GeneratedColumn<String> suggestedFix = GeneratedColumn<String>(
      'suggested_fix', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns =>
      [id, projectId, clipId, category, severity, code, message, suggestedFix];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'tts_dataset_validation_issue_table';
  @override
  VerificationContext validateIntegrity(
      Insertable<TtsDatasetValidationIssueTableData> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('project_id')) {
      context.handle(_projectIdMeta,
          projectId.isAcceptableOrUnknown(data['project_id']!, _projectIdMeta));
    } else if (isInserting) {
      context.missing(_projectIdMeta);
    }
    if (data.containsKey('clip_id')) {
      context.handle(_clipIdMeta,
          clipId.isAcceptableOrUnknown(data['clip_id']!, _clipIdMeta));
    }
    if (data.containsKey('category')) {
      context.handle(_categoryMeta,
          category.isAcceptableOrUnknown(data['category']!, _categoryMeta));
    } else if (isInserting) {
      context.missing(_categoryMeta);
    }
    if (data.containsKey('severity')) {
      context.handle(_severityMeta,
          severity.isAcceptableOrUnknown(data['severity']!, _severityMeta));
    } else if (isInserting) {
      context.missing(_severityMeta);
    }
    if (data.containsKey('code')) {
      context.handle(
          _codeMeta, code.isAcceptableOrUnknown(data['code']!, _codeMeta));
    } else if (isInserting) {
      context.missing(_codeMeta);
    }
    if (data.containsKey('message')) {
      context.handle(_messageMeta,
          message.isAcceptableOrUnknown(data['message']!, _messageMeta));
    } else if (isInserting) {
      context.missing(_messageMeta);
    }
    if (data.containsKey('suggested_fix')) {
      context.handle(
          _suggestedFixMeta,
          suggestedFix.isAcceptableOrUnknown(
              data['suggested_fix']!, _suggestedFixMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  TtsDatasetValidationIssueTableData map(Map<String, dynamic> data,
      {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return TtsDatasetValidationIssueTableData(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      projectId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}project_id'])!,
      clipId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}clip_id']),
      category: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}category'])!,
      severity: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}severity'])!,
      code: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}code'])!,
      message: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}message'])!,
      suggestedFix: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}suggested_fix']),
    );
  }

  @override
  $TtsDatasetValidationIssueTableTable createAlias(String alias) {
    return $TtsDatasetValidationIssueTableTable(attachedDatabase, alias);
  }
}

class TtsDatasetValidationIssueTableData extends DataClass
    implements Insertable<TtsDatasetValidationIssueTableData> {
  /// Primary key.
  final String id;

  /// Owning dataset project.
  final String projectId;

  /// Optional affected clip.
  final String? clipId;

  /// Issue category: schema, audio, text, consent, qwen, or export.
  final String category;

  /// Issue severity: error, warning, or info.
  final String severity;

  /// Stable issue code.
  final String code;

  /// User-facing issue message.
  final String message;

  /// Optional suggested fix.
  final String? suggestedFix;
  const TtsDatasetValidationIssueTableData(
      {required this.id,
      required this.projectId,
      this.clipId,
      required this.category,
      required this.severity,
      required this.code,
      required this.message,
      this.suggestedFix});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['project_id'] = Variable<String>(projectId);
    if (!nullToAbsent || clipId != null) {
      map['clip_id'] = Variable<String>(clipId);
    }
    map['category'] = Variable<String>(category);
    map['severity'] = Variable<String>(severity);
    map['code'] = Variable<String>(code);
    map['message'] = Variable<String>(message);
    if (!nullToAbsent || suggestedFix != null) {
      map['suggested_fix'] = Variable<String>(suggestedFix);
    }
    return map;
  }

  TtsDatasetValidationIssueTableCompanion toCompanion(bool nullToAbsent) {
    return TtsDatasetValidationIssueTableCompanion(
      id: Value(id),
      projectId: Value(projectId),
      clipId:
          clipId == null && nullToAbsent ? const Value.absent() : Value(clipId),
      category: Value(category),
      severity: Value(severity),
      code: Value(code),
      message: Value(message),
      suggestedFix: suggestedFix == null && nullToAbsent
          ? const Value.absent()
          : Value(suggestedFix),
    );
  }

  factory TtsDatasetValidationIssueTableData.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return TtsDatasetValidationIssueTableData(
      id: serializer.fromJson<String>(json['id']),
      projectId: serializer.fromJson<String>(json['projectId']),
      clipId: serializer.fromJson<String?>(json['clipId']),
      category: serializer.fromJson<String>(json['category']),
      severity: serializer.fromJson<String>(json['severity']),
      code: serializer.fromJson<String>(json['code']),
      message: serializer.fromJson<String>(json['message']),
      suggestedFix: serializer.fromJson<String?>(json['suggestedFix']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'projectId': serializer.toJson<String>(projectId),
      'clipId': serializer.toJson<String?>(clipId),
      'category': serializer.toJson<String>(category),
      'severity': serializer.toJson<String>(severity),
      'code': serializer.toJson<String>(code),
      'message': serializer.toJson<String>(message),
      'suggestedFix': serializer.toJson<String?>(suggestedFix),
    };
  }

  TtsDatasetValidationIssueTableData copyWith(
          {String? id,
          String? projectId,
          Value<String?> clipId = const Value.absent(),
          String? category,
          String? severity,
          String? code,
          String? message,
          Value<String?> suggestedFix = const Value.absent()}) =>
      TtsDatasetValidationIssueTableData(
        id: id ?? this.id,
        projectId: projectId ?? this.projectId,
        clipId: clipId.present ? clipId.value : this.clipId,
        category: category ?? this.category,
        severity: severity ?? this.severity,
        code: code ?? this.code,
        message: message ?? this.message,
        suggestedFix:
            suggestedFix.present ? suggestedFix.value : this.suggestedFix,
      );
  TtsDatasetValidationIssueTableData copyWithCompanion(
      TtsDatasetValidationIssueTableCompanion data) {
    return TtsDatasetValidationIssueTableData(
      id: data.id.present ? data.id.value : this.id,
      projectId: data.projectId.present ? data.projectId.value : this.projectId,
      clipId: data.clipId.present ? data.clipId.value : this.clipId,
      category: data.category.present ? data.category.value : this.category,
      severity: data.severity.present ? data.severity.value : this.severity,
      code: data.code.present ? data.code.value : this.code,
      message: data.message.present ? data.message.value : this.message,
      suggestedFix: data.suggestedFix.present
          ? data.suggestedFix.value
          : this.suggestedFix,
    );
  }

  @override
  String toString() {
    return (StringBuffer('TtsDatasetValidationIssueTableData(')
          ..write('id: $id, ')
          ..write('projectId: $projectId, ')
          ..write('clipId: $clipId, ')
          ..write('category: $category, ')
          ..write('severity: $severity, ')
          ..write('code: $code, ')
          ..write('message: $message, ')
          ..write('suggestedFix: $suggestedFix')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id, projectId, clipId, category, severity, code, message, suggestedFix);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is TtsDatasetValidationIssueTableData &&
          other.id == this.id &&
          other.projectId == this.projectId &&
          other.clipId == this.clipId &&
          other.category == this.category &&
          other.severity == this.severity &&
          other.code == this.code &&
          other.message == this.message &&
          other.suggestedFix == this.suggestedFix);
}

class TtsDatasetValidationIssueTableCompanion
    extends UpdateCompanion<TtsDatasetValidationIssueTableData> {
  final Value<String> id;
  final Value<String> projectId;
  final Value<String?> clipId;
  final Value<String> category;
  final Value<String> severity;
  final Value<String> code;
  final Value<String> message;
  final Value<String?> suggestedFix;
  final Value<int> rowid;
  const TtsDatasetValidationIssueTableCompanion({
    this.id = const Value.absent(),
    this.projectId = const Value.absent(),
    this.clipId = const Value.absent(),
    this.category = const Value.absent(),
    this.severity = const Value.absent(),
    this.code = const Value.absent(),
    this.message = const Value.absent(),
    this.suggestedFix = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  TtsDatasetValidationIssueTableCompanion.insert({
    required String id,
    required String projectId,
    this.clipId = const Value.absent(),
    required String category,
    required String severity,
    required String code,
    required String message,
    this.suggestedFix = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        projectId = Value(projectId),
        category = Value(category),
        severity = Value(severity),
        code = Value(code),
        message = Value(message);
  static Insertable<TtsDatasetValidationIssueTableData> custom({
    Expression<String>? id,
    Expression<String>? projectId,
    Expression<String>? clipId,
    Expression<String>? category,
    Expression<String>? severity,
    Expression<String>? code,
    Expression<String>? message,
    Expression<String>? suggestedFix,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (projectId != null) 'project_id': projectId,
      if (clipId != null) 'clip_id': clipId,
      if (category != null) 'category': category,
      if (severity != null) 'severity': severity,
      if (code != null) 'code': code,
      if (message != null) 'message': message,
      if (suggestedFix != null) 'suggested_fix': suggestedFix,
      if (rowid != null) 'rowid': rowid,
    });
  }

  TtsDatasetValidationIssueTableCompanion copyWith(
      {Value<String>? id,
      Value<String>? projectId,
      Value<String?>? clipId,
      Value<String>? category,
      Value<String>? severity,
      Value<String>? code,
      Value<String>? message,
      Value<String?>? suggestedFix,
      Value<int>? rowid}) {
    return TtsDatasetValidationIssueTableCompanion(
      id: id ?? this.id,
      projectId: projectId ?? this.projectId,
      clipId: clipId ?? this.clipId,
      category: category ?? this.category,
      severity: severity ?? this.severity,
      code: code ?? this.code,
      message: message ?? this.message,
      suggestedFix: suggestedFix ?? this.suggestedFix,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (projectId.present) {
      map['project_id'] = Variable<String>(projectId.value);
    }
    if (clipId.present) {
      map['clip_id'] = Variable<String>(clipId.value);
    }
    if (category.present) {
      map['category'] = Variable<String>(category.value);
    }
    if (severity.present) {
      map['severity'] = Variable<String>(severity.value);
    }
    if (code.present) {
      map['code'] = Variable<String>(code.value);
    }
    if (message.present) {
      map['message'] = Variable<String>(message.value);
    }
    if (suggestedFix.present) {
      map['suggested_fix'] = Variable<String>(suggestedFix.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TtsDatasetValidationIssueTableCompanion(')
          ..write('id: $id, ')
          ..write('projectId: $projectId, ')
          ..write('clipId: $clipId, ')
          ..write('category: $category, ')
          ..write('severity: $severity, ')
          ..write('code: $code, ')
          ..write('message: $message, ')
          ..write('suggestedFix: $suggestedFix, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $WhoisHistoryTableTable whoisHistoryTable =
      $WhoisHistoryTableTable(this);
  late final $DnsZoneTableTable dnsZoneTable = $DnsZoneTableTable(this);
  late final $GitHubRepoTableTable gitHubRepoTable =
      $GitHubRepoTableTable(this);
  late final $ChatConversationTableTable chatConversationTable =
      $ChatConversationTableTable(this);
  late final $ChatMessageTableTable chatMessageTable =
      $ChatMessageTableTable(this);
  late final $ChatSettingsTableTable chatSettingsTable =
      $ChatSettingsTableTable(this);
  late final $ServiceAccountTableTable serviceAccountTable =
      $ServiceAccountTableTable(this);
  late final $MonitorHostTableTable monitorHostTable =
      $MonitorHostTableTable(this);
  late final $MonitorTrustedCertTableTable monitorTrustedCertTable =
      $MonitorTrustedCertTableTable(this);
  late final $TtsDatasetProjectTableTable ttsDatasetProjectTable =
      $TtsDatasetProjectTableTable(this);
  late final $TtsDatasetSpeakerTableTable ttsDatasetSpeakerTable =
      $TtsDatasetSpeakerTableTable(this);
  late final $TtsDatasetPromptTableTable ttsDatasetPromptTable =
      $TtsDatasetPromptTableTable(this);
  late final $TtsDatasetClipTableTable ttsDatasetClipTable =
      $TtsDatasetClipTableTable(this);
  late final $TtsDatasetValidationIssueTableTable
      ttsDatasetValidationIssueTable =
      $TtsDatasetValidationIssueTableTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
        whoisHistoryTable,
        dnsZoneTable,
        gitHubRepoTable,
        chatConversationTable,
        chatMessageTable,
        chatSettingsTable,
        serviceAccountTable,
        monitorHostTable,
        monitorTrustedCertTable,
        ttsDatasetProjectTable,
        ttsDatasetSpeakerTable,
        ttsDatasetPromptTable,
        ttsDatasetClipTable,
        ttsDatasetValidationIssueTable
      ];
}

typedef $$WhoisHistoryTableTableCreateCompanionBuilder
    = WhoisHistoryTableCompanion Function({
  Value<int> id,
  Value<String?> query,
  Value<List<String>?> result,
  Value<DateTime> createdAt,
});
typedef $$WhoisHistoryTableTableUpdateCompanionBuilder
    = WhoisHistoryTableCompanion Function({
  Value<int> id,
  Value<String?> query,
  Value<List<String>?> result,
  Value<DateTime> createdAt,
});

class $$WhoisHistoryTableTableFilterComposer
    extends Composer<_$AppDatabase, $WhoisHistoryTableTable> {
  $$WhoisHistoryTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get query => $composableBuilder(
      column: $table.query, builder: (column) => ColumnFilters(column));

  ColumnWithTypeConverterFilters<List<String>?, List<String>, String>
      get result => $composableBuilder(
          column: $table.result,
          builder: (column) => ColumnWithTypeConverterFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));
}

class $$WhoisHistoryTableTableOrderingComposer
    extends Composer<_$AppDatabase, $WhoisHistoryTableTable> {
  $$WhoisHistoryTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get query => $composableBuilder(
      column: $table.query, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get result => $composableBuilder(
      column: $table.result, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));
}

class $$WhoisHistoryTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $WhoisHistoryTableTable> {
  $$WhoisHistoryTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get query =>
      $composableBuilder(column: $table.query, builder: (column) => column);

  GeneratedColumnWithTypeConverter<List<String>?, String> get result =>
      $composableBuilder(column: $table.result, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$WhoisHistoryTableTableTableManager extends RootTableManager<
    _$AppDatabase,
    $WhoisHistoryTableTable,
    WhoisHistoryTableData,
    $$WhoisHistoryTableTableFilterComposer,
    $$WhoisHistoryTableTableOrderingComposer,
    $$WhoisHistoryTableTableAnnotationComposer,
    $$WhoisHistoryTableTableCreateCompanionBuilder,
    $$WhoisHistoryTableTableUpdateCompanionBuilder,
    (
      WhoisHistoryTableData,
      BaseReferences<_$AppDatabase, $WhoisHistoryTableTable,
          WhoisHistoryTableData>
    ),
    WhoisHistoryTableData,
    PrefetchHooks Function()> {
  $$WhoisHistoryTableTableTableManager(
      _$AppDatabase db, $WhoisHistoryTableTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$WhoisHistoryTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$WhoisHistoryTableTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$WhoisHistoryTableTableAnnotationComposer(
                  $db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<String?> query = const Value.absent(),
            Value<List<String>?> result = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
          }) =>
              WhoisHistoryTableCompanion(
            id: id,
            query: query,
            result: result,
            createdAt: createdAt,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<String?> query = const Value.absent(),
            Value<List<String>?> result = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
          }) =>
              WhoisHistoryTableCompanion.insert(
            id: id,
            query: query,
            result: result,
            createdAt: createdAt,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$WhoisHistoryTableTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $WhoisHistoryTableTable,
    WhoisHistoryTableData,
    $$WhoisHistoryTableTableFilterComposer,
    $$WhoisHistoryTableTableOrderingComposer,
    $$WhoisHistoryTableTableAnnotationComposer,
    $$WhoisHistoryTableTableCreateCompanionBuilder,
    $$WhoisHistoryTableTableUpdateCompanionBuilder,
    (
      WhoisHistoryTableData,
      BaseReferences<_$AppDatabase, $WhoisHistoryTableTable,
          WhoisHistoryTableData>
    ),
    WhoisHistoryTableData,
    PrefetchHooks Function()>;
typedef $$DnsZoneTableTableCreateCompanionBuilder = DnsZoneTableCompanion
    Function({
  Value<int> id,
  required DnsProvider provider,
  required String zoneId,
  required String zoneName,
  required int serviceAccountId,
  Value<String?> comment,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
});
typedef $$DnsZoneTableTableUpdateCompanionBuilder = DnsZoneTableCompanion
    Function({
  Value<int> id,
  Value<DnsProvider> provider,
  Value<String> zoneId,
  Value<String> zoneName,
  Value<int> serviceAccountId,
  Value<String?> comment,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
});

class $$DnsZoneTableTableFilterComposer
    extends Composer<_$AppDatabase, $DnsZoneTableTable> {
  $$DnsZoneTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnWithTypeConverterFilters<DnsProvider, DnsProvider, String>
      get provider => $composableBuilder(
          column: $table.provider,
          builder: (column) => ColumnWithTypeConverterFilters(column));

  ColumnFilters<String> get zoneId => $composableBuilder(
      column: $table.zoneId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get zoneName => $composableBuilder(
      column: $table.zoneName, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get serviceAccountId => $composableBuilder(
      column: $table.serviceAccountId,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get comment => $composableBuilder(
      column: $table.comment, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnFilters(column));
}

class $$DnsZoneTableTableOrderingComposer
    extends Composer<_$AppDatabase, $DnsZoneTableTable> {
  $$DnsZoneTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get provider => $composableBuilder(
      column: $table.provider, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get zoneId => $composableBuilder(
      column: $table.zoneId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get zoneName => $composableBuilder(
      column: $table.zoneName, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get serviceAccountId => $composableBuilder(
      column: $table.serviceAccountId,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get comment => $composableBuilder(
      column: $table.comment, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnOrderings(column));
}

class $$DnsZoneTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $DnsZoneTableTable> {
  $$DnsZoneTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumnWithTypeConverter<DnsProvider, String> get provider =>
      $composableBuilder(column: $table.provider, builder: (column) => column);

  GeneratedColumn<String> get zoneId =>
      $composableBuilder(column: $table.zoneId, builder: (column) => column);

  GeneratedColumn<String> get zoneName =>
      $composableBuilder(column: $table.zoneName, builder: (column) => column);

  GeneratedColumn<int> get serviceAccountId => $composableBuilder(
      column: $table.serviceAccountId, builder: (column) => column);

  GeneratedColumn<String> get comment =>
      $composableBuilder(column: $table.comment, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$DnsZoneTableTableTableManager extends RootTableManager<
    _$AppDatabase,
    $DnsZoneTableTable,
    DnsZoneTableData,
    $$DnsZoneTableTableFilterComposer,
    $$DnsZoneTableTableOrderingComposer,
    $$DnsZoneTableTableAnnotationComposer,
    $$DnsZoneTableTableCreateCompanionBuilder,
    $$DnsZoneTableTableUpdateCompanionBuilder,
    (
      DnsZoneTableData,
      BaseReferences<_$AppDatabase, $DnsZoneTableTable, DnsZoneTableData>
    ),
    DnsZoneTableData,
    PrefetchHooks Function()> {
  $$DnsZoneTableTableTableManager(_$AppDatabase db, $DnsZoneTableTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$DnsZoneTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$DnsZoneTableTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$DnsZoneTableTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<DnsProvider> provider = const Value.absent(),
            Value<String> zoneId = const Value.absent(),
            Value<String> zoneName = const Value.absent(),
            Value<int> serviceAccountId = const Value.absent(),
            Value<String?> comment = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
          }) =>
              DnsZoneTableCompanion(
            id: id,
            provider: provider,
            zoneId: zoneId,
            zoneName: zoneName,
            serviceAccountId: serviceAccountId,
            comment: comment,
            createdAt: createdAt,
            updatedAt: updatedAt,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required DnsProvider provider,
            required String zoneId,
            required String zoneName,
            required int serviceAccountId,
            Value<String?> comment = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
          }) =>
              DnsZoneTableCompanion.insert(
            id: id,
            provider: provider,
            zoneId: zoneId,
            zoneName: zoneName,
            serviceAccountId: serviceAccountId,
            comment: comment,
            createdAt: createdAt,
            updatedAt: updatedAt,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$DnsZoneTableTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $DnsZoneTableTable,
    DnsZoneTableData,
    $$DnsZoneTableTableFilterComposer,
    $$DnsZoneTableTableOrderingComposer,
    $$DnsZoneTableTableAnnotationComposer,
    $$DnsZoneTableTableCreateCompanionBuilder,
    $$DnsZoneTableTableUpdateCompanionBuilder,
    (
      DnsZoneTableData,
      BaseReferences<_$AppDatabase, $DnsZoneTableTable, DnsZoneTableData>
    ),
    DnsZoneTableData,
    PrefetchHooks Function()>;
typedef $$GitHubRepoTableTableCreateCompanionBuilder = GitHubRepoTableCompanion
    Function({
  Value<int> id,
  required int repoId,
  required String fullName,
  required String name,
  required String ownerLogin,
  Value<String?> ownerAvatarUrl,
  Value<String?> description,
  Value<bool> isPrivate,
  Value<String> defaultBranch,
  Value<int> stargazersCount,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
});
typedef $$GitHubRepoTableTableUpdateCompanionBuilder = GitHubRepoTableCompanion
    Function({
  Value<int> id,
  Value<int> repoId,
  Value<String> fullName,
  Value<String> name,
  Value<String> ownerLogin,
  Value<String?> ownerAvatarUrl,
  Value<String?> description,
  Value<bool> isPrivate,
  Value<String> defaultBranch,
  Value<int> stargazersCount,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
});

class $$GitHubRepoTableTableFilterComposer
    extends Composer<_$AppDatabase, $GitHubRepoTableTable> {
  $$GitHubRepoTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get repoId => $composableBuilder(
      column: $table.repoId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get fullName => $composableBuilder(
      column: $table.fullName, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get ownerLogin => $composableBuilder(
      column: $table.ownerLogin, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get ownerAvatarUrl => $composableBuilder(
      column: $table.ownerAvatarUrl,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get description => $composableBuilder(
      column: $table.description, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get isPrivate => $composableBuilder(
      column: $table.isPrivate, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get defaultBranch => $composableBuilder(
      column: $table.defaultBranch, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get stargazersCount => $composableBuilder(
      column: $table.stargazersCount,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnFilters(column));
}

class $$GitHubRepoTableTableOrderingComposer
    extends Composer<_$AppDatabase, $GitHubRepoTableTable> {
  $$GitHubRepoTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get repoId => $composableBuilder(
      column: $table.repoId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get fullName => $composableBuilder(
      column: $table.fullName, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get ownerLogin => $composableBuilder(
      column: $table.ownerLogin, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get ownerAvatarUrl => $composableBuilder(
      column: $table.ownerAvatarUrl,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get description => $composableBuilder(
      column: $table.description, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get isPrivate => $composableBuilder(
      column: $table.isPrivate, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get defaultBranch => $composableBuilder(
      column: $table.defaultBranch,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get stargazersCount => $composableBuilder(
      column: $table.stargazersCount,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnOrderings(column));
}

class $$GitHubRepoTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $GitHubRepoTableTable> {
  $$GitHubRepoTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get repoId =>
      $composableBuilder(column: $table.repoId, builder: (column) => column);

  GeneratedColumn<String> get fullName =>
      $composableBuilder(column: $table.fullName, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get ownerLogin => $composableBuilder(
      column: $table.ownerLogin, builder: (column) => column);

  GeneratedColumn<String> get ownerAvatarUrl => $composableBuilder(
      column: $table.ownerAvatarUrl, builder: (column) => column);

  GeneratedColumn<String> get description => $composableBuilder(
      column: $table.description, builder: (column) => column);

  GeneratedColumn<bool> get isPrivate =>
      $composableBuilder(column: $table.isPrivate, builder: (column) => column);

  GeneratedColumn<String> get defaultBranch => $composableBuilder(
      column: $table.defaultBranch, builder: (column) => column);

  GeneratedColumn<int> get stargazersCount => $composableBuilder(
      column: $table.stargazersCount, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$GitHubRepoTableTableTableManager extends RootTableManager<
    _$AppDatabase,
    $GitHubRepoTableTable,
    GitHubRepoTableData,
    $$GitHubRepoTableTableFilterComposer,
    $$GitHubRepoTableTableOrderingComposer,
    $$GitHubRepoTableTableAnnotationComposer,
    $$GitHubRepoTableTableCreateCompanionBuilder,
    $$GitHubRepoTableTableUpdateCompanionBuilder,
    (
      GitHubRepoTableData,
      BaseReferences<_$AppDatabase, $GitHubRepoTableTable, GitHubRepoTableData>
    ),
    GitHubRepoTableData,
    PrefetchHooks Function()> {
  $$GitHubRepoTableTableTableManager(
      _$AppDatabase db, $GitHubRepoTableTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$GitHubRepoTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$GitHubRepoTableTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$GitHubRepoTableTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<int> repoId = const Value.absent(),
            Value<String> fullName = const Value.absent(),
            Value<String> name = const Value.absent(),
            Value<String> ownerLogin = const Value.absent(),
            Value<String?> ownerAvatarUrl = const Value.absent(),
            Value<String?> description = const Value.absent(),
            Value<bool> isPrivate = const Value.absent(),
            Value<String> defaultBranch = const Value.absent(),
            Value<int> stargazersCount = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
          }) =>
              GitHubRepoTableCompanion(
            id: id,
            repoId: repoId,
            fullName: fullName,
            name: name,
            ownerLogin: ownerLogin,
            ownerAvatarUrl: ownerAvatarUrl,
            description: description,
            isPrivate: isPrivate,
            defaultBranch: defaultBranch,
            stargazersCount: stargazersCount,
            createdAt: createdAt,
            updatedAt: updatedAt,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required int repoId,
            required String fullName,
            required String name,
            required String ownerLogin,
            Value<String?> ownerAvatarUrl = const Value.absent(),
            Value<String?> description = const Value.absent(),
            Value<bool> isPrivate = const Value.absent(),
            Value<String> defaultBranch = const Value.absent(),
            Value<int> stargazersCount = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
          }) =>
              GitHubRepoTableCompanion.insert(
            id: id,
            repoId: repoId,
            fullName: fullName,
            name: name,
            ownerLogin: ownerLogin,
            ownerAvatarUrl: ownerAvatarUrl,
            description: description,
            isPrivate: isPrivate,
            defaultBranch: defaultBranch,
            stargazersCount: stargazersCount,
            createdAt: createdAt,
            updatedAt: updatedAt,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$GitHubRepoTableTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $GitHubRepoTableTable,
    GitHubRepoTableData,
    $$GitHubRepoTableTableFilterComposer,
    $$GitHubRepoTableTableOrderingComposer,
    $$GitHubRepoTableTableAnnotationComposer,
    $$GitHubRepoTableTableCreateCompanionBuilder,
    $$GitHubRepoTableTableUpdateCompanionBuilder,
    (
      GitHubRepoTableData,
      BaseReferences<_$AppDatabase, $GitHubRepoTableTable, GitHubRepoTableData>
    ),
    GitHubRepoTableData,
    PrefetchHooks Function()>;
typedef $$ChatConversationTableTableCreateCompanionBuilder
    = ChatConversationTableCompanion Function({
  required String id,
  required String title,
  Value<String?> systemPrompt,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
  Value<int> rowid,
});
typedef $$ChatConversationTableTableUpdateCompanionBuilder
    = ChatConversationTableCompanion Function({
  Value<String> id,
  Value<String> title,
  Value<String?> systemPrompt,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
  Value<int> rowid,
});

final class $$ChatConversationTableTableReferences extends BaseReferences<
    _$AppDatabase, $ChatConversationTableTable, ChatConversationTableData> {
  $$ChatConversationTableTableReferences(
      super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$ChatMessageTableTable, List<ChatMessageTableData>>
      _chatMessageTableRefsTable(_$AppDatabase db) =>
          MultiTypedResultKey.fromTable(db.chatMessageTable,
              aliasName: $_aliasNameGenerator(db.chatConversationTable.id,
                  db.chatMessageTable.conversationId));

  $$ChatMessageTableTableProcessedTableManager get chatMessageTableRefs {
    final manager =
        $$ChatMessageTableTableTableManager($_db, $_db.chatMessageTable).filter(
            (f) => f.conversationId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache =
        $_typedResult.readTableOrNull(_chatMessageTableRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }
}

class $$ChatConversationTableTableFilterComposer
    extends Composer<_$AppDatabase, $ChatConversationTableTable> {
  $$ChatConversationTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get title => $composableBuilder(
      column: $table.title, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get systemPrompt => $composableBuilder(
      column: $table.systemPrompt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnFilters(column));

  Expression<bool> chatMessageTableRefs(
      Expression<bool> Function($$ChatMessageTableTableFilterComposer f) f) {
    final $$ChatMessageTableTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.chatMessageTable,
        getReferencedColumn: (t) => t.conversationId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$ChatMessageTableTableFilterComposer(
              $db: $db,
              $table: $db.chatMessageTable,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }
}

class $$ChatConversationTableTableOrderingComposer
    extends Composer<_$AppDatabase, $ChatConversationTableTable> {
  $$ChatConversationTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get title => $composableBuilder(
      column: $table.title, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get systemPrompt => $composableBuilder(
      column: $table.systemPrompt,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnOrderings(column));
}

class $$ChatConversationTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $ChatConversationTableTable> {
  $$ChatConversationTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<String> get systemPrompt => $composableBuilder(
      column: $table.systemPrompt, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  Expression<T> chatMessageTableRefs<T extends Object>(
      Expression<T> Function($$ChatMessageTableTableAnnotationComposer a) f) {
    final $$ChatMessageTableTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.chatMessageTable,
        getReferencedColumn: (t) => t.conversationId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$ChatMessageTableTableAnnotationComposer(
              $db: $db,
              $table: $db.chatMessageTable,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }
}

class $$ChatConversationTableTableTableManager extends RootTableManager<
    _$AppDatabase,
    $ChatConversationTableTable,
    ChatConversationTableData,
    $$ChatConversationTableTableFilterComposer,
    $$ChatConversationTableTableOrderingComposer,
    $$ChatConversationTableTableAnnotationComposer,
    $$ChatConversationTableTableCreateCompanionBuilder,
    $$ChatConversationTableTableUpdateCompanionBuilder,
    (ChatConversationTableData, $$ChatConversationTableTableReferences),
    ChatConversationTableData,
    PrefetchHooks Function({bool chatMessageTableRefs})> {
  $$ChatConversationTableTableTableManager(
      _$AppDatabase db, $ChatConversationTableTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ChatConversationTableTableFilterComposer(
                  $db: db, $table: table),
          createOrderingComposer: () =>
              $$ChatConversationTableTableOrderingComposer(
                  $db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ChatConversationTableTableAnnotationComposer(
                  $db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> title = const Value.absent(),
            Value<String?> systemPrompt = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              ChatConversationTableCompanion(
            id: id,
            title: title,
            systemPrompt: systemPrompt,
            createdAt: createdAt,
            updatedAt: updatedAt,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String title,
            Value<String?> systemPrompt = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              ChatConversationTableCompanion.insert(
            id: id,
            title: title,
            systemPrompt: systemPrompt,
            createdAt: createdAt,
            updatedAt: updatedAt,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable(table),
                    $$ChatConversationTableTableReferences(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: ({chatMessageTableRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [
                if (chatMessageTableRefs) db.chatMessageTable
              ],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (chatMessageTableRefs)
                    await $_getPrefetchedData<ChatConversationTableData,
                            $ChatConversationTableTable, ChatMessageTableData>(
                        currentTable: table,
                        referencedTable: $$ChatConversationTableTableReferences
                            ._chatMessageTableRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$ChatConversationTableTableReferences(
                                    db, table, p0)
                                .chatMessageTableRefs,
                        referencedItemsForCurrentItem:
                            (item, referencedItems) => referencedItems
                                .where((e) => e.conversationId == item.id),
                        typedResults: items)
                ];
              },
            );
          },
        ));
}

typedef $$ChatConversationTableTableProcessedTableManager
    = ProcessedTableManager<
        _$AppDatabase,
        $ChatConversationTableTable,
        ChatConversationTableData,
        $$ChatConversationTableTableFilterComposer,
        $$ChatConversationTableTableOrderingComposer,
        $$ChatConversationTableTableAnnotationComposer,
        $$ChatConversationTableTableCreateCompanionBuilder,
        $$ChatConversationTableTableUpdateCompanionBuilder,
        (ChatConversationTableData, $$ChatConversationTableTableReferences),
        ChatConversationTableData,
        PrefetchHooks Function({bool chatMessageTableRefs})>;
typedef $$ChatMessageTableTableCreateCompanionBuilder
    = ChatMessageTableCompanion Function({
  required String id,
  required String conversationId,
  required String role,
  required String content,
  Value<int?> tokenCount,
  Value<int?> responseOutputTokens,
  Value<int?> responseContextTokens,
  Value<int?> responseMaxOutputTokens,
  Value<int?> responseDurationMs,
  Value<Uint8List?> imageBytes,
  Value<String?> toolName,
  Value<DateTime> timestamp,
  Value<int> rowid,
});
typedef $$ChatMessageTableTableUpdateCompanionBuilder
    = ChatMessageTableCompanion Function({
  Value<String> id,
  Value<String> conversationId,
  Value<String> role,
  Value<String> content,
  Value<int?> tokenCount,
  Value<int?> responseOutputTokens,
  Value<int?> responseContextTokens,
  Value<int?> responseMaxOutputTokens,
  Value<int?> responseDurationMs,
  Value<Uint8List?> imageBytes,
  Value<String?> toolName,
  Value<DateTime> timestamp,
  Value<int> rowid,
});

final class $$ChatMessageTableTableReferences extends BaseReferences<
    _$AppDatabase, $ChatMessageTableTable, ChatMessageTableData> {
  $$ChatMessageTableTableReferences(
      super.$_db, super.$_table, super.$_typedResult);

  static $ChatConversationTableTable _conversationIdTable(_$AppDatabase db) =>
      db.chatConversationTable.createAlias($_aliasNameGenerator(
          db.chatMessageTable.conversationId, db.chatConversationTable.id));

  $$ChatConversationTableTableProcessedTableManager get conversationId {
    final $_column = $_itemColumn<String>('conversation_id')!;

    final manager = $$ChatConversationTableTableTableManager(
            $_db, $_db.chatConversationTable)
        .filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_conversationIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }
}

class $$ChatMessageTableTableFilterComposer
    extends Composer<_$AppDatabase, $ChatMessageTableTable> {
  $$ChatMessageTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get role => $composableBuilder(
      column: $table.role, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get content => $composableBuilder(
      column: $table.content, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get tokenCount => $composableBuilder(
      column: $table.tokenCount, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get responseOutputTokens => $composableBuilder(
      column: $table.responseOutputTokens,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get responseContextTokens => $composableBuilder(
      column: $table.responseContextTokens,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get responseMaxOutputTokens => $composableBuilder(
      column: $table.responseMaxOutputTokens,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get responseDurationMs => $composableBuilder(
      column: $table.responseDurationMs,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<Uint8List> get imageBytes => $composableBuilder(
      column: $table.imageBytes, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get toolName => $composableBuilder(
      column: $table.toolName, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get timestamp => $composableBuilder(
      column: $table.timestamp, builder: (column) => ColumnFilters(column));

  $$ChatConversationTableTableFilterComposer get conversationId {
    final $$ChatConversationTableTableFilterComposer composer =
        $composerBuilder(
            composer: this,
            getCurrentColumn: (t) => t.conversationId,
            referencedTable: $db.chatConversationTable,
            getReferencedColumn: (t) => t.id,
            builder: (joinBuilder,
                    {$addJoinBuilderToRootComposer,
                    $removeJoinBuilderFromRootComposer}) =>
                $$ChatConversationTableTableFilterComposer(
                  $db: $db,
                  $table: $db.chatConversationTable,
                  $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                  joinBuilder: joinBuilder,
                  $removeJoinBuilderFromRootComposer:
                      $removeJoinBuilderFromRootComposer,
                ));
    return composer;
  }
}

class $$ChatMessageTableTableOrderingComposer
    extends Composer<_$AppDatabase, $ChatMessageTableTable> {
  $$ChatMessageTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get role => $composableBuilder(
      column: $table.role, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get content => $composableBuilder(
      column: $table.content, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get tokenCount => $composableBuilder(
      column: $table.tokenCount, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get responseOutputTokens => $composableBuilder(
      column: $table.responseOutputTokens,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get responseContextTokens => $composableBuilder(
      column: $table.responseContextTokens,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get responseMaxOutputTokens => $composableBuilder(
      column: $table.responseMaxOutputTokens,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get responseDurationMs => $composableBuilder(
      column: $table.responseDurationMs,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<Uint8List> get imageBytes => $composableBuilder(
      column: $table.imageBytes, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get toolName => $composableBuilder(
      column: $table.toolName, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get timestamp => $composableBuilder(
      column: $table.timestamp, builder: (column) => ColumnOrderings(column));

  $$ChatConversationTableTableOrderingComposer get conversationId {
    final $$ChatConversationTableTableOrderingComposer composer =
        $composerBuilder(
            composer: this,
            getCurrentColumn: (t) => t.conversationId,
            referencedTable: $db.chatConversationTable,
            getReferencedColumn: (t) => t.id,
            builder: (joinBuilder,
                    {$addJoinBuilderToRootComposer,
                    $removeJoinBuilderFromRootComposer}) =>
                $$ChatConversationTableTableOrderingComposer(
                  $db: $db,
                  $table: $db.chatConversationTable,
                  $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                  joinBuilder: joinBuilder,
                  $removeJoinBuilderFromRootComposer:
                      $removeJoinBuilderFromRootComposer,
                ));
    return composer;
  }
}

class $$ChatMessageTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $ChatMessageTableTable> {
  $$ChatMessageTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get role =>
      $composableBuilder(column: $table.role, builder: (column) => column);

  GeneratedColumn<String> get content =>
      $composableBuilder(column: $table.content, builder: (column) => column);

  GeneratedColumn<int> get tokenCount => $composableBuilder(
      column: $table.tokenCount, builder: (column) => column);

  GeneratedColumn<int> get responseOutputTokens => $composableBuilder(
      column: $table.responseOutputTokens, builder: (column) => column);

  GeneratedColumn<int> get responseContextTokens => $composableBuilder(
      column: $table.responseContextTokens, builder: (column) => column);

  GeneratedColumn<int> get responseMaxOutputTokens => $composableBuilder(
      column: $table.responseMaxOutputTokens, builder: (column) => column);

  GeneratedColumn<int> get responseDurationMs => $composableBuilder(
      column: $table.responseDurationMs, builder: (column) => column);

  GeneratedColumn<Uint8List> get imageBytes => $composableBuilder(
      column: $table.imageBytes, builder: (column) => column);

  GeneratedColumn<String> get toolName =>
      $composableBuilder(column: $table.toolName, builder: (column) => column);

  GeneratedColumn<DateTime> get timestamp =>
      $composableBuilder(column: $table.timestamp, builder: (column) => column);

  $$ChatConversationTableTableAnnotationComposer get conversationId {
    final $$ChatConversationTableTableAnnotationComposer composer =
        $composerBuilder(
            composer: this,
            getCurrentColumn: (t) => t.conversationId,
            referencedTable: $db.chatConversationTable,
            getReferencedColumn: (t) => t.id,
            builder: (joinBuilder,
                    {$addJoinBuilderToRootComposer,
                    $removeJoinBuilderFromRootComposer}) =>
                $$ChatConversationTableTableAnnotationComposer(
                  $db: $db,
                  $table: $db.chatConversationTable,
                  $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                  joinBuilder: joinBuilder,
                  $removeJoinBuilderFromRootComposer:
                      $removeJoinBuilderFromRootComposer,
                ));
    return composer;
  }
}

class $$ChatMessageTableTableTableManager extends RootTableManager<
    _$AppDatabase,
    $ChatMessageTableTable,
    ChatMessageTableData,
    $$ChatMessageTableTableFilterComposer,
    $$ChatMessageTableTableOrderingComposer,
    $$ChatMessageTableTableAnnotationComposer,
    $$ChatMessageTableTableCreateCompanionBuilder,
    $$ChatMessageTableTableUpdateCompanionBuilder,
    (ChatMessageTableData, $$ChatMessageTableTableReferences),
    ChatMessageTableData,
    PrefetchHooks Function({bool conversationId})> {
  $$ChatMessageTableTableTableManager(
      _$AppDatabase db, $ChatMessageTableTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ChatMessageTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ChatMessageTableTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ChatMessageTableTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> conversationId = const Value.absent(),
            Value<String> role = const Value.absent(),
            Value<String> content = const Value.absent(),
            Value<int?> tokenCount = const Value.absent(),
            Value<int?> responseOutputTokens = const Value.absent(),
            Value<int?> responseContextTokens = const Value.absent(),
            Value<int?> responseMaxOutputTokens = const Value.absent(),
            Value<int?> responseDurationMs = const Value.absent(),
            Value<Uint8List?> imageBytes = const Value.absent(),
            Value<String?> toolName = const Value.absent(),
            Value<DateTime> timestamp = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              ChatMessageTableCompanion(
            id: id,
            conversationId: conversationId,
            role: role,
            content: content,
            tokenCount: tokenCount,
            responseOutputTokens: responseOutputTokens,
            responseContextTokens: responseContextTokens,
            responseMaxOutputTokens: responseMaxOutputTokens,
            responseDurationMs: responseDurationMs,
            imageBytes: imageBytes,
            toolName: toolName,
            timestamp: timestamp,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String conversationId,
            required String role,
            required String content,
            Value<int?> tokenCount = const Value.absent(),
            Value<int?> responseOutputTokens = const Value.absent(),
            Value<int?> responseContextTokens = const Value.absent(),
            Value<int?> responseMaxOutputTokens = const Value.absent(),
            Value<int?> responseDurationMs = const Value.absent(),
            Value<Uint8List?> imageBytes = const Value.absent(),
            Value<String?> toolName = const Value.absent(),
            Value<DateTime> timestamp = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              ChatMessageTableCompanion.insert(
            id: id,
            conversationId: conversationId,
            role: role,
            content: content,
            tokenCount: tokenCount,
            responseOutputTokens: responseOutputTokens,
            responseContextTokens: responseContextTokens,
            responseMaxOutputTokens: responseMaxOutputTokens,
            responseDurationMs: responseDurationMs,
            imageBytes: imageBytes,
            toolName: toolName,
            timestamp: timestamp,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable(table),
                    $$ChatMessageTableTableReferences(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: ({conversationId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins: <
                  T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic>>(state) {
                if (conversationId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.conversationId,
                    referencedTable: $$ChatMessageTableTableReferences
                        ._conversationIdTable(db),
                    referencedColumn: $$ChatMessageTableTableReferences
                        ._conversationIdTable(db)
                        .id,
                  ) as T;
                }

                return state;
              },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ));
}

typedef $$ChatMessageTableTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $ChatMessageTableTable,
    ChatMessageTableData,
    $$ChatMessageTableTableFilterComposer,
    $$ChatMessageTableTableOrderingComposer,
    $$ChatMessageTableTableAnnotationComposer,
    $$ChatMessageTableTableCreateCompanionBuilder,
    $$ChatMessageTableTableUpdateCompanionBuilder,
    (ChatMessageTableData, $$ChatMessageTableTableReferences),
    ChatMessageTableData,
    PrefetchHooks Function({bool conversationId})>;
typedef $$ChatSettingsTableTableCreateCompanionBuilder
    = ChatSettingsTableCompanion Function({
  Value<String> key,
  Value<String> inferenceMode,
  Value<String> modelType,
  Value<String?> customModelPath,
  Value<int> maxTokens,
  Value<int> temperatureX100,
  Value<int> topK,
  Value<String> backend,
  Value<String> remoteProvider,
  Value<String> remoteApiType,
  Value<int?> remoteAccountId,
  Value<String> remoteBaseUrl,
  Value<String> remoteModel,
  Value<String> remoteAuthType,
  Value<String?> remoteAuthHeaderName,
  Value<bool> remoteStreamingEnabled,
  Value<String> remoteThinkingEffort,
  Value<String?> defaultSystemPrompt,
  Value<String?> localModelId,
  Value<int> rowid,
});
typedef $$ChatSettingsTableTableUpdateCompanionBuilder
    = ChatSettingsTableCompanion Function({
  Value<String> key,
  Value<String> inferenceMode,
  Value<String> modelType,
  Value<String?> customModelPath,
  Value<int> maxTokens,
  Value<int> temperatureX100,
  Value<int> topK,
  Value<String> backend,
  Value<String> remoteProvider,
  Value<String> remoteApiType,
  Value<int?> remoteAccountId,
  Value<String> remoteBaseUrl,
  Value<String> remoteModel,
  Value<String> remoteAuthType,
  Value<String?> remoteAuthHeaderName,
  Value<bool> remoteStreamingEnabled,
  Value<String> remoteThinkingEffort,
  Value<String?> defaultSystemPrompt,
  Value<String?> localModelId,
  Value<int> rowid,
});

class $$ChatSettingsTableTableFilterComposer
    extends Composer<_$AppDatabase, $ChatSettingsTableTable> {
  $$ChatSettingsTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get key => $composableBuilder(
      column: $table.key, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get inferenceMode => $composableBuilder(
      column: $table.inferenceMode, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get modelType => $composableBuilder(
      column: $table.modelType, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get customModelPath => $composableBuilder(
      column: $table.customModelPath,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get maxTokens => $composableBuilder(
      column: $table.maxTokens, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get temperatureX100 => $composableBuilder(
      column: $table.temperatureX100,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get topK => $composableBuilder(
      column: $table.topK, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get backend => $composableBuilder(
      column: $table.backend, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get remoteProvider => $composableBuilder(
      column: $table.remoteProvider,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get remoteApiType => $composableBuilder(
      column: $table.remoteApiType, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get remoteAccountId => $composableBuilder(
      column: $table.remoteAccountId,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get remoteBaseUrl => $composableBuilder(
      column: $table.remoteBaseUrl, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get remoteModel => $composableBuilder(
      column: $table.remoteModel, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get remoteAuthType => $composableBuilder(
      column: $table.remoteAuthType,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get remoteAuthHeaderName => $composableBuilder(
      column: $table.remoteAuthHeaderName,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get remoteStreamingEnabled => $composableBuilder(
      column: $table.remoteStreamingEnabled,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get remoteThinkingEffort => $composableBuilder(
      column: $table.remoteThinkingEffort,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get defaultSystemPrompt => $composableBuilder(
      column: $table.defaultSystemPrompt,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get localModelId => $composableBuilder(
      column: $table.localModelId, builder: (column) => ColumnFilters(column));
}

class $$ChatSettingsTableTableOrderingComposer
    extends Composer<_$AppDatabase, $ChatSettingsTableTable> {
  $$ChatSettingsTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get key => $composableBuilder(
      column: $table.key, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get inferenceMode => $composableBuilder(
      column: $table.inferenceMode,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get modelType => $composableBuilder(
      column: $table.modelType, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get customModelPath => $composableBuilder(
      column: $table.customModelPath,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get maxTokens => $composableBuilder(
      column: $table.maxTokens, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get temperatureX100 => $composableBuilder(
      column: $table.temperatureX100,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get topK => $composableBuilder(
      column: $table.topK, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get backend => $composableBuilder(
      column: $table.backend, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get remoteProvider => $composableBuilder(
      column: $table.remoteProvider,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get remoteApiType => $composableBuilder(
      column: $table.remoteApiType,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get remoteAccountId => $composableBuilder(
      column: $table.remoteAccountId,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get remoteBaseUrl => $composableBuilder(
      column: $table.remoteBaseUrl,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get remoteModel => $composableBuilder(
      column: $table.remoteModel, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get remoteAuthType => $composableBuilder(
      column: $table.remoteAuthType,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get remoteAuthHeaderName => $composableBuilder(
      column: $table.remoteAuthHeaderName,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get remoteStreamingEnabled => $composableBuilder(
      column: $table.remoteStreamingEnabled,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get remoteThinkingEffort => $composableBuilder(
      column: $table.remoteThinkingEffort,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get defaultSystemPrompt => $composableBuilder(
      column: $table.defaultSystemPrompt,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get localModelId => $composableBuilder(
      column: $table.localModelId,
      builder: (column) => ColumnOrderings(column));
}

class $$ChatSettingsTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $ChatSettingsTableTable> {
  $$ChatSettingsTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get key =>
      $composableBuilder(column: $table.key, builder: (column) => column);

  GeneratedColumn<String> get inferenceMode => $composableBuilder(
      column: $table.inferenceMode, builder: (column) => column);

  GeneratedColumn<String> get modelType =>
      $composableBuilder(column: $table.modelType, builder: (column) => column);

  GeneratedColumn<String> get customModelPath => $composableBuilder(
      column: $table.customModelPath, builder: (column) => column);

  GeneratedColumn<int> get maxTokens =>
      $composableBuilder(column: $table.maxTokens, builder: (column) => column);

  GeneratedColumn<int> get temperatureX100 => $composableBuilder(
      column: $table.temperatureX100, builder: (column) => column);

  GeneratedColumn<int> get topK =>
      $composableBuilder(column: $table.topK, builder: (column) => column);

  GeneratedColumn<String> get backend =>
      $composableBuilder(column: $table.backend, builder: (column) => column);

  GeneratedColumn<String> get remoteProvider => $composableBuilder(
      column: $table.remoteProvider, builder: (column) => column);

  GeneratedColumn<String> get remoteApiType => $composableBuilder(
      column: $table.remoteApiType, builder: (column) => column);

  GeneratedColumn<int> get remoteAccountId => $composableBuilder(
      column: $table.remoteAccountId, builder: (column) => column);

  GeneratedColumn<String> get remoteBaseUrl => $composableBuilder(
      column: $table.remoteBaseUrl, builder: (column) => column);

  GeneratedColumn<String> get remoteModel => $composableBuilder(
      column: $table.remoteModel, builder: (column) => column);

  GeneratedColumn<String> get remoteAuthType => $composableBuilder(
      column: $table.remoteAuthType, builder: (column) => column);

  GeneratedColumn<String> get remoteAuthHeaderName => $composableBuilder(
      column: $table.remoteAuthHeaderName, builder: (column) => column);

  GeneratedColumn<bool> get remoteStreamingEnabled => $composableBuilder(
      column: $table.remoteStreamingEnabled, builder: (column) => column);

  GeneratedColumn<String> get remoteThinkingEffort => $composableBuilder(
      column: $table.remoteThinkingEffort, builder: (column) => column);

  GeneratedColumn<String> get defaultSystemPrompt => $composableBuilder(
      column: $table.defaultSystemPrompt, builder: (column) => column);

  GeneratedColumn<String> get localModelId => $composableBuilder(
      column: $table.localModelId, builder: (column) => column);
}

class $$ChatSettingsTableTableTableManager extends RootTableManager<
    _$AppDatabase,
    $ChatSettingsTableTable,
    ChatSettingsTableData,
    $$ChatSettingsTableTableFilterComposer,
    $$ChatSettingsTableTableOrderingComposer,
    $$ChatSettingsTableTableAnnotationComposer,
    $$ChatSettingsTableTableCreateCompanionBuilder,
    $$ChatSettingsTableTableUpdateCompanionBuilder,
    (
      ChatSettingsTableData,
      BaseReferences<_$AppDatabase, $ChatSettingsTableTable,
          ChatSettingsTableData>
    ),
    ChatSettingsTableData,
    PrefetchHooks Function()> {
  $$ChatSettingsTableTableTableManager(
      _$AppDatabase db, $ChatSettingsTableTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ChatSettingsTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ChatSettingsTableTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ChatSettingsTableTableAnnotationComposer(
                  $db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> key = const Value.absent(),
            Value<String> inferenceMode = const Value.absent(),
            Value<String> modelType = const Value.absent(),
            Value<String?> customModelPath = const Value.absent(),
            Value<int> maxTokens = const Value.absent(),
            Value<int> temperatureX100 = const Value.absent(),
            Value<int> topK = const Value.absent(),
            Value<String> backend = const Value.absent(),
            Value<String> remoteProvider = const Value.absent(),
            Value<String> remoteApiType = const Value.absent(),
            Value<int?> remoteAccountId = const Value.absent(),
            Value<String> remoteBaseUrl = const Value.absent(),
            Value<String> remoteModel = const Value.absent(),
            Value<String> remoteAuthType = const Value.absent(),
            Value<String?> remoteAuthHeaderName = const Value.absent(),
            Value<bool> remoteStreamingEnabled = const Value.absent(),
            Value<String> remoteThinkingEffort = const Value.absent(),
            Value<String?> defaultSystemPrompt = const Value.absent(),
            Value<String?> localModelId = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              ChatSettingsTableCompanion(
            key: key,
            inferenceMode: inferenceMode,
            modelType: modelType,
            customModelPath: customModelPath,
            maxTokens: maxTokens,
            temperatureX100: temperatureX100,
            topK: topK,
            backend: backend,
            remoteProvider: remoteProvider,
            remoteApiType: remoteApiType,
            remoteAccountId: remoteAccountId,
            remoteBaseUrl: remoteBaseUrl,
            remoteModel: remoteModel,
            remoteAuthType: remoteAuthType,
            remoteAuthHeaderName: remoteAuthHeaderName,
            remoteStreamingEnabled: remoteStreamingEnabled,
            remoteThinkingEffort: remoteThinkingEffort,
            defaultSystemPrompt: defaultSystemPrompt,
            localModelId: localModelId,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            Value<String> key = const Value.absent(),
            Value<String> inferenceMode = const Value.absent(),
            Value<String> modelType = const Value.absent(),
            Value<String?> customModelPath = const Value.absent(),
            Value<int> maxTokens = const Value.absent(),
            Value<int> temperatureX100 = const Value.absent(),
            Value<int> topK = const Value.absent(),
            Value<String> backend = const Value.absent(),
            Value<String> remoteProvider = const Value.absent(),
            Value<String> remoteApiType = const Value.absent(),
            Value<int?> remoteAccountId = const Value.absent(),
            Value<String> remoteBaseUrl = const Value.absent(),
            Value<String> remoteModel = const Value.absent(),
            Value<String> remoteAuthType = const Value.absent(),
            Value<String?> remoteAuthHeaderName = const Value.absent(),
            Value<bool> remoteStreamingEnabled = const Value.absent(),
            Value<String> remoteThinkingEffort = const Value.absent(),
            Value<String?> defaultSystemPrompt = const Value.absent(),
            Value<String?> localModelId = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              ChatSettingsTableCompanion.insert(
            key: key,
            inferenceMode: inferenceMode,
            modelType: modelType,
            customModelPath: customModelPath,
            maxTokens: maxTokens,
            temperatureX100: temperatureX100,
            topK: topK,
            backend: backend,
            remoteProvider: remoteProvider,
            remoteApiType: remoteApiType,
            remoteAccountId: remoteAccountId,
            remoteBaseUrl: remoteBaseUrl,
            remoteModel: remoteModel,
            remoteAuthType: remoteAuthType,
            remoteAuthHeaderName: remoteAuthHeaderName,
            remoteStreamingEnabled: remoteStreamingEnabled,
            remoteThinkingEffort: remoteThinkingEffort,
            defaultSystemPrompt: defaultSystemPrompt,
            localModelId: localModelId,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$ChatSettingsTableTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $ChatSettingsTableTable,
    ChatSettingsTableData,
    $$ChatSettingsTableTableFilterComposer,
    $$ChatSettingsTableTableOrderingComposer,
    $$ChatSettingsTableTableAnnotationComposer,
    $$ChatSettingsTableTableCreateCompanionBuilder,
    $$ChatSettingsTableTableUpdateCompanionBuilder,
    (
      ChatSettingsTableData,
      BaseReferences<_$AppDatabase, $ChatSettingsTableTable,
          ChatSettingsTableData>
    ),
    ChatSettingsTableData,
    PrefetchHooks Function()>;
typedef $$ServiceAccountTableTableCreateCompanionBuilder
    = ServiceAccountTableCompanion Function({
  Value<int> id,
  required ServiceProvider provider,
  required String name,
  Value<String> description,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
});
typedef $$ServiceAccountTableTableUpdateCompanionBuilder
    = ServiceAccountTableCompanion Function({
  Value<int> id,
  Value<ServiceProvider> provider,
  Value<String> name,
  Value<String> description,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
});

class $$ServiceAccountTableTableFilterComposer
    extends Composer<_$AppDatabase, $ServiceAccountTableTable> {
  $$ServiceAccountTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnWithTypeConverterFilters<ServiceProvider, ServiceProvider, String>
      get provider => $composableBuilder(
          column: $table.provider,
          builder: (column) => ColumnWithTypeConverterFilters(column));

  ColumnFilters<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get description => $composableBuilder(
      column: $table.description, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnFilters(column));
}

class $$ServiceAccountTableTableOrderingComposer
    extends Composer<_$AppDatabase, $ServiceAccountTableTable> {
  $$ServiceAccountTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get provider => $composableBuilder(
      column: $table.provider, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get description => $composableBuilder(
      column: $table.description, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnOrderings(column));
}

class $$ServiceAccountTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $ServiceAccountTableTable> {
  $$ServiceAccountTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumnWithTypeConverter<ServiceProvider, String> get provider =>
      $composableBuilder(column: $table.provider, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get description => $composableBuilder(
      column: $table.description, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$ServiceAccountTableTableTableManager extends RootTableManager<
    _$AppDatabase,
    $ServiceAccountTableTable,
    ServiceAccountTableData,
    $$ServiceAccountTableTableFilterComposer,
    $$ServiceAccountTableTableOrderingComposer,
    $$ServiceAccountTableTableAnnotationComposer,
    $$ServiceAccountTableTableCreateCompanionBuilder,
    $$ServiceAccountTableTableUpdateCompanionBuilder,
    (
      ServiceAccountTableData,
      BaseReferences<_$AppDatabase, $ServiceAccountTableTable,
          ServiceAccountTableData>
    ),
    ServiceAccountTableData,
    PrefetchHooks Function()> {
  $$ServiceAccountTableTableTableManager(
      _$AppDatabase db, $ServiceAccountTableTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ServiceAccountTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ServiceAccountTableTableOrderingComposer(
                  $db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ServiceAccountTableTableAnnotationComposer(
                  $db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<ServiceProvider> provider = const Value.absent(),
            Value<String> name = const Value.absent(),
            Value<String> description = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
          }) =>
              ServiceAccountTableCompanion(
            id: id,
            provider: provider,
            name: name,
            description: description,
            createdAt: createdAt,
            updatedAt: updatedAt,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required ServiceProvider provider,
            required String name,
            Value<String> description = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
          }) =>
              ServiceAccountTableCompanion.insert(
            id: id,
            provider: provider,
            name: name,
            description: description,
            createdAt: createdAt,
            updatedAt: updatedAt,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$ServiceAccountTableTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $ServiceAccountTableTable,
    ServiceAccountTableData,
    $$ServiceAccountTableTableFilterComposer,
    $$ServiceAccountTableTableOrderingComposer,
    $$ServiceAccountTableTableAnnotationComposer,
    $$ServiceAccountTableTableCreateCompanionBuilder,
    $$ServiceAccountTableTableUpdateCompanionBuilder,
    (
      ServiceAccountTableData,
      BaseReferences<_$AppDatabase, $ServiceAccountTableTable,
          ServiceAccountTableData>
    ),
    ServiceAccountTableData,
    PrefetchHooks Function()>;
typedef $$MonitorHostTableTableCreateCompanionBuilder
    = MonitorHostTableCompanion Function({
  required String id,
  required String ip,
  required int port,
  Value<String?> label,
  Value<bool> isManual,
  Value<DateTime> createdAt,
  Value<int> rowid,
});
typedef $$MonitorHostTableTableUpdateCompanionBuilder
    = MonitorHostTableCompanion Function({
  Value<String> id,
  Value<String> ip,
  Value<int> port,
  Value<String?> label,
  Value<bool> isManual,
  Value<DateTime> createdAt,
  Value<int> rowid,
});

final class $$MonitorHostTableTableReferences extends BaseReferences<
    _$AppDatabase, $MonitorHostTableTable, MonitorHostTableData> {
  $$MonitorHostTableTableReferences(
      super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$MonitorTrustedCertTableTable,
      List<MonitorTrustedCertTableData>> _monitorTrustedCertTableRefsTable(
          _$AppDatabase db) =>
      MultiTypedResultKey.fromTable(db.monitorTrustedCertTable,
          aliasName: $_aliasNameGenerator(
              db.monitorHostTable.id, db.monitorTrustedCertTable.hostId));

  $$MonitorTrustedCertTableTableProcessedTableManager
      get monitorTrustedCertTableRefs {
    final manager = $$MonitorTrustedCertTableTableTableManager(
            $_db, $_db.monitorTrustedCertTable)
        .filter((f) => f.hostId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache =
        $_typedResult.readTableOrNull(_monitorTrustedCertTableRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }
}

class $$MonitorHostTableTableFilterComposer
    extends Composer<_$AppDatabase, $MonitorHostTableTable> {
  $$MonitorHostTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get ip => $composableBuilder(
      column: $table.ip, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get port => $composableBuilder(
      column: $table.port, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get label => $composableBuilder(
      column: $table.label, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get isManual => $composableBuilder(
      column: $table.isManual, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  Expression<bool> monitorTrustedCertTableRefs(
      Expression<bool> Function($$MonitorTrustedCertTableTableFilterComposer f)
          f) {
    final $$MonitorTrustedCertTableTableFilterComposer composer =
        $composerBuilder(
            composer: this,
            getCurrentColumn: (t) => t.id,
            referencedTable: $db.monitorTrustedCertTable,
            getReferencedColumn: (t) => t.hostId,
            builder: (joinBuilder,
                    {$addJoinBuilderToRootComposer,
                    $removeJoinBuilderFromRootComposer}) =>
                $$MonitorTrustedCertTableTableFilterComposer(
                  $db: $db,
                  $table: $db.monitorTrustedCertTable,
                  $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                  joinBuilder: joinBuilder,
                  $removeJoinBuilderFromRootComposer:
                      $removeJoinBuilderFromRootComposer,
                ));
    return f(composer);
  }
}

class $$MonitorHostTableTableOrderingComposer
    extends Composer<_$AppDatabase, $MonitorHostTableTable> {
  $$MonitorHostTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get ip => $composableBuilder(
      column: $table.ip, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get port => $composableBuilder(
      column: $table.port, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get label => $composableBuilder(
      column: $table.label, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get isManual => $composableBuilder(
      column: $table.isManual, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));
}

class $$MonitorHostTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $MonitorHostTableTable> {
  $$MonitorHostTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get ip =>
      $composableBuilder(column: $table.ip, builder: (column) => column);

  GeneratedColumn<int> get port =>
      $composableBuilder(column: $table.port, builder: (column) => column);

  GeneratedColumn<String> get label =>
      $composableBuilder(column: $table.label, builder: (column) => column);

  GeneratedColumn<bool> get isManual =>
      $composableBuilder(column: $table.isManual, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  Expression<T> monitorTrustedCertTableRefs<T extends Object>(
      Expression<T> Function($$MonitorTrustedCertTableTableAnnotationComposer a)
          f) {
    final $$MonitorTrustedCertTableTableAnnotationComposer composer =
        $composerBuilder(
            composer: this,
            getCurrentColumn: (t) => t.id,
            referencedTable: $db.monitorTrustedCertTable,
            getReferencedColumn: (t) => t.hostId,
            builder: (joinBuilder,
                    {$addJoinBuilderToRootComposer,
                    $removeJoinBuilderFromRootComposer}) =>
                $$MonitorTrustedCertTableTableAnnotationComposer(
                  $db: $db,
                  $table: $db.monitorTrustedCertTable,
                  $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                  joinBuilder: joinBuilder,
                  $removeJoinBuilderFromRootComposer:
                      $removeJoinBuilderFromRootComposer,
                ));
    return f(composer);
  }
}

class $$MonitorHostTableTableTableManager extends RootTableManager<
    _$AppDatabase,
    $MonitorHostTableTable,
    MonitorHostTableData,
    $$MonitorHostTableTableFilterComposer,
    $$MonitorHostTableTableOrderingComposer,
    $$MonitorHostTableTableAnnotationComposer,
    $$MonitorHostTableTableCreateCompanionBuilder,
    $$MonitorHostTableTableUpdateCompanionBuilder,
    (MonitorHostTableData, $$MonitorHostTableTableReferences),
    MonitorHostTableData,
    PrefetchHooks Function({bool monitorTrustedCertTableRefs})> {
  $$MonitorHostTableTableTableManager(
      _$AppDatabase db, $MonitorHostTableTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$MonitorHostTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$MonitorHostTableTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$MonitorHostTableTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> ip = const Value.absent(),
            Value<int> port = const Value.absent(),
            Value<String?> label = const Value.absent(),
            Value<bool> isManual = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              MonitorHostTableCompanion(
            id: id,
            ip: ip,
            port: port,
            label: label,
            isManual: isManual,
            createdAt: createdAt,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String ip,
            required int port,
            Value<String?> label = const Value.absent(),
            Value<bool> isManual = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              MonitorHostTableCompanion.insert(
            id: id,
            ip: ip,
            port: port,
            label: label,
            isManual: isManual,
            createdAt: createdAt,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable(table),
                    $$MonitorHostTableTableReferences(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: ({monitorTrustedCertTableRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [
                if (monitorTrustedCertTableRefs) db.monitorTrustedCertTable
              ],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (monitorTrustedCertTableRefs)
                    await $_getPrefetchedData<
                            MonitorHostTableData,
                            $MonitorHostTableTable,
                            MonitorTrustedCertTableData>(
                        currentTable: table,
                        referencedTable: $$MonitorHostTableTableReferences
                            ._monitorTrustedCertTableRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$MonitorHostTableTableReferences(db, table, p0)
                                .monitorTrustedCertTableRefs,
                        referencedItemsForCurrentItem: (item,
                                referencedItems) =>
                            referencedItems.where((e) => e.hostId == item.id),
                        typedResults: items)
                ];
              },
            );
          },
        ));
}

typedef $$MonitorHostTableTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $MonitorHostTableTable,
    MonitorHostTableData,
    $$MonitorHostTableTableFilterComposer,
    $$MonitorHostTableTableOrderingComposer,
    $$MonitorHostTableTableAnnotationComposer,
    $$MonitorHostTableTableCreateCompanionBuilder,
    $$MonitorHostTableTableUpdateCompanionBuilder,
    (MonitorHostTableData, $$MonitorHostTableTableReferences),
    MonitorHostTableData,
    PrefetchHooks Function({bool monitorTrustedCertTableRefs})>;
typedef $$MonitorTrustedCertTableTableCreateCompanionBuilder
    = MonitorTrustedCertTableCompanion Function({
  required String hostId,
  required String fingerprint,
  Value<DateTime> firstTrustedAt,
  Value<DateTime> lastVerifiedAt,
  Value<int> rowid,
});
typedef $$MonitorTrustedCertTableTableUpdateCompanionBuilder
    = MonitorTrustedCertTableCompanion Function({
  Value<String> hostId,
  Value<String> fingerprint,
  Value<DateTime> firstTrustedAt,
  Value<DateTime> lastVerifiedAt,
  Value<int> rowid,
});

final class $$MonitorTrustedCertTableTableReferences extends BaseReferences<
    _$AppDatabase, $MonitorTrustedCertTableTable, MonitorTrustedCertTableData> {
  $$MonitorTrustedCertTableTableReferences(
      super.$_db, super.$_table, super.$_typedResult);

  static $MonitorHostTableTable _hostIdTable(_$AppDatabase db) =>
      db.monitorHostTable.createAlias($_aliasNameGenerator(
          db.monitorTrustedCertTable.hostId, db.monitorHostTable.id));

  $$MonitorHostTableTableProcessedTableManager get hostId {
    final $_column = $_itemColumn<String>('host_id')!;

    final manager =
        $$MonitorHostTableTableTableManager($_db, $_db.monitorHostTable)
            .filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_hostIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }
}

class $$MonitorTrustedCertTableTableFilterComposer
    extends Composer<_$AppDatabase, $MonitorTrustedCertTableTable> {
  $$MonitorTrustedCertTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get fingerprint => $composableBuilder(
      column: $table.fingerprint, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get firstTrustedAt => $composableBuilder(
      column: $table.firstTrustedAt,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get lastVerifiedAt => $composableBuilder(
      column: $table.lastVerifiedAt,
      builder: (column) => ColumnFilters(column));

  $$MonitorHostTableTableFilterComposer get hostId {
    final $$MonitorHostTableTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.hostId,
        referencedTable: $db.monitorHostTable,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$MonitorHostTableTableFilterComposer(
              $db: $db,
              $table: $db.monitorHostTable,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$MonitorTrustedCertTableTableOrderingComposer
    extends Composer<_$AppDatabase, $MonitorTrustedCertTableTable> {
  $$MonitorTrustedCertTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get fingerprint => $composableBuilder(
      column: $table.fingerprint, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get firstTrustedAt => $composableBuilder(
      column: $table.firstTrustedAt,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get lastVerifiedAt => $composableBuilder(
      column: $table.lastVerifiedAt,
      builder: (column) => ColumnOrderings(column));

  $$MonitorHostTableTableOrderingComposer get hostId {
    final $$MonitorHostTableTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.hostId,
        referencedTable: $db.monitorHostTable,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$MonitorHostTableTableOrderingComposer(
              $db: $db,
              $table: $db.monitorHostTable,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$MonitorTrustedCertTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $MonitorTrustedCertTableTable> {
  $$MonitorTrustedCertTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get fingerprint => $composableBuilder(
      column: $table.fingerprint, builder: (column) => column);

  GeneratedColumn<DateTime> get firstTrustedAt => $composableBuilder(
      column: $table.firstTrustedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get lastVerifiedAt => $composableBuilder(
      column: $table.lastVerifiedAt, builder: (column) => column);

  $$MonitorHostTableTableAnnotationComposer get hostId {
    final $$MonitorHostTableTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.hostId,
        referencedTable: $db.monitorHostTable,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$MonitorHostTableTableAnnotationComposer(
              $db: $db,
              $table: $db.monitorHostTable,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$MonitorTrustedCertTableTableTableManager extends RootTableManager<
    _$AppDatabase,
    $MonitorTrustedCertTableTable,
    MonitorTrustedCertTableData,
    $$MonitorTrustedCertTableTableFilterComposer,
    $$MonitorTrustedCertTableTableOrderingComposer,
    $$MonitorTrustedCertTableTableAnnotationComposer,
    $$MonitorTrustedCertTableTableCreateCompanionBuilder,
    $$MonitorTrustedCertTableTableUpdateCompanionBuilder,
    (MonitorTrustedCertTableData, $$MonitorTrustedCertTableTableReferences),
    MonitorTrustedCertTableData,
    PrefetchHooks Function({bool hostId})> {
  $$MonitorTrustedCertTableTableTableManager(
      _$AppDatabase db, $MonitorTrustedCertTableTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$MonitorTrustedCertTableTableFilterComposer(
                  $db: db, $table: table),
          createOrderingComposer: () =>
              $$MonitorTrustedCertTableTableOrderingComposer(
                  $db: db, $table: table),
          createComputedFieldComposer: () =>
              $$MonitorTrustedCertTableTableAnnotationComposer(
                  $db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> hostId = const Value.absent(),
            Value<String> fingerprint = const Value.absent(),
            Value<DateTime> firstTrustedAt = const Value.absent(),
            Value<DateTime> lastVerifiedAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              MonitorTrustedCertTableCompanion(
            hostId: hostId,
            fingerprint: fingerprint,
            firstTrustedAt: firstTrustedAt,
            lastVerifiedAt: lastVerifiedAt,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String hostId,
            required String fingerprint,
            Value<DateTime> firstTrustedAt = const Value.absent(),
            Value<DateTime> lastVerifiedAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              MonitorTrustedCertTableCompanion.insert(
            hostId: hostId,
            fingerprint: fingerprint,
            firstTrustedAt: firstTrustedAt,
            lastVerifiedAt: lastVerifiedAt,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable(table),
                    $$MonitorTrustedCertTableTableReferences(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: ({hostId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins: <
                  T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic>>(state) {
                if (hostId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.hostId,
                    referencedTable: $$MonitorTrustedCertTableTableReferences
                        ._hostIdTable(db),
                    referencedColumn: $$MonitorTrustedCertTableTableReferences
                        ._hostIdTable(db)
                        .id,
                  ) as T;
                }

                return state;
              },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ));
}

typedef $$MonitorTrustedCertTableTableProcessedTableManager
    = ProcessedTableManager<
        _$AppDatabase,
        $MonitorTrustedCertTableTable,
        MonitorTrustedCertTableData,
        $$MonitorTrustedCertTableTableFilterComposer,
        $$MonitorTrustedCertTableTableOrderingComposer,
        $$MonitorTrustedCertTableTableAnnotationComposer,
        $$MonitorTrustedCertTableTableCreateCompanionBuilder,
        $$MonitorTrustedCertTableTableUpdateCompanionBuilder,
        (MonitorTrustedCertTableData, $$MonitorTrustedCertTableTableReferences),
        MonitorTrustedCertTableData,
        PrefetchHooks Function({bool hostId})>;
typedef $$TtsDatasetProjectTableTableCreateCompanionBuilder
    = TtsDatasetProjectTableCompanion Function({
  required String id,
  required String name,
  required String targetProfile,
  required String language,
  required String speakerId,
  required String rootPath,
  required String status,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
  Value<int> rowid,
});
typedef $$TtsDatasetProjectTableTableUpdateCompanionBuilder
    = TtsDatasetProjectTableCompanion Function({
  Value<String> id,
  Value<String> name,
  Value<String> targetProfile,
  Value<String> language,
  Value<String> speakerId,
  Value<String> rootPath,
  Value<String> status,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
  Value<int> rowid,
});

final class $$TtsDatasetProjectTableTableReferences extends BaseReferences<
    _$AppDatabase, $TtsDatasetProjectTableTable, TtsDatasetProjectTableData> {
  $$TtsDatasetProjectTableTableReferences(
      super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$TtsDatasetSpeakerTableTable,
      List<TtsDatasetSpeakerTableData>> _ttsDatasetSpeakerTableRefsTable(
          _$AppDatabase db) =>
      MultiTypedResultKey.fromTable(db.ttsDatasetSpeakerTable,
          aliasName: $_aliasNameGenerator(db.ttsDatasetProjectTable.id,
              db.ttsDatasetSpeakerTable.projectId));

  $$TtsDatasetSpeakerTableTableProcessedTableManager
      get ttsDatasetSpeakerTableRefs {
    final manager = $$TtsDatasetSpeakerTableTableTableManager(
            $_db, $_db.ttsDatasetSpeakerTable)
        .filter((f) => f.projectId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache =
        $_typedResult.readTableOrNull(_ttsDatasetSpeakerTableRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }

  static MultiTypedResultKey<$TtsDatasetPromptTableTable,
      List<TtsDatasetPromptTableData>> _ttsDatasetPromptTableRefsTable(
          _$AppDatabase db) =>
      MultiTypedResultKey.fromTable(db.ttsDatasetPromptTable,
          aliasName: $_aliasNameGenerator(db.ttsDatasetProjectTable.id,
              db.ttsDatasetPromptTable.projectId));

  $$TtsDatasetPromptTableTableProcessedTableManager
      get ttsDatasetPromptTableRefs {
    final manager = $$TtsDatasetPromptTableTableTableManager(
            $_db, $_db.ttsDatasetPromptTable)
        .filter((f) => f.projectId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache =
        $_typedResult.readTableOrNull(_ttsDatasetPromptTableRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }

  static MultiTypedResultKey<$TtsDatasetClipTableTable,
      List<TtsDatasetClipTableData>> _ttsDatasetClipTableRefsTable(
          _$AppDatabase db) =>
      MultiTypedResultKey.fromTable(db.ttsDatasetClipTable,
          aliasName: $_aliasNameGenerator(
              db.ttsDatasetProjectTable.id, db.ttsDatasetClipTable.projectId));

  $$TtsDatasetClipTableTableProcessedTableManager get ttsDatasetClipTableRefs {
    final manager = $$TtsDatasetClipTableTableTableManager(
            $_db, $_db.ttsDatasetClipTable)
        .filter((f) => f.projectId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache =
        $_typedResult.readTableOrNull(_ttsDatasetClipTableRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }

  static MultiTypedResultKey<$TtsDatasetValidationIssueTableTable,
          List<TtsDatasetValidationIssueTableData>>
      _ttsDatasetValidationIssueTableRefsTable(_$AppDatabase db) =>
          MultiTypedResultKey.fromTable(db.ttsDatasetValidationIssueTable,
              aliasName: $_aliasNameGenerator(db.ttsDatasetProjectTable.id,
                  db.ttsDatasetValidationIssueTable.projectId));

  $$TtsDatasetValidationIssueTableTableProcessedTableManager
      get ttsDatasetValidationIssueTableRefs {
    final manager = $$TtsDatasetValidationIssueTableTableTableManager(
            $_db, $_db.ttsDatasetValidationIssueTable)
        .filter((f) => f.projectId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult
        .readTableOrNull(_ttsDatasetValidationIssueTableRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }
}

class $$TtsDatasetProjectTableTableFilterComposer
    extends Composer<_$AppDatabase, $TtsDatasetProjectTableTable> {
  $$TtsDatasetProjectTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get targetProfile => $composableBuilder(
      column: $table.targetProfile, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get language => $composableBuilder(
      column: $table.language, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get speakerId => $composableBuilder(
      column: $table.speakerId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get rootPath => $composableBuilder(
      column: $table.rootPath, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get status => $composableBuilder(
      column: $table.status, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnFilters(column));

  Expression<bool> ttsDatasetSpeakerTableRefs(
      Expression<bool> Function($$TtsDatasetSpeakerTableTableFilterComposer f)
          f) {
    final $$TtsDatasetSpeakerTableTableFilterComposer composer =
        $composerBuilder(
            composer: this,
            getCurrentColumn: (t) => t.id,
            referencedTable: $db.ttsDatasetSpeakerTable,
            getReferencedColumn: (t) => t.projectId,
            builder: (joinBuilder,
                    {$addJoinBuilderToRootComposer,
                    $removeJoinBuilderFromRootComposer}) =>
                $$TtsDatasetSpeakerTableTableFilterComposer(
                  $db: $db,
                  $table: $db.ttsDatasetSpeakerTable,
                  $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                  joinBuilder: joinBuilder,
                  $removeJoinBuilderFromRootComposer:
                      $removeJoinBuilderFromRootComposer,
                ));
    return f(composer);
  }

  Expression<bool> ttsDatasetPromptTableRefs(
      Expression<bool> Function($$TtsDatasetPromptTableTableFilterComposer f)
          f) {
    final $$TtsDatasetPromptTableTableFilterComposer composer =
        $composerBuilder(
            composer: this,
            getCurrentColumn: (t) => t.id,
            referencedTable: $db.ttsDatasetPromptTable,
            getReferencedColumn: (t) => t.projectId,
            builder: (joinBuilder,
                    {$addJoinBuilderToRootComposer,
                    $removeJoinBuilderFromRootComposer}) =>
                $$TtsDatasetPromptTableTableFilterComposer(
                  $db: $db,
                  $table: $db.ttsDatasetPromptTable,
                  $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                  joinBuilder: joinBuilder,
                  $removeJoinBuilderFromRootComposer:
                      $removeJoinBuilderFromRootComposer,
                ));
    return f(composer);
  }

  Expression<bool> ttsDatasetClipTableRefs(
      Expression<bool> Function($$TtsDatasetClipTableTableFilterComposer f) f) {
    final $$TtsDatasetClipTableTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.ttsDatasetClipTable,
        getReferencedColumn: (t) => t.projectId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$TtsDatasetClipTableTableFilterComposer(
              $db: $db,
              $table: $db.ttsDatasetClipTable,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }

  Expression<bool> ttsDatasetValidationIssueTableRefs(
      Expression<bool> Function(
              $$TtsDatasetValidationIssueTableTableFilterComposer f)
          f) {
    final $$TtsDatasetValidationIssueTableTableFilterComposer composer =
        $composerBuilder(
            composer: this,
            getCurrentColumn: (t) => t.id,
            referencedTable: $db.ttsDatasetValidationIssueTable,
            getReferencedColumn: (t) => t.projectId,
            builder: (joinBuilder,
                    {$addJoinBuilderToRootComposer,
                    $removeJoinBuilderFromRootComposer}) =>
                $$TtsDatasetValidationIssueTableTableFilterComposer(
                  $db: $db,
                  $table: $db.ttsDatasetValidationIssueTable,
                  $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                  joinBuilder: joinBuilder,
                  $removeJoinBuilderFromRootComposer:
                      $removeJoinBuilderFromRootComposer,
                ));
    return f(composer);
  }
}

class $$TtsDatasetProjectTableTableOrderingComposer
    extends Composer<_$AppDatabase, $TtsDatasetProjectTableTable> {
  $$TtsDatasetProjectTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get targetProfile => $composableBuilder(
      column: $table.targetProfile,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get language => $composableBuilder(
      column: $table.language, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get speakerId => $composableBuilder(
      column: $table.speakerId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get rootPath => $composableBuilder(
      column: $table.rootPath, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get status => $composableBuilder(
      column: $table.status, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnOrderings(column));
}

class $$TtsDatasetProjectTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $TtsDatasetProjectTableTable> {
  $$TtsDatasetProjectTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get targetProfile => $composableBuilder(
      column: $table.targetProfile, builder: (column) => column);

  GeneratedColumn<String> get language =>
      $composableBuilder(column: $table.language, builder: (column) => column);

  GeneratedColumn<String> get speakerId =>
      $composableBuilder(column: $table.speakerId, builder: (column) => column);

  GeneratedColumn<String> get rootPath =>
      $composableBuilder(column: $table.rootPath, builder: (column) => column);

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  Expression<T> ttsDatasetSpeakerTableRefs<T extends Object>(
      Expression<T> Function($$TtsDatasetSpeakerTableTableAnnotationComposer a)
          f) {
    final $$TtsDatasetSpeakerTableTableAnnotationComposer composer =
        $composerBuilder(
            composer: this,
            getCurrentColumn: (t) => t.id,
            referencedTable: $db.ttsDatasetSpeakerTable,
            getReferencedColumn: (t) => t.projectId,
            builder: (joinBuilder,
                    {$addJoinBuilderToRootComposer,
                    $removeJoinBuilderFromRootComposer}) =>
                $$TtsDatasetSpeakerTableTableAnnotationComposer(
                  $db: $db,
                  $table: $db.ttsDatasetSpeakerTable,
                  $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                  joinBuilder: joinBuilder,
                  $removeJoinBuilderFromRootComposer:
                      $removeJoinBuilderFromRootComposer,
                ));
    return f(composer);
  }

  Expression<T> ttsDatasetPromptTableRefs<T extends Object>(
      Expression<T> Function($$TtsDatasetPromptTableTableAnnotationComposer a)
          f) {
    final $$TtsDatasetPromptTableTableAnnotationComposer composer =
        $composerBuilder(
            composer: this,
            getCurrentColumn: (t) => t.id,
            referencedTable: $db.ttsDatasetPromptTable,
            getReferencedColumn: (t) => t.projectId,
            builder: (joinBuilder,
                    {$addJoinBuilderToRootComposer,
                    $removeJoinBuilderFromRootComposer}) =>
                $$TtsDatasetPromptTableTableAnnotationComposer(
                  $db: $db,
                  $table: $db.ttsDatasetPromptTable,
                  $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                  joinBuilder: joinBuilder,
                  $removeJoinBuilderFromRootComposer:
                      $removeJoinBuilderFromRootComposer,
                ));
    return f(composer);
  }

  Expression<T> ttsDatasetClipTableRefs<T extends Object>(
      Expression<T> Function($$TtsDatasetClipTableTableAnnotationComposer a)
          f) {
    final $$TtsDatasetClipTableTableAnnotationComposer composer =
        $composerBuilder(
            composer: this,
            getCurrentColumn: (t) => t.id,
            referencedTable: $db.ttsDatasetClipTable,
            getReferencedColumn: (t) => t.projectId,
            builder: (joinBuilder,
                    {$addJoinBuilderToRootComposer,
                    $removeJoinBuilderFromRootComposer}) =>
                $$TtsDatasetClipTableTableAnnotationComposer(
                  $db: $db,
                  $table: $db.ttsDatasetClipTable,
                  $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                  joinBuilder: joinBuilder,
                  $removeJoinBuilderFromRootComposer:
                      $removeJoinBuilderFromRootComposer,
                ));
    return f(composer);
  }

  Expression<T> ttsDatasetValidationIssueTableRefs<T extends Object>(
      Expression<T> Function(
              $$TtsDatasetValidationIssueTableTableAnnotationComposer a)
          f) {
    final $$TtsDatasetValidationIssueTableTableAnnotationComposer composer =
        $composerBuilder(
            composer: this,
            getCurrentColumn: (t) => t.id,
            referencedTable: $db.ttsDatasetValidationIssueTable,
            getReferencedColumn: (t) => t.projectId,
            builder: (joinBuilder,
                    {$addJoinBuilderToRootComposer,
                    $removeJoinBuilderFromRootComposer}) =>
                $$TtsDatasetValidationIssueTableTableAnnotationComposer(
                  $db: $db,
                  $table: $db.ttsDatasetValidationIssueTable,
                  $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                  joinBuilder: joinBuilder,
                  $removeJoinBuilderFromRootComposer:
                      $removeJoinBuilderFromRootComposer,
                ));
    return f(composer);
  }
}

class $$TtsDatasetProjectTableTableTableManager extends RootTableManager<
    _$AppDatabase,
    $TtsDatasetProjectTableTable,
    TtsDatasetProjectTableData,
    $$TtsDatasetProjectTableTableFilterComposer,
    $$TtsDatasetProjectTableTableOrderingComposer,
    $$TtsDatasetProjectTableTableAnnotationComposer,
    $$TtsDatasetProjectTableTableCreateCompanionBuilder,
    $$TtsDatasetProjectTableTableUpdateCompanionBuilder,
    (TtsDatasetProjectTableData, $$TtsDatasetProjectTableTableReferences),
    TtsDatasetProjectTableData,
    PrefetchHooks Function(
        {bool ttsDatasetSpeakerTableRefs,
        bool ttsDatasetPromptTableRefs,
        bool ttsDatasetClipTableRefs,
        bool ttsDatasetValidationIssueTableRefs})> {
  $$TtsDatasetProjectTableTableTableManager(
      _$AppDatabase db, $TtsDatasetProjectTableTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$TtsDatasetProjectTableTableFilterComposer(
                  $db: db, $table: table),
          createOrderingComposer: () =>
              $$TtsDatasetProjectTableTableOrderingComposer(
                  $db: db, $table: table),
          createComputedFieldComposer: () =>
              $$TtsDatasetProjectTableTableAnnotationComposer(
                  $db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> name = const Value.absent(),
            Value<String> targetProfile = const Value.absent(),
            Value<String> language = const Value.absent(),
            Value<String> speakerId = const Value.absent(),
            Value<String> rootPath = const Value.absent(),
            Value<String> status = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              TtsDatasetProjectTableCompanion(
            id: id,
            name: name,
            targetProfile: targetProfile,
            language: language,
            speakerId: speakerId,
            rootPath: rootPath,
            status: status,
            createdAt: createdAt,
            updatedAt: updatedAt,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String name,
            required String targetProfile,
            required String language,
            required String speakerId,
            required String rootPath,
            required String status,
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              TtsDatasetProjectTableCompanion.insert(
            id: id,
            name: name,
            targetProfile: targetProfile,
            language: language,
            speakerId: speakerId,
            rootPath: rootPath,
            status: status,
            createdAt: createdAt,
            updatedAt: updatedAt,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable(table),
                    $$TtsDatasetProjectTableTableReferences(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: (
              {ttsDatasetSpeakerTableRefs = false,
              ttsDatasetPromptTableRefs = false,
              ttsDatasetClipTableRefs = false,
              ttsDatasetValidationIssueTableRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [
                if (ttsDatasetSpeakerTableRefs) db.ttsDatasetSpeakerTable,
                if (ttsDatasetPromptTableRefs) db.ttsDatasetPromptTable,
                if (ttsDatasetClipTableRefs) db.ttsDatasetClipTable,
                if (ttsDatasetValidationIssueTableRefs)
                  db.ttsDatasetValidationIssueTable
              ],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (ttsDatasetSpeakerTableRefs)
                    await $_getPrefetchedData<
                            TtsDatasetProjectTableData,
                            $TtsDatasetProjectTableTable,
                            TtsDatasetSpeakerTableData>(
                        currentTable: table,
                        referencedTable: $$TtsDatasetProjectTableTableReferences
                            ._ttsDatasetSpeakerTableRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$TtsDatasetProjectTableTableReferences(
                                    db, table, p0)
                                .ttsDatasetSpeakerTableRefs,
                        referencedItemsForCurrentItem:
                            (item, referencedItems) => referencedItems
                                .where((e) => e.projectId == item.id),
                        typedResults: items),
                  if (ttsDatasetPromptTableRefs)
                    await $_getPrefetchedData<
                            TtsDatasetProjectTableData,
                            $TtsDatasetProjectTableTable,
                            TtsDatasetPromptTableData>(
                        currentTable: table,
                        referencedTable: $$TtsDatasetProjectTableTableReferences
                            ._ttsDatasetPromptTableRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$TtsDatasetProjectTableTableReferences(
                                    db, table, p0)
                                .ttsDatasetPromptTableRefs,
                        referencedItemsForCurrentItem:
                            (item, referencedItems) => referencedItems
                                .where((e) => e.projectId == item.id),
                        typedResults: items),
                  if (ttsDatasetClipTableRefs)
                    await $_getPrefetchedData<
                            TtsDatasetProjectTableData,
                            $TtsDatasetProjectTableTable,
                            TtsDatasetClipTableData>(
                        currentTable: table,
                        referencedTable: $$TtsDatasetProjectTableTableReferences
                            ._ttsDatasetClipTableRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$TtsDatasetProjectTableTableReferences(
                                    db, table, p0)
                                .ttsDatasetClipTableRefs,
                        referencedItemsForCurrentItem:
                            (item, referencedItems) => referencedItems
                                .where((e) => e.projectId == item.id),
                        typedResults: items),
                  if (ttsDatasetValidationIssueTableRefs)
                    await $_getPrefetchedData<
                            TtsDatasetProjectTableData,
                            $TtsDatasetProjectTableTable,
                            TtsDatasetValidationIssueTableData>(
                        currentTable: table,
                        referencedTable: $$TtsDatasetProjectTableTableReferences
                            ._ttsDatasetValidationIssueTableRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$TtsDatasetProjectTableTableReferences(
                                    db, table, p0)
                                .ttsDatasetValidationIssueTableRefs,
                        referencedItemsForCurrentItem:
                            (item, referencedItems) => referencedItems
                                .where((e) => e.projectId == item.id),
                        typedResults: items)
                ];
              },
            );
          },
        ));
}

typedef $$TtsDatasetProjectTableTableProcessedTableManager
    = ProcessedTableManager<
        _$AppDatabase,
        $TtsDatasetProjectTableTable,
        TtsDatasetProjectTableData,
        $$TtsDatasetProjectTableTableFilterComposer,
        $$TtsDatasetProjectTableTableOrderingComposer,
        $$TtsDatasetProjectTableTableAnnotationComposer,
        $$TtsDatasetProjectTableTableCreateCompanionBuilder,
        $$TtsDatasetProjectTableTableUpdateCompanionBuilder,
        (TtsDatasetProjectTableData, $$TtsDatasetProjectTableTableReferences),
        TtsDatasetProjectTableData,
        PrefetchHooks Function(
            {bool ttsDatasetSpeakerTableRefs,
            bool ttsDatasetPromptTableRefs,
            bool ttsDatasetClipTableRefs,
            bool ttsDatasetValidationIssueTableRefs})>;
typedef $$TtsDatasetSpeakerTableTableCreateCompanionBuilder
    = TtsDatasetSpeakerTableCompanion Function({
  required String id,
  required String projectId,
  required String displayName,
  required String consentStatus,
  required String allowedUse,
  required String datasetLicense,
  Value<String?> consentDocumentPath,
  Value<String?> referenceClipId,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
  Value<int> rowid,
});
typedef $$TtsDatasetSpeakerTableTableUpdateCompanionBuilder
    = TtsDatasetSpeakerTableCompanion Function({
  Value<String> id,
  Value<String> projectId,
  Value<String> displayName,
  Value<String> consentStatus,
  Value<String> allowedUse,
  Value<String> datasetLicense,
  Value<String?> consentDocumentPath,
  Value<String?> referenceClipId,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
  Value<int> rowid,
});

final class $$TtsDatasetSpeakerTableTableReferences extends BaseReferences<
    _$AppDatabase, $TtsDatasetSpeakerTableTable, TtsDatasetSpeakerTableData> {
  $$TtsDatasetSpeakerTableTableReferences(
      super.$_db, super.$_table, super.$_typedResult);

  static $TtsDatasetProjectTableTable _projectIdTable(_$AppDatabase db) =>
      db.ttsDatasetProjectTable.createAlias($_aliasNameGenerator(
          db.ttsDatasetSpeakerTable.projectId, db.ttsDatasetProjectTable.id));

  $$TtsDatasetProjectTableTableProcessedTableManager get projectId {
    final $_column = $_itemColumn<String>('project_id')!;

    final manager = $$TtsDatasetProjectTableTableTableManager(
            $_db, $_db.ttsDatasetProjectTable)
        .filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_projectIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }

  static MultiTypedResultKey<$TtsDatasetClipTableTable,
      List<TtsDatasetClipTableData>> _ttsDatasetClipTableRefsTable(
          _$AppDatabase db) =>
      MultiTypedResultKey.fromTable(db.ttsDatasetClipTable,
          aliasName: $_aliasNameGenerator(
              db.ttsDatasetSpeakerTable.id, db.ttsDatasetClipTable.speakerId));

  $$TtsDatasetClipTableTableProcessedTableManager get ttsDatasetClipTableRefs {
    final manager = $$TtsDatasetClipTableTableTableManager(
            $_db, $_db.ttsDatasetClipTable)
        .filter((f) => f.speakerId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache =
        $_typedResult.readTableOrNull(_ttsDatasetClipTableRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }
}

class $$TtsDatasetSpeakerTableTableFilterComposer
    extends Composer<_$AppDatabase, $TtsDatasetSpeakerTableTable> {
  $$TtsDatasetSpeakerTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get displayName => $composableBuilder(
      column: $table.displayName, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get consentStatus => $composableBuilder(
      column: $table.consentStatus, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get allowedUse => $composableBuilder(
      column: $table.allowedUse, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get datasetLicense => $composableBuilder(
      column: $table.datasetLicense,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get consentDocumentPath => $composableBuilder(
      column: $table.consentDocumentPath,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get referenceClipId => $composableBuilder(
      column: $table.referenceClipId,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnFilters(column));

  $$TtsDatasetProjectTableTableFilterComposer get projectId {
    final $$TtsDatasetProjectTableTableFilterComposer composer =
        $composerBuilder(
            composer: this,
            getCurrentColumn: (t) => t.projectId,
            referencedTable: $db.ttsDatasetProjectTable,
            getReferencedColumn: (t) => t.id,
            builder: (joinBuilder,
                    {$addJoinBuilderToRootComposer,
                    $removeJoinBuilderFromRootComposer}) =>
                $$TtsDatasetProjectTableTableFilterComposer(
                  $db: $db,
                  $table: $db.ttsDatasetProjectTable,
                  $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                  joinBuilder: joinBuilder,
                  $removeJoinBuilderFromRootComposer:
                      $removeJoinBuilderFromRootComposer,
                ));
    return composer;
  }

  Expression<bool> ttsDatasetClipTableRefs(
      Expression<bool> Function($$TtsDatasetClipTableTableFilterComposer f) f) {
    final $$TtsDatasetClipTableTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.ttsDatasetClipTable,
        getReferencedColumn: (t) => t.speakerId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$TtsDatasetClipTableTableFilterComposer(
              $db: $db,
              $table: $db.ttsDatasetClipTable,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }
}

class $$TtsDatasetSpeakerTableTableOrderingComposer
    extends Composer<_$AppDatabase, $TtsDatasetSpeakerTableTable> {
  $$TtsDatasetSpeakerTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get displayName => $composableBuilder(
      column: $table.displayName, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get consentStatus => $composableBuilder(
      column: $table.consentStatus,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get allowedUse => $composableBuilder(
      column: $table.allowedUse, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get datasetLicense => $composableBuilder(
      column: $table.datasetLicense,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get consentDocumentPath => $composableBuilder(
      column: $table.consentDocumentPath,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get referenceClipId => $composableBuilder(
      column: $table.referenceClipId,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnOrderings(column));

  $$TtsDatasetProjectTableTableOrderingComposer get projectId {
    final $$TtsDatasetProjectTableTableOrderingComposer composer =
        $composerBuilder(
            composer: this,
            getCurrentColumn: (t) => t.projectId,
            referencedTable: $db.ttsDatasetProjectTable,
            getReferencedColumn: (t) => t.id,
            builder: (joinBuilder,
                    {$addJoinBuilderToRootComposer,
                    $removeJoinBuilderFromRootComposer}) =>
                $$TtsDatasetProjectTableTableOrderingComposer(
                  $db: $db,
                  $table: $db.ttsDatasetProjectTable,
                  $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                  joinBuilder: joinBuilder,
                  $removeJoinBuilderFromRootComposer:
                      $removeJoinBuilderFromRootComposer,
                ));
    return composer;
  }
}

class $$TtsDatasetSpeakerTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $TtsDatasetSpeakerTableTable> {
  $$TtsDatasetSpeakerTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get displayName => $composableBuilder(
      column: $table.displayName, builder: (column) => column);

  GeneratedColumn<String> get consentStatus => $composableBuilder(
      column: $table.consentStatus, builder: (column) => column);

  GeneratedColumn<String> get allowedUse => $composableBuilder(
      column: $table.allowedUse, builder: (column) => column);

  GeneratedColumn<String> get datasetLicense => $composableBuilder(
      column: $table.datasetLicense, builder: (column) => column);

  GeneratedColumn<String> get consentDocumentPath => $composableBuilder(
      column: $table.consentDocumentPath, builder: (column) => column);

  GeneratedColumn<String> get referenceClipId => $composableBuilder(
      column: $table.referenceClipId, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  $$TtsDatasetProjectTableTableAnnotationComposer get projectId {
    final $$TtsDatasetProjectTableTableAnnotationComposer composer =
        $composerBuilder(
            composer: this,
            getCurrentColumn: (t) => t.projectId,
            referencedTable: $db.ttsDatasetProjectTable,
            getReferencedColumn: (t) => t.id,
            builder: (joinBuilder,
                    {$addJoinBuilderToRootComposer,
                    $removeJoinBuilderFromRootComposer}) =>
                $$TtsDatasetProjectTableTableAnnotationComposer(
                  $db: $db,
                  $table: $db.ttsDatasetProjectTable,
                  $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                  joinBuilder: joinBuilder,
                  $removeJoinBuilderFromRootComposer:
                      $removeJoinBuilderFromRootComposer,
                ));
    return composer;
  }

  Expression<T> ttsDatasetClipTableRefs<T extends Object>(
      Expression<T> Function($$TtsDatasetClipTableTableAnnotationComposer a)
          f) {
    final $$TtsDatasetClipTableTableAnnotationComposer composer =
        $composerBuilder(
            composer: this,
            getCurrentColumn: (t) => t.id,
            referencedTable: $db.ttsDatasetClipTable,
            getReferencedColumn: (t) => t.speakerId,
            builder: (joinBuilder,
                    {$addJoinBuilderToRootComposer,
                    $removeJoinBuilderFromRootComposer}) =>
                $$TtsDatasetClipTableTableAnnotationComposer(
                  $db: $db,
                  $table: $db.ttsDatasetClipTable,
                  $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                  joinBuilder: joinBuilder,
                  $removeJoinBuilderFromRootComposer:
                      $removeJoinBuilderFromRootComposer,
                ));
    return f(composer);
  }
}

class $$TtsDatasetSpeakerTableTableTableManager extends RootTableManager<
    _$AppDatabase,
    $TtsDatasetSpeakerTableTable,
    TtsDatasetSpeakerTableData,
    $$TtsDatasetSpeakerTableTableFilterComposer,
    $$TtsDatasetSpeakerTableTableOrderingComposer,
    $$TtsDatasetSpeakerTableTableAnnotationComposer,
    $$TtsDatasetSpeakerTableTableCreateCompanionBuilder,
    $$TtsDatasetSpeakerTableTableUpdateCompanionBuilder,
    (TtsDatasetSpeakerTableData, $$TtsDatasetSpeakerTableTableReferences),
    TtsDatasetSpeakerTableData,
    PrefetchHooks Function({bool projectId, bool ttsDatasetClipTableRefs})> {
  $$TtsDatasetSpeakerTableTableTableManager(
      _$AppDatabase db, $TtsDatasetSpeakerTableTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$TtsDatasetSpeakerTableTableFilterComposer(
                  $db: db, $table: table),
          createOrderingComposer: () =>
              $$TtsDatasetSpeakerTableTableOrderingComposer(
                  $db: db, $table: table),
          createComputedFieldComposer: () =>
              $$TtsDatasetSpeakerTableTableAnnotationComposer(
                  $db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> projectId = const Value.absent(),
            Value<String> displayName = const Value.absent(),
            Value<String> consentStatus = const Value.absent(),
            Value<String> allowedUse = const Value.absent(),
            Value<String> datasetLicense = const Value.absent(),
            Value<String?> consentDocumentPath = const Value.absent(),
            Value<String?> referenceClipId = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              TtsDatasetSpeakerTableCompanion(
            id: id,
            projectId: projectId,
            displayName: displayName,
            consentStatus: consentStatus,
            allowedUse: allowedUse,
            datasetLicense: datasetLicense,
            consentDocumentPath: consentDocumentPath,
            referenceClipId: referenceClipId,
            createdAt: createdAt,
            updatedAt: updatedAt,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String projectId,
            required String displayName,
            required String consentStatus,
            required String allowedUse,
            required String datasetLicense,
            Value<String?> consentDocumentPath = const Value.absent(),
            Value<String?> referenceClipId = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              TtsDatasetSpeakerTableCompanion.insert(
            id: id,
            projectId: projectId,
            displayName: displayName,
            consentStatus: consentStatus,
            allowedUse: allowedUse,
            datasetLicense: datasetLicense,
            consentDocumentPath: consentDocumentPath,
            referenceClipId: referenceClipId,
            createdAt: createdAt,
            updatedAt: updatedAt,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable(table),
                    $$TtsDatasetSpeakerTableTableReferences(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: (
              {projectId = false, ttsDatasetClipTableRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [
                if (ttsDatasetClipTableRefs) db.ttsDatasetClipTable
              ],
              addJoins: <
                  T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic>>(state) {
                if (projectId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.projectId,
                    referencedTable: $$TtsDatasetSpeakerTableTableReferences
                        ._projectIdTable(db),
                    referencedColumn: $$TtsDatasetSpeakerTableTableReferences
                        ._projectIdTable(db)
                        .id,
                  ) as T;
                }

                return state;
              },
              getPrefetchedDataCallback: (items) async {
                return [
                  if (ttsDatasetClipTableRefs)
                    await $_getPrefetchedData<
                            TtsDatasetSpeakerTableData,
                            $TtsDatasetSpeakerTableTable,
                            TtsDatasetClipTableData>(
                        currentTable: table,
                        referencedTable: $$TtsDatasetSpeakerTableTableReferences
                            ._ttsDatasetClipTableRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$TtsDatasetSpeakerTableTableReferences(
                                    db, table, p0)
                                .ttsDatasetClipTableRefs,
                        referencedItemsForCurrentItem:
                            (item, referencedItems) => referencedItems
                                .where((e) => e.speakerId == item.id),
                        typedResults: items)
                ];
              },
            );
          },
        ));
}

typedef $$TtsDatasetSpeakerTableTableProcessedTableManager
    = ProcessedTableManager<
        _$AppDatabase,
        $TtsDatasetSpeakerTableTable,
        TtsDatasetSpeakerTableData,
        $$TtsDatasetSpeakerTableTableFilterComposer,
        $$TtsDatasetSpeakerTableTableOrderingComposer,
        $$TtsDatasetSpeakerTableTableAnnotationComposer,
        $$TtsDatasetSpeakerTableTableCreateCompanionBuilder,
        $$TtsDatasetSpeakerTableTableUpdateCompanionBuilder,
        (TtsDatasetSpeakerTableData, $$TtsDatasetSpeakerTableTableReferences),
        TtsDatasetSpeakerTableData,
        PrefetchHooks Function({bool projectId, bool ttsDatasetClipTableRefs})>;
typedef $$TtsDatasetPromptTableTableCreateCompanionBuilder
    = TtsDatasetPromptTableCompanion Function({
  required String id,
  required String projectId,
  required String rawText,
  required String normalizedText,
  required String language,
  required List<String> tags,
  required int sortOrder,
  required String status,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
  Value<int> rowid,
});
typedef $$TtsDatasetPromptTableTableUpdateCompanionBuilder
    = TtsDatasetPromptTableCompanion Function({
  Value<String> id,
  Value<String> projectId,
  Value<String> rawText,
  Value<String> normalizedText,
  Value<String> language,
  Value<List<String>> tags,
  Value<int> sortOrder,
  Value<String> status,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
  Value<int> rowid,
});

final class $$TtsDatasetPromptTableTableReferences extends BaseReferences<
    _$AppDatabase, $TtsDatasetPromptTableTable, TtsDatasetPromptTableData> {
  $$TtsDatasetPromptTableTableReferences(
      super.$_db, super.$_table, super.$_typedResult);

  static $TtsDatasetProjectTableTable _projectIdTable(_$AppDatabase db) =>
      db.ttsDatasetProjectTable.createAlias($_aliasNameGenerator(
          db.ttsDatasetPromptTable.projectId, db.ttsDatasetProjectTable.id));

  $$TtsDatasetProjectTableTableProcessedTableManager get projectId {
    final $_column = $_itemColumn<String>('project_id')!;

    final manager = $$TtsDatasetProjectTableTableTableManager(
            $_db, $_db.ttsDatasetProjectTable)
        .filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_projectIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }

  static MultiTypedResultKey<$TtsDatasetClipTableTable,
      List<TtsDatasetClipTableData>> _ttsDatasetClipTableRefsTable(
          _$AppDatabase db) =>
      MultiTypedResultKey.fromTable(db.ttsDatasetClipTable,
          aliasName: $_aliasNameGenerator(
              db.ttsDatasetPromptTable.id, db.ttsDatasetClipTable.promptId));

  $$TtsDatasetClipTableTableProcessedTableManager get ttsDatasetClipTableRefs {
    final manager = $$TtsDatasetClipTableTableTableManager(
            $_db, $_db.ttsDatasetClipTable)
        .filter((f) => f.promptId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache =
        $_typedResult.readTableOrNull(_ttsDatasetClipTableRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }
}

class $$TtsDatasetPromptTableTableFilterComposer
    extends Composer<_$AppDatabase, $TtsDatasetPromptTableTable> {
  $$TtsDatasetPromptTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get rawText => $composableBuilder(
      column: $table.rawText, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get normalizedText => $composableBuilder(
      column: $table.normalizedText,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get language => $composableBuilder(
      column: $table.language, builder: (column) => ColumnFilters(column));

  ColumnWithTypeConverterFilters<List<String>, List<String>, String> get tags =>
      $composableBuilder(
          column: $table.tags,
          builder: (column) => ColumnWithTypeConverterFilters(column));

  ColumnFilters<int> get sortOrder => $composableBuilder(
      column: $table.sortOrder, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get status => $composableBuilder(
      column: $table.status, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnFilters(column));

  $$TtsDatasetProjectTableTableFilterComposer get projectId {
    final $$TtsDatasetProjectTableTableFilterComposer composer =
        $composerBuilder(
            composer: this,
            getCurrentColumn: (t) => t.projectId,
            referencedTable: $db.ttsDatasetProjectTable,
            getReferencedColumn: (t) => t.id,
            builder: (joinBuilder,
                    {$addJoinBuilderToRootComposer,
                    $removeJoinBuilderFromRootComposer}) =>
                $$TtsDatasetProjectTableTableFilterComposer(
                  $db: $db,
                  $table: $db.ttsDatasetProjectTable,
                  $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                  joinBuilder: joinBuilder,
                  $removeJoinBuilderFromRootComposer:
                      $removeJoinBuilderFromRootComposer,
                ));
    return composer;
  }

  Expression<bool> ttsDatasetClipTableRefs(
      Expression<bool> Function($$TtsDatasetClipTableTableFilterComposer f) f) {
    final $$TtsDatasetClipTableTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.ttsDatasetClipTable,
        getReferencedColumn: (t) => t.promptId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$TtsDatasetClipTableTableFilterComposer(
              $db: $db,
              $table: $db.ttsDatasetClipTable,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }
}

class $$TtsDatasetPromptTableTableOrderingComposer
    extends Composer<_$AppDatabase, $TtsDatasetPromptTableTable> {
  $$TtsDatasetPromptTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get rawText => $composableBuilder(
      column: $table.rawText, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get normalizedText => $composableBuilder(
      column: $table.normalizedText,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get language => $composableBuilder(
      column: $table.language, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get tags => $composableBuilder(
      column: $table.tags, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get sortOrder => $composableBuilder(
      column: $table.sortOrder, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get status => $composableBuilder(
      column: $table.status, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnOrderings(column));

  $$TtsDatasetProjectTableTableOrderingComposer get projectId {
    final $$TtsDatasetProjectTableTableOrderingComposer composer =
        $composerBuilder(
            composer: this,
            getCurrentColumn: (t) => t.projectId,
            referencedTable: $db.ttsDatasetProjectTable,
            getReferencedColumn: (t) => t.id,
            builder: (joinBuilder,
                    {$addJoinBuilderToRootComposer,
                    $removeJoinBuilderFromRootComposer}) =>
                $$TtsDatasetProjectTableTableOrderingComposer(
                  $db: $db,
                  $table: $db.ttsDatasetProjectTable,
                  $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                  joinBuilder: joinBuilder,
                  $removeJoinBuilderFromRootComposer:
                      $removeJoinBuilderFromRootComposer,
                ));
    return composer;
  }
}

class $$TtsDatasetPromptTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $TtsDatasetPromptTableTable> {
  $$TtsDatasetPromptTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get rawText =>
      $composableBuilder(column: $table.rawText, builder: (column) => column);

  GeneratedColumn<String> get normalizedText => $composableBuilder(
      column: $table.normalizedText, builder: (column) => column);

  GeneratedColumn<String> get language =>
      $composableBuilder(column: $table.language, builder: (column) => column);

  GeneratedColumnWithTypeConverter<List<String>, String> get tags =>
      $composableBuilder(column: $table.tags, builder: (column) => column);

  GeneratedColumn<int> get sortOrder =>
      $composableBuilder(column: $table.sortOrder, builder: (column) => column);

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  $$TtsDatasetProjectTableTableAnnotationComposer get projectId {
    final $$TtsDatasetProjectTableTableAnnotationComposer composer =
        $composerBuilder(
            composer: this,
            getCurrentColumn: (t) => t.projectId,
            referencedTable: $db.ttsDatasetProjectTable,
            getReferencedColumn: (t) => t.id,
            builder: (joinBuilder,
                    {$addJoinBuilderToRootComposer,
                    $removeJoinBuilderFromRootComposer}) =>
                $$TtsDatasetProjectTableTableAnnotationComposer(
                  $db: $db,
                  $table: $db.ttsDatasetProjectTable,
                  $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                  joinBuilder: joinBuilder,
                  $removeJoinBuilderFromRootComposer:
                      $removeJoinBuilderFromRootComposer,
                ));
    return composer;
  }

  Expression<T> ttsDatasetClipTableRefs<T extends Object>(
      Expression<T> Function($$TtsDatasetClipTableTableAnnotationComposer a)
          f) {
    final $$TtsDatasetClipTableTableAnnotationComposer composer =
        $composerBuilder(
            composer: this,
            getCurrentColumn: (t) => t.id,
            referencedTable: $db.ttsDatasetClipTable,
            getReferencedColumn: (t) => t.promptId,
            builder: (joinBuilder,
                    {$addJoinBuilderToRootComposer,
                    $removeJoinBuilderFromRootComposer}) =>
                $$TtsDatasetClipTableTableAnnotationComposer(
                  $db: $db,
                  $table: $db.ttsDatasetClipTable,
                  $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                  joinBuilder: joinBuilder,
                  $removeJoinBuilderFromRootComposer:
                      $removeJoinBuilderFromRootComposer,
                ));
    return f(composer);
  }
}

class $$TtsDatasetPromptTableTableTableManager extends RootTableManager<
    _$AppDatabase,
    $TtsDatasetPromptTableTable,
    TtsDatasetPromptTableData,
    $$TtsDatasetPromptTableTableFilterComposer,
    $$TtsDatasetPromptTableTableOrderingComposer,
    $$TtsDatasetPromptTableTableAnnotationComposer,
    $$TtsDatasetPromptTableTableCreateCompanionBuilder,
    $$TtsDatasetPromptTableTableUpdateCompanionBuilder,
    (TtsDatasetPromptTableData, $$TtsDatasetPromptTableTableReferences),
    TtsDatasetPromptTableData,
    PrefetchHooks Function({bool projectId, bool ttsDatasetClipTableRefs})> {
  $$TtsDatasetPromptTableTableTableManager(
      _$AppDatabase db, $TtsDatasetPromptTableTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$TtsDatasetPromptTableTableFilterComposer(
                  $db: db, $table: table),
          createOrderingComposer: () =>
              $$TtsDatasetPromptTableTableOrderingComposer(
                  $db: db, $table: table),
          createComputedFieldComposer: () =>
              $$TtsDatasetPromptTableTableAnnotationComposer(
                  $db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> projectId = const Value.absent(),
            Value<String> rawText = const Value.absent(),
            Value<String> normalizedText = const Value.absent(),
            Value<String> language = const Value.absent(),
            Value<List<String>> tags = const Value.absent(),
            Value<int> sortOrder = const Value.absent(),
            Value<String> status = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              TtsDatasetPromptTableCompanion(
            id: id,
            projectId: projectId,
            rawText: rawText,
            normalizedText: normalizedText,
            language: language,
            tags: tags,
            sortOrder: sortOrder,
            status: status,
            createdAt: createdAt,
            updatedAt: updatedAt,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String projectId,
            required String rawText,
            required String normalizedText,
            required String language,
            required List<String> tags,
            required int sortOrder,
            required String status,
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              TtsDatasetPromptTableCompanion.insert(
            id: id,
            projectId: projectId,
            rawText: rawText,
            normalizedText: normalizedText,
            language: language,
            tags: tags,
            sortOrder: sortOrder,
            status: status,
            createdAt: createdAt,
            updatedAt: updatedAt,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable(table),
                    $$TtsDatasetPromptTableTableReferences(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: (
              {projectId = false, ttsDatasetClipTableRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [
                if (ttsDatasetClipTableRefs) db.ttsDatasetClipTable
              ],
              addJoins: <
                  T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic>>(state) {
                if (projectId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.projectId,
                    referencedTable: $$TtsDatasetPromptTableTableReferences
                        ._projectIdTable(db),
                    referencedColumn: $$TtsDatasetPromptTableTableReferences
                        ._projectIdTable(db)
                        .id,
                  ) as T;
                }

                return state;
              },
              getPrefetchedDataCallback: (items) async {
                return [
                  if (ttsDatasetClipTableRefs)
                    await $_getPrefetchedData<
                            TtsDatasetPromptTableData,
                            $TtsDatasetPromptTableTable,
                            TtsDatasetClipTableData>(
                        currentTable: table,
                        referencedTable: $$TtsDatasetPromptTableTableReferences
                            ._ttsDatasetClipTableRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$TtsDatasetPromptTableTableReferences(
                                    db, table, p0)
                                .ttsDatasetClipTableRefs,
                        referencedItemsForCurrentItem: (item,
                                referencedItems) =>
                            referencedItems.where((e) => e.promptId == item.id),
                        typedResults: items)
                ];
              },
            );
          },
        ));
}

typedef $$TtsDatasetPromptTableTableProcessedTableManager
    = ProcessedTableManager<
        _$AppDatabase,
        $TtsDatasetPromptTableTable,
        TtsDatasetPromptTableData,
        $$TtsDatasetPromptTableTableFilterComposer,
        $$TtsDatasetPromptTableTableOrderingComposer,
        $$TtsDatasetPromptTableTableAnnotationComposer,
        $$TtsDatasetPromptTableTableCreateCompanionBuilder,
        $$TtsDatasetPromptTableTableUpdateCompanionBuilder,
        (TtsDatasetPromptTableData, $$TtsDatasetPromptTableTableReferences),
        TtsDatasetPromptTableData,
        PrefetchHooks Function({bool projectId, bool ttsDatasetClipTableRefs})>;
typedef $$TtsDatasetClipTableTableCreateCompanionBuilder
    = TtsDatasetClipTableCompanion Function({
  required String id,
  required String projectId,
  required String speakerId,
  Value<String?> promptId,
  required String rawPath,
  required String processedPath,
  required String exportWavPath,
  required String rawText,
  required String normalizedText,
  required String language,
  required int durationMs,
  required int sampleRate,
  required int channels,
  required int bitDepth,
  Value<double?> peakDb,
  Value<double?> rmsDb,
  Value<double?> noiseFloorDb,
  Value<double?> snrEstimateDb,
  Value<int?> clippingCount,
  Value<int?> leadingSilenceMs,
  Value<int?> trailingSilenceMs,
  required String noiseReductionMode,
  Value<String?> noiseReductionEngine,
  Value<String?> processingProfileId,
  required String status,
  Value<String?> rejectionReason,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
  Value<int> rowid,
});
typedef $$TtsDatasetClipTableTableUpdateCompanionBuilder
    = TtsDatasetClipTableCompanion Function({
  Value<String> id,
  Value<String> projectId,
  Value<String> speakerId,
  Value<String?> promptId,
  Value<String> rawPath,
  Value<String> processedPath,
  Value<String> exportWavPath,
  Value<String> rawText,
  Value<String> normalizedText,
  Value<String> language,
  Value<int> durationMs,
  Value<int> sampleRate,
  Value<int> channels,
  Value<int> bitDepth,
  Value<double?> peakDb,
  Value<double?> rmsDb,
  Value<double?> noiseFloorDb,
  Value<double?> snrEstimateDb,
  Value<int?> clippingCount,
  Value<int?> leadingSilenceMs,
  Value<int?> trailingSilenceMs,
  Value<String> noiseReductionMode,
  Value<String?> noiseReductionEngine,
  Value<String?> processingProfileId,
  Value<String> status,
  Value<String?> rejectionReason,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
  Value<int> rowid,
});

final class $$TtsDatasetClipTableTableReferences extends BaseReferences<
    _$AppDatabase, $TtsDatasetClipTableTable, TtsDatasetClipTableData> {
  $$TtsDatasetClipTableTableReferences(
      super.$_db, super.$_table, super.$_typedResult);

  static $TtsDatasetProjectTableTable _projectIdTable(_$AppDatabase db) =>
      db.ttsDatasetProjectTable.createAlias($_aliasNameGenerator(
          db.ttsDatasetClipTable.projectId, db.ttsDatasetProjectTable.id));

  $$TtsDatasetProjectTableTableProcessedTableManager get projectId {
    final $_column = $_itemColumn<String>('project_id')!;

    final manager = $$TtsDatasetProjectTableTableTableManager(
            $_db, $_db.ttsDatasetProjectTable)
        .filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_projectIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }

  static $TtsDatasetSpeakerTableTable _speakerIdTable(_$AppDatabase db) =>
      db.ttsDatasetSpeakerTable.createAlias($_aliasNameGenerator(
          db.ttsDatasetClipTable.speakerId, db.ttsDatasetSpeakerTable.id));

  $$TtsDatasetSpeakerTableTableProcessedTableManager get speakerId {
    final $_column = $_itemColumn<String>('speaker_id')!;

    final manager = $$TtsDatasetSpeakerTableTableTableManager(
            $_db, $_db.ttsDatasetSpeakerTable)
        .filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_speakerIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }

  static $TtsDatasetPromptTableTable _promptIdTable(_$AppDatabase db) =>
      db.ttsDatasetPromptTable.createAlias($_aliasNameGenerator(
          db.ttsDatasetClipTable.promptId, db.ttsDatasetPromptTable.id));

  $$TtsDatasetPromptTableTableProcessedTableManager? get promptId {
    final $_column = $_itemColumn<String>('prompt_id');
    if ($_column == null) return null;
    final manager = $$TtsDatasetPromptTableTableTableManager(
            $_db, $_db.ttsDatasetPromptTable)
        .filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_promptIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }

  static MultiTypedResultKey<$TtsDatasetValidationIssueTableTable,
          List<TtsDatasetValidationIssueTableData>>
      _ttsDatasetValidationIssueTableRefsTable(_$AppDatabase db) =>
          MultiTypedResultKey.fromTable(db.ttsDatasetValidationIssueTable,
              aliasName: $_aliasNameGenerator(db.ttsDatasetClipTable.id,
                  db.ttsDatasetValidationIssueTable.clipId));

  $$TtsDatasetValidationIssueTableTableProcessedTableManager
      get ttsDatasetValidationIssueTableRefs {
    final manager = $$TtsDatasetValidationIssueTableTableTableManager(
            $_db, $_db.ttsDatasetValidationIssueTable)
        .filter((f) => f.clipId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult
        .readTableOrNull(_ttsDatasetValidationIssueTableRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }
}

class $$TtsDatasetClipTableTableFilterComposer
    extends Composer<_$AppDatabase, $TtsDatasetClipTableTable> {
  $$TtsDatasetClipTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get rawPath => $composableBuilder(
      column: $table.rawPath, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get processedPath => $composableBuilder(
      column: $table.processedPath, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get exportWavPath => $composableBuilder(
      column: $table.exportWavPath, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get rawText => $composableBuilder(
      column: $table.rawText, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get normalizedText => $composableBuilder(
      column: $table.normalizedText,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get language => $composableBuilder(
      column: $table.language, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get durationMs => $composableBuilder(
      column: $table.durationMs, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get sampleRate => $composableBuilder(
      column: $table.sampleRate, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get channels => $composableBuilder(
      column: $table.channels, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get bitDepth => $composableBuilder(
      column: $table.bitDepth, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get peakDb => $composableBuilder(
      column: $table.peakDb, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get rmsDb => $composableBuilder(
      column: $table.rmsDb, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get noiseFloorDb => $composableBuilder(
      column: $table.noiseFloorDb, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get snrEstimateDb => $composableBuilder(
      column: $table.snrEstimateDb, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get clippingCount => $composableBuilder(
      column: $table.clippingCount, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get leadingSilenceMs => $composableBuilder(
      column: $table.leadingSilenceMs,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get trailingSilenceMs => $composableBuilder(
      column: $table.trailingSilenceMs,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get noiseReductionMode => $composableBuilder(
      column: $table.noiseReductionMode,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get noiseReductionEngine => $composableBuilder(
      column: $table.noiseReductionEngine,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get processingProfileId => $composableBuilder(
      column: $table.processingProfileId,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get status => $composableBuilder(
      column: $table.status, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get rejectionReason => $composableBuilder(
      column: $table.rejectionReason,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnFilters(column));

  $$TtsDatasetProjectTableTableFilterComposer get projectId {
    final $$TtsDatasetProjectTableTableFilterComposer composer =
        $composerBuilder(
            composer: this,
            getCurrentColumn: (t) => t.projectId,
            referencedTable: $db.ttsDatasetProjectTable,
            getReferencedColumn: (t) => t.id,
            builder: (joinBuilder,
                    {$addJoinBuilderToRootComposer,
                    $removeJoinBuilderFromRootComposer}) =>
                $$TtsDatasetProjectTableTableFilterComposer(
                  $db: $db,
                  $table: $db.ttsDatasetProjectTable,
                  $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                  joinBuilder: joinBuilder,
                  $removeJoinBuilderFromRootComposer:
                      $removeJoinBuilderFromRootComposer,
                ));
    return composer;
  }

  $$TtsDatasetSpeakerTableTableFilterComposer get speakerId {
    final $$TtsDatasetSpeakerTableTableFilterComposer composer =
        $composerBuilder(
            composer: this,
            getCurrentColumn: (t) => t.speakerId,
            referencedTable: $db.ttsDatasetSpeakerTable,
            getReferencedColumn: (t) => t.id,
            builder: (joinBuilder,
                    {$addJoinBuilderToRootComposer,
                    $removeJoinBuilderFromRootComposer}) =>
                $$TtsDatasetSpeakerTableTableFilterComposer(
                  $db: $db,
                  $table: $db.ttsDatasetSpeakerTable,
                  $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                  joinBuilder: joinBuilder,
                  $removeJoinBuilderFromRootComposer:
                      $removeJoinBuilderFromRootComposer,
                ));
    return composer;
  }

  $$TtsDatasetPromptTableTableFilterComposer get promptId {
    final $$TtsDatasetPromptTableTableFilterComposer composer =
        $composerBuilder(
            composer: this,
            getCurrentColumn: (t) => t.promptId,
            referencedTable: $db.ttsDatasetPromptTable,
            getReferencedColumn: (t) => t.id,
            builder: (joinBuilder,
                    {$addJoinBuilderToRootComposer,
                    $removeJoinBuilderFromRootComposer}) =>
                $$TtsDatasetPromptTableTableFilterComposer(
                  $db: $db,
                  $table: $db.ttsDatasetPromptTable,
                  $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                  joinBuilder: joinBuilder,
                  $removeJoinBuilderFromRootComposer:
                      $removeJoinBuilderFromRootComposer,
                ));
    return composer;
  }

  Expression<bool> ttsDatasetValidationIssueTableRefs(
      Expression<bool> Function(
              $$TtsDatasetValidationIssueTableTableFilterComposer f)
          f) {
    final $$TtsDatasetValidationIssueTableTableFilterComposer composer =
        $composerBuilder(
            composer: this,
            getCurrentColumn: (t) => t.id,
            referencedTable: $db.ttsDatasetValidationIssueTable,
            getReferencedColumn: (t) => t.clipId,
            builder: (joinBuilder,
                    {$addJoinBuilderToRootComposer,
                    $removeJoinBuilderFromRootComposer}) =>
                $$TtsDatasetValidationIssueTableTableFilterComposer(
                  $db: $db,
                  $table: $db.ttsDatasetValidationIssueTable,
                  $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                  joinBuilder: joinBuilder,
                  $removeJoinBuilderFromRootComposer:
                      $removeJoinBuilderFromRootComposer,
                ));
    return f(composer);
  }
}

class $$TtsDatasetClipTableTableOrderingComposer
    extends Composer<_$AppDatabase, $TtsDatasetClipTableTable> {
  $$TtsDatasetClipTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get rawPath => $composableBuilder(
      column: $table.rawPath, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get processedPath => $composableBuilder(
      column: $table.processedPath,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get exportWavPath => $composableBuilder(
      column: $table.exportWavPath,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get rawText => $composableBuilder(
      column: $table.rawText, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get normalizedText => $composableBuilder(
      column: $table.normalizedText,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get language => $composableBuilder(
      column: $table.language, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get durationMs => $composableBuilder(
      column: $table.durationMs, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get sampleRate => $composableBuilder(
      column: $table.sampleRate, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get channels => $composableBuilder(
      column: $table.channels, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get bitDepth => $composableBuilder(
      column: $table.bitDepth, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get peakDb => $composableBuilder(
      column: $table.peakDb, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get rmsDb => $composableBuilder(
      column: $table.rmsDb, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get noiseFloorDb => $composableBuilder(
      column: $table.noiseFloorDb,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get snrEstimateDb => $composableBuilder(
      column: $table.snrEstimateDb,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get clippingCount => $composableBuilder(
      column: $table.clippingCount,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get leadingSilenceMs => $composableBuilder(
      column: $table.leadingSilenceMs,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get trailingSilenceMs => $composableBuilder(
      column: $table.trailingSilenceMs,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get noiseReductionMode => $composableBuilder(
      column: $table.noiseReductionMode,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get noiseReductionEngine => $composableBuilder(
      column: $table.noiseReductionEngine,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get processingProfileId => $composableBuilder(
      column: $table.processingProfileId,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get status => $composableBuilder(
      column: $table.status, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get rejectionReason => $composableBuilder(
      column: $table.rejectionReason,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnOrderings(column));

  $$TtsDatasetProjectTableTableOrderingComposer get projectId {
    final $$TtsDatasetProjectTableTableOrderingComposer composer =
        $composerBuilder(
            composer: this,
            getCurrentColumn: (t) => t.projectId,
            referencedTable: $db.ttsDatasetProjectTable,
            getReferencedColumn: (t) => t.id,
            builder: (joinBuilder,
                    {$addJoinBuilderToRootComposer,
                    $removeJoinBuilderFromRootComposer}) =>
                $$TtsDatasetProjectTableTableOrderingComposer(
                  $db: $db,
                  $table: $db.ttsDatasetProjectTable,
                  $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                  joinBuilder: joinBuilder,
                  $removeJoinBuilderFromRootComposer:
                      $removeJoinBuilderFromRootComposer,
                ));
    return composer;
  }

  $$TtsDatasetSpeakerTableTableOrderingComposer get speakerId {
    final $$TtsDatasetSpeakerTableTableOrderingComposer composer =
        $composerBuilder(
            composer: this,
            getCurrentColumn: (t) => t.speakerId,
            referencedTable: $db.ttsDatasetSpeakerTable,
            getReferencedColumn: (t) => t.id,
            builder: (joinBuilder,
                    {$addJoinBuilderToRootComposer,
                    $removeJoinBuilderFromRootComposer}) =>
                $$TtsDatasetSpeakerTableTableOrderingComposer(
                  $db: $db,
                  $table: $db.ttsDatasetSpeakerTable,
                  $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                  joinBuilder: joinBuilder,
                  $removeJoinBuilderFromRootComposer:
                      $removeJoinBuilderFromRootComposer,
                ));
    return composer;
  }

  $$TtsDatasetPromptTableTableOrderingComposer get promptId {
    final $$TtsDatasetPromptTableTableOrderingComposer composer =
        $composerBuilder(
            composer: this,
            getCurrentColumn: (t) => t.promptId,
            referencedTable: $db.ttsDatasetPromptTable,
            getReferencedColumn: (t) => t.id,
            builder: (joinBuilder,
                    {$addJoinBuilderToRootComposer,
                    $removeJoinBuilderFromRootComposer}) =>
                $$TtsDatasetPromptTableTableOrderingComposer(
                  $db: $db,
                  $table: $db.ttsDatasetPromptTable,
                  $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                  joinBuilder: joinBuilder,
                  $removeJoinBuilderFromRootComposer:
                      $removeJoinBuilderFromRootComposer,
                ));
    return composer;
  }
}

class $$TtsDatasetClipTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $TtsDatasetClipTableTable> {
  $$TtsDatasetClipTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get rawPath =>
      $composableBuilder(column: $table.rawPath, builder: (column) => column);

  GeneratedColumn<String> get processedPath => $composableBuilder(
      column: $table.processedPath, builder: (column) => column);

  GeneratedColumn<String> get exportWavPath => $composableBuilder(
      column: $table.exportWavPath, builder: (column) => column);

  GeneratedColumn<String> get rawText =>
      $composableBuilder(column: $table.rawText, builder: (column) => column);

  GeneratedColumn<String> get normalizedText => $composableBuilder(
      column: $table.normalizedText, builder: (column) => column);

  GeneratedColumn<String> get language =>
      $composableBuilder(column: $table.language, builder: (column) => column);

  GeneratedColumn<int> get durationMs => $composableBuilder(
      column: $table.durationMs, builder: (column) => column);

  GeneratedColumn<int> get sampleRate => $composableBuilder(
      column: $table.sampleRate, builder: (column) => column);

  GeneratedColumn<int> get channels =>
      $composableBuilder(column: $table.channels, builder: (column) => column);

  GeneratedColumn<int> get bitDepth =>
      $composableBuilder(column: $table.bitDepth, builder: (column) => column);

  GeneratedColumn<double> get peakDb =>
      $composableBuilder(column: $table.peakDb, builder: (column) => column);

  GeneratedColumn<double> get rmsDb =>
      $composableBuilder(column: $table.rmsDb, builder: (column) => column);

  GeneratedColumn<double> get noiseFloorDb => $composableBuilder(
      column: $table.noiseFloorDb, builder: (column) => column);

  GeneratedColumn<double> get snrEstimateDb => $composableBuilder(
      column: $table.snrEstimateDb, builder: (column) => column);

  GeneratedColumn<int> get clippingCount => $composableBuilder(
      column: $table.clippingCount, builder: (column) => column);

  GeneratedColumn<int> get leadingSilenceMs => $composableBuilder(
      column: $table.leadingSilenceMs, builder: (column) => column);

  GeneratedColumn<int> get trailingSilenceMs => $composableBuilder(
      column: $table.trailingSilenceMs, builder: (column) => column);

  GeneratedColumn<String> get noiseReductionMode => $composableBuilder(
      column: $table.noiseReductionMode, builder: (column) => column);

  GeneratedColumn<String> get noiseReductionEngine => $composableBuilder(
      column: $table.noiseReductionEngine, builder: (column) => column);

  GeneratedColumn<String> get processingProfileId => $composableBuilder(
      column: $table.processingProfileId, builder: (column) => column);

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<String> get rejectionReason => $composableBuilder(
      column: $table.rejectionReason, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  $$TtsDatasetProjectTableTableAnnotationComposer get projectId {
    final $$TtsDatasetProjectTableTableAnnotationComposer composer =
        $composerBuilder(
            composer: this,
            getCurrentColumn: (t) => t.projectId,
            referencedTable: $db.ttsDatasetProjectTable,
            getReferencedColumn: (t) => t.id,
            builder: (joinBuilder,
                    {$addJoinBuilderToRootComposer,
                    $removeJoinBuilderFromRootComposer}) =>
                $$TtsDatasetProjectTableTableAnnotationComposer(
                  $db: $db,
                  $table: $db.ttsDatasetProjectTable,
                  $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                  joinBuilder: joinBuilder,
                  $removeJoinBuilderFromRootComposer:
                      $removeJoinBuilderFromRootComposer,
                ));
    return composer;
  }

  $$TtsDatasetSpeakerTableTableAnnotationComposer get speakerId {
    final $$TtsDatasetSpeakerTableTableAnnotationComposer composer =
        $composerBuilder(
            composer: this,
            getCurrentColumn: (t) => t.speakerId,
            referencedTable: $db.ttsDatasetSpeakerTable,
            getReferencedColumn: (t) => t.id,
            builder: (joinBuilder,
                    {$addJoinBuilderToRootComposer,
                    $removeJoinBuilderFromRootComposer}) =>
                $$TtsDatasetSpeakerTableTableAnnotationComposer(
                  $db: $db,
                  $table: $db.ttsDatasetSpeakerTable,
                  $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                  joinBuilder: joinBuilder,
                  $removeJoinBuilderFromRootComposer:
                      $removeJoinBuilderFromRootComposer,
                ));
    return composer;
  }

  $$TtsDatasetPromptTableTableAnnotationComposer get promptId {
    final $$TtsDatasetPromptTableTableAnnotationComposer composer =
        $composerBuilder(
            composer: this,
            getCurrentColumn: (t) => t.promptId,
            referencedTable: $db.ttsDatasetPromptTable,
            getReferencedColumn: (t) => t.id,
            builder: (joinBuilder,
                    {$addJoinBuilderToRootComposer,
                    $removeJoinBuilderFromRootComposer}) =>
                $$TtsDatasetPromptTableTableAnnotationComposer(
                  $db: $db,
                  $table: $db.ttsDatasetPromptTable,
                  $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                  joinBuilder: joinBuilder,
                  $removeJoinBuilderFromRootComposer:
                      $removeJoinBuilderFromRootComposer,
                ));
    return composer;
  }

  Expression<T> ttsDatasetValidationIssueTableRefs<T extends Object>(
      Expression<T> Function(
              $$TtsDatasetValidationIssueTableTableAnnotationComposer a)
          f) {
    final $$TtsDatasetValidationIssueTableTableAnnotationComposer composer =
        $composerBuilder(
            composer: this,
            getCurrentColumn: (t) => t.id,
            referencedTable: $db.ttsDatasetValidationIssueTable,
            getReferencedColumn: (t) => t.clipId,
            builder: (joinBuilder,
                    {$addJoinBuilderToRootComposer,
                    $removeJoinBuilderFromRootComposer}) =>
                $$TtsDatasetValidationIssueTableTableAnnotationComposer(
                  $db: $db,
                  $table: $db.ttsDatasetValidationIssueTable,
                  $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                  joinBuilder: joinBuilder,
                  $removeJoinBuilderFromRootComposer:
                      $removeJoinBuilderFromRootComposer,
                ));
    return f(composer);
  }
}

class $$TtsDatasetClipTableTableTableManager extends RootTableManager<
    _$AppDatabase,
    $TtsDatasetClipTableTable,
    TtsDatasetClipTableData,
    $$TtsDatasetClipTableTableFilterComposer,
    $$TtsDatasetClipTableTableOrderingComposer,
    $$TtsDatasetClipTableTableAnnotationComposer,
    $$TtsDatasetClipTableTableCreateCompanionBuilder,
    $$TtsDatasetClipTableTableUpdateCompanionBuilder,
    (TtsDatasetClipTableData, $$TtsDatasetClipTableTableReferences),
    TtsDatasetClipTableData,
    PrefetchHooks Function(
        {bool projectId,
        bool speakerId,
        bool promptId,
        bool ttsDatasetValidationIssueTableRefs})> {
  $$TtsDatasetClipTableTableTableManager(
      _$AppDatabase db, $TtsDatasetClipTableTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$TtsDatasetClipTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$TtsDatasetClipTableTableOrderingComposer(
                  $db: db, $table: table),
          createComputedFieldComposer: () =>
              $$TtsDatasetClipTableTableAnnotationComposer(
                  $db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> projectId = const Value.absent(),
            Value<String> speakerId = const Value.absent(),
            Value<String?> promptId = const Value.absent(),
            Value<String> rawPath = const Value.absent(),
            Value<String> processedPath = const Value.absent(),
            Value<String> exportWavPath = const Value.absent(),
            Value<String> rawText = const Value.absent(),
            Value<String> normalizedText = const Value.absent(),
            Value<String> language = const Value.absent(),
            Value<int> durationMs = const Value.absent(),
            Value<int> sampleRate = const Value.absent(),
            Value<int> channels = const Value.absent(),
            Value<int> bitDepth = const Value.absent(),
            Value<double?> peakDb = const Value.absent(),
            Value<double?> rmsDb = const Value.absent(),
            Value<double?> noiseFloorDb = const Value.absent(),
            Value<double?> snrEstimateDb = const Value.absent(),
            Value<int?> clippingCount = const Value.absent(),
            Value<int?> leadingSilenceMs = const Value.absent(),
            Value<int?> trailingSilenceMs = const Value.absent(),
            Value<String> noiseReductionMode = const Value.absent(),
            Value<String?> noiseReductionEngine = const Value.absent(),
            Value<String?> processingProfileId = const Value.absent(),
            Value<String> status = const Value.absent(),
            Value<String?> rejectionReason = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              TtsDatasetClipTableCompanion(
            id: id,
            projectId: projectId,
            speakerId: speakerId,
            promptId: promptId,
            rawPath: rawPath,
            processedPath: processedPath,
            exportWavPath: exportWavPath,
            rawText: rawText,
            normalizedText: normalizedText,
            language: language,
            durationMs: durationMs,
            sampleRate: sampleRate,
            channels: channels,
            bitDepth: bitDepth,
            peakDb: peakDb,
            rmsDb: rmsDb,
            noiseFloorDb: noiseFloorDb,
            snrEstimateDb: snrEstimateDb,
            clippingCount: clippingCount,
            leadingSilenceMs: leadingSilenceMs,
            trailingSilenceMs: trailingSilenceMs,
            noiseReductionMode: noiseReductionMode,
            noiseReductionEngine: noiseReductionEngine,
            processingProfileId: processingProfileId,
            status: status,
            rejectionReason: rejectionReason,
            createdAt: createdAt,
            updatedAt: updatedAt,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String projectId,
            required String speakerId,
            Value<String?> promptId = const Value.absent(),
            required String rawPath,
            required String processedPath,
            required String exportWavPath,
            required String rawText,
            required String normalizedText,
            required String language,
            required int durationMs,
            required int sampleRate,
            required int channels,
            required int bitDepth,
            Value<double?> peakDb = const Value.absent(),
            Value<double?> rmsDb = const Value.absent(),
            Value<double?> noiseFloorDb = const Value.absent(),
            Value<double?> snrEstimateDb = const Value.absent(),
            Value<int?> clippingCount = const Value.absent(),
            Value<int?> leadingSilenceMs = const Value.absent(),
            Value<int?> trailingSilenceMs = const Value.absent(),
            required String noiseReductionMode,
            Value<String?> noiseReductionEngine = const Value.absent(),
            Value<String?> processingProfileId = const Value.absent(),
            required String status,
            Value<String?> rejectionReason = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              TtsDatasetClipTableCompanion.insert(
            id: id,
            projectId: projectId,
            speakerId: speakerId,
            promptId: promptId,
            rawPath: rawPath,
            processedPath: processedPath,
            exportWavPath: exportWavPath,
            rawText: rawText,
            normalizedText: normalizedText,
            language: language,
            durationMs: durationMs,
            sampleRate: sampleRate,
            channels: channels,
            bitDepth: bitDepth,
            peakDb: peakDb,
            rmsDb: rmsDb,
            noiseFloorDb: noiseFloorDb,
            snrEstimateDb: snrEstimateDb,
            clippingCount: clippingCount,
            leadingSilenceMs: leadingSilenceMs,
            trailingSilenceMs: trailingSilenceMs,
            noiseReductionMode: noiseReductionMode,
            noiseReductionEngine: noiseReductionEngine,
            processingProfileId: processingProfileId,
            status: status,
            rejectionReason: rejectionReason,
            createdAt: createdAt,
            updatedAt: updatedAt,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable(table),
                    $$TtsDatasetClipTableTableReferences(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: (
              {projectId = false,
              speakerId = false,
              promptId = false,
              ttsDatasetValidationIssueTableRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [
                if (ttsDatasetValidationIssueTableRefs)
                  db.ttsDatasetValidationIssueTable
              ],
              addJoins: <
                  T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic>>(state) {
                if (projectId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.projectId,
                    referencedTable: $$TtsDatasetClipTableTableReferences
                        ._projectIdTable(db),
                    referencedColumn: $$TtsDatasetClipTableTableReferences
                        ._projectIdTable(db)
                        .id,
                  ) as T;
                }
                if (speakerId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.speakerId,
                    referencedTable: $$TtsDatasetClipTableTableReferences
                        ._speakerIdTable(db),
                    referencedColumn: $$TtsDatasetClipTableTableReferences
                        ._speakerIdTable(db)
                        .id,
                  ) as T;
                }
                if (promptId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.promptId,
                    referencedTable:
                        $$TtsDatasetClipTableTableReferences._promptIdTable(db),
                    referencedColumn: $$TtsDatasetClipTableTableReferences
                        ._promptIdTable(db)
                        .id,
                  ) as T;
                }

                return state;
              },
              getPrefetchedDataCallback: (items) async {
                return [
                  if (ttsDatasetValidationIssueTableRefs)
                    await $_getPrefetchedData<
                            TtsDatasetClipTableData,
                            $TtsDatasetClipTableTable,
                            TtsDatasetValidationIssueTableData>(
                        currentTable: table,
                        referencedTable: $$TtsDatasetClipTableTableReferences
                            ._ttsDatasetValidationIssueTableRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$TtsDatasetClipTableTableReferences(db, table, p0)
                                .ttsDatasetValidationIssueTableRefs,
                        referencedItemsForCurrentItem: (item,
                                referencedItems) =>
                            referencedItems.where((e) => e.clipId == item.id),
                        typedResults: items)
                ];
              },
            );
          },
        ));
}

typedef $$TtsDatasetClipTableTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $TtsDatasetClipTableTable,
    TtsDatasetClipTableData,
    $$TtsDatasetClipTableTableFilterComposer,
    $$TtsDatasetClipTableTableOrderingComposer,
    $$TtsDatasetClipTableTableAnnotationComposer,
    $$TtsDatasetClipTableTableCreateCompanionBuilder,
    $$TtsDatasetClipTableTableUpdateCompanionBuilder,
    (TtsDatasetClipTableData, $$TtsDatasetClipTableTableReferences),
    TtsDatasetClipTableData,
    PrefetchHooks Function(
        {bool projectId,
        bool speakerId,
        bool promptId,
        bool ttsDatasetValidationIssueTableRefs})>;
typedef $$TtsDatasetValidationIssueTableTableCreateCompanionBuilder
    = TtsDatasetValidationIssueTableCompanion Function({
  required String id,
  required String projectId,
  Value<String?> clipId,
  required String category,
  required String severity,
  required String code,
  required String message,
  Value<String?> suggestedFix,
  Value<int> rowid,
});
typedef $$TtsDatasetValidationIssueTableTableUpdateCompanionBuilder
    = TtsDatasetValidationIssueTableCompanion Function({
  Value<String> id,
  Value<String> projectId,
  Value<String?> clipId,
  Value<String> category,
  Value<String> severity,
  Value<String> code,
  Value<String> message,
  Value<String?> suggestedFix,
  Value<int> rowid,
});

final class $$TtsDatasetValidationIssueTableTableReferences
    extends BaseReferences<_$AppDatabase, $TtsDatasetValidationIssueTableTable,
        TtsDatasetValidationIssueTableData> {
  $$TtsDatasetValidationIssueTableTableReferences(
      super.$_db, super.$_table, super.$_typedResult);

  static $TtsDatasetProjectTableTable _projectIdTable(_$AppDatabase db) =>
      db.ttsDatasetProjectTable.createAlias($_aliasNameGenerator(
          db.ttsDatasetValidationIssueTable.projectId,
          db.ttsDatasetProjectTable.id));

  $$TtsDatasetProjectTableTableProcessedTableManager get projectId {
    final $_column = $_itemColumn<String>('project_id')!;

    final manager = $$TtsDatasetProjectTableTableTableManager(
            $_db, $_db.ttsDatasetProjectTable)
        .filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_projectIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }

  static $TtsDatasetClipTableTable _clipIdTable(_$AppDatabase db) =>
      db.ttsDatasetClipTable.createAlias($_aliasNameGenerator(
          db.ttsDatasetValidationIssueTable.clipId, db.ttsDatasetClipTable.id));

  $$TtsDatasetClipTableTableProcessedTableManager? get clipId {
    final $_column = $_itemColumn<String>('clip_id');
    if ($_column == null) return null;
    final manager =
        $$TtsDatasetClipTableTableTableManager($_db, $_db.ttsDatasetClipTable)
            .filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_clipIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }
}

class $$TtsDatasetValidationIssueTableTableFilterComposer
    extends Composer<_$AppDatabase, $TtsDatasetValidationIssueTableTable> {
  $$TtsDatasetValidationIssueTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get category => $composableBuilder(
      column: $table.category, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get severity => $composableBuilder(
      column: $table.severity, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get code => $composableBuilder(
      column: $table.code, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get message => $composableBuilder(
      column: $table.message, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get suggestedFix => $composableBuilder(
      column: $table.suggestedFix, builder: (column) => ColumnFilters(column));

  $$TtsDatasetProjectTableTableFilterComposer get projectId {
    final $$TtsDatasetProjectTableTableFilterComposer composer =
        $composerBuilder(
            composer: this,
            getCurrentColumn: (t) => t.projectId,
            referencedTable: $db.ttsDatasetProjectTable,
            getReferencedColumn: (t) => t.id,
            builder: (joinBuilder,
                    {$addJoinBuilderToRootComposer,
                    $removeJoinBuilderFromRootComposer}) =>
                $$TtsDatasetProjectTableTableFilterComposer(
                  $db: $db,
                  $table: $db.ttsDatasetProjectTable,
                  $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                  joinBuilder: joinBuilder,
                  $removeJoinBuilderFromRootComposer:
                      $removeJoinBuilderFromRootComposer,
                ));
    return composer;
  }

  $$TtsDatasetClipTableTableFilterComposer get clipId {
    final $$TtsDatasetClipTableTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.clipId,
        referencedTable: $db.ttsDatasetClipTable,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$TtsDatasetClipTableTableFilterComposer(
              $db: $db,
              $table: $db.ttsDatasetClipTable,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$TtsDatasetValidationIssueTableTableOrderingComposer
    extends Composer<_$AppDatabase, $TtsDatasetValidationIssueTableTable> {
  $$TtsDatasetValidationIssueTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get category => $composableBuilder(
      column: $table.category, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get severity => $composableBuilder(
      column: $table.severity, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get code => $composableBuilder(
      column: $table.code, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get message => $composableBuilder(
      column: $table.message, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get suggestedFix => $composableBuilder(
      column: $table.suggestedFix,
      builder: (column) => ColumnOrderings(column));

  $$TtsDatasetProjectTableTableOrderingComposer get projectId {
    final $$TtsDatasetProjectTableTableOrderingComposer composer =
        $composerBuilder(
            composer: this,
            getCurrentColumn: (t) => t.projectId,
            referencedTable: $db.ttsDatasetProjectTable,
            getReferencedColumn: (t) => t.id,
            builder: (joinBuilder,
                    {$addJoinBuilderToRootComposer,
                    $removeJoinBuilderFromRootComposer}) =>
                $$TtsDatasetProjectTableTableOrderingComposer(
                  $db: $db,
                  $table: $db.ttsDatasetProjectTable,
                  $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                  joinBuilder: joinBuilder,
                  $removeJoinBuilderFromRootComposer:
                      $removeJoinBuilderFromRootComposer,
                ));
    return composer;
  }

  $$TtsDatasetClipTableTableOrderingComposer get clipId {
    final $$TtsDatasetClipTableTableOrderingComposer composer =
        $composerBuilder(
            composer: this,
            getCurrentColumn: (t) => t.clipId,
            referencedTable: $db.ttsDatasetClipTable,
            getReferencedColumn: (t) => t.id,
            builder: (joinBuilder,
                    {$addJoinBuilderToRootComposer,
                    $removeJoinBuilderFromRootComposer}) =>
                $$TtsDatasetClipTableTableOrderingComposer(
                  $db: $db,
                  $table: $db.ttsDatasetClipTable,
                  $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                  joinBuilder: joinBuilder,
                  $removeJoinBuilderFromRootComposer:
                      $removeJoinBuilderFromRootComposer,
                ));
    return composer;
  }
}

class $$TtsDatasetValidationIssueTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $TtsDatasetValidationIssueTableTable> {
  $$TtsDatasetValidationIssueTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get category =>
      $composableBuilder(column: $table.category, builder: (column) => column);

  GeneratedColumn<String> get severity =>
      $composableBuilder(column: $table.severity, builder: (column) => column);

  GeneratedColumn<String> get code =>
      $composableBuilder(column: $table.code, builder: (column) => column);

  GeneratedColumn<String> get message =>
      $composableBuilder(column: $table.message, builder: (column) => column);

  GeneratedColumn<String> get suggestedFix => $composableBuilder(
      column: $table.suggestedFix, builder: (column) => column);

  $$TtsDatasetProjectTableTableAnnotationComposer get projectId {
    final $$TtsDatasetProjectTableTableAnnotationComposer composer =
        $composerBuilder(
            composer: this,
            getCurrentColumn: (t) => t.projectId,
            referencedTable: $db.ttsDatasetProjectTable,
            getReferencedColumn: (t) => t.id,
            builder: (joinBuilder,
                    {$addJoinBuilderToRootComposer,
                    $removeJoinBuilderFromRootComposer}) =>
                $$TtsDatasetProjectTableTableAnnotationComposer(
                  $db: $db,
                  $table: $db.ttsDatasetProjectTable,
                  $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                  joinBuilder: joinBuilder,
                  $removeJoinBuilderFromRootComposer:
                      $removeJoinBuilderFromRootComposer,
                ));
    return composer;
  }

  $$TtsDatasetClipTableTableAnnotationComposer get clipId {
    final $$TtsDatasetClipTableTableAnnotationComposer composer =
        $composerBuilder(
            composer: this,
            getCurrentColumn: (t) => t.clipId,
            referencedTable: $db.ttsDatasetClipTable,
            getReferencedColumn: (t) => t.id,
            builder: (joinBuilder,
                    {$addJoinBuilderToRootComposer,
                    $removeJoinBuilderFromRootComposer}) =>
                $$TtsDatasetClipTableTableAnnotationComposer(
                  $db: $db,
                  $table: $db.ttsDatasetClipTable,
                  $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                  joinBuilder: joinBuilder,
                  $removeJoinBuilderFromRootComposer:
                      $removeJoinBuilderFromRootComposer,
                ));
    return composer;
  }
}

class $$TtsDatasetValidationIssueTableTableTableManager
    extends RootTableManager<
        _$AppDatabase,
        $TtsDatasetValidationIssueTableTable,
        TtsDatasetValidationIssueTableData,
        $$TtsDatasetValidationIssueTableTableFilterComposer,
        $$TtsDatasetValidationIssueTableTableOrderingComposer,
        $$TtsDatasetValidationIssueTableTableAnnotationComposer,
        $$TtsDatasetValidationIssueTableTableCreateCompanionBuilder,
        $$TtsDatasetValidationIssueTableTableUpdateCompanionBuilder,
        (
          TtsDatasetValidationIssueTableData,
          $$TtsDatasetValidationIssueTableTableReferences
        ),
        TtsDatasetValidationIssueTableData,
        PrefetchHooks Function({bool projectId, bool clipId})> {
  $$TtsDatasetValidationIssueTableTableTableManager(
      _$AppDatabase db, $TtsDatasetValidationIssueTableTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$TtsDatasetValidationIssueTableTableFilterComposer(
                  $db: db, $table: table),
          createOrderingComposer: () =>
              $$TtsDatasetValidationIssueTableTableOrderingComposer(
                  $db: db, $table: table),
          createComputedFieldComposer: () =>
              $$TtsDatasetValidationIssueTableTableAnnotationComposer(
                  $db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> projectId = const Value.absent(),
            Value<String?> clipId = const Value.absent(),
            Value<String> category = const Value.absent(),
            Value<String> severity = const Value.absent(),
            Value<String> code = const Value.absent(),
            Value<String> message = const Value.absent(),
            Value<String?> suggestedFix = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              TtsDatasetValidationIssueTableCompanion(
            id: id,
            projectId: projectId,
            clipId: clipId,
            category: category,
            severity: severity,
            code: code,
            message: message,
            suggestedFix: suggestedFix,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String projectId,
            Value<String?> clipId = const Value.absent(),
            required String category,
            required String severity,
            required String code,
            required String message,
            Value<String?> suggestedFix = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              TtsDatasetValidationIssueTableCompanion.insert(
            id: id,
            projectId: projectId,
            clipId: clipId,
            category: category,
            severity: severity,
            code: code,
            message: message,
            suggestedFix: suggestedFix,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable(table),
                    $$TtsDatasetValidationIssueTableTableReferences(
                        db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: ({projectId = false, clipId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins: <
                  T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic>>(state) {
                if (projectId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.projectId,
                    referencedTable:
                        $$TtsDatasetValidationIssueTableTableReferences
                            ._projectIdTable(db),
                    referencedColumn:
                        $$TtsDatasetValidationIssueTableTableReferences
                            ._projectIdTable(db)
                            .id,
                  ) as T;
                }
                if (clipId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.clipId,
                    referencedTable:
                        $$TtsDatasetValidationIssueTableTableReferences
                            ._clipIdTable(db),
                    referencedColumn:
                        $$TtsDatasetValidationIssueTableTableReferences
                            ._clipIdTable(db)
                            .id,
                  ) as T;
                }

                return state;
              },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ));
}

typedef $$TtsDatasetValidationIssueTableTableProcessedTableManager
    = ProcessedTableManager<
        _$AppDatabase,
        $TtsDatasetValidationIssueTableTable,
        TtsDatasetValidationIssueTableData,
        $$TtsDatasetValidationIssueTableTableFilterComposer,
        $$TtsDatasetValidationIssueTableTableOrderingComposer,
        $$TtsDatasetValidationIssueTableTableAnnotationComposer,
        $$TtsDatasetValidationIssueTableTableCreateCompanionBuilder,
        $$TtsDatasetValidationIssueTableTableUpdateCompanionBuilder,
        (
          TtsDatasetValidationIssueTableData,
          $$TtsDatasetValidationIssueTableTableReferences
        ),
        TtsDatasetValidationIssueTableData,
        PrefetchHooks Function({bool projectId, bool clipId})>;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$WhoisHistoryTableTableTableManager get whoisHistoryTable =>
      $$WhoisHistoryTableTableTableManager(_db, _db.whoisHistoryTable);
  $$DnsZoneTableTableTableManager get dnsZoneTable =>
      $$DnsZoneTableTableTableManager(_db, _db.dnsZoneTable);
  $$GitHubRepoTableTableTableManager get gitHubRepoTable =>
      $$GitHubRepoTableTableTableManager(_db, _db.gitHubRepoTable);
  $$ChatConversationTableTableTableManager get chatConversationTable =>
      $$ChatConversationTableTableTableManager(_db, _db.chatConversationTable);
  $$ChatMessageTableTableTableManager get chatMessageTable =>
      $$ChatMessageTableTableTableManager(_db, _db.chatMessageTable);
  $$ChatSettingsTableTableTableManager get chatSettingsTable =>
      $$ChatSettingsTableTableTableManager(_db, _db.chatSettingsTable);
  $$ServiceAccountTableTableTableManager get serviceAccountTable =>
      $$ServiceAccountTableTableTableManager(_db, _db.serviceAccountTable);
  $$MonitorHostTableTableTableManager get monitorHostTable =>
      $$MonitorHostTableTableTableManager(_db, _db.monitorHostTable);
  $$MonitorTrustedCertTableTableTableManager get monitorTrustedCertTable =>
      $$MonitorTrustedCertTableTableTableManager(
          _db, _db.monitorTrustedCertTable);
  $$TtsDatasetProjectTableTableTableManager get ttsDatasetProjectTable =>
      $$TtsDatasetProjectTableTableTableManager(
          _db, _db.ttsDatasetProjectTable);
  $$TtsDatasetSpeakerTableTableTableManager get ttsDatasetSpeakerTable =>
      $$TtsDatasetSpeakerTableTableTableManager(
          _db, _db.ttsDatasetSpeakerTable);
  $$TtsDatasetPromptTableTableTableManager get ttsDatasetPromptTable =>
      $$TtsDatasetPromptTableTableTableManager(_db, _db.ttsDatasetPromptTable);
  $$TtsDatasetClipTableTableTableManager get ttsDatasetClipTable =>
      $$TtsDatasetClipTableTableTableManager(_db, _db.ttsDatasetClipTable);
  $$TtsDatasetValidationIssueTableTableTableManager
      get ttsDatasetValidationIssueTable =>
          $$TtsDatasetValidationIssueTableTableTableManager(
              _db, _db.ttsDatasetValidationIssueTable);
}
