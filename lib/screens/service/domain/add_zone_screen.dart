import 'dart:convert';

import 'package:accounts_bloc/accounts_bloc.dart';
import 'package:app_adaptive_widgets/app_adaptive_widgets.dart';
import 'package:app_database/app_database.dart';
import 'package:cloudflare_dns/cloudflare_dns.dart' as cf;
import 'package:dio/dio.dart';
import 'package:domain_bloc/domain_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:gsmlg/destination.dart';
import 'package:gsmlg/screens/service/service_screen.dart';
import 'package:route53/route53.dart' as r53;

class AddZoneScreen extends StatefulWidget {
  static const name = 'AddZone';
  static const path = 'add';

  const AddZoneScreen({super.key});

  @override
  State<AddZoneScreen> createState() => _AddZoneScreenState();
}

class _ZoneOption {
  final String id;
  final String name;

  const _ZoneOption({required this.id, required this.name});
}

class _AddZoneScreenState extends State<AddZoneScreen> {
  final _formKey = GlobalKey<FormState>();
  DnsProvider _provider = DnsProvider.cloudflare;

  final _commentController = TextEditingController();

  // Service account selection
  ServiceAccountTableData? _selectedAccount;

  // Zone selection
  List<_ZoneOption>? _availableZones;
  _ZoneOption? _selectedZone;
  bool _isFetchingZones = false;
  String? _fetchError;
  bool _isSubmitting = false;

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  ServiceProvider get _serviceProvider => switch (_provider) {
    DnsProvider.cloudflare => ServiceProvider.cloudflare,
    DnsProvider.route53 => ServiceProvider.aws,
  };

  List<ServiceAccountTableData> _filteredAccounts(AccountsState state) {
    if (state is! AccountsLoaded) return [];
    return state.accounts.where((a) => a.provider == _serviceProvider).toList();
  }

  Future<void> _fetchZones() async {
    if (_selectedAccount == null) {
      setState(() => _fetchError = 'Please select a service account first');
      return;
    }

    setState(() {
      _isFetchingZones = true;
      _fetchError = null;
      _availableZones = null;
      _selectedZone = null;
    });

    try {
      final accountsBloc = context.read<AccountsBloc>();
      final apiKey = await accountsBloc.getApiKey(_selectedAccount!.id);
      if (apiKey == null) {
        throw Exception('No API key found for this account');
      }

      final zones = <_ZoneOption>[];

      switch (_provider) {
        case DnsProvider.route53:
          final credentials = jsonDecode(apiKey) as Map<String, dynamic>;
          final dio = Dio(
            BaseOptions(
              baseUrl: 'https://route53.amazonaws.com/2013-04-01',
              headers: {'Content-Type': 'application/xml'},
            ),
          );
          dio.transformer = r53.XmlTransformer();
          dio.interceptors.add(r53.XmlRequestInterceptor());
          dio.interceptors.add(
            r53.AwsSigV4Interceptor(
              accessKeyId: credentials['accessKeyId'] as String,
              secretAccessKey: credentials['secretAccessKey'] as String,
              region: credentials['region'] as String? ?? 'us-east-1',
              serviceName: 'route53',
            ),
          );
          dio.interceptors.add(
            LogInterceptor(
              request: true,
              requestHeader: true,
              requestBody: true,
              responseHeader: true,
              responseBody: true,
              error: true,
              logPrint: (o) => debugPrint(o.toString()),
            ),
          );
          final client = r53.Route53(dio);
          final response = await client.hostedZones.listHostedZones();

          for (final zone in response.hostedZones) {
            zones.add(
              _ZoneOption(
                id: zone.id.replaceFirst('/hostedzone/', ''),
                name: zone.name.endsWith('.')
                    ? zone.name.substring(0, zone.name.length - 1)
                    : zone.name,
              ),
            );
          }

        case DnsProvider.cloudflare:
          final dio = Dio(
            BaseOptions(
              baseUrl: 'https://api.cloudflare.com/client/v4',
              headers: {
                'Authorization': 'Bearer $apiKey',
                'Content-Type': 'application/json',
              },
            ),
          );
          final client = cf.CloudflareDns(dio, enableLogging: true);
          final response = await client.zones.listZones();

          for (final zone in response.result) {
            zones.add(_ZoneOption(id: zone.id, name: zone.name));
          }
      }

      setState(() {
        _availableZones = zones;
        _isFetchingZones = false;
        if (zones.isEmpty) {
          _fetchError = 'No zones found for this account';
        }
      });
    } catch (e, stackTrace) {
      debugPrint('Failed to fetch zones: $e');
      debugPrint('Stack trace: $stackTrace');
      setState(() {
        _isFetchingZones = false;
        _fetchError = 'Failed to fetch zones: ${e.toString()}';
      });
    }
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedZone == null) {
      setState(() => _fetchError = 'Please select a zone');
      return;
    }
    if (_selectedAccount == null) {
      setState(() => _fetchError = 'Please select a service account');
      return;
    }

    setState(() => _isSubmitting = true);

    context.read<ZoneBloc>().add(
      ZoneAdd(
        provider: _provider,
        zoneId: _selectedZone!.id,
        zoneName: _selectedZone!.name,
        serviceAccountId: _selectedAccount!.id,
        comment: _commentController.text.isEmpty
            ? null
            : _commentController.text,
      ),
    );

