import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeService extends ChangeNotifier {
  static const _key = 'isDarkMode';
  static final ThemeService _instance = ThemeService._();

  factory ThemeService() => _instance;
  static ThemeService get instance => _instance;

  ThemeService._();

  bool _isDark = false;

  bool get isDark => false;
  ThemeMode get themeMode => ThemeMode.light;

  Future<void> init() async {
    _isDark = false;
    notifyListeners();
  }

  Future<void> toggleTheme() async {
    _isDark = !_isDark;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_key, _isDark);
    notifyListeners();
  }

  Future<void> setDark(bool value) async {
    if (_isDark == value) return;
    _isDark = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_key, _isDark);
    notifyListeners();
  }
}
