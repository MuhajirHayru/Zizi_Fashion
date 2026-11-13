import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:tailor_shop/data/auth_service.dart';
import 'package:tailor_shop/data/local_db.dart';
import 'package:tailor_shop/l10n/app_localizations.dart';
import 'package:tailor_shop/screens/settings_screen.dart';
import 'package:tailor_shop/state/settings_provider.dart';
import 'package:tailor_shop/state/shop_provider.dart';

void main() {
  testWidgets('settings screen renders in English', (tester) async {
    await tester.pumpWidget(MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => SettingsProvider()),
        // Not loaded: defaults (lock off) are used while building.
        ChangeNotifierProvider(create: (_) => AuthService()),
        // The DB is only opened when loading data, never while building.
        ChangeNotifierProvider(create: (_) => ShopProvider(LocalDb.instance)),
      ],
      child: MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: const SettingsScreen(),
      ),
    ));
    await tester.pumpAndSettle();

    expect(find.text('Language'), findsOneWidget);
    expect(find.text('አማርኛ'), findsOneWidget);
  });
}
