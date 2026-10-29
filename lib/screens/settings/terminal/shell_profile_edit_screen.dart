import 'package:flutter/material.dart';
import 'package:duskmoon_settings/duskmoon_settings.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:app_adaptive_widgets/app_adaptive_widgets.dart';
import 'package:go_router/go_router.dart';
import 'package:shell_profile_bloc/shell_profile_bloc.dart';
import 'package:gsmlg/destination.dart';
import 'package:gsmlg/screens/settings/settings_screen.dart';
import 'package:gsmlg/screens/settings/terminal/shell_profile_screen.dart';

class ShellProfileEditScreen extends StatefulWidget {
  static const name = 'Shell Profile Edit';
  static const path = 'edit';

  static const String fullPath =
      '${SettingsScreen.path}/${ShellProfileScreen.path}/$path';

  /// Profile ID to edit, or null for creating a new profile.
  final int? profileId;

  const ShellProfileEditScreen({super.key, this.profileId});

  @override
  State<ShellProfileEditScreen> createState() => _ShellProfileEditScreenState();
}

class _ShellProfileEditScreenState extends State<ShellProfileEditScreen> {
  late final TextEditingController _nameController;
  late final TextEditingController _workingDirController;
  late final TextEditingController _startupCmdController;

  var _shellType = ShellType.sh;
  var _isDefault = false;
  var _fontFamily = 'Source Code Pro';
  var _fontSize = 14.0;
  var _cursorStyle = CursorStyleType.block;
  var _scrollbackLines = 10000;
  var _colorTheme = 'default';
  var _inheritCurrentState = false;

  ShellProfile? _loadedProfile;
  bool _initialized = false;

  bool get _isEditing => widget.profileId != null;

