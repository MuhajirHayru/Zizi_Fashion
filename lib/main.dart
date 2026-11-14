import 'dart:io';

import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'app.dart';
import 'data/app_storage.dart';
import 'data/auth_service.dart';
import 'data/local_db.dart';
import 'state/settings_provider.dart';
import 'state/shop_provider.dart';
import 'util/zizi_colors.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Log uncaught errors to the permanent storage folder so crashes can be
  // diagnosed from the file manager.
  FlutterError.onError = (details) {
    _logCrash(details.exceptionAsString(), details.stack?.toString() ?? '');
    FlutterError.presentError(details);
  };
  PlatformDispatcher.instance.onError = (error, stack) {
    _logCrash(error.toString(), stack.toString());
    return true;
  };

  final settings = SettingsProvider();
  final auth = AuthService();
  final shop = ShopProvider(LocalDb.instance);

  // Render the branded splash IMMEDIATELY - never a black screen - then
  // run startup (permissions, database, data load) in the background.
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: settings),
        ChangeNotifierProvider.value(value: auth),
        ChangeNotifierProvider.value(value: shop),
      ],
      child: AppRoot(
        settings: settings,
        auth: auth,
        shop: shop,
      ),
    ),
  );
}

Future<void> _logCrash(String message, String stack) async {
  try {
    final dir = await AppStorage.base();
    final file = File(
        '${dir.path}${Platform.pathSeparator}crash_log.txt');
    await file.writeAsString(
      '${DateTime.now().toIso8601String()}\n$message\n$stack\n\n',
      mode: FileMode.append,
      flush: true,
    );
  } catch (_) {
    // Never crash while logging.
  }
}

/// Shows the brand splash until startup finished, then the real app.
class AppRoot extends StatelessWidget {
  const AppRoot({super.key, 
    required this.settings,
    required this.auth,
    required this.shop,
  });

  final SettingsProvider settings;
  final AuthService auth;
  final ShopProvider shop;

  @override
  Widget build(BuildContext context) {
    // Watch (not just read) so this widget rebuilds when loading finishes.
    final ready = context.watch<SettingsProvider>().loaded &&
        context.watch<AuthService>().loaded &&
        context.watch<ShopProvider>().loaded;
    if (!ready) {
      return const MaterialApp(
        debugShowCheckedModeBanner: false,
        home: _SplashScreen(),
      );
    }
    return const TailorShopApp();
  }
}

class _SplashScreen extends StatefulWidget {
  const _SplashScreen();

  @override
  State<_SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<_SplashScreen> {
  bool _started = false;

  @override
  void initState() {
    super.initState();
    // Kick off startup after the first frame is on screen.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_started) return;
      _started = true;
      _startup();
    });
  }

  Future<void> _startup() async {
    final settings = context.read<SettingsProvider>();
    final auth = context.read<AuthService>();
    final shop = context.read<ShopProvider>();

    // Permissions must NEVER block startup: request in the background with
    // a timeout; if the user grants later, data migrates on next launch.
    unawaited(AppStorage.ensurePermissions()
        .timeout(const Duration(seconds: 10), onTimeout: () {}));

    try {
      await settings.load().timeout(const Duration(seconds: 15));
      await auth.load().timeout(const Duration(seconds: 15));
      await shop.loadAll().timeout(const Duration(seconds: 30));
    } catch (e) {
      _logCrash('startup: $e', '');
      // Force the app open even if a step failed or timed out - the
      // providers notify and the UI shows whatever loaded.
      settings.markLoaded();
      auth.markLoaded();
      shop.markLoaded();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: ZiziColors.purpleDark,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.checkroom, color: ZiziColors.gold, size: 44),
            const SizedBox(height: 8),
            const Text(
              'ZIZU FASHION',
              style: TextStyle(
                color: ZiziColors.gold,
                fontSize: 26,
                fontWeight: FontWeight.w800,
                letterSpacing: 2,
              ),
            ),
            const SizedBox(height: 24),
            const CircularProgressIndicator(color: ZiziColors.gold),
          ],
        ),
      ),
    );
  }
}
