
import 'package:flutter/material.dart';

enum SettingsCategory {
  general,
  audio,
  backup,
  troubleshooter,
  about,
}
class SettingsModels extends ChangeNotifier {
  SettingsCategory _selectedCategory = SettingsCategory.general;
  SettingsCategory get selectedCategory => _selectedCategory;

  void setSettingCategory(SettingsCategory category) {
    _selectedCategory = category;
    notifyListeners();
  }

  ThemeMode _themeMode = ThemeMode.dark;
  ThemeMode get themeMode => _themeMode;

  void toogleTheme(bool isDark) {
    _themeMode = isDark ? ThemeMode.light : ThemeMode.dark;
    notifyListeners();
  }
}
