import 'package:app_locale/app_locale.dart';
import 'package:bloc/bloc.dart';
import 'package:bluetooth_bloc/bluetooth_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gsmlg/screens/toolbox/bluetooth/bluetooth_scanner_screen.dart';

class _FakeBluetoothBloc extends BluetoothBloc {
  final List<BluetoothEvent> dispatchedEvents = [];
  final BluetoothBlocState _stubState;

  _FakeBluetoothBloc(this._stubState);

  @override
  BluetoothBlocState get state => _stubState;

  @override
  void add(BluetoothEvent event) {
    dispatchedEvents.add(event);
  }
}

Widget _buildTestApp({required _FakeBluetoothBloc bloc}) {
  return MaterialApp(
    localizationsDelegates: AppLocale.localizationsDelegates,
    supportedLocales: AppLocale.supportedLocales,
    home: BlocProvider<BluetoothBloc>.value(
      value: bloc,
      child: const BluetoothScannerScreen(),
    ),
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets(
    'BluetoothScannerScreen initializes state on mount and stops on dispose',
    (tester) async {
      await tester.binding.setSurfaceSize(const Size(1000, 800));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      final bloc = _FakeBluetoothBloc(const BluetoothLoaded(isSupported: true));

      await tester.pumpWidget(_buildTestApp(bloc: bloc));
      await tester.pump();

      expect(bloc.dispatchedEvents, contains(isA<BluetoothInitState>()));
      expect(bloc.dispatchedEvents, isNot(contains(isA<BluetoothStartScan>())));

      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pump();

      expect(bloc.dispatchedEvents, contains(isA<BluetoothStopScan>()));
    },
  );

  testWidgets('BluetoothScannerScreen renders error state and retry button', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(1000, 800));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    final bloc = _FakeBluetoothBloc(
      BluetoothError(Exception('Bluetooth is turned off'), StackTrace.empty),
    );

    await tester.pumpWidget(_buildTestApp(bloc: bloc));
    await tester.pump();

    expect(find.text('Exception: Bluetooth is turned off'), findsOneWidget);
    expect(find.text('Retry'), findsOneWidget);

    await tester.tap(find.text('Retry'));
    await tester.pump();

    expect(
      bloc.dispatchedEvents.whereType<BluetoothStartScan>().length,
      equals(1),
    );
  });

  testWidgets(
    'BluetoothScannerScreen renders empty scan state when no devices are found',
    (tester) async {
      await tester.binding.setSurfaceSize(const Size(1000, 800));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      final bloc = _FakeBluetoothBloc(
        const BluetoothLoaded(isSupported: true, scanResults: Stream.empty()),
      );

      await tester.pumpWidget(_buildTestApp(bloc: bloc));
      await tester.pump();

      expect(find.byType(BluetoothScannerScreen), findsOneWidget);
      expect(find.text('Bluetooth Scanner'), findsOneWidget);
    },
  );
}
