part of 'bloc.dart';

sealed class BluetoothBlocState extends Equatable {
  const BluetoothBlocState();

  @override
  List<Object?> get props => [];
}

final class BluetoothInitial extends BluetoothBlocState {
  const BluetoothInitial();
}

final class BluetoothLoaded extends BluetoothBlocState {
  final bool isSupported;
  final Stream<BluetoothAdapterState> adapterStateStream;
  final bool bluetoothScanning;
  final Stream<List<ScanResult>> scanResults;

  const BluetoothLoaded({
    required this.isSupported,
    required this.adapterStateStream,
    required this.scanResults,
    this.bluetoothScanning = false,
  });

  @override
  List<Object?> get props => [
        isSupported,
        adapterStateStream,
        scanResults,
        bluetoothScanning,
      ];

  BluetoothLoaded copyWith({
    bool? isSupported,
    Stream<BluetoothAdapterState>? adapterStateStream,
    Stream<List<ScanResult>>? scanResults,
    bool? bluetoothScanning,
  }) {
    return BluetoothLoaded(
      isSupported: isSupported ?? this.isSupported,
      adapterStateStream: adapterStateStream ?? this.adapterStateStream,
      scanResults: scanResults ?? this.scanResults,
      bluetoothScanning: bluetoothScanning ?? this.bluetoothScanning,
    );
  }
}

final class BluetoothError extends BluetoothBlocState {
  final Object error;
  final StackTrace stackTrace;

  const BluetoothError(this.error, this.stackTrace);

  @override
  List<Object?> get props => [error, stackTrace];
}
