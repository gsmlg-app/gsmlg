import 'package:app_database/app_database.dart';
import 'package:app_provider/app_provider.dart';
import 'package:app_secure_storage/app_secure_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:navigation_bloc/navigation_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  testWidgets(
    'one navigation bloc preserves preferences across pushed routes',
    (tester) async {
      SharedPreferences.setMockInitialValues({});
      final preferences = await SharedPreferences.getInstance();
      final database = AppDatabase.forTesting();
      addTearDown(database.close);
      late NavigationBloc firstRouteBloc;
      NavigationBloc? secondRouteBloc;

      await tester.pumpWidget(
        MainProvider(
          sharedPrefs: preferences,
          database: database,
          vault: _UnusedVault(),
          child: MaterialApp(
            home: Builder(
              builder: (context) {
                firstRouteBloc = context.read<NavigationBloc>();
                return Scaffold(
                  body: TextButton(
                    onPressed: () => Navigator.of(context).push<void>(
                      MaterialPageRoute(
                        builder: (context) {
                          secondRouteBloc = context.read<NavigationBloc>();
                          return Scaffold(
                            appBar: AppBar(title: const Text('Second route')),
                          );
                        },
                      ),
                    ),
                    child: const Text('Open next route'),
                  ),
                );
              },
            ),
          ),
        ),
      );

      expect(find.byType(BlocProvider<NavigationBloc>), findsOneWidget);
      firstRouteBloc
        ..add(const NavigationVisibilityChanged(false))
        ..add(const NavigationRailExtendedChanged(false));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Open next route'));
      await tester.pumpAndSettle();

      expect(secondRouteBloc, same(firstRouteBloc));
      expect(
        secondRouteBloc!.state,
        const NavigationState(navigationVisible: false, isExtended: false),
      );
      expect(firstRouteBloc.isClosed, isFalse);

      await tester.pageBack();
      await tester.pumpAndSettle();
      expect(firstRouteBloc.state.navigationVisible, isFalse);
      expect(firstRouteBloc.state.isExtended, isFalse);

      await tester.pumpWidget(const SizedBox.shrink());
      expect(firstRouteBloc.isClosed, isTrue);
    },
  );
}

class _UnusedVault implements VaultRepository {
  @override
  dynamic noSuchMethod(Invocation invocation) =>
      throw StateError('Navigation must not access secure storage');
}
