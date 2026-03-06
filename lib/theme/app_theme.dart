import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Colors mapped from tailwind config
  static const Color skyLight = Color(0xFFE0F2FE);
  static const Color skyBlue = Color(0xFF0EA5E9);
  static const Color skyDeep = Color(0xFF0284C7);
  static const Color zenBlue = Color(0xFF7DD3FC);
  static const Color softSky = Color(0xFFBAE6FD);
  static const Color backgroundLight = Color(0xFFF8FAFC);
  static const Color cloudWhite = Color(0xFFFFFFFF);

  static const Color textDark = Color(0xFF0F172A); // slate-900
  static const Color textLight = Color(0xFF64748B); // slate-500

  static ThemeData get lightTheme {
    return ThemeData(
      primaryColor: skyBlue,
      scaffoldBackgroundColor: backgroundLight,
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        iconTheme: IconThemeData(color: Colors.white),
      ),
      textTheme: GoogleFonts.interTextTheme().copyWith(
        displayLarge: GoogleFonts.inter(color: textDark, fontWeight: FontWeight.bold),
        bodyLarge: GoogleFonts.inter(color: textDark),
        bodyMedium: GoogleFonts.inter(color: textLight),
      ),
      colorScheme: ColorScheme.fromSeed(
        seedColor: skyBlue,
        primary: skyBlue,
        secondary: zenBlue,
        surface: backgroundLight,
      ),
      useMaterial3: true,
    );
  }
}
