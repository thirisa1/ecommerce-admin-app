import 'package:flutter/material.dart';
import 'theme_provider.dart';

// ─────────────────────────────────────────────
// AppColors — palette MTS Médico-Dentaire
//
// STRATÉGIE : les propriétés dynamiques (fond,
// texte, ombres) sont des GETTERS qui lisent
// themeProvider.isDark → une seule instance,
// pas besoin de context, tous les fichiers
// existants fonctionnent sans modification.
// ─────────────────────────────────────────────
class AppColors {
  AppColors._();

  // ── Couleurs marque (fixes) ──
  static const Color primary = Color(0xFF1A3A8F);
  static const Color accent = Color(0xFF29ABE2);
  static const Color green = Color(0xFF39B54A);
  static const Color primaryLight = Color(0x1A1A3A8F);
  static const Color accentLight = Color(0x1A29ABE2);
  static const Color textOnDark = Colors.white;

  // ── Dégradés (fixes) ──
  static const LinearGradient appBarGradient = LinearGradient(
    colors: [Color(0xFF1A3A8F), Color(0xFF1557B0)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  static const LinearGradient fabGradient = LinearGradient(
    colors: [Color(0xFF29ABE2), Color(0xFF1A3A8F)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  static const LinearGradient cardAccent = LinearGradient(
    colors: [Color(0xFF1A3A8F), Color(0xFF29ABE2)],
    begin: Alignment.topLeft,
    end: Alignment.centerRight,
  );

  // ── Statuts (fixes) ──
  static const Color statusEnAttente = Color(0xFFFFF3E0);
  static const Color statusEnAttenteText = Color(0xFFE65100);
  static const Color statusValidee = Color(0xFF39B54A);
  static const Color statusEnCours = Color(0xFF29ABE2);
  static const Color statusLivree = Color(0xFF1A3A8F);

  // ── Couleurs dynamiques (GETTERS) ──
  // Tous les widgets existants appellent AppColors.background etc.
  // Ces getters retournent la bonne valeur selon le thème actif.

  static Color get background =>
      themeProvider.isDark ? const Color(0xFF0D1117) : const Color(0xFFF0F4FF);

  static Color get surface =>
      themeProvider.isDark ? const Color(0xFF161B27) : Colors.white;

  static Color get surfaceAlt =>
      themeProvider.isDark ? const Color(0xFF1E2535) : const Color(0xFFF8FAFF);

  static Color get textPrimary =>
      themeProvider.isDark ? const Color(0xFFE8EEF8) : const Color(0xFF0D1B4B);

  static Color get textSecondary =>
      themeProvider.isDark ? const Color(0xFF8A9BC0) : const Color(0xFF5A6A8A);

  static Color get textHint =>
      themeProvider.isDark ? const Color(0xFF4A5A7A) : const Color(0xFFB0BED9);

  static Color get textMuted =>
      themeProvider.isDark ? const Color(0xFF5A6A8A) : const Color(0xFF9AAAC4);

  static Color get shadow =>
      themeProvider.isDark ? const Color(0x40000000) : const Color(0x141A3A8F);

  static Color get shadowDeep =>
      themeProvider.isDark ? const Color(0x60000000) : const Color(0x281A3A8F);

  // ── Alias pour main.dart ──
  //static Color get _lightBg => const Color(0xFFF0F4FF);
  //static Color get _darkBg  => const Color(0xFF0D1117);
}

// Alias utilisés dans main.dart uniquement
class LightColors {
  static const Color background = Color(0xFFF0F4FF);
}

class DarkColors {
  static const Color background = Color(0xFF0D1117);
}
