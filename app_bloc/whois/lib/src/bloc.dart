import 'dart:async';

import 'package:app_database/app_database.dart';
import 'package:bloc/bloc.dart';
import 'package:drift/drift.dart';
import 'package:equatable/equatable.dart';
import 'package:gsmlg_whois/gsmlg_whois.dart';

part 'event.dart';
part 'state.dart';

/// BLoC for performing Whois lookups on domain names and IP addresses.
///
/// Uses the [Whois] class for network lookups and [AppDatabase] for
/// persisting lookup history.
class WhoisBloc extends Bloc<WhoisEvent, WhoisState> {
  /// The database instance for storing lookup history.
  final AppDatabase database;

  /// Timeout duration for Whois queries.
  static const _queryTimeout = Duration(seconds: 10);

  /// Creates a new [WhoisBloc] with the given [database].
  WhoisBloc(this.database) : super(const WhoisInitial()) {
    on<WhoisReset>(_onReset);
    on<WhoisLookup>(_onLookup);
  }

  void _onReset(WhoisReset event, Emitter<WhoisState> emit) {
    emit(const WhoisInitial());
  }

  Future<void> _onLookup(WhoisLookup event, Emitter<WhoisState> emit) async {
    try {
      emit(const WhoisLoading());

      final query = event.domain;

      // Perform the Whois lookup with timeout
      final whoisList = await Whois.queryList(query).timeout(
        _queryTimeout,
        onTimeout: () => throw TimeoutException('Whois Query Timeout'),
      );

      // Save to history
      await _saveWhoisHistory(query, whoisList);

      emit(WhoisLoaded(query, whoisList));
    } on TimeoutException catch (e) {
      emit(WhoisFailure(e.message ?? 'Whois Query Timeout'));
    } catch (e) {
      emit(WhoisFailure(e.toString()));
    }
  }

  /// Saves a Whois lookup result to the database history.
  Future<void> _saveWhoisHistory(String query, List<String> result) async {
    await database.into(database.whoisHistoryTable).insert(
          WhoisHistoryTableCompanion.insert(
            query: Value(query),
            result: Value(result),
          ),
        );
  }
}
