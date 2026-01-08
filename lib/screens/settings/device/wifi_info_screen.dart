import 'dart:io';

import 'package:app_adaptive_widgets/app_adaptive_widgets.dart';
import 'package:app_locale/app_locale.dart';
import 'package:flutter/material.dart';
import 'package:gsmlg/destination.dart';
import 'package:gsmlg/screens/settings/settings_screen.dart';
import 'package:settings_ui/settings_ui.dart';

class WifiInfoScreen extends StatefulWidget {
  static const name = 'Wifi Info';
  static const path = 'wifi-info';

  const WifiInfoScreen({super.key});

  @override
  State<WifiInfoScreen> createState() => _WifiInfoScreenState();
}

class _WifiInfoScreenState extends State<WifiInfoScreen> {
  List<NetworkInterface>? _interfaces;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadNetworkInterfaces();
  }

  Future<void> _loadNetworkInterfaces() async {
    try {
      final interfaces = await NetworkInterface.list(
        includeLoopback: false,
        type: InternetAddressType.any,
      );
      setState(() {
        _interfaces = interfaces;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppAdaptiveScaffold(
      selectedIndex: Destinations.indexOf(
        const Key(SettingsScreen.name),
        context,
      ),
      onSelectedIndexChange: (idx) => Destinations.changeHandler(idx, context),
      destinations: Destinations.navs(context),
      body: (context) {
        return SafeArea(
          child: CustomScrollView(
            slivers: <Widget>[
              SliverAppBar(title: Text(context.l10n.wifiInfo)),
              SliverFillRemaining(child: _buildContent(context)),
            ],
          ),
        );
      },
      smallSecondaryBody: AdaptiveScaffold.emptyBuilder,
    );
  }

  Widget _buildContent(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return Center(child: Text('Error: $_error'));
    }

    final interfaces = _interfaces;
    if (interfaces == null || interfaces.isEmpty) {
      return const Center(child: Text('No network interfaces found'));
    }

    return SettingsList(
      sections: interfaces.map((interface) {
        return SettingsSection(
          title: Text(interface.name),
          tiles: interface.addresses.map((address) {
            final isIPv6 = address.type == InternetAddressType.IPv6;
            return SettingsTile(
              leading: Icon(isIPv6 ? Icons.dns : Icons.wifi),
              title: Text(isIPv6 ? 'IPv6 Address' : 'IPv4 Address'),
              value: Text(address.address),
            );
          }).toList(),
        );
      }).toList(),
    );
  }
}
