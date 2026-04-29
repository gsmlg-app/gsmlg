import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

part 'event.dart';
part 'state.dart';

class BluetoothBloc extends Bloc<BluetoothEvent, BluetoothBlocState> {
  BluetoothBloc() : super(const BluetoothInitial()) {
    on<BluetoothInitState>(_onBluetoothInitState);
    on<BluetoothStartScan>(_onBluetoothStartScan);
    on<BluetoothStopScan>(_onBluetoothStopScan);
  }

  Future<BluetoothLoaded> _loadState() async {
    final isSupported = await FlutterBluePlus.isSupported;
    return BluetoothLoaded(
      isSupported: isSupported,
      adapterStateStream: FlutterBluePlus.adapterState.asBroadcastStream(),
      scanResults: FlutterBluePlus.scanResults.asBroadcastStream(),
      bluetoothScanning: FlutterBluePlus.isScanningNow,
    );
  }

  Future<BluetoothLoaded> _ensureLoaded(
    Emitter<BluetoothBlocState> emit,
  ) async {
    final currentState = state;
    if (currentState is BluetoothLoaded) {
      return currentState;
    }
    final loadedState = await _loadState();
    emit(loadedState);
    return loadedState;
  }

  Future<void> _ensureReadyToScan(BluetoothLoaded state) async {
    if (!state.isSupported) {
      throw StateError('Bluetooth LE is not supported on this device.');
    }

    final adapterState = await FlutterBluePlus.adapterState.first.timeout(
      const Duration(seconds: 5),
      onTimeout: () => BluetoothAdapterState.unknown,
    );
    if (adapterState != BluetoothAdapterState.on) {
      throw StateError(
        'Bluetooth adapter is ${adapterState.name}; turn it on and grant permission before scanning.',
      );
    }
  }

  Future<void> _onBluetoothInitState(
    BluetoothInitState event,
    Emitter<BluetoothBlocState> emit,
  ) async {
    try {
      if (state is BluetoothLoaded) {
        return;
      }
      emit(await _loadState());
    } catch (e, stackTrace) {
      emit(BluetoothError(e, stackTrace));
    }
  }

  Future<void> _onBluetoothStartScan(
    BluetoothStartScan event,
    Emitter<BluetoothBlocState> emit,
  ) async {
    try {
      final loadedState = await _ensureLoaded(emit);
      await _ensureReadyToScan(loadedState);
      await FlutterBluePlus.startScan();
      emit(loadedState.copyWith(
          bluetoothScanning: FlutterBluePlus.isScanningNow));
    } catch (e, stackTrace) {
      emit(BluetoothError(e, stackTrace));
    }
  }

  Future<void> _onBluetoothStopScan(
    BluetoothStopScan event,
    Emitter<BluetoothBlocState> emit,
  ) async {
    try {
      final loadedState = await _ensureLoaded(emit);
      await FlutterBluePlus.stopScan();
      emit(loadedState.copyWith(
          bluetoothScanning: FlutterBluePlus.isScanningNow));
    } catch (e, stackTrace) {
      emit(BluetoothError(e, stackTrace));
    }
  }
}
