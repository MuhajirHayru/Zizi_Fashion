import 'dart:convert';
import 'dart:math';

import 'package:crypto/crypto.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Local app lock: a username + password created by the shop owner.
/// Everything stays on this phone; the password itself is never stored -
/// only a random salt and its salted SHA-256 hash.
class AuthService extends ChangeNotifier {
  static const _kEnabled = 'auth_enabled';
  static const _kUsername = 'auth_username';
  static const _kHash = 'auth_password_hash';
  static const _kSalt = 'auth_password_salt';

  bool _enabled = false;
  bool loaded = false;
  String? _username;
  String? _hash;
  String? _salt;
  bool _unlocked = false;

  bool get enabled => _enabled;

  /// Username of the current credentials (null until the lock is set up).
  String? get username => _username;

  bool get isSetUp => _username != null && _hash != null && _salt != null;

  /// The app must show the login screen while this is true.
  bool get locked => _enabled && isSetUp && !_unlocked;

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    _enabled = prefs.getBool(_kEnabled) ?? false;
    _username = prefs.getString(_kUsername);
    _hash = prefs.getString(_kHash);
    _salt = prefs.getString(_kSalt);
    loaded = true;
    notifyListeners();
  }

  String _digest(String password, String salt) =>
      sha256.convert(utf8.encode('$salt::$password')).toString();

  /// Returns true and unlocks the app when username + password are correct.
  Future<bool> verify(String username, String password) async {
    if (!isSetUp) return false;
    final matches =
        username.trim().toLowerCase() == _username!.toLowerCase() &&
            _digest(password, _salt!) == _hash;
    if (matches) {
      _unlocked = true;
      notifyListeners();
    }
    return matches;
  }

  /// Creates (or replaces) the credentials and turns the lock on.
  /// The caller stays unlocked for the current session; the lock applies
  /// from the next app start.
  Future<void> setUp(String username, String password) async {
    final prefs = await SharedPreferences.getInstance();
    final random = Random.secure();
    final salt =
        base64UrlEncode(List<int>.generate(16, (_) => random.nextInt(256)));
    _username = username.trim();
    _salt = salt;
    _hash = _digest(password, salt);
    _enabled = true;
    _unlocked = true;
    await prefs.setString(_kUsername, _username!);
    await prefs.setString(_kSalt, salt);
    await prefs.setString(_kHash, _hash!);
    await prefs.setBool(_kEnabled, true);
    notifyListeners();
  }

  /// Toggles enforcement. Needs existing credentials to switch on.
  Future<void> setEnabled(bool value) async {
    if (!isSetUp && value) return;
    _enabled = value;
    if (!value) _unlocked = false;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_kEnabled, value);
  }
}
