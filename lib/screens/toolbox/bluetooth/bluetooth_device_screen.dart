import 'dart:async';
import 'dart:io';

import 'package:app_adaptive_widgets/app_adaptive_widgets.dart';
import 'package:app_components/app_components.dart';
import 'package:bluetooth_bloc/bluetooth_bloc.dart';
import 'package:flutter/material.dart';
import 'package:gsmlg/destination.dart';
import 'package:gsmlg/screens/toolbox/toolbox_screen.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

class BluetoothDeviceScreen extends StatefulWidget {
  static const name = 'Bluetooth Device';
  static const path = 'device/:remoteId';

  const BluetoothDeviceScreen({super.key, required this.remoteId});

  final String remoteId;

  @override
  State<BluetoothDeviceScreen> createState() => _BluetoothDeviceScreenState();
}

class _BluetoothDeviceScreenState extends State<BluetoothDeviceScreen> {
  Future<List<BluetoothService>>? services;
  BluetoothDevice? device;
  StreamSubscription<BluetoothBlocState>? _ssb;

  @override
  void initState() {
    super.initState();
    context.read<BluetoothBloc>().add(const BluetoothStartScan());
    _ssb = context.read<BluetoothBloc>().stream.listen((state) async {
      if (state is BluetoothLoaded) {
        final scanResults = await state.scanResults.firstWhere(
          (scanResults) => scanResults
              .where((result) => result.device.remoteId.str == widget.remoteId)
              .isNotEmpty,
        );
        final device = scanResults
            .firstWhere(
              (element) => element.device.remoteId.str == widget.remoteId,
            )
            .device;
        setState(() {
          this.device = device;
          services = device.discoverServices();
        });
      }
    });
  }

