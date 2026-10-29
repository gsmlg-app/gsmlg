import 'package:code_text_field/code_text_field.dart';
import 'package:flex_tabs/flex_tabs.dart';
import 'package:flutter/material.dart';
import 'package:highlight/highlight.dart';
import 'package:highlight/languages/all.dart';

// TODO: Import File from terminal_core package when available
// import 'package:terminal_core/terminal_core.dart';

/// Abstract class representing a file.
///
/// TODO: This should be imported from terminal_core package.
abstract class File {
  String get basename;
  Future<String> readAsString();
  Future<void> writeAsString(String content);
}

class CodeEditorTab extends TabItem {
  final File file;

  CodeEditorTab(this.file) {
    title.value = Text(file.basename);
    content.value = CodeEditorView(this);
    loadContent();
  }

  final codeController = ValueNotifier<CodeController?>(null);

  Future<void> loadContent() async {
    final content = await file.readAsString();
    codeController.value = CodeController(
      text: content,
      language: _detectLanguage(content),
      // theme: githubTheme,
    );
  }
}

class CodeEditorView extends StatelessWidget {
  const CodeEditorView(this.tab, {super.key});

  final CodeEditorTab tab;

  static const fontFamily = 'SourceCode';

  static const fontFamilyFallback = [
    'Menlo', // macos
    'Consolas', // windows
    'monospace',
  ];

  @override
  Widget build(BuildContext context) {
    return Material(
      child: Column(
        children: [
          _buildToolbar(),
          const Divider(),
          Expanded(child: _buildEditor()),
        ],
      ),
    );
  }

  Widget _buildToolbar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 8, 8, 0),
      child: SizedBox(
        height: 24,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(tab.file.basename),
            const Spacer(),
            TextButton.icon(
              icon: const Icon(Icons.save),
              label: const Text('Save'),
              onPressed: () async {
                final controller = tab.codeController.value;
                if (controller == null) return;
                await tab.file.writeAsString(controller.value.text);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEditor() {
    return ValueListenableBuilder(
      valueListenable: tab.codeController,
      builder: (context, codeController, child) {
        if (codeController == null) {
          return const Center(child: CircularProgressIndicator.adaptive());
        }

        return SingleChildScrollView(
          child: CodeField(
            controller: codeController,
            lineNumberStyle: const LineNumberStyle(
              textStyle: TextStyle(
                fontFamily: fontFamily,
                fontFamilyFallback: fontFamilyFallback,
              ),
            ),
            textStyle: const TextStyle(
              fontFamily: fontFamily,
              fontSize: 12,
              fontFamilyFallback: fontFamilyFallback,
            ),
          ),
        );
      },
    );
  }
}

Mode _detectLanguage(String source) {
  final result = highlight.parse(source, autoDetection: true);
  return allLanguages[result.language]!;
}
