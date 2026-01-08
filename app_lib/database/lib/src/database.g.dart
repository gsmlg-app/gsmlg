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

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $WhoisHistoryTableTable whoisHistoryTable =
      $WhoisHistoryTableTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [whoisHistoryTable];
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

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$WhoisHistoryTableTableTableManager get whoisHistoryTable =>
      $$WhoisHistoryTableTableTableManager(_db, _db.whoisHistoryTable);
}
