import 'dart:async';

import 'package:app_locale/app_locale.dart';
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';
import 'package:terminal_core/terminal_core.dart';
import 'package:file_manager_plugin/src/navigation_breadcrumbs.dart';
import 'package:file_manager_plugin/src/navigation_stack.dart';

class FileManagerPlugin with Plugin {
  late FileSystem fs;

  String? homePath;

  final currentPath = ValueNotifier<String?>(null);

  String? get currentDirectory =>
      currentPath.value == null ? null : fs.path.basename(currentPath.value!);

  final files = ValueNotifier(<FileSystemEntity>[]);

  late final navigationStack = NavigationStack<String>(onNavigate: _onNavigate);

  final _filesCache = <String, List<FileSystemEntity>>{};
  final error = ValueNotifier<Object?>(null);
  final loading = ValueNotifier<bool>(false);
  FileSystem? _ownedFileSystem;
  int _generation = 0;
  int _navigationGeneration = 0;

  Future<void> _fetchFiles() async {
    final fileSystem = _ownedFileSystem;
    final path = currentPath.value;
    if (fileSystem == null || path == null || !mounted || !connected) return;
    final generation = _generation;
    final navigation = ++_navigationGeneration;
    bool isCurrent() =>
        mounted &&
        connected &&
        generation == _generation &&
        navigation == _navigationGeneration;
    files.value = _filesCache[path] ?? [];
    error.value = null;
    loading.value = true;
    try {
      final result = await fileSystem.directory(path).list().toList();
      if (!isCurrent()) return;
      _filesCache[path] = result;
      files.value = result;
    } catch (exception) {
      if (isCurrent()) error.value = exception;
    } finally {
      if (isCurrent()) loading.value = false;
    }
  }

  Future<void> _onNavigate(String path) async {
    if (_ownedFileSystem == null || !mounted || !connected) return;
    currentPath.value = fs.path.normalize(path);
    title.value =
        currentDirectory == null ? null : currentDirectory! + fs.path.separator;
    await _fetchFiles();
  }

  Future<void> goto(String target) async {
    if (_ownedFileSystem == null || !mounted || !connected) return;
    final path = fs.path.isAbsolute(target)
        ? target
        : fs.path
            .normalize(fs.path.join(currentPath.value ?? homePath!, target));
    navigationStack.push(path);
  }

  List<String> get breadcrumbs {
    final path = currentPath.value;
    if (path == null) return [];
    final parts = fs.path.split(path);
    return parts;
  }

  bool get canGoUp => breadcrumbs.length > 1;

  Future<void> goUp() async {
    if (!canGoUp) return;
    await goto('..');
  }

  Future<void> goHome() async {
    if (homePath == null) return;
    await goto(homePath!);
  }

  @override
  void didMounted() {
    title.value = 'Files';
  }

  @override
  void didConnected() {
    unawaited(_connectFileSystem(++_generation));
  }

  Future<void> _connectFileSystem(int generation) async {
    loading.value = true;
    error.value = null;
    FileSystem? fileSystem;
    try {
      fileSystem = await host.connectFileSystem();
      if (!mounted || !connected || generation != _generation) {
        _closeFileSystem(fileSystem);
        return;
      }
      _ownedFileSystem = fileSystem;
      fs = fileSystem;
      final home = (await fileSystem.directory('.').absolute).path;
      if (!mounted || !connected || generation != _generation) return;
      homePath = home;
      await goto(home);
    } catch (exception) {
      if (identical(_ownedFileSystem, fileSystem)) {
        _ownedFileSystem = null;
        if (fileSystem != null) _closeFileSystem(fileSystem);
      }
      if (mounted && connected && generation == _generation) {
        error.value = exception;
      }
    } finally {
      if (mounted &&
          connected &&
          generation == _generation &&
          currentPath.value == null) {
        loading.value = false;
      }
    }
  }

  void _closeFileSystem(FileSystem fileSystem) {
    unawaited(Future<void>.sync(fileSystem.close)
        .catchError((Object exception, StackTrace stack) {
      FlutterError.reportError(FlutterErrorDetails(
        exception: exception,
        stack: stack,
        library: 'file_manager_plugin',
      ));
    }));
  }

  void _releaseFileSystem() {
    _generation++;
    _navigationGeneration++;
    final fileSystem = _ownedFileSystem;
    _ownedFileSystem = null;
    if (fileSystem != null) _closeFileSystem(fileSystem);
    homePath = null;
    currentPath.value = null;
    files.value = [];
    _filesCache.clear();
    loading.value = false;
  }

  @override
  void didUnmounted() => _releaseFileSystem();

  @override
  void didDisconnected() => _releaseFileSystem();

  @override
  void onConnectionError(Object error) {
    if (!mounted) return;
    loading.value = false;
    this.error.value = error;
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 40, child: FileListToolbar(this)),
          ValueListenableBuilder(
            valueListenable: loading,
            builder: (context, loading, _) => loading
                ? const LinearProgressIndicator()
                : const SizedBox.shrink(),
          ),
          ValueListenableBuilder(
            valueListenable: error,
            builder: (context, error, _) => error == null
                ? const SizedBox.shrink()
                : Padding(
                    padding: const EdgeInsets.all(8),
                    child: Text('${context.l10n.error}: $error'),
                  ),
          ),
          Expanded(child: FileListView(this)),
          const Divider(),
          SizedBox(height: 30, child: FileListNavigator(this)),
        ],
      ),
    );
  }
}

