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

class BluetoothScannerScreen extends StatefulWidget {
  static const name = 'Bluetooth Scanner';
  static const path = 'bluetooth_scanner';

  const BluetoothScannerScreen({super.key});

  @override
  State<BluetoothScannerScreen> createState() => _BluetoothScannerScreenState();
}

class _BluetoothScannerScreenState extends State<BluetoothScannerScreen> {
  late BluetoothBloc _bluetoothBloc;
  bool _namedOnly = true;
  bool _connectableOnly = false;
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _bluetoothBloc = context.read<BluetoothBloc>();
  }

  @override
  void initState() {
    super.initState();
    context.read<BluetoothBloc>().add(const BluetoothInitState());
  }

  @override
  void dispose() {
    _bluetoothBloc.add(const BluetoothStopScan());
    _searchController.dispose();
    super.dispose();
  }

  void _navigateToDevice(ScanResult result) {
    context.goNamed(
      BluetoothDeviceScreen.name,
      pathParameters: {
        'remoteId': result.device.remoteId.str,
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    const String title = 'Bluetooth Scanner';
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return AppAdaptiveScaffold(
      navigationRestoreInHeader: true,
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
            DmNavigationHeader(
              builder: (context, header) => SliverAppBar(
                leading: header.leading,
                leadingWidth: header.leadingWidth,
                automaticallyImplyLeading: header.automaticallyImplyLeading,
                floating: true,
                title: const Text(title),
                actions: [
                  StreamBuilder<bool>(
                    stream: FlutterBluePlus.isScanning,
                    initialData: FlutterBluePlus.isScanningNow,
                    builder: (context, snapshot) {
                      if (snapshot.hasError) {
                        return const SizedBox();
                      }
                      final isScanning = snapshot.data ?? false;
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
                  return SliverFillRemaining(
                    hasScrollBody: false,
                    child: Center(
                      child: Padding(
                        padding: const EdgeInsets.all(24.0),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.error_outline,
                              color: Colors.red,
                              size: 48,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              '${state.error}',
                              textAlign: TextAlign.center,
                              style: theme.textTheme.bodyLarge,
                            ),
                            const SizedBox(height: 16),
                            FilledButton.icon(
                              onPressed: () {
                                context.read<BluetoothBloc>().add(
                                  const BluetoothStartScan(),
                                );
                              },
                              icon: const Icon(Icons.refresh),
                              label: const Text('Retry'),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }

                if (state is BluetoothLoaded) {
                  return StreamBuilder<List<ScanResult>>(
                    stream: state.scanResults,
                    initialData: FlutterBluePlus.lastScanResults,
                    builder: (context, snapshot) {
                      if (snapshot.hasError) {
                        return SliverList.list(
                          children: [
                            const Text('Error:'),
                            Text('Error: ${snapshot.error}'),
                          ],
                        );
                      }

                      final List<ScanResult> allResults = List<ScanResult>.from(
                        snapshot.data ?? const [],
                      );

                      // If no devices scanned at all yet
                      if (allResults.isEmpty) {
                        return StreamBuilder<bool>(
                          stream: FlutterBluePlus.isScanning,
                          initialData: FlutterBluePlus.isScanningNow,
                          builder: (context, scanSnap) {
                            final isScanning = scanSnap.data ?? false;
                            return SliverFillRemaining(
                              hasScrollBody: false,
                              child: Center(
                                child: Padding(
                                  padding: const EdgeInsets.all(32.0),
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      if (isScanning) ...[
                                        const CircularProgressIndicator.adaptive(),
                                        const SizedBox(height: 16),
                                        const Text(
                                          'Scanning for Bluetooth Devices...',
                                        ),
                                        const SizedBox(height: 12),
                                        OutlinedButton.icon(
                                          icon: const Icon(Icons.stop),
                                          label: const Text('Stop Scan'),
                                          onPressed: () {
                                            context.read<BluetoothBloc>().add(
                                              const BluetoothStopScan(),
                                            );
                                          },
                                        ),
                                      ] else ...[
                                        Icon(
                                          Icons.bluetooth_searching,
                                          size: 56,
                                          color: colorScheme.outline,
                                        ),
                                        const SizedBox(height: 16),
                                        Text(
                                          'Bluetooth Scanner is idle',
                                          style: theme.textTheme.titleMedium,
                                        ),
                                        const SizedBox(height: 6),
                                        Text(
                                          'Tap "Start Scan" to discover nearby BLE devices',
                                          style: theme.textTheme.bodySmall?.copyWith(
                                            color: colorScheme.outline,
                                          ),
                                        ),
                                        const SizedBox(height: 16),
                                        FilledButton.icon(
                                          icon: const Icon(Icons.play_arrow),
                                          label: const Text('Start Scan'),
                                          onPressed: () {
                                            context.read<BluetoothBloc>().add(
                                              const BluetoothStartScan(),
                                            );
                                          },
                                        ),
                                      ],
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
                        );
                      }

                      allResults.sort(
                        (a, b) => a.rssi < b.rssi
                            ? 1
                            : a.rssi > b.rssi
                            ? -1
                            : 0,
                      );

                      final namedCount = allResults.where((r) {
                        final name = (r.advertisementData.advName.isNotEmpty
                                ? r.advertisementData.advName
                                : r.device.platformName)
                            .trim();
                        return name.isNotEmpty;
                      }).length;

                      final connectableCount = allResults
                          .where((r) => r.advertisementData.connectable)
                          .length;

                      final filteredResults = allResults.where((r) {
                        final name = (r.advertisementData.advName.isNotEmpty
                                ? r.advertisementData.advName
                                : r.device.platformName)
                            .trim();
                        if (_namedOnly && name.isEmpty) return false;
                        if (_connectableOnly &&
                            !r.advertisementData.connectable) {
                          return false;
                        }
                        if (_searchQuery.isNotEmpty) {
                          final q = _searchQuery.toLowerCase();
                          final matchName = name.toLowerCase().contains(q);
                          final matchId =
                              r.device.remoteId.str.toLowerCase().contains(q);
                          if (!matchName && !matchId) return false;
                        }
                        return true;
                      }).toList();

                      return SliverMainAxisGroup(
                        slivers: [
                          // Filter & Search Controls
                          SliverToBoxAdapter(
                            child: Padding(
                              padding: const EdgeInsets.only(top: 10, bottom: 12),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Search Field
                                  TextField(
                                    controller: _searchController,
                                    decoration: InputDecoration(
                                      hintText: 'Filter by name or Remote ID...',
                                      prefixIcon: const Icon(Icons.search, size: 20),
                                      suffixIcon: _searchQuery.isNotEmpty
                                          ? IconButton(
                                              icon: const Icon(Icons.clear, size: 18),
                                              onPressed: () {
                                                _searchController.clear();
                                                setState(() => _searchQuery = '');
                                              },
                                            )
                                          : null,
                                      isDense: true,
                                      contentPadding: const EdgeInsets.symmetric(
                                        horizontal: 12,
                                        vertical: 10,
                                      ),
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                    ),
                                    onChanged: (val) {
                                      setState(() => _searchQuery = val.trim());
                                    },
                                  ),
                                  const SizedBox(height: 8),
                                  // Filter Chips & Counter
                                  SingleChildScrollView(
                                    scrollDirection: Axis.horizontal,
                                    child: Row(
                                      children: [
                                        FilterChip(
                                          label: Text('Named ($namedCount)'),
                                          selected: _namedOnly,
                                          onSelected: (val) {
                                            setState(() => _namedOnly = val);
                                          },
                                        ),
                                        const SizedBox(width: 8),
                                        FilterChip(
                                          label: Text('Connectable ($connectableCount)'),
                                          selected: _connectableOnly,
                                          onSelected: (val) {
                                            setState(() => _connectableOnly = val);
                                          },
                                        ),
                                        const SizedBox(width: 12),
                                        Text(
                                          'Showing ${filteredResults.length} / ${allResults.length}',
                                          style: theme.textTheme.bodySmall?.copyWith(
                                            color: colorScheme.outline,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          // Content: Filtered Cards or Filter-Empty state
                          if (filteredResults.isEmpty)
                            SliverFillRemaining(
                              hasScrollBody: false,
                              child: Center(
                                child: Padding(
                                  padding: const EdgeInsets.all(32.0),
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        Icons.filter_list_off,
                                        size: 48,
                                        color: colorScheme.outline,
                                      ),
                                      const SizedBox(height: 16),
                                      Text(
                                        'No devices match current filters',
                                        style: theme.textTheme.titleMedium,
                                      ),
                                      const SizedBox(height: 6),
                                      Text(
                                        '${allResults.length} devices discovered in area',
                                        style: theme.textTheme.bodySmall?.copyWith(
                                          color: colorScheme.outline,
                                        ),
                                      ),
                                      const SizedBox(height: 12),
                                      OutlinedButton.icon(
                                        icon: const Icon(Icons.clear_all),
                                        label: const Text('Show all devices'),
                                        onPressed: () {
                                          _searchController.clear();
                                          setState(() {
                                            _namedOnly = false;
                                            _connectableOnly = false;
                                            _searchQuery = '';
                                          });
                                        },
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            )
                          else
                            SliverLayoutBuilder(
                              builder: (context, constraints) {
                                if (constraints.crossAxisExtent > 700) {
                                  return SliverGrid.extent(
                                    maxCrossAxisExtent: 480,
                                    mainAxisSpacing: 10,
                                    crossAxisSpacing: 10,
                                    childAspectRatio: 1.85,
                                    children: [
                                      for (final result in filteredResults)
                                        BluetoothResultCard(
                                          result: result,
                                          onTapConnect: () =>
                                              _navigateToDevice(result),
                                        ),
                                    ],
                                  );
                                }
                                return SliverList.separated(
                                  itemCount: filteredResults.length,
                                  separatorBuilder: (_, __) =>
                                      const SizedBox(height: 10),
                                  itemBuilder: (context, index) {
                                    final result = filteredResults[index];
                                    return BluetoothResultCard(
                                      result: result,
                                      onTapConnect: () =>
                                          _navigateToDevice(result),
                                    );
                                  },
                                );
                              },
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
