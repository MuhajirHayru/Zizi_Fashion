import 'package:flutter/material.dart';
import 'package:tailor_shop/l10n/app_localizations.dart';
import 'package:provider/provider.dart';

import 'data/auth_service.dart';
import 'screens/login_screen.dart';
import 'screens/root_shell.dart';
import 'state/settings_provider.dart';
import 'util/zizi_colors.dart';

class TailorShopApp extends StatelessWidget {
  const TailorShopApp({super.key});

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsProvider>();
    final auth = context.watch<AuthService>();
    return MaterialApp(
      title: 'ZIZU FASHION',
      onGenerateTitle: (context) => AppLocalizations.of(context)!.appTitle,
      debugShowCheckedModeBanner: false,
      // Purple + gold fashion palette from the approved ZIZI FASHION mockup.
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: ZiziColors.purple,
          primary: ZiziColors.purple,
          secondary: ZiziColors.gold,
          surface: Colors.white,
        ),
        scaffoldBackgroundColor: ZiziColors.background,
        appBarTheme: const AppBarTheme(
          backgroundColor: ZiziColors.purple,
          foregroundColor: Colors.white,
          elevation: 0,
        ),
        cardTheme: CardThemeData(
          elevation: 0,
          color: Colors.white,
          surfaceTintColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
            side: const BorderSide(color: ZiziColors.cardBorder),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: ZiziColors.cardBorder),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: ZiziColors.cardBorder),
          ),
        ),
        filledButtonTheme: FilledButtonThemeData(
          style: FilledButton.styleFrom(
            backgroundColor: ZiziColors.purple,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
        floatingActionButtonTheme: const FloatingActionButtonThemeData(
          backgroundColor: ZiziColors.purple,
          foregroundColor: Colors.white,
        ),
        navigationBarTheme: const NavigationBarThemeData(
          backgroundColor: Colors.white,
          indicatorColor: Color(0xFFE7DBF5),
        ),
        chipTheme: ChipThemeData(
          backgroundColor: Colors.white,
          selectedColor: ZiziColors.purple,
          checkmarkColor: Colors.white,
          labelStyle: const TextStyle(color: ZiziColors.ink),
          secondaryLabelStyle: const TextStyle(color: Colors.white),
          side: const BorderSide(color: ZiziColors.cardBorder),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(999),
          ),
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