  @override
  void dispose() {
    _ssb?.cancel();
    context.read<BluetoothBloc>().add(const BluetoothStopScan());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const String title = 'Bluetooth Device';

    return AppAdaptiveScaffold(
      selectedIndex: Destinations.indexOf(
        const Key(ToolboxScreen.name),
        context,
      ),
      destinations: Destinations.navs(context),
      onSelectedIndexChange: (idx) => Destinations.changeHandler(idx, context),
      body: (_) => SafeArea(
        minimum: Platform.isMacOS
            ? const EdgeInsets.all(kDefaultGridGap)
            : const EdgeInsets.symmetric(horizontal: kDefaultGridGap),
        child: device == null
            ? CustomScrollView(
                slivers: <Widget>[
                  const SliverAppBar(floating: true, title: Text(title)),
                  SliverList.list(
                    children: [
                      Text('Seeking ${widget.remoteId} for device...'),
                      const SizedBox(
                        height: 400,
                        child: Center(
                          child: CircularProgressIndicator.adaptive(),
                        ),
                      ),
                    ],
                  ),
                ],
              )
            : CustomScrollView(
                slivers: <Widget>[
                  SliverAppBar(
                    floating: true,
                    title: StreamBuilder(
                      stream: FlutterBluePlus.events.onNameChanged.where(
                        (event) => event.device.remoteId == device!.remoteId,
                      ),
                      builder: (context, snapshot) => snapshot.hasData
                          ? Text(snapshot.data!.name!)
                          : Text(device!.platformName),
                    ),
                  ),
                  SliverList(
                    delegate: SliverChildListDelegate([
                      ListTile(
                        leading: const Icon(Icons.tag),
                        title: const Text('Remote ID'),
                        subtitle: Text(device!.remoteId.str),
                      ),
                      ListTile(
                        leading: const Icon(Icons.bluetooth_connected),
                        title: const Text('Device Connection Status'),
                        subtitle: StreamBuilder<BluetoothConnectionState>(
                          stream: device!.connectionState,
                          builder: (context, snapshot) {
                            if (snapshot.hasData) {
                              return Text(snapshot.data!.name);
                            } else {
                              return const Text('Loading...');
                            }
                          },
                        ),
                        trailing: StreamBuilder<BluetoothConnectionState>(
                          stream: device!.connectionState,
                          builder: (context, snapshot) {
                            if (snapshot.hasData) {
                              return switch (snapshot.data!) {
                                BluetoothConnectionState.connected =>
                                  TextButton(
                                    onPressed: () {
                                      device!.disconnect();
                                    },
                                    child: const Text('Disconnect'),
                                  ),
                                BluetoothConnectionState.disconnected =>
                                  TextButton(
                                    onPressed: () {
                                      device!.connect();
                                    },
                                    child: const Text('Connect'),
                                  ),
                                _ => const SizedBox(),
                              };
                            } else {
                              return const Text('Loading...');
                            }
                          },
                        ),
                      ),
                      ListTile(
                        leading: const Icon(Icons.numbers),
                        title: const Text('MTU Size'),
                        subtitle: StreamBuilder<int>(
                          stream: device!.mtu,
                          builder: (context, snapshot) {
                            if (snapshot.hasData) {
                              return Text(snapshot.data.toString());
                            } else {
                              return const Text('Loading...');
                            }
                          },
                        ),
                      ),
                      ListTile(
                        leading: const Icon(Icons.electrical_services),
                        title: const Text('Services'),
                        trailing: TextButton(
                          onPressed: () {
                            setState(() {
                              services = device!.discoverServices();
                            });
                          },
                          child: const Text('Discover Services'),
                        ),
                      ),
                      FutureBuilder<List<BluetoothService>>(
                        future: services,
                        builder: (context, snapshot) {
                          if (snapshot.hasData) {
                            if (snapshot.data == null ||
                                snapshot.data!.isEmpty) {
                              return const ListTile(
                                title: Text('No services found'),
                              );
                            }
                            return ListView(
                              shrinkWrap: true,
                              children: snapshot.data!
                                  .map(
                                    (BluetoothService service) => Card(
                                      child: Padding(
                                        padding: const EdgeInsets.all(
                                          kDefaultGridGap,
                                        ),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              'Primary: ${service.isPrimary}',
                                            ),
                                            Text(
                                              'Service UUID: ${service.uuid}',
                                            ),
                                            Padding(
                                              padding: const EdgeInsets.all(
                                                8.0,
                                              ),
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  const Text(
                                                    'Characteristics:',
                                                  ),
                                                  ...service.characteristics.map(
                                                    (
                                                      BluetoothCharacteristic c,
                                                    ) => Padding(
                                                      padding:
                                                          const EdgeInsets.only(
                                                            left: 8.0,
                                                          ),
                                                      child: Column(
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .start,
                                                        children: [
                                                          Text(
                                                            'UUID: ${c.uuid}',
                                                          ),
                                                          Text(
                                                            'Properties: ${c.properties}',
                                                          ),
                                                          Text(
                                                            'Descriptors: ${c.descriptors}',
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            Padding(
                                              padding: const EdgeInsets.all(
                                                kDefaultGridGap,
                                              ),
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  const Text(
                                                    'Included Services:',
                                                  ),
                                                  ...service.includedServices.map(
                                                    (
                                                      BluetoothService s,
                                                    ) => Padding(
                                                      padding:
                                                          const EdgeInsets.only(
                                                            left: 8.0,
                                                          ),
                                                      child: Column(
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .start,
                                                        children: [
                                                          Text(
                                                            'UUID: ${s.uuid}',
                                                          ),
                                                          Text(
                                                            'Primary: ${s.isPrimary}',
                                                          ),
                                                          Text(
                                                            'Characteristics: ${s.characteristics}',
                                                          ),
                                                          Text(
                                                            'Included Services: ${s.includedServices}',
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  )
                                  .toList(),
                            );
                          } else if (snapshot.hasError) {
                            return ListTile(
                              title: Text('Error: ${snapshot.error}'),
                            );
                          } else if (snapshot.connectionState ==
                              ConnectionState.none) {
                            return const ListTile(title: Text('...'));
                          } else {
                            return const ListTile(title: Text('Loading...'));
                          }
                        },
                      ),
                    ]),
                  ),
                ],
              ),
      ),
    );
  }
}
