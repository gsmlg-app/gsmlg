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
  static const VerificationMeta _timestampMeta =
      const VerificationMeta('timestamp');
  @override
  late final GeneratedColumn<DateTime> timestamp = GeneratedColumn<DateTime>(
      'timestamp', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  @override
  List<GeneratedColumn> get $columns =>
      [id, conversationId, role, content, tokenCount, timestamp];
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

  /// Timestamp when the message was created.
  final DateTime timestamp;
  const ChatMessageTableData(
      {required this.id,
      required this.conversationId,
      required this.role,
      required this.content,
      this.tokenCount,
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
      'timestamp': serializer.toJson<DateTime>(timestamp),
    };
  }

  ChatMessageTableData copyWith(
          {String? id,
          String? conversationId,
          String? role,
          String? content,
          Value<int?> tokenCount = const Value.absent(),
          DateTime? timestamp}) =>
      ChatMessageTableData(
        id: id ?? this.id,
        conversationId: conversationId ?? this.conversationId,
        role: role ?? this.role,
        content: content ?? this.content,
        tokenCount: tokenCount.present ? tokenCount.value : this.tokenCount,
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
          ..write('timestamp: $timestamp')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, conversationId, role, content, tokenCount, timestamp);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ChatMessageTableData &&
          other.id == this.id &&
          other.conversationId == this.conversationId &&
          other.role == this.role &&
          other.content == this.content &&
          other.tokenCount == this.tokenCount &&
          other.timestamp == this.timestamp);
}

