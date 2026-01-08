import 'package:app_database/app_database.dart';
import 'package:bloc/bloc.dart';
import 'package:drift/drift.dart';
import 'package:equatable/equatable.dart';

part 'event.dart';
part 'state.dart';

class WhoisHistoryBloc extends Bloc<WhoisHistoryEvent, WhoisHistoryState> {
  final AppDatabase database;

  WhoisHistoryBloc(this.database) : super(const WhoisHistoryInitial()) {
    on<WhoisHistorySync>(_onSync);
    on<WhoisHistoryRemoveOne>(_onRemoveOne);
    on<WhoisHistoryRemoveAll>(_onRemoveAll);
  }

  Future<void> _onSync(
    WhoisHistorySync event,
    Emitter<WhoisHistoryState> emit,
  ) async {
    emit(const WhoisHistoryLoading());
    try {
      final query = database.select(database.whoisHistoryTable)
        ..orderBy([
          (t) => OrderingTerm(
                expression: t.createdAt,
                mode: OrderingMode.desc,
              ),
        ]);
      final list = await query.get();
      emit(WhoisHistoryLoaded(list));
    } catch (e) {
      emit(WhoisHistoryFailure(e.toString()));
    }
  }

  Future<void> _onRemoveOne(
    WhoisHistoryRemoveOne event,
    Emitter<WhoisHistoryState> emit,
  ) async {
    try {
      await (database.delete(database.whoisHistoryTable)
            ..where((t) => t.id.equals(event.whoisHistory.id)))
          .go();
      add(const WhoisHistorySync());
    } catch (e) {
      emit(WhoisHistoryFailure(e.toString()));
    }
  }

  Future<void> _onRemoveAll(
    WhoisHistoryRemoveAll event,
    Emitter<WhoisHistoryState> emit,
  ) async {
    try {
      await database.delete(database.whoisHistoryTable).go();
      add(const WhoisHistorySync());
    } catch (e) {
      emit(WhoisHistoryFailure(e.toString()));
    }
  }
}
