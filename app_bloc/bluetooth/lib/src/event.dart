part of 'bloc.dart';

sealed class BluetoothEvent {
  const BluetoothEvent();
}

final class BluetoothInitState extends BluetoothEvent {
  const BluetoothInitState();
}

final class BluetoothStartScan extends BluetoothEvent {
  const BluetoothStartScan();
}

final class BluetoothStopScan extends BluetoothEvent {
  const BluetoothStopScan();
}

final class _BluetoothScanningUpdated extends BluetoothEvent {
  final bool isScanning;
  const _BluetoothScanningUpdated(this.isScanning);
}