class FileListToolbar extends StatelessWidget {
  const FileListToolbar(this.plugin, {super.key});

  final FileManagerPlugin plugin;

  NavigationStack<String> get stack => plugin.navigationStack;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: plugin.currentPath,
      builder: (context, currentPath, _) => _buildToolbar(context),
    );
  }

  Widget _buildToolbar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Row(
        children: [
          IconButton(
            icon: Icon(Icons.adaptive.arrow_back),
            onPressed: stack.canGoBack ? stack.back : null,
          ),
          const SizedBox(width: 8),
          IconButton(
            icon: Icon(Icons.adaptive.arrow_forward),
            onPressed: stack.canGoForward ? stack.forward : null,
          ),
          const SizedBox(width: 8),
          IconButton(
            icon: const Icon(Icons.arrow_upward),
            onPressed: plugin.canGoUp ? plugin.goUp : null,
          ),
          const SizedBox(width: 8),
          IconButton(
            icon: const Icon(Icons.home),
            onPressed: plugin.homePath == null ? null : plugin.goHome,
          ),
          const SizedBox(width: 16),
          const VerticalDivider(),
          const SizedBox(width: 16),
          Expanded(child: Text(plugin.currentDirectory ?? '')),
          const SizedBox(width: 8),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => plugin._fetchFiles(),
          ),
        ],
      ),
    );
  }
}

class FileListNavigator extends StatelessWidget {
  const FileListNavigator(this.plugin, {super.key});

  final FileManagerPlugin plugin;

  NavigationStack<String> get stack => plugin.navigationStack;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: ValueListenableBuilder(
        valueListenable: plugin.currentPath,
        builder: (context, currentPath, _) {
          return NavigationBreadcrumbs(
            breadcrumbs: plugin.breadcrumbs,
            onTap: (breadcrumbs) {
              plugin.goto(plugin.fs.path.joinAll(breadcrumbs));
            },
          );
        },
      ),
    );
  }
}

class FileListView extends StatefulWidget {
  const FileListView(this.plugin, {super.key});

  final FileManagerPlugin plugin;

  @override
  FileListViewState createState() => FileListViewState();
}

class FileListViewState extends State<FileListView> {
  FileManagerPlugin get plugin => widget.plugin;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: plugin.files,
      builder: (context, files, child) {
        return _buildTable(context, files);
      },
    );
  }

  Widget _buildTable(BuildContext context, List<FileSystemEntity> files) {
    final source = _FilesDataSource(files);
    return SfDataGrid(
      headerRowHeight: 40,
      allowSorting: true,
      allowFiltering: true,
      horizontalScrollPhysics: const NeverScrollableScrollPhysics(),
      onCellTap: (details) {
        final rowIndex = details.rowColumnIndex.rowIndex;

        if (rowIndex == 0) return;

        final row = source.effectiveRows[rowIndex - 1] as _FileDataGridRow;

        final file = row.file;

        if (file is Directory) {
          plugin.goto(file.path);
        }
      },
      columns: [
        GridColumn(
          columnName: 'name',
          label: Container(
            padding: const EdgeInsets.all(8),
            child: const Text('Name'),
          ),
          columnWidthMode: ColumnWidthMode.fill,
          allowFiltering: true,
        ),
        GridColumn(
          columnName: 'date',
          label: Container(
            padding: const EdgeInsets.all(8),
            child: const Text('Date'),
          ),
          minimumWidth: 210,
          allowFiltering: false,
        ),
      ],
      source: source,
    );
  }
}

class _FilesDataSource extends DataGridSource {
  _FilesDataSource(this.files);

  final List<FileSystemEntity> files;

  @override
  late final rows = files
      .where((file) => file.basename != '.' && file.basename != '..')
      .map((file) => _FileDataGridRow(file))
      .toList();

  @override
  DataGridRowAdapter buildRow(covariant _FileDataGridRow row) {
    return DataGridRowAdapter(
      cells: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(width: 8),
            Icon(
              row.file is Directory ? Icons.folder : Icons.file_open,
              size: 16,
            ),
            Container(
              padding: const EdgeInsets.all(8),
              child: Text(row.name),
            ),
          ],
        ),
        Container(
          padding: const EdgeInsets.all(8),
          child: Text(row.date),
        ),
      ],
    );
  }
}

class _FileDataGridRow implements DataGridRow {
  _FileDataGridRow(this.file);

  final FileSystemEntity file;

  late final name = file.basename;

  late final date = '${file.cachedStat?.modified ?? ''}';

  @override
  List<DataGridCell> getCells() {
    return [
      DataGridCell<String>(columnName: 'name', value: name),
      DataGridCell<String>(columnName: 'date', value: date),
    ];
  }
}
