import 'package:flutter/material.dart';

class AppColors {
  static const Color primaryDark = Color(0xFF1B5E20);    // Deep Forest Green
  static const Color primaryLight = Color(0xFF4CAF50);   // Leaf Green
  static const Color secondary = Color(0xFFBF5B34);      // Warm Terracotta
  static const Color secondaryLight = Color(0xFFE8A838); // Ochre Gold
  static const Color neutralDark = Color(0xFF1E1E1E);    // Charcoal
  static const Color neutralLight = Color(0xFFFAFAF5);   // Warm Cream
  static const Color surfaceCard = Color(0xFFFFFFFF);    // Card Surface
  static const Color error = Color(0xFFC62828);
  static const Color info = Color(0xFF0288D1);
  static const Color warning = Color(0xFFFF8F00);
  
  // Gradients
  static const Gradient heroGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      Color(0x99000000),
      Color(0xCC000000),
    ],
  );

  static const Gradient primaryGradient = LinearGradient(
    colors: [primaryDark, primaryLight],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}
