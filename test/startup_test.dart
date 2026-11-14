import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:tailor_shop/data/auth_service.dart';
import 'package:tailor_shop/data/local_db.dart';
import 'package:tailor_shop/main.dart';
import 'package:tailor_shop/state/settings_provider.dart';
import 'package:tailor_shop/state/shop_provider.dart';

/// The exact startup bug from v4.0.1: the splash gate read the provider
/// flags WITHOUT listening, so the app never left the splash screen
/// ("rotating without opening"). This test fails on that code and passes
/// once the gate watches the providers.
void main() {
  testWidgets('splash gives way to the real app when loading finishes',
      (tester) async {
    final settings = SettingsProvider();
    final auth = AuthService();
    final shop = ShopProvider(LocalDb.instance);

    await tester.pumpWidget(MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: settings),
        ChangeNotifierProvider.value(value: auth),
        ChangeNotifierProvider.value(value: shop),
      ],
      child: AppRoot(settings: settings, auth: auth, shop: shop),
    ));
    await tester.pump();

    // Splash phase: brand visible, real app (with tagline) not yet.
    expect(find.text('Tailor Management System'), findsNothing);

    // Startup finishes -> providers notify -> the gate must rebuild.
    settings.loaded = true;
    settings.notifyListeners();
    auth.loaded = true;
    auth.notifyListeners();
    shop.loaded = true;
    shop.notifyListeners();
    // Advance the fake clock past the startup timeout timers, then settle.
    await tester.pump(const Duration(seconds: 31));
    await tester.pump(const Duration(seconds: 1));
    await tester.pump(const Duration(seconds: 1));

    // Real app is now visible (home dashboard hero + tagline).
    expect(find.text('Tailor Management System'), findsOneWidget);
    expect(find.text('ZIZU FASHION'), findsOneWidget);
  });
}
