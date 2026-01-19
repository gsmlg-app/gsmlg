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
  static const VerificationMeta _credentialsMeta =
      const VerificationMeta('credentials');
  @override
  late final GeneratedColumn<String> credentials = GeneratedColumn<String>(
      'credentials', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
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
        credentials,
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
    if (data.containsKey('credentials')) {
      context.handle(
          _credentialsMeta,
          credentials.isAcceptableOrUnknown(
              data['credentials']!, _credentialsMeta));
    } else if (isInserting) {
      context.missing(_credentialsMeta);
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
      credentials: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}credentials'])!,
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

  /// API credentials (encrypted JSON containing keys/tokens).
  final String credentials;

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
      required this.credentials,
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
    map['credentials'] = Variable<String>(credentials);
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
      credentials: Value(credentials),
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
      credentials: serializer.fromJson<String>(json['credentials']),
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
      'credentials': serializer.toJson<String>(credentials),
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
          String? credentials,
          Value<String?> comment = const Value.absent(),
          DateTime? createdAt,
          DateTime? updatedAt}) =>
      DnsZoneTableData(
        id: id ?? this.id,
        provider: provider ?? this.provider,
        zoneId: zoneId ?? this.zoneId,
        zoneName: zoneName ?? this.zoneName,
        credentials: credentials ?? this.credentials,
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
      credentials:
          data.credentials.present ? data.credentials.value : this.credentials,
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
          ..write('credentials: $credentials, ')
          ..write('comment: $comment, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, provider, zoneId, zoneName, credentials,
      comment, createdAt, updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is DnsZoneTableData &&
          other.id == this.id &&
          other.provider == this.provider &&
          other.zoneId == this.zoneId &&
          other.zoneName == this.zoneName &&
          other.credentials == this.credentials &&
          other.comment == this.comment &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class DnsZoneTableCompanion extends UpdateCompanion<DnsZoneTableData> {
  final Value<int> id;
  final Value<DnsProvider> provider;
  final Value<String> zoneId;
  final Value<String> zoneName;
  final Value<String> credentials;
  final Value<String?> comment;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  const DnsZoneTableCompanion({
    this.id = const Value.absent(),
    this.provider = const Value.absent(),
    this.zoneId = const Value.absent(),
    this.zoneName = const Value.absent(),
    this.credentials = const Value.absent(),
    this.comment = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
  });
  DnsZoneTableCompanion.insert({
    this.id = const Value.absent(),
    required DnsProvider provider,
    required String zoneId,
    required String zoneName,
    required String credentials,
    this.comment = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
  })  : provider = Value(provider),
        zoneId = Value(zoneId),
        zoneName = Value(zoneName),
        credentials = Value(credentials);
  static Insertable<DnsZoneTableData> custom({
    Expression<int>? id,
    Expression<String>? provider,
    Expression<String>? zoneId,
    Expression<String>? zoneName,
    Expression<String>? credentials,
    Expression<String>? comment,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (provider != null) 'provider': provider,
      if (zoneId != null) 'zone_id': zoneId,
      if (zoneName != null) 'zone_name': zoneName,
      if (credentials != null) 'credentials': credentials,
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
      Value<String>? credentials,
      Value<String?>? comment,
      Value<DateTime>? createdAt,
      Value<DateTime>? updatedAt}) {
    return DnsZoneTableCompanion(
      id: id ?? this.id,
      provider: provider ?? this.provider,
      zoneId: zoneId ?? this.zoneId,
      zoneName: zoneName ?? this.zoneName,
      credentials: credentials ?? this.credentials,
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
    if (credentials.present) {
      map['credentials'] = Variable<String>(credentials.value);
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
          ..write('credentials: $credentials, ')
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

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $WhoisHistoryTableTable whoisHistoryTable =
      $WhoisHistoryTableTable(this);
  late final $DnsZoneTableTable dnsZoneTable = $DnsZoneTableTable(this);
  late final $GitHubRepoTableTable gitHubRepoTable =
      $GitHubRepoTableTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities =>
      [whoisHistoryTable, dnsZoneTable, gitHubRepoTable];
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
  required String credentials,
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
  Value<String> credentials,
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

  ColumnFilters<String> get credentials => $composableBuilder(
      column: $table.credentials, builder: (column) => ColumnFilters(column));

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

  ColumnOrderings<String> get credentials => $composableBuilder(
      column: $table.credentials, builder: (column) => ColumnOrderings(column));

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

  GeneratedColumn<String> get credentials => $composableBuilder(
      column: $table.credentials, builder: (column) => column);

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
            Value<String> credentials = const Value.absent(),
            Value<String?> comment = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
          }) =>
              DnsZoneTableCompanion(
            id: id,
            provider: provider,
            zoneId: zoneId,
            zoneName: zoneName,
            credentials: credentials,
            comment: comment,
            createdAt: createdAt,
            updatedAt: updatedAt,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required DnsProvider provider,
            required String zoneId,
            required String zoneName,
            required String credentials,
            Value<String?> comment = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
          }) =>
              DnsZoneTableCompanion.insert(
            id: id,
            provider: provider,
            zoneId: zoneId,
            zoneName: zoneName,
            credentials: credentials,
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

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$WhoisHistoryTableTableTableManager get whoisHistoryTable =>
      $$WhoisHistoryTableTableTableManager(_db, _db.whoisHistoryTable);
  $$DnsZoneTableTableTableManager get dnsZoneTable =>
      $$DnsZoneTableTableTableManager(_db, _db.dnsZoneTable);
  $$GitHubRepoTableTableTableManager get gitHubRepoTable =>
      $$GitHubRepoTableTableTableManager(_db, _db.gitHubRepoTable);
}
