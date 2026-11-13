import 'package:flutter/material.dart';
import 'package:tailor_shop/l10n/app_localizations.dart';
import 'package:provider/provider.dart';

import 'data/auth_service.dart';
import 'screens/login_screen.dart';
import 'screens/root_shell.dart';
import 'state/settings_provider.dart';

class TailorShopApp extends StatelessWidget {
  const TailorShopApp({super.key});

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsProvider>();
    final auth = context.watch<AuthService>();
    return MaterialApp(
      title: 'ZIZI FASHION',
      onGenerateTitle: (context) => AppLocalizations.of(context)!.appTitle,
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
      ),
      locale: settings.locale,
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      // While the app lock is active the login screen comes first.
      home: auth.locked ? const LoginScreen() : const RootShell(),
    );
  }
}
