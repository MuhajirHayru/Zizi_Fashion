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
      // Fashion-inspired palette: deep espresso + gold accents on warm
      // cream surfaces (matching the ZIZU FASHION brand).
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF2E2A24),
          primary: const Color(0xFF26221C),
          secondary: const Color(0xFFB08D3E),
          surface: Colors.white,
        ),
        scaffoldBackgroundColor: const Color(0xFFF7F2EA),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF26221C),
          foregroundColor: Color(0xFFE9DCC6),
          elevation: 0,
        ),
        cardTheme: CardThemeData(
          elevation: 0,
          color: Colors.white,
          surfaceTintColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
            side: const BorderSide(color: Color(0xFFE8DFD0)),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFFDDD3C4)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFFDDD3C4)),
          ),
        ),
        filledButtonTheme: FilledButtonThemeData(
          style: FilledButton.styleFrom(
            backgroundColor: const Color(0xFF26221C),
            foregroundColor: const Color(0xFFE9DCC6),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
        floatingActionButtonTheme: const FloatingActionButtonThemeData(
          backgroundColor: Color(0xFF26221C),
          foregroundColor: Color(0xFFE9DCC6),
        ),
        navigationBarTheme: const NavigationBarThemeData(
          backgroundColor: Colors.white,
          indicatorColor: Color(0xFFE9DCC6),
        ),
      ),
      locale: settings.locale,
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      // While the app lock is active the login screen comes first.
      home: auth.locked ? const LoginScreen() : const RootShell(),
    );
  }
}
