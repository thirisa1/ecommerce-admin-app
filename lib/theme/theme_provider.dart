import 'package:flutter/material.dart';

// ─────────────────────────────────────────────
// ThemeProvider — gère le mode Light / Dark
// À enregistrer avec Provider ou utiliser
// via l'instance globale themeProvider
// ─────────────────────────────────────────────
class ThemeProvider extends ChangeNotifier {
  ThemeMode _mode = ThemeMode.light;

  ThemeMode get mode => _mode;

  bool get isDark => _mode == ThemeMode.dark;

  void toggleTheme() {
    _mode = isDark ? ThemeMode.light : ThemeMode.dark;
    notifyListeners();
  }

  void setLight() {
    _mode = ThemeMode.light;
    notifyListeners();
  }

  void setDark() {
    _mode = ThemeMode.dark;
    notifyListeners();
  }
}

// Instance globale simple (sans Provider package)
// Remplacer par Provider/Riverpod si déjà utilisé dans le projet
final themeProvider = ThemeProvider();