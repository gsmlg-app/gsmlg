import 'package:app_database/app_database.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:drift/drift.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:whois_history_bloc/whois_history_bloc.dart';

void main() {
  group('WhoisHistoryBloc', () {
    late AppDatabase database;
    late WhoisHistoryBloc bloc;

    setUp(() {
      database = AppDatabase.forTesting();
      bloc = WhoisHistoryBloc(database);
    });

    tearDown(() async {
      await bloc.close();
      await database.close();
    });

    test('initial state is WhoisHistoryInitial', () {
      expect(bloc.state, const WhoisHistoryInitial());
    });

    blocTest<WhoisHistoryBloc, WhoisHistoryState>(
      'emits [WhoisHistoryLoading, WhoisHistoryLoaded] when WhoisHistorySync is added',
      build: () => WhoisHistoryBloc(database),
      act: (bloc) => bloc.add(const WhoisHistorySync()),
      expect: () => [
        const WhoisHistoryLoading(),
        isA<WhoisHistoryLoaded>().having((s) => s.data, 'data', isEmpty),
      ],
    );

    blocTest<WhoisHistoryBloc, WhoisHistoryState>(
      'emits WhoisHistoryLoaded with data after adding records',
      setUp: () async {
        await database.into(database.whoisHistoryTable).insert(
              WhoisHistoryTableCompanion.insert(
                query: const Value('example.com'),
                result: const Value(['Domain Name: example.com']),
              ),
            );
      },
      build: () => WhoisHistoryBloc(database),
      act: (bloc) => bloc.add(const WhoisHistorySync()),
      expect: () => [
        const WhoisHistoryLoading(),
        isA<WhoisHistoryLoaded>()
            .having((s) => s.data.length, 'data length', 1),
      ],
    );

    blocTest<WhoisHistoryBloc, WhoisHistoryState>(
      'emits empty list after WhoisHistoryRemoveAll',
      setUp: () async {
        await database.into(database.whoisHistoryTable).insert(
              WhoisHistoryTableCompanion.insert(
                query: const Value('example.com'),
                result: const Value(['Domain Name: example.com']),
              ),
            );
      },
      build: () => WhoisHistoryBloc(database),
      act: (bloc) async {
        bloc.add(const WhoisHistoryRemoveAll());
        // Wait for the sync to complete after removal
        await Future.delayed(const Duration(milliseconds: 100));
      },
      wait: const Duration(milliseconds: 200),
      expect: () => [
        const WhoisHistoryLoading(),
        isA<WhoisHistoryLoaded>().having((s) => s.data, 'data', isEmpty),
      ],
    );
  });
}
