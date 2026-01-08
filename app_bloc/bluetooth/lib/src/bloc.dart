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

  Future<void> _onBluetoothInitState(
    BluetoothInitState event,
    Emitter<BluetoothBlocState> emit,
  ) async {
    try {
      if (state is BluetoothLoaded) {
        return;
      }
      final isSupported = await FlutterBluePlus.isSupported;
      // Use asBroadcastStream to allow multiple listeners (e.g., when widget rebuilds)
      final adapterStateStream = FlutterBluePlus.adapterState.asBroadcastStream();
      final scanResults = FlutterBluePlus.scanResults.asBroadcastStream();
      emit(BluetoothLoaded(
        isSupported: isSupported,
        adapterStateStream: adapterStateStream,
        scanResults: scanResults,
      ));
    } catch (e, stackTrace) {
      emit(BluetoothError(e, stackTrace));
    }
  }

  Future<void> _onBluetoothStartScan(
    BluetoothStartScan event,
    Emitter<BluetoothBlocState> emit,
  ) async {
    try {
      await FlutterBluePlus.startScan();
      emit((state as BluetoothLoaded).copyWith(bluetoothScanning: true));
    } catch (e, stackTrace) {
      emit(BluetoothError(e, stackTrace));
    }
  }

  Future<void> _onBluetoothStopScan(
    BluetoothStopScan event,
    Emitter<BluetoothBlocState> emit,
  ) async {
    try {
      await FlutterBluePlus.stopScan();
      emit((state as BluetoothLoaded).copyWith(bluetoothScanning: false));
    } catch (e, stackTrace) {
      emit(BluetoothError(e, stackTrace));
    }
  }
}
