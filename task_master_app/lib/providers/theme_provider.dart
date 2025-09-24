import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeProvider with ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.system;
  final String _themePreferenceKey = 'theme_mode';

  ThemeMode get themeMode => _themeMode;

  ThemeProvider() {
    _loadThemeFromPrefs();
  }

  void toggleTheme(bool isDarkMode) {
    _themeMode = isDarkMode ? ThemeMode.dark : ThemeMode.light;
    _saveThemeToPrefs();
    notifyListeners();
  }

  Future<void> _loadThemeFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    final theme = prefs.getString(_themePreferenceKey);
    if (theme == 'dark') {
      _themeMode = ThemeMode.dark;
    } else if (theme == 'light') {
      _themeMode = ThemeMode.light;
    } else {
      _themeMode = ThemeMode.system;
    }
    notifyListeners();
  }

  Future<void> _saveThemeToPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    if (_themeMode == ThemeMode.dark) {
      await prefs.setString(_themePreferenceKey, 'dark');
    } else if (_themeMode == ThemeMode.light) {
      await prefs.setString(_themePreferenceKey, 'light');
    } else {
      await prefs.remove(_themePreferenceKey);
    }
  }
}
