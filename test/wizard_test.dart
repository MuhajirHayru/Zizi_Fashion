import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:tailor_shop/l10n/app_localizations.dart';
import 'package:tailor_shop/data/auth_service.dart';
import 'package:tailor_shop/data/local_db.dart';
import 'package:tailor_shop/screens/new_order_wizard.dart';
import 'package:tailor_shop/state/settings_provider.dart';
import 'package:tailor_shop/state/shop_provider.dart';

/// Walks Customer -> Clothing -> Measurements and verifies the
/// measurement form actually renders (guards against the gray/blank
/// Measurements tab).
void main() {
  testWidgets('measurements step renders after adding a garment',
      (tester) async {
    await tester.pumpWidget(MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => SettingsProvider()),
        ChangeNotifierProvider(create: (_) => AuthService()),
        ChangeNotifierProvider(create: (_) => ShopProvider(LocalDb.instance)),
      ],
      child: MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: const NewOrderWizard(),
      ),
    ));
    await tester.pumpAndSettle();

    // Customer step.
    await tester.enterText(find.byType(TextFormField).at(0), '0912345678');
    await tester.enterText(find.byType(TextFormField).at(1), 'Abebe Kebede');
    await tester.pumpAndSettle();

    await tester.tap(find.byType(DropdownButtonFormField<String>).first);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Male').last);
    await tester.pumpAndSettle();

    await tester.tap(find.widgetWithText(FilledButton, 'Next'));
    await tester.pumpAndSettle();

    // Clothing step: pick category, then a garment.
    await tester.tap(find.text("Men's suit"));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Suit jacket'));
    await tester.pumpAndSettle();

    await tester.tap(find.widgetWithText(FilledButton, 'Next'));
    await tester.pumpAndSettle();

    // Measurements step must show the form rows (not a blank screen).
    expect(find.text('Measurements (cm)'), findsOneWidget);
    expect(find.textContaining('Jacket length'), findsOneWidget);
    expect(find.textContaining('Chest'), findsWidgets);
    expect(find.byType(TextFormField), findsAtLeastNWidgets(10));
  });
}
