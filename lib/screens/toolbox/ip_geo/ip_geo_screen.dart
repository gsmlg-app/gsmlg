import 'dart:io';

import 'package:app_adaptive_widgets/app_adaptive_widgets.dart';
import 'package:app_components/app_components.dart';
import 'package:flutter/material.dart';
import 'package:gsmlg/destination.dart';
import 'package:app_world_map/app_world_map.dart';
import 'package:gsmlg/screens/toolbox/toolbox_screen.dart';
import 'package:ip_db/ip_db.dart';

class IpGeoScreen extends StatefulWidget {
  static const name = 'IpGeo';
  static const path = 'ip-geo';

  const IpGeoScreen({super.key});

  @override
  State<IpGeoScreen> createState() => _IpGeoScreenState();
}

class _IpGeoScreenState extends State<IpGeoScreen> {
  final _controller = TextEditingController();
  final _ipDatabase = IpDatabase();

  bool _isInitializing = true;
  bool _isLoading = false;
  String? _error;
  IpLocation? _location;

  @override
  void initState() {
    super.initState();
    _initDatabase();
  }

  Future<void> _initDatabase() async {
    try {
      await _ipDatabase.initialize();
      if (mounted) {
        setState(() {
          _isInitializing = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isInitializing = false;
          _error = 'Failed to initialize IP database: $e';
        });
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _ipDatabase.close();
    super.dispose();
  }

  Future<void> _lookup(String ipAddress) async {
    if (ipAddress.isEmpty) return;

    setState(() {
      _isLoading = true;
      _error = null;
      _location = null;
    });

    try {
      final location = await _ipDatabase.lookup(ipAddress);
      if (mounted) {
        setState(() {
          _isLoading = false;
          _location = location;
          if (location == null) {
            _error = 'IP address not found in database';
          }
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _error = 'Lookup failed: $e';
        });
      }
    }
  }

  void _reset() {
    _controller.clear();
    setState(() {
      _error = null;
      _location = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    const String title = 'IP Geolocation';

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
        child: CustomScrollView(
          slivers: [
            SliverAppBar(
              floating: true,
              title: const Text(title),
              bottom: PreferredSize(
                preferredSize: const Size.fromHeight(48.0 + 24.0),
                child: Container(
                  margin: const EdgeInsets.all(12.0),
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: TextField(
                    autocorrect: false,
                    controller: _controller,
                    enabled: !_isInitializing,
                    keyboardType: TextInputType.text,
                    onSubmitted: _lookup,
                    decoration: InputDecoration(
                      hintText: _isInitializing
                          ? 'Loading database...'
                          : 'Enter IP address (e.g., 8.8.8.8)',
                      suffixIcon: IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: _reset,
                      ),
                      prefixIcon: IconButton(
                        icon: const Icon(Icons.search),
                        onPressed: () => _lookup(_controller.text),
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20.0),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            if (_isInitializing)
              SliverToBoxAdapter(
                child: SizedBox(
                  height: MediaQuery.of(context).size.height * 0.5,
                  child: const Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        CircularProgressIndicator.adaptive(),
                        SizedBox(height: 16),
                        Text('Loading IP database...'),
                      ],
                    ),
                  ),
                ),
              )
            else if (_isLoading)
              SliverToBoxAdapter(
                child: SizedBox(
                  height: MediaQuery.of(context).size.height * 0.5,
                  child: const Center(
                    child: CircularProgressIndicator.adaptive(),
                  ),
                ),
              )
            else if (_error != null)
              SliverToBoxAdapter(
                child: SizedBox(
                  height: MediaQuery.of(context).size.height * 0.5,
                  child: Center(
                    child: Text(
                      _error!,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.error,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
              )
            else if (_location != null)
              SliverList.list(
                children: [
                  if (_location!.hasCoordinates)
                    _buildMapCard(context, _location!),
                  _buildLocationCard(context, _location!),
                ],
              )
            else
              SliverToBoxAdapter(
                child: SizedBox(
                  height: MediaQuery.of(context).size.height * 0.5,
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.location_on_outlined,
                          size: 64,
                          color: Theme.of(context).colorScheme.secondary,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'IP Geolocation Lookup',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Enter an IP address to find its location',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildMapCard(BuildContext context, IpLocation location) {
    return Card(
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Location on Map',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 300,
              child: WorldMapWidget(
                latitude: location.latitude!,
                longitude: location.longitude!,
                label: location.displayName,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLocationCard(BuildContext context, IpLocation location) {
    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              location.displayName,
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const Divider(),
            if (location.city != null)
              _buildInfoRow(context, 'City', location.city!),
            if (location.stateProv != null)
              _buildInfoRow(context, 'State/Province', location.stateProv!),
            if (location.country != null)
              _buildInfoRow(context, 'Country', location.country!),
            if (location.countryCode != null)
              _buildInfoRow(context, 'Country Code', location.countryCode!),
            if (location.continent != null)
              _buildInfoRow(context, 'Continent', location.continent!),
            if (location.postalCode != null)
              _buildInfoRow(context, 'Postal Code', location.postalCode!),
            if (location.timezone != null)
              _buildInfoRow(context, 'Timezone', location.timezone!),
            if (location.hasCoordinates) ...[
              const Divider(),
              _buildInfoRow(
                context,
                'Coordinates',
                '${location.latitude!.toStringAsFixed(4)}, ${location.longitude!.toStringAsFixed(4)}',
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(BuildContext context, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.secondary,
              ),
            ),
          ),
          Expanded(
            child: Text(value, style: Theme.of(context).textTheme.bodyMedium),
          ),
        ],
      ),
    );
  }
}
