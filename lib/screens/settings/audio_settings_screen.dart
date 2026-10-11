// ignore_for_file: depend_on_referenced_packages

import 'package:accounts_bloc/accounts_bloc.dart';
import 'package:app_adaptive_widgets/app_adaptive_widgets.dart';
import 'package:app_audio/audio.dart';
import 'package:app_database/app_database.dart';
import 'package:app_locale/app_locale.dart';
import 'package:audio_bloc/audio_bloc.dart';
import 'package:duskmoon_settings/duskmoon_settings.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:gsmlg/destination.dart';
import 'package:gsmlg/screens/settings/account_screen.dart';
import 'package:gsmlg/screens/settings/settings_screen.dart';

class AudioSettingsScreen extends StatefulWidget {
  static const name = 'AudioSettings';
  static const path = 'audio';

  const AudioSettingsScreen({super.key});

  @override
  State<AudioSettingsScreen> createState() => _AudioSettingsScreenState();
}

class _AudioSettingsScreenState extends State<AudioSettingsScreen> {
  static const _supportedFormats = ['mp3', 'opus', 'aac', 'flac', 'wav', 'pcm'];
  static const _standardVoices = [
    'alloy',
    'echo',
    'fable',
    'onyx',
    'nova',
    'shimmer',
  ];

  late AudioProviderType _providerType;
  late final TextEditingController _urlController;
  int? _accountId;
  bool _useDummyToken = false;
  late final TextEditingController _ttsModelController;
  String _ttsVoice = 'alloy';
  double _ttsSpeed = 1.0;
  String _ttsFormat = 'mp3';
  late final TextEditingController _asrModelController;
  late final TextEditingController _asrLanguageController;

  @override
  void initState() {
    super.initState();
    final settings = context.read<AudioSettingsBloc>().state.settings;
    _providerType = settings.providerType;
    _urlController = TextEditingController(text: settings.baseUrl);
    _accountId = settings.accountId;
    _useDummyToken = settings.useDummyToken;
    _ttsModelController = TextEditingController(text: settings.ttsModel);
    _ttsVoice = settings.ttsVoice.isNotEmpty ? settings.ttsVoice : 'alloy';
    _ttsSpeed = settings.ttsSpeed;
    _ttsFormat = settings.ttsResponseFormat;
    _asrModelController = TextEditingController(text: settings.asrModel);
    _asrLanguageController = TextEditingController(
      text: settings.asrLanguage ?? '',
    );
  }

  @override
  void dispose() {
    _urlController.dispose();
    _ttsModelController.dispose();
    _asrModelController.dispose();
    _asrLanguageController.dispose();
    super.dispose();
  }

  void _applySettings(AudioSettings settings) {
    setState(() {
      _providerType = settings.providerType;
      _urlController.text = settings.baseUrl;
      _accountId = settings.accountId;
      _useDummyToken = settings.useDummyToken;
      _ttsModelController.text = settings.ttsModel;
      _ttsVoice = settings.ttsVoice.isNotEmpty ? settings.ttsVoice : 'alloy';
      _ttsSpeed = settings.ttsSpeed;
      _ttsFormat = settings.ttsResponseFormat;
      _asrModelController.text = settings.asrModel;
      _asrLanguageController.text = settings.asrLanguage ?? '';
    });
  }

  void _save() {
    final settings = AudioSettings(
      providerType: _providerType,
      baseUrl: _urlController.text.trim(),
      accountId: _accountId,
      useDummyToken: _useDummyToken,
      ttsModel: _ttsModelController.text.trim(),
      ttsVoice: _ttsVoice,
      ttsSpeed: _ttsSpeed,
      ttsResponseFormat: _ttsFormat,
      asrModel: _asrModelController.text.trim(),
      asrLanguage: _asrLanguageController.text.trim().isEmpty
          ? null
          : _asrLanguageController.text.trim(),
    );
    context.read<AudioSettingsBloc>().add(AudioSettingsSave(settings));
  }

