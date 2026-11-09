import 'package:app_adaptive_widgets/app_adaptive_widgets.dart';
import 'package:app_duckdb/app_duckdb.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('LogCardTile', () {
    testWidgets('renders log item fields and responds to tap', (tester) async {
      bool tapped = false;
      final item = LogRecordItem(
        id: '1',
        timestamp: DateTime(2026, 11, 9, 12, 0, 0),
        logType: 'api',
        level: LogLevel.info,
        message: 'A google.com. => 142.250.190.46',
        clientAddress: '192.168.1.100',
        status: 'NoError',
        latencyMs: 15,
        rawFields: const {},
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: LogCardTile(
              item: item,
              showTypeBadge: true,
              onTap: () => tapped = true,
            ),
          ),
        ),
      );

      expect(find.text('API'), findsOneWidget);
      expect(find.text('A google.com. => 142.250.190.46'), findsOneWidget);
      expect(find.text('192.168.1.100'), findsOneWidget);
      expect(find.text('NoError'), findsOneWidget);
      expect(find.text('15ms'), findsOneWidget);

      await tester.tap(find.byType(LogCardTile));
      expect(tapped, isTrue);
    });
  });

  group('LogPaginationBar', () {
    testWidgets('renders pagination counts and responds to page change',
        (tester) async {
      int? changedPage;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: LogPaginationBar(
              currentPage: 1,
              totalPages: 5,
              totalCount: 250,
              onPageChanged: (p) => changedPage = p,
            ),
          ),
        ),
      );

      expect(find.text('250 records'), findsOneWidget);
      expect(find.text('Page 2 of 5'), findsOneWidget);

      // Tap next page
      await tester.tap(find.byTooltip('Next page'));
      expect(changedPage, equals(2));

      // Tap previous page
      await tester.tap(find.byTooltip('Previous page'));
      expect(changedPage, equals(0));
    });
  });

  group('LogFilterBar', () {
    testWidgets('renders search and clear triggers', (tester) async {
      bool cleared = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: LogFilterBar(
              initialKeyword: 'initial',
              onKeywordChanged: (_) {},
              onTimeRangeChanged: (_) {},
              onLevelChanged: (_) {},
              onClearFilters: () => cleared = true,
            ),
          ),
        ),
      );

      expect(find.text('initial'), findsOneWidget);
      expect(find.text('Reset'), findsOneWidget);

      await tester.tap(find.text('Reset'));
      expect(cleared, isTrue);
    });
  });
}
