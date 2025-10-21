import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

class SettingsService {
  final Box _box;

  SettingsService(this._box);

  // Font size (0 = small, 1 = medium, 2 = large)
  int getFontSize() {
    return _box.get('font_size', defaultValue: 1);
  }

  Future<void> setFontSize(int size) async {
    await _box.put('font_size', size);
  }

  double getFontSizeValue() {
    final size = getFontSize();
    switch (size) {
      case 0:
        return 14.0; // Small
      case 2:
        return 18.0; // Large
      default:
        return 16.0; // Medium
    }
  }

  // Theme mode
  ThemeMode getThemeMode() {
    final mode = _box.get('theme_mode', defaultValue: 'system');
    switch (mode) {
      case 'light':
        return ThemeMode.light;
      case 'dark':
        return ThemeMode.dark;
      default:
        return ThemeMode.system;
    }
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    String value;
    switch (mode) {
      case ThemeMode.light:
        value = 'light';
        break;
      case ThemeMode.dark:
        value = 'dark';
        break;
      default:
        value = 'system';
    }
    await _box.put('theme_mode', value);
  }

  // Notifications enabled
  bool getNotificationsEnabled() {
    return _box.get('notifications_enabled', defaultValue: true);
  }

  Future<void> setNotificationsEnabled(bool enabled) async {
    await _box.put('notifications_enabled', enabled);
  }

  // Line height
  double getLineHeight() {
    return _box.get('line_height', defaultValue: 1.8);
  }

  Future<void> setLineHeight(double height) async {
    await _box.put('line_height', height);
  }
}
