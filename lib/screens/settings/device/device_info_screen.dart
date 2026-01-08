import 'package:app_adaptive_widgets/app_adaptive_widgets.dart';
import 'package:app_client_info/app_client_info.dart';
import 'package:app_locale/app_locale.dart';
import 'package:flutter/material.dart';
import 'package:gsmlg/destination.dart';
import 'package:gsmlg/screens/settings/settings_screen.dart';
import 'package:settings_ui/settings_ui.dart';

class DeviceInfoScreen extends StatelessWidget {
  static const name = 'Device Info';
  static const path = 'device-info';

  const DeviceInfoScreen({super.key});

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
              SliverAppBar(title: Text(context.l10n.deviceInfo)),
              SliverFillRemaining(
                child: FutureBuilder<ClientInfoData>(
                  future: ClientInfo.instance.getData(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    if (snapshot.hasError) {
                      return Center(
                        child: Text('Error: ${snapshot.error}'),
                      );
                    }

                    final clientInfo = snapshot.data;
                    if (clientInfo == null) {
                      return const Center(
                        child: Text('No device info available'),
                      );
                    }

                    final additionalData = clientInfo.additionalData;

                    return SettingsList(
                      sections: [
                        SettingsSection(
                          title: Text(context.l10n.deviceInfo),
                          tiles: <SettingsTile>[
                            SettingsTile(
                              leading: const Icon(Icons.computer),
                              title: const Text('Platform'),
                              value: Text(clientInfo.platform),
                            ),
                            if (additionalData['deviceName'] != null)
                              SettingsTile(
                                leading: const Icon(Icons.devices),
                                title: const Text('Device Name'),
                                value:
                                    Text(additionalData['deviceName'] as String),
                              ),
                            if (additionalData['deviceModel'] != null)
                              SettingsTile(
                                leading: const Icon(Icons.phone_android),
                                title: const Text('Device Model'),
                                value:
                                    Text(additionalData['deviceModel'] as String),
                              ),
                            if (additionalData['systemName'] != null)
                              SettingsTile(
                                leading: const Icon(Icons.memory),
                                title: const Text('System Name'),
                                value:
                                    Text(additionalData['systemName'] as String),
                              ),
                            if (additionalData['systemVersion'] != null)
                              SettingsTile(
                                leading: const Icon(Icons.info_outline),
                                title: const Text('System Version'),
                                value: Text(
                                    additionalData['systemVersion'] as String),
                              ),
                          ],
                        ),
                        if (additionalData['appName'] != null ||
                            additionalData['appVersion'] != null)
                          SettingsSection(
                            title: const Text('App Info'),
                            tiles: <SettingsTile>[
                              if (additionalData['appName'] != null)
                                SettingsTile(
                                  leading: const Icon(Icons.apps),
                                  title: const Text('App Name'),
                                  value:
                                      Text(additionalData['appName'] as String),
                                ),
                              if (additionalData['appVersion'] != null)
                                SettingsTile(
                                  leading: const Icon(Icons.tag),
                                  title: const Text('App Version'),
                                  value: Text(
                                      additionalData['appVersion'] as String),
                                ),
                              if (additionalData['appBuildNumber'] != null)
                                SettingsTile(
                                  leading: const Icon(Icons.build),
                                  title: const Text('Build Number'),
                                  value: Text(
                                      additionalData['appBuildNumber'] as String),
                                ),
                            ],
                          ),
                        SettingsSection(
                          title: const Text('Collection Info'),
                          tiles: <SettingsTile>[
                            SettingsTile(
                              leading: const Icon(Icons.access_time),
                              title: const Text('Timestamp'),
                              value: Text(clientInfo.timestamp.toLocal().toString()),
                            ),
                          ],
                        ),
                      ],
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
      smallSecondaryBody: AdaptiveScaffold.emptyBuilder,
    );
  }
}