    context.go('/service/domain');
  }

  void _onProviderChanged(DnsProvider provider) {
    setState(() {
      _provider = provider;
      _selectedAccount = null;
      _availableZones = null;
      _selectedZone = null;
      _fetchError = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return AppAdaptiveScaffold(
      selectedIndex: Destinations.indexOf(
        const Key(ServiceScreen.name),
        context,
      ),
      destinations: Destinations.navs(context),
      onSelectedIndexChange: (idx) => Destinations.changeHandler(idx, context),
      body: (_) => SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverAppBar(
              floating: true,
              title: const Text('Add DNS Zone'),
              leading: IconButton(
                tooltip: 'Back',
                icon: const Icon(Icons.arrow_back),
                onPressed: () => context.go('/service/domain'),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.all(16),
              sliver: SliverToBoxAdapter(
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Provider selection
                      const Text(
                        'DNS Provider',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      SegmentedButton<DnsProvider>(
                        segments: const [
                          ButtonSegment(
                            value: DnsProvider.cloudflare,
                            label: Text('Cloudflare'),
                            icon: Icon(Icons.cloud_circle_outlined),
                          ),
                          ButtonSegment(
                            value: DnsProvider.route53,
                            label: Text('Route 53'),
                            icon: Icon(Icons.cloud_outlined),
                          ),
                        ],
                        selected: {_provider},
                        onSelectionChanged: (selection) {
                          _onProviderChanged(selection.first);
                        },
                      ),
                      const SizedBox(height: 24),

                      // Service account selection
                      const Text(
                        'Service Account',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      BlocBuilder<AccountsBloc, AccountsState>(
                        builder: (context, state) {
                          final accounts = _filteredAccounts(state);

                          if (accounts.isEmpty) {
                            return Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                border: Border.all(
                                  color: Theme.of(context).colorScheme.outline,
                                ),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Column(
                                children: [
                                  Text(
                                    'No ${_provider == DnsProvider.cloudflare ? "Cloudflare" : "AWS"} accounts configured',
                                    style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant),
                                  ),
                                  const SizedBox(height: 8),
                                  OutlinedButton.icon(
                                    onPressed: () =>
                                        context.go('/settings/account'),
                                    icon: const Icon(Icons.add),
                                    label: const Text('Add Account'),
                                  ),
                                ],
                              ),
                            );
                          }

                          return DropdownButtonFormField<
                            ServiceAccountTableData
                          >(
                            value: _selectedAccount,
                            decoration: const InputDecoration(
                              labelText: 'Account',
                              border: OutlineInputBorder(),
                            ),
                            items: accounts
                                .map(
                                  (account) => DropdownMenuItem(
                                    value: account,
                                    child: Text(account.name),
                                  ),
                                )
                                .toList(),
                            onChanged: (account) {
                              setState(() {
                                _selectedAccount = account;
                                _availableZones = null;
                                _selectedZone = null;
                                _fetchError = null;
                              });
                            },
                            validator: (value) {
                              if (value == null) {
                                return 'Please select an account';
                              }
                              return null;
                            },
                          );
                        },
                      ),
                      const SizedBox(height: 16),

                      // Fetch zones button
                      OutlinedButton.icon(
                        onPressed:
                            (_isFetchingZones || _selectedAccount == null)
                            ? null
                            : _fetchZones,
                        icon: _isFetchingZones
                            ? const SizedBox(
                                height: 16,
                                width: 16,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                            : const Icon(Icons.refresh),
                        label: Text(
                          _isFetchingZones
                              ? 'Fetching zones...'
                              : 'Fetch Available Zones',
                        ),
                      ),

                      if (_fetchError != null) ...[
                        const SizedBox(height: 8),
                        Text(
                          _fetchError!,
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.error,
                            fontSize: 12,
                          ),
                        ),
                      ],

                      const SizedBox(height: 24),

                      // Zone selection
                      const Text(
                        'Select Zone',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),

                      if (_availableZones == null) ...[
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: Theme.of(context).colorScheme.outline,
                            ),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            'Select an account and tap "Fetch Available Zones" to see your zones',
                            style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ] else if (_availableZones!.isEmpty) ...[
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: Theme.of(context).colorScheme.outline,
                            ),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            'No zones found for this account',
                            style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ] else ...[
                        DropdownButtonFormField<_ZoneOption>(
                          initialValue: _selectedZone,
                          decoration: const InputDecoration(
                            labelText: 'Zone',
                            border: OutlineInputBorder(),
                          ),
                          items: _availableZones!
                              .map(
                                (zone) => DropdownMenuItem(
                                  value: zone,
                                  child: Text('${zone.name} (${zone.id})'),
                                ),
                              )
                              .toList(),
                          onChanged: (zone) {
                            setState(() => _selectedZone = zone);
                          },
                          validator: (value) {
                            if (value == null) {
                              return 'Please select a zone';
                            }
                            return null;
                          },
                        ),
                      ],

                      const SizedBox(height: 24),

                      // Comment
                      TextFormField(
                        controller: _commentController,
                        decoration: const InputDecoration(
                          labelText: 'Comment (optional)',
                          border: OutlineInputBorder(),
                        ),
                        maxLines: 2,
                      ),
                      const SizedBox(height: 32),

                      // Submit button
                      FilledButton(
                        onPressed: (_isSubmitting || _selectedZone == null)
                            ? null
                            : _submit,
                        child: _isSubmitting
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                            : const Text('Add Zone'),
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
}
