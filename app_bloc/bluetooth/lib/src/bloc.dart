import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

part 'event.dart';
part 'state.dart';

class BluetoothBloc extends Bloc<BluetoothEvent, BluetoothBlocState> {
  StreamSubscription<bool>? _isScanningSubscription;

  BluetoothBloc() : super(const BluetoothInitial()) {
    on<BluetoothInitState>(_onBluetoothInitState);
    on<BluetoothStartScan>(_onBluetoothStartScan);
    on<BluetoothStopScan>(_onBluetoothStopScan);
    on<_BluetoothScanningUpdated>(_onBluetoothScanningUpdated);

    _isScanningSubscription = FlutterBluePlus.isScanning.listen((isScanning) {
      add(_BluetoothScanningUpdated(isScanning));
    });
  }

  @override
  Future<void> close() async {
    await _isScanningSubscription?.cancel();
    return super.close();
  }

  Future<BluetoothLoaded> _loadState() async {
    final isSupported = await FlutterBluePlus.isSupported;
    return BluetoothLoaded(
      isSupported: isSupported,
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

    if (FlutterBluePlus.adapterStateNow == BluetoothAdapterState.on) {
      return;
    }

    final adapterState = await FlutterBluePlus.adapterState
        .where((s) => s == BluetoothAdapterState.on)
        .first
        .timeout(
          const Duration(seconds: 3),
          onTimeout: () => FlutterBluePlus.adapterStateNow,
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
      if (!FlutterBluePlus.isScanningNow) {
        await FlutterBluePlus.startScan();
      }
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
      if (FlutterBluePlus.isScanningNow) {
        await FlutterBluePlus.stopScan();
      }
      emit(loadedState.copyWith(
          bluetoothScanning: FlutterBluePlus.isScanningNow));
    } catch (e, stackTrace) {
      emit(BluetoothError(e, stackTrace));
    }
  }

  void _onBluetoothScanningUpdated(
    _BluetoothScanningUpdated event,
    Emitter<BluetoothBlocState> emit,
  ) {
    final currentState = state;
    if (currentState is BluetoothLoaded) {
      if (currentState.bluetoothScanning != event.isScanning) {
        emit(currentState.copyWith(bluetoothScanning: event.isScanning));
      }
    }
  }
}
