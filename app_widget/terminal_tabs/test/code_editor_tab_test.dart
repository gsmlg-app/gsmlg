import 'package:code_text_field/code_text_field.dart';
import 'package:flex_tabs/flex_tabs.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:terminal_tabs/src/code_editor_tab.dart';

// Default JavaScript content that is recognizable by highlight.js
const _defaultJsContent = '''
function hello() {
  console.log("Hello, World!");
  return 42;
}
''';

// Mock implementation of File for testing
class MockFile implements File {
  final String _basename;
  String _content;

  MockFile({String basename = 'test.js', String content = _defaultJsContent})
    : _basename = basename,
      _content = content;

  @override
  String get basename => _basename;

  @override
  Future<String> readAsString() async => _content;

  @override
  Future<void> writeAsString(String content) async {
    _content = content;
  }
}

void main() {
  group('File interface', () {
    test('MockFile implements File', () {
      expect(MockFile(), isA<File>());
    });

    test('basename returns expected value', () {
      final file = MockFile(basename: 'example.dart');
      expect(file.basename, equals('example.dart'));
    });

    test('readAsString returns content', () async {
      final file = MockFile(content: 'hello world');
      expect(await file.readAsString(), equals('hello world'));
    });

    test('writeAsString updates content', () async {
      final file = MockFile();
      await file.writeAsString('new content');
      expect(await file.readAsString(), equals('new content'));
    });

    test('handles empty content', () async {
      final file = MockFile(content: '');
      expect(await file.readAsString(), equals(''));
    });

    test('handles unicode content', () async {
      final file = MockFile(content: '日本語テスト 🚀');
      expect(await file.readAsString(), equals('日本語テスト 🚀'));
    });
  });

  group('CodeEditorTab construction', () {
    // Note: These tests avoid triggering loadContent which uses _detectLanguage
    // that can fail on empty/undetectable content

    test('extends TabItem', () {
      final file = MockFile();
      final tab = CodeEditorTab(file);
      expect(tab, isA<TabItem>());
    });

    test('stores file reference', () {
      final file = MockFile();
      final tab = CodeEditorTab(file);
      expect(tab.file, same(file));
    });

    test('title displays file basename', () {
      final file = MockFile(basename: 'main.dart');
      final tab = CodeEditorTab(file);
      final titleWidget = tab.title.value;
      expect(titleWidget, isA<Text>());
      expect((titleWidget as Text).data, equals('main.dart'));
    });

    test('content is set to CodeEditorView', () {
      final file = MockFile();
      final tab = CodeEditorTab(file);
      expect(tab.content.value, isA<CodeEditorView>());
    });

    test('codeController is a ValueNotifier', () {
      final file = MockFile();
      final tab = CodeEditorTab(file);
      expect(tab.codeController, isA<ValueNotifier<CodeController?>>());
    });

    test('codeController is initially null', () {
      final file = MockFile();
      final tab = CodeEditorTab(file);
      // Controller is null immediately after construction (before async load)
      expect(tab.codeController.value, isNull);
    });
  });

  group('CodeEditorTab file types (construction only)', () {
    // These tests only verify construction, not loading

    test('creates with .dart file', () {
      final file = MockFile(basename: 'main.dart');
      final tab = CodeEditorTab(file);
      expect(tab.file.basename, endsWith('.dart'));
    });

    test('creates with .js file', () {
      final file = MockFile(basename: 'script.js');
      final tab = CodeEditorTab(file);
      expect(tab.file.basename, endsWith('.js'));
    });

    test('creates with .json file', () {
      final file = MockFile(basename: 'config.json');
      final tab = CodeEditorTab(file);
      expect(tab.file.basename, endsWith('.json'));
    });

    test('creates with .txt file', () {
      final file = MockFile(basename: 'readme.txt');
      final tab = CodeEditorTab(file);
      expect(tab.file.basename, endsWith('.txt'));
    });

    test('creates with file without extension', () {
      final file = MockFile(basename: 'Makefile');
      final tab = CodeEditorTab(file);
      expect(tab.file.basename, equals('Makefile'));
    });

    test('creates with .py file', () {
      final file = MockFile(basename: 'script.py');
      final tab = CodeEditorTab(file);
      expect(tab.file.basename, endsWith('.py'));
    });

    test('creates with .yaml file', () {
      final file = MockFile(basename: 'pubspec.yaml');
      final tab = CodeEditorTab(file);
      expect(tab.file.basename, endsWith('.yaml'));
    });
  });

  group('CodeEditorView', () {
    test('is a StatelessWidget', () {
      final file = MockFile();
      final tab = CodeEditorTab(file);
      final view = CodeEditorView(tab);
      expect(view, isA<StatelessWidget>());
    });

    test('stores tab reference', () {
      final file = MockFile();
      final tab = CodeEditorTab(file);
      final view = CodeEditorView(tab);
      expect(view.tab, same(tab));
    });

    test('can be constructed with key', () {
      final file = MockFile();
      final tab = CodeEditorTab(file);
      final key = UniqueKey();
      final view = CodeEditorView(tab, key: key);
      expect(view.key, equals(key));
    });

    test('fontFamily is SourceCode', () {
      expect(CodeEditorView.fontFamily, equals('SourceCode'));
    });

    test('fontFamilyFallback contains expected fonts', () {
      expect(CodeEditorView.fontFamilyFallback, contains('Menlo'));
      expect(CodeEditorView.fontFamilyFallback, contains('Consolas'));
      expect(CodeEditorView.fontFamilyFallback, contains('monospace'));
    });

    test('fontFamilyFallback has correct order for platforms', () {
      final fallback = CodeEditorView.fontFamilyFallback;
      expect(fallback[0], equals('Menlo')); // macos first
      expect(fallback[1], equals('Consolas')); // windows second
      expect(fallback[2], equals('monospace')); // generic last
    });

    test('fontFamilyFallback has 3 entries', () {
      expect(CodeEditorView.fontFamilyFallback.length, equals(3));
    });
  });

  group('CodeEditorTab multiple instances', () {
    test('two tabs with same file reference same file', () {
      final file = MockFile(basename: 'shared.txt');
      final tab1 = CodeEditorTab(file);
      final tab2 = CodeEditorTab(file);

      expect(tab1.file, same(tab2.file));
    });

    test('two tabs have separate codeControllers', () {
      final file = MockFile();
      final tab1 = CodeEditorTab(file);
      final tab2 = CodeEditorTab(file);

      expect(tab1.codeController, isNot(same(tab2.codeController)));
    });

    test('two tabs have separate content widgets', () {
      final file = MockFile();
      final tab1 = CodeEditorTab(file);
      final tab2 = CodeEditorTab(file);

      expect(tab1.content, isNot(same(tab2.content)));
    });

    test('two tabs have separate title widgets', () {
      final file = MockFile();
      final tab1 = CodeEditorTab(file);
      final tab2 = CodeEditorTab(file);

      expect(tab1.title, isNot(same(tab2.title)));
    });
  });

  group('CodeEditorTab loadContent with valid code', () {
    // These tests use content that _detectLanguage can parse

    test('loads JavaScript content', () async {
      // JavaScript is well-detected by highlight.js
      final file = MockFile(
        basename: 'script.js',
        content: '''
function hello() {
  console.log("Hello, World!");
  return 42;
}
''',
      );
      final tab = CodeEditorTab(file);

      // Wait for async loadContent
      await Future.delayed(const Duration(milliseconds: 200));

      expect(tab.codeController.value, isA<CodeController>());
    });

    test('loads Python content', () async {
      final file = MockFile(
        basename: 'script.py',
        content: '''
def hello():
    print("Hello, World!")
    return 42
''',
      );
      final tab = CodeEditorTab(file);

      await Future.delayed(const Duration(milliseconds: 200));

      expect(tab.codeController.value, isA<CodeController>());
    });

    test('controller text matches file content', () async {
      final content = '''
function test() {
  return "test";
}
''';
      final file = MockFile(basename: 'test.js', content: content);
      final tab = CodeEditorTab(file);

      await Future.delayed(const Duration(milliseconds: 200));

      expect(tab.codeController.value?.value.text, equals(content));
    });
  });
}
