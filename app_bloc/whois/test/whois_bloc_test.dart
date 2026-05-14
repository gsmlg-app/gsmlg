import 'package:app_database/app_database.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:whois_bloc/whois_bloc.dart';

void main() {
  group('WhoisBloc', () {
    late AppDatabase database;
    late WhoisBloc bloc;

    setUp(() {
      database = AppDatabase.forTesting();
      bloc = WhoisBloc(database);
    });

    tearDown(() async {
      await bloc.close();
      await database.close();
    });

    test('initial state is WhoisInitial', () {
      expect(bloc.state, isA<WhoisInitial>());
    });

    blocTest<WhoisBloc, WhoisState>(
      'emits WhoisInitial when WhoisReset is added',
      build: () => WhoisBloc(database),
      act: (bloc) => bloc.add(const WhoisReset()),
      expect: () => [isA<WhoisInitial>()],
    );

    test('emits WhoisLoading when WhoisLookup is added', () async {
      final firstState = bloc.stream.first;

      bloc.add(const WhoisLookup('example.com'));

      expect(await firstState, isA<WhoisLoading>());
    });

    group('WhoisState', () {
      test('WhoisInitial props are empty', () {
        const state = WhoisInitial();
        expect(state.props, isEmpty);
      });

      test('WhoisLoading props are empty', () {
        const state = WhoisLoading();
        expect(state.props, isEmpty);
      });

      test('WhoisLoaded contains domain and data', () {
        const state = WhoisLoaded('example.com', ['result1', 'result2']);
        expect(state.domain, 'example.com');
        expect(state.data, ['result1', 'result2']);
        expect(state.props, [
          'example.com',
          ['result1', 'result2'],
        ]);
      });

      test('WhoisFailure contains error message', () {
        const state = WhoisFailure('Connection failed');
        expect(state.error, 'Connection failed');
        expect(state.props, ['Connection failed']);
      });

      test('WhoisLoaded equality', () {
        const state1 = WhoisLoaded('example.com', ['result']);
        const state2 = WhoisLoaded('example.com', ['result']);
        const state3 = WhoisLoaded('other.com', ['result']);

        expect(state1, equals(state2));
        expect(state1, isNot(equals(state3)));
      });
    });

    group('WhoisEvent', () {
      test('WhoisReset can be instantiated', () {
        const event = WhoisReset();
        expect(event, isA<WhoisEvent>());
      });

      test('WhoisLookup contains domain', () {
        const event = WhoisLookup('example.com');
        expect(event.domain, 'example.com');
        expect(event, isA<WhoisEvent>());
      });
    });
  });
}
