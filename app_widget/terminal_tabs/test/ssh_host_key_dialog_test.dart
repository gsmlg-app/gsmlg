import 'package:app_locale/app_locale.dart';
import 'package:duskmoon_ui/duskmoon_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:terminal_hosts/terminal_hosts.dart';
import 'package:terminal_tabs/terminal_tabs.dart';

void main() {
  for (final style in DmPlatformStyle.values) {
    for (final accept in [false, true]) {
      testWidgets('host trust decision $accept using ${style.name}', (
        tester,
      ) async {
        bool? decision;
        await tester.pumpWidget(
          DuskmoonApp(
            platformStyle: style,
            child: MaterialApp(
              locale: const Locale('en'),
              localizationsDelegates: AppLocale.localizationsDelegates,
              supportedLocales: AppLocale.supportedLocales,
              home: Builder(
                builder: (context) {
                  return Scaffold(
                    body: TextButton(
                      onPressed: () async {
                        decision = await showSshHostKeyConfirmation(
                          context,
                          const SshHostKey(
                            hostname: 'server.example',
                            port: 2222,
                            type: 'ssh-ed25519',
                            fingerprint: 'SHA256:test-fingerprint',
                          ),
                        );
                      },
                      child: const Text('Connect'),
                    ),
                  );
                },
              ),
            ),
          ),
        );
        await tester.tap(find.text('Connect'));
        await tester.pumpAndSettle();
        expect(decision, isNull);
        expect(find.textContaining('server.example:2222'), findsOneWidget);
        expect(find.textContaining('SHA256:test-fingerprint'), findsOneWidget);
        await tester.tap(find.text(accept ? 'Trust and connect' : 'Cancel'));
        await tester.pumpAndSettle();
        expect(decision, accept);
        expect(tester.takeException(), isNull);
      });
    }
  }
}
