import 'package:flutter/material.dart';

/// Design Tokens — "Chupaca Directo"
/// Paleta Eco-Sostenible & Alto Contraste para accesibilidad rural
class AppColors {
  AppColors._();

  // ── Primary — Deep Forest Green ──────────────────────────
  static const Color primary = Color(0xFF1B5E20);
  static const Color primaryLight = Color(0xFF4CAF50);
  static const Color primaryDark = Color(0xFF0A3D0D);
  static const Color primaryContainer = Color(0xFFE8F5E9);
  static const Color onPrimary = Color(0xFFFFFFFF);
  static const Color onPrimaryContainer = Color(0xFF1B5E20);

  // ── Secondary — Warm Terracotta ──────────────────────────
  static const Color secondary = Color(0xFFBF5B34);
  static const Color secondaryLight = Color(0xFFE8A838);
  static const Color secondaryDark = Color(0xFF8B3A1F);
  static const Color secondaryContainer = Color(0xFFFBE9E7);
  static const Color onSecondary = Color(0xFFFFFFFF);

  // ── Neutrals ─────────────────────────────────────────────
  static const Color neutralDark = Color(0xFF1E1E1E);
  static const Color neutralMedium = Color(0xFF5C5C5C);
  static const Color neutralLight = Color(0xFFFAFAF5);
  static const Color neutralBorder = Color(0xFFE0E0D8);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color background = Color(0xFFFAFAF5);

  // ── Semantic ──────────────────────────────────────────────
  static const Color error = Color(0xFFC62828);
  static const Color errorLight = Color(0xFFFFEBEE);
  static const Color success = Color(0xFF2E7D32);
  static const Color successLight = Color(0xFFE8F5E9);
  static const Color warning = Color(0xFFFF8F00);
  static const Color warningLight = Color(0xFFFFF8E1);
  static const Color info = Color(0xFF0288D1);
  static const Color infoLight = Color(0xFFE1F5FE);

  // ── Stock indicators ──────────────────────────────────────
  static const Color stockHigh = Color(0xFF4CAF50);   // > 100 kg
  static const Color stockMedium = Color(0xFFFF8F00); // 20–100 kg
  static const Color stockLow = Color(0xFFC62828);    // < 20 kg

  // ── Dark theme (Admin Dashboard) ─────────────────────────
  static const Color darkBackground = Color(0xFF121212);
  static const Color darkSurface = Color(0xFF1E1E1E);
  static const Color darkSurfaceVariant = Color(0xFF2C2C2C);
  static const Color darkBorder = Color(0xFF3A3A3A);
  static const Color darkText = Color(0xFFE0E0E0);
  static const Color darkTextMuted = Color(0xFF9E9E9E);

  // ── Chart colors ─────────────────────────────────────────
  static const List<Color> chartPalette = [
    Color(0xFF4CAF50),
    Color(0xFFE8A838),
    Color(0xFF0288D1),
    Color(0xFFBF5B34),
    Color(0xFF7B1FA2),
    Color(0xFF00838F),
  ];

  // ── Gradient ─────────────────────────────────────────────
  static const LinearGradient heroGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0x991B5E20), Color(0xCC0A2E10)],
  );

  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF1B5E20), Color(0xFF4CAF50)],
  );

  static const LinearGradient cardGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFFFFFFF), Color(0xFFF5FBF5)],
  );
}
