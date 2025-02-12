import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ThemeNotifier extends StateNotifier<ThemeMode> {
  ThemeNotifier() : super(WidgetsBinding.instance.window.platformBrightness == Brightness.dark 
          ? ThemeMode.dark 
          : ThemeMode.light);

  void toggleTheme(bool isDarkMode) {
    state = isDarkMode ? ThemeMode.dark : ThemeMode.light;
  }
}

final themeNotifierProvider = StateNotifierProvider<ThemeNotifier, ThemeMode>(
  (ref) => ThemeNotifier(),
);