class ChatMessageTableCompanion extends UpdateCompanion<ChatMessageTableData> {
  final Value<String> id;
  final Value<String> conversationId;
  final Value<String> role;
  final Value<String> content;
  final Value<int?> tokenCount;
  final Value<DateTime> timestamp;
  final Value<int> rowid;
  const ChatMessageTableCompanion({
    this.id = const Value.absent(),
    this.conversationId = const Value.absent(),
    this.role = const Value.absent(),
    this.content = const Value.absent(),
    this.tokenCount = const Value.absent(),
    this.timestamp = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ChatMessageTableCompanion.insert({
    required String id,
    required String conversationId,
    required String role,
    required String content,
    this.tokenCount = const Value.absent(),
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
    Expression<DateTime>? timestamp,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (conversationId != null) 'conversation_id': conversationId,
      if (role != null) 'role': role,
      if (content != null) 'content': content,
      if (tokenCount != null) 'token_count': tokenCount,
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
      Value<DateTime>? timestamp,
      Value<int>? rowid}) {
    return ChatMessageTableCompanion(
      id: id ?? this.id,
      conversationId: conversationId ?? this.conversationId,
      role: role ?? this.role,
      content: content ?? this.content,
      tokenCount: tokenCount ?? this.tokenCount,
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
  static const VerificationMeta _defaultSystemPromptMeta =
      const VerificationMeta('defaultSystemPrompt');
  @override
  late final GeneratedColumn<String> defaultSystemPrompt =
      GeneratedColumn<String>('default_system_prompt', aliasedName, true,
          type: DriftSqlType.string, requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns => [
        key,
        modelType,
        customModelPath,
        maxTokens,
        temperatureX100,
        topK,
        backend,
        defaultSystemPrompt
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
    if (data.containsKey('default_system_prompt')) {
      context.handle(
          _defaultSystemPromptMeta,
          defaultSystemPrompt.isAcceptableOrUnknown(
              data['default_system_prompt']!, _defaultSystemPromptMeta));
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
      defaultSystemPrompt: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}default_system_prompt']),
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

  /// Default system prompt for new conversations.
  final String? defaultSystemPrompt;
  const ChatSettingsTableData(
      {required this.key,
      required this.modelType,
      this.customModelPath,
      required this.maxTokens,
      required this.temperatureX100,
      required this.topK,
      required this.backend,
      this.defaultSystemPrompt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['key'] = Variable<String>(key);
    map['model_type'] = Variable<String>(modelType);
    if (!nullToAbsent || customModelPath != null) {
      map['custom_model_path'] = Variable<String>(customModelPath);
    }
    map['max_tokens'] = Variable<int>(maxTokens);
    map['temperature_x100'] = Variable<int>(temperatureX100);
    map['top_k'] = Variable<int>(topK);
    map['backend'] = Variable<String>(backend);
    if (!nullToAbsent || defaultSystemPrompt != null) {
      map['default_system_prompt'] = Variable<String>(defaultSystemPrompt);
    }
    return map;
  }

  ChatSettingsTableCompanion toCompanion(bool nullToAbsent) {
    return ChatSettingsTableCompanion(
      key: Value(key),
      modelType: Value(modelType),
      customModelPath: customModelPath == null && nullToAbsent
          ? const Value.absent()
          : Value(customModelPath),
      maxTokens: Value(maxTokens),
      temperatureX100: Value(temperatureX100),
      topK: Value(topK),
      backend: Value(backend),
      defaultSystemPrompt: defaultSystemPrompt == null && nullToAbsent
          ? const Value.absent()
          : Value(defaultSystemPrompt),
    );
  }

  factory ChatSettingsTableData.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ChatSettingsTableData(
      key: serializer.fromJson<String>(json['key']),
      modelType: serializer.fromJson<String>(json['modelType']),
      customModelPath: serializer.fromJson<String?>(json['customModelPath']),
      maxTokens: serializer.fromJson<int>(json['maxTokens']),
      temperatureX100: serializer.fromJson<int>(json['temperatureX100']),
      topK: serializer.fromJson<int>(json['topK']),
      backend: serializer.fromJson<String>(json['backend']),
      defaultSystemPrompt:
          serializer.fromJson<String?>(json['defaultSystemPrompt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'key': serializer.toJson<String>(key),
      'modelType': serializer.toJson<String>(modelType),
      'customModelPath': serializer.toJson<String?>(customModelPath),
      'maxTokens': serializer.toJson<int>(maxTokens),
      'temperatureX100': serializer.toJson<int>(temperatureX100),
      'topK': serializer.toJson<int>(topK),
      'backend': serializer.toJson<String>(backend),
      'defaultSystemPrompt': serializer.toJson<String?>(defaultSystemPrompt),
    };
  }

  ChatSettingsTableData copyWith(
          {String? key,
          String? modelType,
          Value<String?> customModelPath = const Value.absent(),
          int? maxTokens,
          int? temperatureX100,
          int? topK,
          String? backend,
          Value<String?> defaultSystemPrompt = const Value.absent()}) =>
      ChatSettingsTableData(
        key: key ?? this.key,
        modelType: modelType ?? this.modelType,
        customModelPath: customModelPath.present
            ? customModelPath.value
            : this.customModelPath,
        maxTokens: maxTokens ?? this.maxTokens,
        temperatureX100: temperatureX100 ?? this.temperatureX100,
        topK: topK ?? this.topK,
        backend: backend ?? this.backend,
        defaultSystemPrompt: defaultSystemPrompt.present
            ? defaultSystemPrompt.value
            : this.defaultSystemPrompt,
      );
  ChatSettingsTableData copyWithCompanion(ChatSettingsTableCompanion data) {
    return ChatSettingsTableData(
      key: data.key.present ? data.key.value : this.key,
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
      defaultSystemPrompt: data.defaultSystemPrompt.present
          ? data.defaultSystemPrompt.value
          : this.defaultSystemPrompt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ChatSettingsTableData(')
          ..write('key: $key, ')
          ..write('modelType: $modelType, ')
          ..write('customModelPath: $customModelPath, ')
          ..write('maxTokens: $maxTokens, ')
          ..write('temperatureX100: $temperatureX100, ')
          ..write('topK: $topK, ')
          ..write('backend: $backend, ')
          ..write('defaultSystemPrompt: $defaultSystemPrompt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(key, modelType, customModelPath, maxTokens,
      temperatureX100, topK, backend, defaultSystemPrompt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ChatSettingsTableData &&
          other.key == this.key &&
          other.modelType == this.modelType &&
          other.customModelPath == this.customModelPath &&
          other.maxTokens == this.maxTokens &&
          other.temperatureX100 == this.temperatureX100 &&
          other.topK == this.topK &&
          other.backend == this.backend &&
          other.defaultSystemPrompt == this.defaultSystemPrompt);
}

class ChatSettingsTableCompanion
    extends UpdateCompanion<ChatSettingsTableData> {
  final Value<String> key;
  final Value<String> modelType;
  final Value<String?> customModelPath;
  final Value<int> maxTokens;
  final Value<int> temperatureX100;
  final Value<int> topK;
  final Value<String> backend;
  final Value<String?> defaultSystemPrompt;
  final Value<int> rowid;
  const ChatSettingsTableCompanion({
    this.key = const Value.absent(),
    this.modelType = const Value.absent(),
    this.customModelPath = const Value.absent(),
    this.maxTokens = const Value.absent(),
    this.temperatureX100 = const Value.absent(),
    this.topK = const Value.absent(),
    this.backend = const Value.absent(),
    this.defaultSystemPrompt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ChatSettingsTableCompanion.insert({
    this.key = const Value.absent(),
    this.modelType = const Value.absent(),
    this.customModelPath = const Value.absent(),
    this.maxTokens = const Value.absent(),
    this.temperatureX100 = const Value.absent(),
    this.topK = const Value.absent(),
    this.backend = const Value.absent(),
    this.defaultSystemPrompt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  static Insertable<ChatSettingsTableData> custom({
    Expression<String>? key,
    Expression<String>? modelType,
    Expression<String>? customModelPath,
    Expression<int>? maxTokens,
    Expression<int>? temperatureX100,
    Expression<int>? topK,
    Expression<String>? backend,
    Expression<String>? defaultSystemPrompt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (key != null) 'key': key,
      if (modelType != null) 'model_type': modelType,
      if (customModelPath != null) 'custom_model_path': customModelPath,
      if (maxTokens != null) 'max_tokens': maxTokens,
      if (temperatureX100 != null) 'temperature_x100': temperatureX100,
      if (topK != null) 'top_k': topK,
      if (backend != null) 'backend': backend,
      if (defaultSystemPrompt != null)
        'default_system_prompt': defaultSystemPrompt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ChatSettingsTableCompanion copyWith(
      {Value<String>? key,
      Value<String>? modelType,
      Value<String?>? customModelPath,
      Value<int>? maxTokens,
      Value<int>? temperatureX100,
      Value<int>? topK,
      Value<String>? backend,
      Value<String?>? defaultSystemPrompt,
      Value<int>? rowid}) {
    return ChatSettingsTableCompanion(
      key: key ?? this.key,
      modelType: modelType ?? this.modelType,
      customModelPath: customModelPath ?? this.customModelPath,
      maxTokens: maxTokens ?? this.maxTokens,
      temperatureX100: temperatureX100 ?? this.temperatureX100,
      topK: topK ?? this.topK,
      backend: backend ?? this.backend,
      defaultSystemPrompt: defaultSystemPrompt ?? this.defaultSystemPrompt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (key.present) {
      map['key'] = Variable<String>(key.value);
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
    if (defaultSystemPrompt.present) {
      map['default_system_prompt'] =
          Variable<String>(defaultSystemPrompt.value);
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
          ..write('modelType: $modelType, ')
          ..write('customModelPath: $customModelPath, ')
          ..write('maxTokens: $maxTokens, ')
          ..write('temperatureX100: $temperatureX100, ')
          ..write('topK: $topK, ')
          ..write('backend: $backend, ')
          ..write('defaultSystemPrompt: $defaultSystemPrompt, ')
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
        chatSettingsTable
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
            Value<DateTime> timestamp = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              ChatMessageTableCompanion(
            id: id,
            conversationId: conversationId,
            role: role,
            content: content,
            tokenCount: tokenCount,
            timestamp: timestamp,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String conversationId,
            required String role,
            required String content,
            Value<int?> tokenCount = const Value.absent(),
            Value<DateTime> timestamp = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              ChatMessageTableCompanion.insert(
            id: id,
            conversationId: conversationId,
            role: role,
            content: content,
            tokenCount: tokenCount,
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
  Value<String> modelType,
  Value<String?> customModelPath,
  Value<int> maxTokens,
  Value<int> temperatureX100,
  Value<int> topK,
  Value<String> backend,
  Value<String?> defaultSystemPrompt,
  Value<int> rowid,
});
typedef $$ChatSettingsTableTableUpdateCompanionBuilder
    = ChatSettingsTableCompanion Function({
  Value<String> key,
  Value<String> modelType,
  Value<String?> customModelPath,
  Value<int> maxTokens,
  Value<int> temperatureX100,
  Value<int> topK,
  Value<String> backend,
  Value<String?> defaultSystemPrompt,
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

  ColumnFilters<String> get defaultSystemPrompt => $composableBuilder(
      column: $table.defaultSystemPrompt,
      builder: (column) => ColumnFilters(column));
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

  ColumnOrderings<String> get defaultSystemPrompt => $composableBuilder(
      column: $table.defaultSystemPrompt,
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

  GeneratedColumn<String> get defaultSystemPrompt => $composableBuilder(
      column: $table.defaultSystemPrompt, builder: (column) => column);
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
            Value<String> modelType = const Value.absent(),
            Value<String?> customModelPath = const Value.absent(),
            Value<int> maxTokens = const Value.absent(),
            Value<int> temperatureX100 = const Value.absent(),
            Value<int> topK = const Value.absent(),
            Value<String> backend = const Value.absent(),
            Value<String?> defaultSystemPrompt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              ChatSettingsTableCompanion(
            key: key,
            modelType: modelType,
            customModelPath: customModelPath,
            maxTokens: maxTokens,
            temperatureX100: temperatureX100,
            topK: topK,
            backend: backend,
            defaultSystemPrompt: defaultSystemPrompt,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            Value<String> key = const Value.absent(),
            Value<String> modelType = const Value.absent(),
            Value<String?> customModelPath = const Value.absent(),
            Value<int> maxTokens = const Value.absent(),
            Value<int> temperatureX100 = const Value.absent(),
            Value<int> topK = const Value.absent(),
            Value<String> backend = const Value.absent(),
            Value<String?> defaultSystemPrompt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              ChatSettingsTableCompanion.insert(
            key: key,
            modelType: modelType,
            customModelPath: customModelPath,
            maxTokens: maxTokens,
            temperatureX100: temperatureX100,
            topK: topK,
            backend: backend,
            defaultSystemPrompt: defaultSystemPrompt,
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
}
