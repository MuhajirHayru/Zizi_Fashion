import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

/// ZIZU FASHION permanent storage.
///
/// On Android the shop data lives in the public folder
/// `/storage/emulated/0/ZIZU_FASHION` — visible in any file manager and
/// **not** deleted when the app is uninstalled or its data is cleared.
/// It is granted through Android's "All files access" special permission
/// (requested on first launch). If the user declines, the app falls back
/// to its private documents folder so nothing ever blocks startup.
class AppStorage {
  AppStorage._();
  static Directory? _base;
  static bool usingPublicStorage = false;

  /// Called once at startup before anything touches the disk.
  static Future<void> ensurePermissions() async {
    if (!Platform.isAndroid) return;
    try {
      await [
        Permission.storage,
        Permission.manageExternalStorage,
      ].request();
    } catch (_) {
      // Permission UI unavailable — fall back to private storage below.
    }
  }

  static Future<Directory> base() async {
    if (_base != null) return _base!;
    if (Platform.isAndroid) {
      final manage = await Permission.manageExternalStorage.isGranted;
      final legacy = await Permission.storage.isGranted;
      if (manage || legacy) {
        try {
          final dir = Directory('/storage/emulated/0/ZIZU_FASHION');
          if (!await dir.exists()) {
            await dir.create(recursive: true);
          }
          usingPublicStorage = true;
          _base = dir;
          return dir;
        } catch (_) {
          // Public folder not writable (rare) — fall through to private.
        }
      }
    }
    final docs = await getApplicationDocumentsDirectory();
    _base = docs;
    return docs;
  }

  static Future<Directory> fabricsDir() async {
    final root = await base();
    final dir = Directory(p.join(root.path, 'fabrics'));
    if (!await dir.exists()) await dir.create(recursive: true);
    return dir;
  }

  static Future<Directory> designsDir() async {
    final root = await base();
    final dir = Directory(p.join(root.path, 'designs'));
    if (!await dir.exists()) await dir.create(recursive: true);
    return dir;
  }

  static Future<String> databasePath() async {
    final root = await base();
    return p.join(root.path, 'zizi_fashion.db');
  }

  /// Previous storage locations whose database should be carried over to
  /// the permanent folder (private app storage and the old ZIZI_ folder).
  static Future<List<String>> legacyDatabasePaths() async {
    final paths = <String>[];
    try {
      final docs = await getApplicationDocumentsDirectory();
      paths.add(p.join(docs.path, 'zizi_fashion.db'));
    } catch (_) {}
    paths.add('/storage/emulated/0/ZIZI_FASHION/zizi_fashion.db');
    return paths;
  }
}