  void _reset() {
    context.read<AudioSettingsBloc>().add(
      const AudioSettingsResetToBackplane(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AppAdaptiveScaffold(
      navigationRestoreInHeader: true,
      selectedIndex: Destinations.indexOf(
        const Key(SettingsScreen.name),
        context,
      ),
      onSelectedIndexChange: (index) =>
          Destinations.changeHandler(index, context),
      destinations: Destinations.navs(context),
      body: (context) => SafeArea(
        child: BlocConsumer<AudioSettingsBloc, AudioSettingsState>(
          listener: (context, state) {
            if (state.status == AudioSettingsStatus.ready) {
              _applySettings(state.settings);
            }
          },
          builder: (context, state) {
            final accountsState = context.watch<AccountsBloc>().state;
            final accounts = accountsState is AccountsLoaded
                ? accountsState.accounts
                : const <ServiceAccountTableData>[];
            final selectedAccountExists =
                _accountId == null ||
                accounts.any((account) => account.id == _accountId);
            final formatItems = _supportedFormats.contains(_ttsFormat)
                ? _supportedFormats
                : [_ttsFormat, ..._supportedFormats];
            final voiceItems = _standardVoices.contains(_ttsVoice)
                ? _standardVoices
                : [_ttsVoice, ..._standardVoices];

            return CustomScrollView(
              slivers: [
                DmNavigationHeader(
                  builder: (context, header) => SliverAppBar(
                    leading: header.leading,
                    leadingWidth: header.leadingWidth,
                    automaticallyImplyLeading: header.automaticallyImplyLeading,
                    title: Text(context.l10n.audioSettingsTitle),
                  ),
                ),
                SliverFillRemaining(
                  child: SettingsList(
                    sections: [
                      SettingsSection(
                        title: Text(context.l10n.audioSettingsProvider),
                        tiles: [
                          SettingsTile(
                            title: Text(context.l10n.audioSettingsProvider),
                            description: DropdownButton<AudioProviderType>(
                              value: _providerType,
                              isExpanded: true,
                              items: [
                                DropdownMenuItem(
                                  value: AudioProviderType.backplane,
                                  child: Text(
                                    context.l10n.audioSettingsBackplanePreset,
                                  ),
                                ),
                                DropdownMenuItem(
                                  value: AudioProviderType.customOpenAi,
                                  child: Text(
                                    context.l10n.audioSettingsCustomOpenAi,
                                  ),
                                ),
                              ],
                              onChanged: (type) {
                                if (type != null) {
                                  setState(() => _providerType = type);
                                }
                              },
                            ),
                          ),
                          SettingsTile(
                            title: Text(context.l10n.audioSettingsBaseUrl),
                            description: TextField(
                              controller: _urlController,
                              keyboardType: TextInputType.url,
                              decoration: InputDecoration(
                                labelText: context.l10n.audioSettingsBaseUrl,
                              ),
                            ),
                          ),
                          SettingsTile.switchTile(
                            title: Text(
                              context.l10n.audioSettingsUseDummyToken,
                            ),
                            initialValue: _useDummyToken,
                            onToggle: (value) =>
                                setState(() => _useDummyToken = value),
                          ),
                          if (!_useDummyToken)
                            SettingsTile(
                              title: Text(context.l10n.audioSettingsAccount),
                              description: DropdownButton<int?>(
                                value: selectedAccountExists
                                    ? _accountId
                                    : null,
                                isExpanded: true,
                                hint: Text(context.l10n.backplaneSelectAccount),
                                items: [
                                  DropdownMenuItem<int?>(
                                    value: null,
                                    child: Text(
                                      context.l10n.backplaneSelectAccount,
                                    ),
                                  ),
                                  for (final account in accounts)
                                    DropdownMenuItem<int?>(
                                      value: account.id,
                                      child: Text(account.name),
                                    ),
                                ],
                                onChanged: (id) =>
                                    setState(() => _accountId = id),
                              ),
                            ),
                          SettingsTile.navigation(
                            title: Text(context.l10n.backplaneManageAccounts),
                            onPressed: (_) =>
                                context.goNamed(AccountScreen.name),
                          ),
                        ],
                      ),
                      SettingsSection(
                        title: Text(context.l10n.audioTtsTab),
                        tiles: [
                          SettingsTile(
                            title: Text(context.l10n.audioSettingsTtsModel),
                            description: TextField(
                              controller: _ttsModelController,
                              decoration: InputDecoration(
                                labelText: context.l10n.audioSettingsTtsModel,
                              ),
                            ),
                          ),
                          SettingsTile(
                            title: Text(context.l10n.audioSettingsTtsVoice),
                            description: DropdownButton<String>(
                              value: voiceItems.contains(_ttsVoice)
                                  ? _ttsVoice
                                  : 'alloy',
                              isExpanded: true,
                              items: [
                                for (final voice in voiceItems)
                                  DropdownMenuItem(
                                    value: voice,
                                    child: Text(voice),
                                  ),
                              ],
                              onChanged: (val) {
                                if (val != null) {
                                  setState(() => _ttsVoice = val);
                                }
                              },
                            ),
                          ),
                          SettingsTile(
                            title: Text(
                              '${context.l10n.audioSettingsTtsSpeed}: ${_ttsSpeed.toStringAsFixed(2)}x',
                            ),
                            description: Slider(
                              value: _ttsSpeed.clamp(0.5, 2.0),
                              min: 0.5,
                              max: 2.0,
                              divisions: 30,
                              label: '${_ttsSpeed.toStringAsFixed(2)}x',
                              onChanged: (val) =>
                                  setState(() => _ttsSpeed = val),
                            ),
                          ),
                          SettingsTile(
                            title: Text(context.l10n.audioSettingsTtsFormat),
                            description: DropdownButton<String>(
                              value: formatItems.contains(_ttsFormat)
                                  ? _ttsFormat
                                  : 'mp3',
                              isExpanded: true,
                              items: [
                                for (final fmt in formatItems)
                                  DropdownMenuItem(
                                    value: fmt,
                                    child: Text(fmt),
                                  ),
                              ],
                              onChanged: (val) {
                                if (val != null) {
                                  setState(() => _ttsFormat = val);
                                }
                              },
                            ),
                          ),
                        ],
                      ),
                      SettingsSection(
                        title: Text(context.l10n.audioAsrTab),
                        tiles: [
                          SettingsTile(
                            title: Text(context.l10n.audioSettingsAsrModel),
                            description: TextField(
                              controller: _asrModelController,
                              decoration: InputDecoration(
                                labelText: context.l10n.audioSettingsAsrModel,
                              ),
                            ),
                          ),
                          SettingsTile(
                            title: Text(context.l10n.audioSettingsAsrLanguage),
                            description: TextField(
                              controller: _asrLanguageController,
                              decoration: InputDecoration(
                                labelText:
                                    context.l10n.audioSettingsAsrLanguage,
                              ),
                            ),
                          ),
                        ],
                      ),
                      SettingsSection(
                        title: const Text('Actions'),
                        tiles: [
                          SettingsTile(
                            title: Text(context.l10n.audioSettingsSaveButton),
                            leading: const Icon(Icons.save),
                            onPressed: (_) => _save(),
                          ),
                          SettingsTile(
                            title: Text(context.l10n.audioSettingsResetButton),
                            leading: const Icon(Icons.restore),
                            onPressed: (_) => _reset(),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
      smallSecondaryBody: DmAdaptiveScaffold.emptyBuilder,
    );
  }
}
