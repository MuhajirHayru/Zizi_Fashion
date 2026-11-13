import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// App settings that persist on the phone. Currently just the UI language.
class SettingsProvider extends ChangeNotifier {
  SettingsProvider({this.locale = const Locale('en')});

  bool loaded = false;

  Locale locale;

  SharedPreferences? _prefs;

  Future<void> load() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _prefs = prefs;
      final code = prefs.getString('locale');
      if (code != null && (code == 'en' || code == 'am')) {
        locale = Locale(code);
      }
    } catch (_) {
      // Plugin unavailable (tests) or read failure - defaults are used.
    }
    loaded = true;
    notifyListeners();
  }

  void markLoaded() {
    loaded = true;
    notifyListeners();
  }

  Future<void> setLocale(Locale value) async {
    locale = value;
    notifyListeners();
    await _prefs?.setString('locale', value.languageCode);
  }
}
