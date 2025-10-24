import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'settings_service.dart';
import '../main.dart';

// Settings service provider
final settingsServiceProvider = Provider((ref) {
  return SettingsService(ref.read(cacheProvider));
});

// Font size provider
final fontSizeProvider = StateProvider<int>((ref) {
  return ref.read(settingsServiceProvider).getFontSize();
});

// Theme mode provider
final themeModeProvider = StateProvider<ThemeMode>((ref) {
  return ref.read(settingsServiceProvider).getThemeMode();
});

// Notifications enabled provider
final notificationsEnabledProvider = StateProvider<bool>((ref) {
  return ref.read(settingsServiceProvider).getNotificationsEnabled();
});

// Line height provider
final lineHeightProvider = StateProvider<double>((ref) {
  return ref.read(settingsServiceProvider).getLineHeight();
});

// Developer mode provider
final developerModeProvider = StateProvider<bool>((ref) {
  return ref.read(settingsServiceProvider).getDeveloperMode();
});
