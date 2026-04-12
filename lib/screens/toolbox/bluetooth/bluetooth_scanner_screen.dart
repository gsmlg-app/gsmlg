import 'package:app_adaptive_widgets/app_adaptive_widgets.dart';
import 'package:app_components/app_components.dart';
import 'package:bluetooth_bloc/bluetooth_bloc.dart';
import 'package:flutter/material.dart';
import 'package:gsmlg/destination.dart';
import 'package:gsmlg/screens/toolbox/bluetooth/bluetooth_device_screen.dart';
import 'package:gsmlg/screens/toolbox/toolbox_screen.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:go_router/go_router.dart';

class BluetoothScannerScreen extends StatelessWidget {
  static const name = 'Bluetooth Scanner';
  static const path = 'bluetooth_scanner';

  const BluetoothScannerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    const String title = 'Bluetooth Scanner';

    return AppAdaptiveScaffold(
      selectedIndex: Destinations.indexOf(
        const Key(ToolboxScreen.name),
        context,
      ),
      destinations: Destinations.navs(context),
      onSelectedIndexChange: (idx) => Destinations.changeHandler(idx, context),
      body: (_) => SafeArea(
        minimum: const EdgeInsets.symmetric(horizontal: kDefaultGridGap),
        child: CustomScrollView(
          slivers: [
            SliverAppBar(
              floating: true,
              title: const Text(title),
              actions: [
                StreamBuilder<bool>(
                  stream: FlutterBluePlus.isScanning,
                  builder: (context, snapshot) {
                    if (snapshot.hasError) {
                      return const SizedBox();
                    }
                    if (!snapshot.hasData) {
                      return const SizedBox();
                    }
                    final isScanning = snapshot.data!;
                    return AppAdaptiveActionList(
                      actions: [
                        AppAdaptiveAction(
                          disabled: isScanning,
                          icon: Icons.start_outlined,
                          title: 'Start Scan',
                          onPressed: () {
                            context.read<BluetoothBloc>().add(
                              const BluetoothStartScan(),
                            );
                          },
                        ),
                        AppAdaptiveAction(
                          disabled: !isScanning,
                          icon: Icons.stop_outlined,
                          title: 'Stop Scan',
                          onPressed: () {
                            context.read<BluetoothBloc>().add(
                              const BluetoothStopScan(),
                            );
                          },
                        ),
                      ],
                    );
                  },
                ),
              ],
              bottom: const BluetoothScannerBar(
                preferredSize: Size.fromHeight(24.0 + 24.0),
              ),
            ),
            BlocBuilder<BluetoothBloc, BluetoothBlocState>(
              builder: (context, state) {
                if (state is BluetoothInitial) {
                  return const SliverToBoxAdapter(
                    child: Center(
                      child: SizedBox(
                        height: 400,
                        child: Icon(Icons.bluetooth_searching),
                      ),
                    ),
                  );
                }

                if (state is BluetoothError) {
                  return SliverList.list(
                    children: [
                      const Text('Error:'),
                      Text('Error: ${state.error}'),
                      Text('Stack: ${state.stackTrace}'),
                    ],
                  );
                }

                if (state is BluetoothLoaded) {
                  return StreamBuilder(
                    stream: state.scanResults,
                    builder: (context, snapshot) {
                      if (snapshot.hasError) {
                        return SliverList.list(
                          children: [
                            const Text('Error:'),
                            Text('Error: ${snapshot.error}'),
                          ],
                        );
                      }
                      if (!snapshot.hasData) {
                        return const SliverToBoxAdapter(
                          child: Center(
                            child: Text('Waiting for Bluetooth Devices...'),
                          ),
                        );
                      }
                      final List<ScanResult> results = snapshot.data!;
                      if (results.isEmpty) {
                        return const SliverToBoxAdapter(
                          child: Center(
                            child: Text('No Bluetooth Devices Found yet!'),
                          ),
                        );
                      }
                      results.sort(
                        (a, b) => a.rssi < b.rssi
                            ? 1
                            : a.rssi > b.rssi
                            ? -1
                            : 0,
                      );
                      return SliverGrid.extent(
                        maxCrossAxisExtent:
                            MediaQuery.of(context).size.width / 360,
                        mainAxisSpacing: kDefaultGridGap,
                        crossAxisSpacing: kDefaultGridGap,
                        childAspectRatio: 5 / 6,
                        children: [
                          for (final result in results)
                            GridTile(
                              child: BluetoothResultCard(
                                result: result,
                                onTapConnect: () {
                                  context.goNamed(
                                    BluetoothDeviceScreen.name,
                                    pathParameters: {
                                      'remoteId': result.device.remoteId.str,
                                    },
                                  );
                                },
                              ),
                            ),
                        ],
                      );
                    },
                  );
                }

                return const SliverToBoxAdapter(child: SizedBox(height: 0));
              },
            ),
          ],
        ),
      ),
    );
  }
}
