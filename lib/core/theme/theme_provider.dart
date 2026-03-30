import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_acrylic/flutter_acrylic.dart';
import 'package:shared_preferences/shared_preferences.dart';

const String _themeModeKey = 'app_theme_mode';

final themeModeProvider = StateNotifierProvider<ThemeModeNotifier, ThemeMode>(
  (ref) => ThemeModeNotifier(),
);

class ThemeModeNotifier extends StateNotifier<ThemeMode> {
  ThemeModeNotifier() : super(ThemeMode.system) {
    _loadThemeMode();
  }

  Future<void> _loadThemeMode() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedTheme = prefs.getString(_themeModeKey);
      if (savedTheme != null) {
        state = savedTheme == 'dark' ? ThemeMode.dark : ThemeMode.light;
      }
    } catch (e) {
      // If loading fails, use system default
    }
  }

  Future<void> toggleTheme() async {
    final newThemeMode = state == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
    state = newThemeMode;
    
    // Save to SharedPreferences
    await _saveThemeMode(newThemeMode);
    
    // Apply window effect based on theme
    await _applyWindowEffect(newThemeMode);
  }

  Future<void> setThemeMode(ThemeMode themeMode) async {
    state = themeMode;
    
    // Save to SharedPreferences
    await _saveThemeMode(themeMode);
    
    // Apply window effect based on theme
    await _applyWindowEffect(themeMode);
  }

  Future<void> _saveThemeMode(ThemeMode themeMode) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(
        _themeModeKey,
        themeMode == ThemeMode.dark ? 'dark' : 'light',
      );
    } catch (e) {
      // If saving fails, theme will reset on next app start
    }
  }

  Future<void> _applyWindowEffect(ThemeMode themeMode) async {
    try {
      if (themeMode == ThemeMode.dark) {
        // Apply Mica effect for dark mode
        await Window.setEffect(
          effect: WindowEffect.mica,
          dark: true,
        );
      } else {
        // Apply light effect for light mode
        await Window.setEffect(
          effect: WindowEffect.acrylic,
          dark: false,
        );
      }
    } catch (e) {
      // If acrylic effects are not supported, fall back to solid color
      // This is fine for older Windows versions
    }
  }
}