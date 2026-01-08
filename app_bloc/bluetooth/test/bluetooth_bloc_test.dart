import 'package:bloc_test/bloc_test.dart';
import 'package:bluetooth_bloc/bluetooth_bloc.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('BluetoothBloc', () {
    test('initial state is BluetoothInitial', () {
      final bloc = BluetoothBloc();
      expect(bloc.state, isA<BluetoothInitial>());
      bloc.close();
    });

    blocTest<BluetoothBloc, BluetoothBlocState>(
      'emits nothing when created',
      build: () => BluetoothBloc(),
      expect: () => [],
    );
  });

  group('BluetoothEvent', () {
    test('BluetoothInitState can be created', () {
      const event = BluetoothInitState();
      expect(event, isA<BluetoothEvent>());
    });

    test('BluetoothStartScan can be created', () {
      const event = BluetoothStartScan();
      expect(event, isA<BluetoothEvent>());
    });

    test('BluetoothStopScan can be created', () {
      const event = BluetoothStopScan();
      expect(event, isA<BluetoothEvent>());
    });
  });

  group('BluetoothBlocState', () {
    test('BluetoothInitial props are empty', () {
      const state = BluetoothInitial();
      expect(state.props, isEmpty);
    });

    test('BluetoothError has correct props', () {
      final error = Exception('test error');
      final stackTrace = StackTrace.current;
      final state = BluetoothError(error, stackTrace);
      expect(state.props, [error, stackTrace]);
    });
  });
}