  static const _fontFamilies = [
    'monospace',
    'Menlo',
    'Monaco',
    'Consolas',
    'Courier New',
    'Source Code Pro',
    'JetBrains Mono',
    'Fira Code',
  ];
  static const _scrollbackOptions = [1000, 5000, 10000, 50000, 100000];
  static final _fontSizeOptions = List.generate(25, (i) => (i + 8).toDouble());

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _workingDirController = TextEditingController();
    _startupCmdController = TextEditingController();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_initialized) {
      if (_isEditing) {
        _loadProfile();
      } else {
        _initialized = true;
      }
    }
  }

  void _loadProfile() {
    final bloc = context.read<ShellProfileBloc>();
    final state = bloc.state;
    if (state is ShellProfileInitial) {
      bloc.add(const LoadShellProfiles());
      return;
    }
    if (state is! ShellProfileLoaded) return;

    final profile = state.profiles
        .where((p) => p.id == widget.profileId)
        .firstOrNull;
    if (profile == null) return;

    _loadedProfile = profile;
    _initialized = true;
    _nameController.text = profile.name;
    _workingDirController.text = profile.workingDirectory;
    _startupCmdController.text = profile.startupCommand;
    _shellType = ShellType.fromValue(profile.shellType) ?? ShellType.sh;
    _isDefault = profile.isDefault;
    _fontFamily = _fontFamilies.contains(profile.fontFamily)
        ? profile.fontFamily
        : 'Source Code Pro';
    _fontSize = _fontSizeOptions.contains(profile.fontSize)
        ? profile.fontSize
        : 14.0;
    _cursorStyle = CursorStyleType.fromValue(profile.cursorStyle);
    _scrollbackLines = _scrollbackOptions.contains(profile.scrollbackLines)
        ? profile.scrollbackLines
        : 10000;
    _colorTheme = profile.colorTheme;
    _inheritCurrentState = profile.inheritCurrentState;
  }

  void _save() {
    final name = _nameController.text.trim();
    if (name.isEmpty) return;

    final bloc = context.read<ShellProfileBloc>();

    if (_isEditing) {
      bloc.add(
        UpdateShellProfile(
          id: widget.profileId!,
          name: name,
          shellType: _shellType,
          isDefault: _isDefault,
          workingDirectory: _workingDirController.text.trim(),
          startupCommand: _startupCmdController.text.trim(),
          fontFamily: _fontFamily,
          fontSize: _fontSize,
          cursorStyle: _cursorStyle.value,
          scrollbackLines: _scrollbackLines,
          colorTheme: _colorTheme,
          inheritCurrentState: _inheritCurrentState,
        ),
      );
    } else {
      bloc.add(
        AddShellProfile(
          name: name,
          shellType: _shellType,
          isDefault: _isDefault,
          workingDirectory: _workingDirController.text.trim(),
          startupCommand: _startupCmdController.text.trim(),
          fontFamily: _fontFamily,
          fontSize: _fontSize,
          cursorStyle: _cursorStyle.value,
          scrollbackLines: _scrollbackLines,
          colorTheme: _colorTheme,
          inheritCurrentState: _inheritCurrentState,
        ),
      );
    }

    context.goNamed(ShellProfileScreen.name);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _workingDirController.dispose();
    _startupCmdController.dispose();
    super.dispose();
  }

  List<Widget> _getActions() {
    return [
      AppAdaptiveActionList(
        actions: [
          AppAdaptiveAction(icon: Icons.check, title: 'Save', onPressed: _save),
        ],
      ),
    ];
  }

  Widget _buildForm() {
    return SettingsList(
      sections: [
        SettingsSection(
          title: const Text('General'),
          tiles: [
            SettingsTile(
              title: TextField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Name',
                  hintText: 'Enter profile name',
                  border: InputBorder.none,
                ),
              ),
              leading: const Icon(Icons.label),
            ),
            SettingsTile(
              title: const Text('Shell Type'),
              leading: const Icon(Icons.terminal),
              trailing: DropdownButton<ShellType>(
                value: _shellType,
                underline: const SizedBox.shrink(),
                items: ShellType.values.map((type) {
                  return DropdownMenuItem(value: type, child: Text(type.name));
                }).toList(),
                onChanged: (value) {
                  if (value != null) setState(() => _shellType = value);
                },
              ),
            ),
            SettingsTile.switchTile(
              title: const Text('Default Profile'),
              leading: const Icon(Icons.star),
              initialValue: _isDefault,
              onToggle: (value) {
                setState(() => _isDefault = value);
              },
            ),
          ],
        ),
        SettingsSection(
          title: const Text('Shell'),
          tiles: [
            SettingsTile(
              title: TextField(
                controller: _workingDirController,
                decoration: const InputDecoration(
                  labelText: 'Working Directory',
                  hintText: 'Leave empty for system default',
                  border: InputBorder.none,
                ),
              ),
              leading: const Icon(Icons.folder),
            ),
            SettingsTile(
              title: TextField(
                controller: _startupCmdController,
                decoration: const InputDecoration(
                  labelText: 'Startup Command',
                  hintText: 'e.g., tmux, screen',
                  border: InputBorder.none,
                ),
              ),
              leading: const Icon(Icons.play_arrow),
            ),
            SettingsTile.switchTile(
              title: const Text('Inherit Active Terminal State'),
              description: const Text(
                'New terminals use the active terminal working directory',
              ),
              leading: const Icon(Icons.call_split),
              initialValue: _inheritCurrentState,
              onToggle: (value) {
                setState(() => _inheritCurrentState = value);
              },
            ),
          ],
        ),
        SettingsSection(
          title: const Text('Appearance'),
          tiles: [
            SettingsTile(
              title: const Text('Font Family'),
              leading: const Icon(Icons.font_download),
              trailing: DropdownButton<String>(
                value: _fontFamily,
                underline: const SizedBox.shrink(),
                items: _fontFamilies.map((f) {
                  return DropdownMenuItem(value: f, child: Text(f));
                }).toList(),
                onChanged: (value) {
                  if (value != null) setState(() => _fontFamily = value);
                },
              ),
            ),
            SettingsTile(
              title: const Text('Font Size'),
              leading: const Icon(Icons.format_size),
              trailing: DropdownButton<double>(
                value: _fontSize,
                underline: const SizedBox.shrink(),
                items: _fontSizeOptions.map((s) {
                  return DropdownMenuItem(
                    value: s,
                    child: Text('${s.round()} px'),
                  );
                }).toList(),
                onChanged: (value) {
                  if (value != null) setState(() => _fontSize = value);
                },
              ),
            ),
            SettingsTile(
              title: const Text('Cursor Style'),
              leading: const Icon(Icons.edit),
              trailing: DropdownButton<CursorStyleType>(
                value: _cursorStyle,
                underline: const SizedBox.shrink(),
                items: CursorStyleType.values.map((c) {
                  final label = switch (c) {
                    CursorStyleType.block => 'Block',
                    CursorStyleType.underline => 'Underline',
                    CursorStyleType.verticalBar => 'Bar',
                  };
                  return DropdownMenuItem(value: c, child: Text(label));
                }).toList(),
                onChanged: (value) {
                  if (value != null) setState(() => _cursorStyle = value);
                },
              ),
            ),
            SettingsTile(
              title: const Text('Color Theme'),
              leading: const Icon(Icons.palette),
              trailing: DropdownButton<String>(
                value: _colorTheme,
                underline: const SizedBox.shrink(),
                items: const [
                  DropdownMenuItem(value: 'default', child: Text('default')),
                ],
                onChanged: (value) {
                  if (value != null) setState(() => _colorTheme = value);
                },
              ),
            ),
          ],
        ),
        SettingsSection(
          title: const Text('Terminal'),
          tiles: [
            SettingsTile(
              title: const Text('Scrollback Lines'),
              leading: const Icon(Icons.history),
              trailing: DropdownButton<int>(
                value: _scrollbackLines,
                underline: const SizedBox.shrink(),
                items: _scrollbackOptions.map((n) {
                  return DropdownMenuItem(value: n, child: Text(n.toString()));
                }).toList(),
                onChanged: (value) {
                  if (value != null) setState(() => _scrollbackLines = value);
                },
              ),
            ),
          ],
        ),
        if (_isEditing && !_isDefault)
          SettingsSection(
            title: const Text('Danger Zone'),
            tiles: [
              SettingsTile(
                title: Text(
                  'Delete Profile',
                  style: TextStyle(color: Theme.of(context).colorScheme.error),
                ),
                leading: Icon(
                  Icons.delete_forever,
                  color: Theme.of(context).colorScheme.error,
                ),
                onPressed: (_) => _confirmDelete(),
              ),
            ],
          ),
      ],
    );
  }

  void _confirmDelete() {
    final profile = _loadedProfile;
    if (profile == null) return;

    showAdaptiveDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog.adaptive(
          title: const Text('Delete Profile'),
          content: Text('Delete "${_nameController.text}"?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                context.read<ShellProfileBloc>().add(
                  DeleteShellProfile(profile),
                );
                Navigator.of(dialogContext).pop();
                context.goNamed(ShellProfileScreen.name);
              },
              child: Text(
                'Delete',
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final title = _isEditing ? 'Edit Profile' : 'New Profile';

    return BlocListener<ShellProfileBloc, ShellProfileState>(
      listener: (context, state) {
        if (!_initialized && _isEditing && state is ShellProfileLoaded) {
          setState(_loadProfile);
        }
      },
      child: AppAdaptiveScaffold(
        navigationRestoreInHeader: true,
        selectedIndex: Destinations.indexOf(
          const Key(SettingsScreen.name),
          context,
        ),
        onSelectedIndexChange: (idx) =>
            Destinations.changeHandler(idx, context),
        destinations: Destinations.navs(context),
        body: (context) => SafeArea(
          child: CustomScrollView(
            slivers: <Widget>[
              DmNavigationHeader(
                builder: (context, header) => SliverAppBar(
                  leading: header.leading,
                  leadingWidth: header.leadingWidth,
                  automaticallyImplyLeading: header.automaticallyImplyLeading,
                  title: Text(title),
                  actions: _getActions(),
                ),
              ),
              SliverFillRemaining(child: _buildForm()),
            ],
          ),
        ),
      ),
    );
  }
}
