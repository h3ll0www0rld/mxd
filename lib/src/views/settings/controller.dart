import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsController with ChangeNotifier {
  SettingsController() {
    loadSettings();
  }

  late ThemeMode _themeMode;

  ThemeMode get themeMode => _themeMode;

  Future<void> loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    String? theme = prefs.getString('themeMode');
    _themeMode = ThemeMode.values.firstWhere(
        (e) => e.toString() == 'ThemeMode.$theme',
        orElse: () => ThemeMode.system);
    notifyListeners();
  }

  Future<void> updateThemeMode(ThemeMode? newThemeMode) async {
    if (newThemeMode == null || newThemeMode == _themeMode) return;

    _themeMode = newThemeMode;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('themeMode', newThemeMode.toString().split('.').last);

    notifyListeners();
  }
}
