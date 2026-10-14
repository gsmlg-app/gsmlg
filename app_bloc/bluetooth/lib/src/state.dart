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
  final Stream<BluetoothAdapterState>? _adapterStateStream;
  final bool bluetoothScanning;
  final Stream<List<ScanResult>>? _scanResults;

  const BluetoothLoaded({
    required this.isSupported,
    Stream<BluetoothAdapterState>? adapterStateStream,
    Stream<List<ScanResult>>? scanResults,
    this.bluetoothScanning = false,
  })  : _adapterStateStream = adapterStateStream,
        _scanResults = scanResults;

  Stream<BluetoothAdapterState> get adapterStateStream =>
      _adapterStateStream ?? FlutterBluePlus.adapterState;

  Stream<List<ScanResult>> get scanResults =>
      _scanResults ?? FlutterBluePlus.scanResults;

  @override
  List<Object?> get props => [
        isSupported,
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
      adapterStateStream: adapterStateStream ?? _adapterStateStream,
      scanResults: scanResults ?? _scanResults,
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
