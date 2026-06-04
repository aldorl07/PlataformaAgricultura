import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

/// Typography — Outfit (headings) + Inter (body)
class AppTypography {
  AppTypography._();

  static TextTheme get textTheme => TextTheme(
    // Display
    displayLarge: GoogleFonts.outfit(
      fontSize: 57,
      fontWeight: FontWeight.w700,
      letterSpacing: -0.25,
      color: AppColors.neutralDark,
    ),
    displayMedium: GoogleFonts.outfit(
      fontSize: 45,
      fontWeight: FontWeight.w700,
      letterSpacing: -0.02,
      color: AppColors.neutralDark,
    ),
    displaySmall: GoogleFonts.outfit(
      fontSize: 36,
      fontWeight: FontWeight.w600,
      letterSpacing: -0.02,
      color: AppColors.neutralDark,
    ),

    // Headline
    headlineLarge: GoogleFonts.outfit(
      fontSize: 32,
      fontWeight: FontWeight.w700,
      letterSpacing: -0.02,
      color: AppColors.neutralDark,
    ),
    headlineMedium: GoogleFonts.outfit(
      fontSize: 28,
      fontWeight: FontWeight.w600,
      letterSpacing: -0.02,
      color: AppColors.neutralDark,
    ),
    headlineSmall: GoogleFonts.outfit(
      fontSize: 24,
      fontWeight: FontWeight.w600,
      letterSpacing: -0.01,
      color: AppColors.neutralDark,
    ),

    // Title
    titleLarge: GoogleFonts.outfit(
      fontSize: 22,
      fontWeight: FontWeight.w600,
      letterSpacing: -0.01,
      color: AppColors.neutralDark,
    ),
    titleMedium: GoogleFonts.inter(
      fontSize: 16,
      fontWeight: FontWeight.w600,
      letterSpacing: 0.1,
      color: AppColors.neutralDark,
    ),
    titleSmall: GoogleFonts.inter(
      fontSize: 14,
      fontWeight: FontWeight.w500,
      letterSpacing: 0.1,
      color: AppColors.neutralDark,
    ),

    // Body
    bodyLarge: GoogleFonts.inter(
      fontSize: 16,
      fontWeight: FontWeight.w400,
      height: 1.6,
      color: AppColors.neutralDark,
    ),
    bodyMedium: GoogleFonts.inter(
      fontSize: 14,
      fontWeight: FontWeight.w400,
      height: 1.6,
      color: AppColors.neutralDark,
    ),
    bodySmall: GoogleFonts.inter(
      fontSize: 12,
      fontWeight: FontWeight.w400,
      height: 1.5,
      color: AppColors.neutralMedium,
    ),

    // Label
    labelLarge: GoogleFonts.inter(
      fontSize: 14,
      fontWeight: FontWeight.w500,
      letterSpacing: 0.1,
      color: AppColors.neutralDark,
    ),
    labelMedium: GoogleFonts.inter(
      fontSize: 12,
      fontWeight: FontWeight.w500,
      letterSpacing: 0.5,
      color: AppColors.neutralMedium,
    ),
    labelSmall: GoogleFonts.inter(
      fontSize: 11,
      fontWeight: FontWeight.w400,
      letterSpacing: 0.5,
      color: AppColors.neutralMedium,
    ),
  );

  // Convenience styles
  static TextStyle priceStyle({Color? color, double? fontSize}) =>
      GoogleFonts.outfit(
        fontSize: fontSize ?? 22,
        fontWeight: FontWeight.w700,
        color: color ?? AppColors.primary,
        letterSpacing: -0.5,
      );

  static TextStyle captionStyle({Color? color}) => GoogleFonts.inter(
        fontSize: 13,
        fontWeight: FontWeight.w400,
        color: color ?? AppColors.neutralMedium,
      );

  static TextStyle chipStyle({Color? color}) => GoogleFonts.inter(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        color: color ?? AppColors.primary,
        letterSpacing: 0.3,
      );
}
