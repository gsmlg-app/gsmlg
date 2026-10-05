import 'package:accounts_bloc/accounts_bloc.dart';
import 'package:app_database/app_database.dart';
import 'package:app_locale/app_locale.dart';
import 'package:duskmoon_settings/duskmoon_settings.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gsmlg/screens/settings/account_screen.dart';

void main() {
  late _AccountsBloc accountsBloc;

  setUp(() {
    accountsBloc = _AccountsBloc();
  });

  tearDown(() async {
    await accountsBloc.close();
  });

  testWidgets('adds a Backplane access token through the account dialog', (
    tester,
  ) async {
    await tester.pumpWidget(
      BlocProvider<AccountsBloc>.value(
        value: accountsBloc,
        child: MaterialApp(
          localizationsDelegates: AppLocale.localizationsDelegates,
          supportedLocales: AppLocale.supportedLocales,
          home: const AccountScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.scrollUntilVisible(
      find.text('Backplane'),
      200,
      scrollable: find
          .descendant(
            of: find.byType(SettingsList),
            matching: find.byType(Scrollable),
          )
          .first,
    );
    await tester.pumpAndSettle();
    expect(find.text('Backplane'), findsOneWidget);
    final addAccount = find.text('Add Backplane Account');
    await tester.ensureVisible(addAccount);
    await tester.tap(addAccount);
    await tester.pumpAndSettle();

    final fields = tester
        .widgetList<TextField>(find.byType(TextField))
        .toList();
    expect(fields.last.decoration?.labelText, 'Access Token');
    expect(fields.last.decoration?.hintText, 'Enter your Backplane API token');
    expect(fields.last.obscureText, isTrue);

    await tester.enterText(find.byType(TextField).at(0), 'Work');
    await tester.enterText(find.byType(TextField).at(1), 'Backplane account');
    await tester.enterText(find.byType(TextField).at(2), 'secret-token');
    await tester.tap(find.widgetWithText(FilledButton, 'Add'));
    await tester.pumpAndSettle();

    expect(accountsBloc.events, hasLength(1));
    final event = accountsBloc.events.single as AccountsAdd;
    expect(event.provider, ServiceProvider.backplane);
    expect(event.name, 'Work');
    expect(event.apiKey, 'secret-token');
  });
}

class _AccountsBloc extends Bloc<AccountsEvent, AccountsState>
    implements AccountsBloc {
  _AccountsBloc() : super(const AccountsLoaded(accounts: [])) {
    on<AccountsEvent>((event, emit) => events.add(event));
  }

  final List<AccountsEvent> events = [];

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}
