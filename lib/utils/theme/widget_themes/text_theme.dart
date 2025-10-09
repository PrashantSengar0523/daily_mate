import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../constants/colors.dart';

/// Custom Class for Light & Dark Text Themes
class TTextTheme {
  TTextTheme._(); // To avoid creating instances

  /// Customizable Light Text Theme
  static TextTheme lightTextTheme = TextTheme(
    headlineLarge: GoogleFonts.manrope().copyWith(fontSize: 24.0, fontWeight: FontWeight.bold, color: TColors.textPrimary),
    headlineMedium: GoogleFonts.manrope().copyWith(fontSize: 18.0, fontWeight: FontWeight.bold, color: TColors.textPrimary),
    headlineSmall: GoogleFonts.manrope().copyWith(fontSize: 16.0, fontWeight: FontWeight.bold, color: TColors.textPrimary),

    titleLarge: GoogleFonts.manrope().copyWith(fontSize: 16.0, fontWeight: FontWeight.w600, color: TColors.textPrimary),
    titleMedium: GoogleFonts.manrope().copyWith(fontSize: 16.0, fontWeight: FontWeight.w600, color: TColors.textSecondary),
    titleSmall: GoogleFonts.manrope().copyWith(fontSize: 16.0, fontWeight: FontWeight.w400, color: TColors.textSecondary),

    bodyLarge: GoogleFonts.manrope().copyWith(fontSize: 14.0, fontWeight: FontWeight.w600, color: TColors.textPrimary),
    bodyMedium: GoogleFonts.manrope().copyWith(fontSize: 14.0, fontWeight: FontWeight.normal, color: TColors.textPrimary),
    bodySmall: GoogleFonts.manrope().copyWith(fontSize: 14.0, fontWeight: FontWeight.normal, color: TColors.textSecondary),

    labelLarge: GoogleFonts.manrope().copyWith(fontSize: 12.0, fontWeight: FontWeight.normal, color: TColors.textPrimary),
    labelMedium: GoogleFonts.manrope().copyWith(fontSize: 12.0, fontWeight: FontWeight.normal, color: TColors.textSecondary),
  );

  /// Customizable Dark Text Theme
  static TextTheme darkTextTheme = TextTheme(
    headlineLarge: GoogleFonts.manrope().copyWith(fontSize: 24.0, fontWeight: FontWeight.bold, color: TColors.light),
    headlineMedium: GoogleFonts.manrope().copyWith(fontSize: 18.0, fontWeight: FontWeight.bold, color: TColors.light),
    headlineSmall: GoogleFonts.manrope().copyWith(fontSize: 16.0, fontWeight: FontWeight.w600, color: TColors.light),

    titleLarge: GoogleFonts.manrope().copyWith(fontSize: 16.0, fontWeight: FontWeight.bold, color: TColors.light),
    titleMedium: GoogleFonts.manrope().copyWith(fontSize: 16.0, fontWeight: FontWeight.w600, color: TColors.light),
    titleSmall: GoogleFonts.manrope().copyWith(fontSize: 16.0, fontWeight: FontWeight.w400, color: TColors.light),

    bodyLarge: GoogleFonts.manrope().copyWith(fontSize: 14.0, fontWeight: FontWeight.w600, color: TColors.light),
    bodyMedium: GoogleFonts.manrope().copyWith(fontSize: 14.0, fontWeight: FontWeight.normal, color: TColors.light),
    bodySmall: GoogleFonts.manrope().copyWith(fontSize: 14.0, fontWeight: FontWeight.w400, color: TColors.light.withOpacity(0.5)),

    labelLarge: GoogleFonts.manrope().copyWith(fontSize: 12.0, fontWeight: FontWeight.normal, color: TColors.light),
    labelMedium: GoogleFonts.manrope().copyWith(fontSize: 12.0, fontWeight: FontWeight.normal, color: TColors.light.withOpacity(0.5)),
  );
}
