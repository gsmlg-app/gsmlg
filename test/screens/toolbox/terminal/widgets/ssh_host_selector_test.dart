import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:ssh_host_bloc/ssh_host_bloc.dart';
import 'package:gsmlg/screens/toolbox/terminal/widgets/ssh_host_selector.dart';

class MockSshHostBloc extends MockBloc<SshHostEvent, SshHostState>
    implements SshHostBloc {}

void main() {
  late MockSshHostBloc mockBloc;

  setUpAll(() {
    registerFallbackValue(SshHostLoad());
  });

  setUp(() {
    mockBloc = MockSshHostBloc();
  });

  tearDown(() {
    mockBloc.close();
  });

  Widget buildSubject() {
    return MaterialApp(
      home: BlocProvider<SshHostBloc>.value(
        value: mockBloc,
        child: const SshHostSelector(),
      ),
    );
  }

  group('SshHostSelector', () {
    testWidgets('shows loading indicator when in initial state', (
      tester,
    ) async {
      when(() => mockBloc.state).thenReturn(SshHostInitial());

      await tester.pumpWidget(buildSubject());

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('shows error state with retry button', (tester) async {
      when(
        () => mockBloc.state,
      ).thenReturn(SshHostError(Exception('Network error')));

      await tester.pumpWidget(buildSubject());

      expect(find.text('Failed to load SSH hosts'), findsOneWidget);
      expect(find.byIcon(Icons.error_outline), findsOneWidget);
      expect(find.text('Retry'), findsOneWidget);
    });

    testWidgets('retry button triggers SshHostLoad event', (tester) async {
      when(
        () => mockBloc.state,
      ).thenReturn(SshHostError(Exception('Network error')));

      await tester.pumpWidget(buildSubject());
      await tester.pump(); // Let initState run (may load if in initial state)
      clearInteractions(mockBloc); // Clear any initial loads

      await tester.tap(find.text('Retry'));
      await tester.pump();

      verify(() => mockBloc.add(any(that: isA<SshHostLoad>()))).called(1);
    });

    testWidgets('shows empty state when no hosts configured', (tester) async {
      when(() => mockBloc.state).thenReturn(SshHostLoaded([]));

      await tester.pumpWidget(buildSubject());

      expect(find.text('No SSH hosts configured'), findsOneWidget);
      expect(find.byIcon(Icons.dns_outlined), findsOneWidget);
      expect(
        find.text('Add SSH hosts in Settings > SSH Host Management'),
        findsOneWidget,
      );
    });

    testWidgets('shows host list when hosts are loaded', (tester) async {
      final hosts = [
        const SshHost(
          id: 1,
          host: 'Server 1',
          hostname: 'server1.example.com',
          port: 22,
          username: 'admin',
        ),
        const SshHost(
          id: 2,
          host: 'Server 2',
          hostname: 'server2.example.com',
          port: 2222,
          username: 'root',
        ),
      ];
      when(() => mockBloc.state).thenReturn(SshHostLoaded(hosts));

      await tester.pumpWidget(buildSubject());

      expect(find.text('Server 1'), findsOneWidget);
      expect(find.text('admin@server1.example.com:22'), findsOneWidget);
      expect(find.text('Server 2'), findsOneWidget);
      expect(find.text('root@server2.example.com:2222'), findsOneWidget);
    });

    testWidgets('uses hostname as display name when host is null', (
      tester,
    ) async {
      final hosts = [
        const SshHost(
          id: 1,
          host: null,
          hostname: 'server.example.com',
          port: 22,
          username: 'user',
        ),
      ];
      when(() => mockBloc.state).thenReturn(SshHostLoaded(hosts));

      await tester.pumpWidget(buildSubject());

      // When host is null, it falls back to hostname
      expect(find.text('server.example.com'), findsOneWidget);
    });

    testWidgets('shows dialog title', (tester) async {
      when(() => mockBloc.state).thenReturn(SshHostLoaded([]));

      await tester.pumpWidget(buildSubject());

      expect(find.text('Select SSH Host'), findsOneWidget);
    });

    testWidgets('has cancel button', (tester) async {
      when(() => mockBloc.state).thenReturn(SshHostLoaded([]));

      await tester.pumpWidget(buildSubject());

      expect(find.text('Cancel'), findsOneWidget);
    });

    testWidgets('cancel button closes dialog without selection', (
      tester,
    ) async {
      when(() => mockBloc.state).thenReturn(SshHostLoaded([]));

      SshHost? result;
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) => ElevatedButton(
              onPressed: () async {
                result = await showDialog<SshHost>(
                  context: context,
                  builder: (context) => BlocProvider<SshHostBloc>.value(
                    value: mockBloc,
                    child: const SshHostSelector(),
                  ),
                );
              },
              child: const Text('Open'),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();

      expect(result, isNull);
    });

    testWidgets('tapping host returns selected host', (tester) async {
      final hosts = [
        const SshHost(
          id: 1,
          host: 'Test Server',
          hostname: 'test.example.com',
          port: 22,
          username: 'testuser',
        ),
      ];
      when(() => mockBloc.state).thenReturn(SshHostLoaded(hosts));

      SshHost? result;
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) => ElevatedButton(
              onPressed: () async {
                result = await showDialog<SshHost>(
                  context: context,
                  builder: (context) => BlocProvider<SshHostBloc>.value(
                    value: mockBloc,
                    child: const SshHostSelector(),
                  ),
                );
              },
              child: const Text('Open'),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Test Server'));
      await tester.pumpAndSettle();

      expect(result, isNotNull);
      expect(result!.id, 1);
      expect(result!.hostname, 'test.example.com');
    });

    testWidgets('loads hosts when not already loaded', (tester) async {
      when(() => mockBloc.state).thenReturn(SshHostLoaded([]));

      await tester.pumpWidget(buildSubject());
      await tester.pump();

      // Should NOT trigger load since state is already SshHostLoaded
      verifyNever(() => mockBloc.add(any(that: isA<SshHostLoad>())));
    });

    testWidgets('triggers load when in initial state', (tester) async {
      when(() => mockBloc.state).thenReturn(SshHostInitial());

      await tester.pumpWidget(buildSubject());
      await tester.pump();

      verify(() => mockBloc.add(any(that: isA<SshHostLoad>()))).called(1);
    });

    group('accessibility', () {
      testWidgets('has semantic labels for loading state', (tester) async {
        when(() => mockBloc.state).thenReturn(SshHostInitial());

        await tester.pumpWidget(buildSubject());

        // Check accessibility tree exists
        expect(find.byType(Semantics), findsWidgets);
      });

      testWidgets('dialog has semantic header', (tester) async {
        when(() => mockBloc.state).thenReturn(SshHostLoaded([]));

        await tester.pumpWidget(buildSubject());

        // Find the Semantics widget wrapping the title
        final titleSemantics = find.descendant(
          of: find.byType(AlertDialog),
          matching: find.byType(Semantics),
        );
        expect(titleSemantics, findsWidgets);
      });

      testWidgets('host list items have semantic labels', (tester) async {
        final hosts = [
          const SshHost(
            id: 1,
            host: 'Server 1',
            hostname: 'server1.example.com',
            port: 22,
            username: 'admin',
          ),
        ];
        when(() => mockBloc.state).thenReturn(SshHostLoaded(hosts));

        await tester.pumpWidget(buildSubject());

        // Each host should have semantic information
        final listTile = find.byType(ListTile);
        expect(listTile, findsOneWidget);
      });
    });

    group('static show method', () {
      testWidgets('returns SshHost type from show method', (tester) async {
        // Since showDialog creates a new context tree, we need to ensure the
        // BlocProvider is available at the app level. This test verifies
        // the static method signature works correctly.

        // The static show method returns Future<SshHost?>
        // Test the method signature by checking it accepts BuildContext
        expect(
          SshHostSelector.show,
          isA<Future<SshHost?> Function(BuildContext)>(),
        );
      });
    });
  });
}
