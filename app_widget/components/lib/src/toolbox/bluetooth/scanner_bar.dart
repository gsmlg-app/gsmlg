import 'package:bluetooth_bloc/bluetooth_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

/// A bar widget that displays Bluetooth scanner status and controls.
class BluetoothScannerBar extends StatefulWidget implements PreferredSizeWidget {
  const BluetoothScannerBar({
    super.key,
    this.preferredSize = const Size.fromHeight(24 + 24),
  });

  @override
  final Size preferredSize;

  @override
  State<BluetoothScannerBar> createState() => _BluetoothScannerBarState();
}

class _BluetoothScannerBarState extends State<BluetoothScannerBar> {
  @override
  void initState() {
    super.initState();
    context.read<BluetoothBloc>().add(const BluetoothInitState());
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<BluetoothBloc, BluetoothBlocState>(
      builder: (context, state) {
        if (state is BluetoothInitial) {
          return Container(
            margin: const EdgeInsets.all(12.0),
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: const LinearProgressIndicator(),
          );
        }
        if (state is BluetoothError) {
          return Container(
            margin: const EdgeInsets.all(12.0),
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Text('Error: ${state.error}'),
          );
        }
        if (state is BluetoothLoaded) {
          final isBLESupported = state.isSupported;
          final adapterStateStream = state.adapterStateStream;
          final bluetoothScanning = state.bluetoothScanning;
          return Container(
            margin: const EdgeInsets.all(12.0),
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Text('BLE: ${isBLESupported ? 'OK' : 'N/A'}'),
                if (isBLESupported)
                  StreamBuilder(
                    stream: adapterStateStream,
                    builder: (
                      BuildContext context,
                      AsyncSnapshot<BluetoothAdapterState> snapshot,
                    ) {
                      if (snapshot.hasError) {
                        return Text('Bluetooth error: ${snapshot.error}');
                      }
                      if (!snapshot.hasData) {
                        return const Text('Bluetooth: ...');
                      }
                      final bluetoothState = snapshot.data!;
                      return Text('Bluetooth: ${bluetoothState.name}');
                    },
                  ),
                bluetoothScanning
                    ? const _AnimatedScanningIcon()
                    : const Icon(Icons.bluetooth_disabled, size: 24.0),
              ],
            ),
          );
        }
        return const SizedBox.shrink();
      },
    );
  }
}

class _AnimatedScanningIcon extends StatefulWidget {
  const _AnimatedScanningIcon();

  @override
  State<_AnimatedScanningIcon> createState() => _AnimatedScanningIconState();
}

class _AnimatedScanningIconState extends State<_AnimatedScanningIcon>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    )..repeat(reverse: true);
    _animation = Tween<double>(begin: 0, end: 10).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(_animation.value - 5, 0),
          child: const Icon(Icons.bluetooth_searching, size: 24.0),
        );
      },
    );
  }
}
