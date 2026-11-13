import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'app.dart';
import 'data/app_storage.dart';
import 'data/auth_service.dart';
import 'data/local_db.dart';
import 'state/settings_provider.dart';
import 'state/shop_provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Ask for "All files access" first so the database lives in the public,
  // permanent ZIZI_FASHION folder (survives uninstall; visible in the
  // file manager). Falls back to private storage if declined.
  await AppStorage.ensurePermissions();
  final settings = SettingsProvider();
  await settings.load();
  final auth = AuthService();
  await auth.load();
  final shop = ShopProvider(LocalDb.instance);
  await shop.loadAll();
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: settings),
        ChangeNotifierProvider.value(value: auth),
        ChangeNotifierProvider.value(value: shop),
      ],
      child: const TailorShopApp(),
    ),
  );
}
