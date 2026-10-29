import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:file_manager_plugin/src/navigation_breadcrumbs.dart';

void main() {
  group('NavigationBreadcrumbs', () {
    testWidgets('renders empty widget when breadcrumbs is empty', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: NavigationBreadcrumbs(breadcrumbs: [])),
        ),
      );

      expect(find.byType(NavigationBreadcrumbs), findsOneWidget);
      expect(find.byType(BreadcrumbButton), findsNothing);
    });

    testWidgets('renders single breadcrumb', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: NavigationBreadcrumbs(breadcrumbs: ['Home']),
          ),
        ),
      );

      expect(find.byType(BreadcrumbButton), findsOneWidget);
      expect(find.text('Home'), findsOneWidget);
    });

    testWidgets('renders multiple breadcrumbs', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: NavigationBreadcrumbs(
              breadcrumbs: ['/', 'Users', 'Documents', 'Files'],
            ),
          ),
        ),
      );

      expect(find.byType(BreadcrumbButton), findsNWidgets(4));
      expect(find.text('/'), findsOneWidget);
      expect(find.text('Users'), findsOneWidget);
      expect(find.text('Documents'), findsOneWidget);
      expect(find.text('Files'), findsOneWidget);
    });

    testWidgets('calls onTap with correct breadcrumbs when first item tapped', (
      WidgetTester tester,
    ) async {
      List<String>? tappedBreadcrumbs;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: NavigationBreadcrumbs(
              breadcrumbs: const ['/', 'Users', 'Documents'],
              onTap: (breadcrumbs) => tappedBreadcrumbs = breadcrumbs,
            ),
          ),
        ),
      );

      await tester.tap(find.text('/'));
      await tester.pump();

      expect(tappedBreadcrumbs, equals(['/']));
    });

    testWidgets('calls onTap with correct breadcrumbs when middle item tapped',
        (WidgetTester tester) async {
      List<String>? tappedBreadcrumbs;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: NavigationBreadcrumbs(
              breadcrumbs: const ['/', 'Users', 'Documents'],
              onTap: (breadcrumbs) => tappedBreadcrumbs = breadcrumbs,
            ),
          ),
        ),
      );

      await tester.tap(find.text('Users'));
      await tester.pump();

      expect(tappedBreadcrumbs, equals(['/', 'Users']));
    });

    testWidgets('calls onTap with correct breadcrumbs when last item tapped', (
      WidgetTester tester,
    ) async {
      List<String>? tappedBreadcrumbs;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: NavigationBreadcrumbs(
              breadcrumbs: const ['/', 'Users', 'Documents'],
              onTap: (breadcrumbs) => tappedBreadcrumbs = breadcrumbs,
            ),
          ),
        ),
      );

      await tester.tap(find.text('Documents'));
      await tester.pump();

      expect(tappedBreadcrumbs, equals(['/', 'Users', 'Documents']));
    });

    testWidgets('does not crash when onTap is null', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: NavigationBreadcrumbs(breadcrumbs: ['Home']),
          ),
        ),
      );

      await tester.tap(find.text('Home'));
      await tester.pump();

      // Should not throw
      expect(find.byType(NavigationBreadcrumbs), findsOneWidget);
    });

    testWidgets('is scrollable horizontally', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: NavigationBreadcrumbs(breadcrumbs: ['Home']),
          ),
        ),
      );

      expect(find.byType(SingleChildScrollView), findsOneWidget);
    });

    testWidgets('has horizontal padding', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: NavigationBreadcrumbs(breadcrumbs: ['Home']),
          ),
        ),
      );

      final padding = tester.widget<Padding>(find.byType(Padding).first);
      expect(
        padding.padding,
        equals(const EdgeInsets.symmetric(horizontal: 8)),
      );
    });

    testWidgets('uses Row to layout breadcrumbs', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: NavigationBreadcrumbs(breadcrumbs: ['Home', 'Documents']),
          ),
        ),
      );

      expect(find.byType(Row), findsOneWidget);
    });

    test('can be constructed with const', () {
      const breadcrumbs = NavigationBreadcrumbs(breadcrumbs: []);
      expect(breadcrumbs, isA<NavigationBreadcrumbs>());
    });

    test('can be constructed with key', () {
      const key = Key('breadcrumbs');
      const breadcrumbs = NavigationBreadcrumbs(key: key, breadcrumbs: []);
      expect(breadcrumbs.key, equals(key));
    });
  });

  group('BreadcrumbButton', () {
    testWidgets('renders breadcrumb text', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: BreadcrumbButton(breadcrumb: 'Home'),
          ),
        ),
      );

      expect(find.text('Home'), findsOneWidget);
    });

    testWidgets('calls onPressed when tapped', (WidgetTester tester) async {
      bool pressed = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: BreadcrumbButton(
              breadcrumb: 'Home',
              onPressed: () => pressed = true,
            ),
          ),
        ),
      );

      await tester.tap(find.byType(BreadcrumbButton));
      await tester.pump();

      expect(pressed, isTrue);
    });

    testWidgets('uses TextButton for rendering', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: BreadcrumbButton(breadcrumb: 'Home'),
          ),
        ),
      );

      expect(find.byType(TextButton), findsOneWidget);
    });

    testWidgets('does not crash when onPressed is null', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: BreadcrumbButton(breadcrumb: 'Home'),
          ),
        ),
      );

      await tester.tap(find.byType(BreadcrumbButton));
      await tester.pump();

      // Should not throw
      expect(find.byType(BreadcrumbButton), findsOneWidget);
    });

    test('can be constructed with const', () {
      const button = BreadcrumbButton(breadcrumb: 'Home');
      expect(button, isA<BreadcrumbButton>());
    });

    test('can be constructed with key', () {
      const key = Key('button');
      const button = BreadcrumbButton(key: key, breadcrumb: 'Home');
      expect(button.key, equals(key));
    });

    test('has isPrimary property defaulting to false', () {
      const button = BreadcrumbButton(breadcrumb: 'Home');
      expect(button.isPrimary, isFalse);
    });

    test('isPrimary can be set to true', () {
      const button = BreadcrumbButton(breadcrumb: 'Home', isPrimary: true);
      expect(button.isPrimary, isTrue);
    });

    test('stores breadcrumb property', () {
      const button = BreadcrumbButton(breadcrumb: 'TestBreadcrumb');
      expect(button.breadcrumb, equals('TestBreadcrumb'));
    });
  });

  group('BreadcrumbSeprator', () {
    testWidgets('renders chevron right icon', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: BreadcrumbSeprator()),
        ),
      );

      expect(find.byIcon(Icons.chevron_right), findsOneWidget);
    });

    testWidgets('icon has size 8', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: BreadcrumbSeprator()),
        ),
      );

      final icon = tester.widget<Icon>(find.byType(Icon));
      expect(icon.size, equals(8));
    });

    test('can be constructed with const', () {
      const separator = BreadcrumbSeprator();
      expect(separator, isA<BreadcrumbSeprator>());
    });

    test('can be constructed with key', () {
      const key = Key('separator');
      const separator = BreadcrumbSeprator(key: key);
      expect(separator.key, equals(key));
    });
  });
}
