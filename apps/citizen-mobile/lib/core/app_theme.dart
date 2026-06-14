import 'package:flutter/material.dart';

class AppTheme {
  // Colors
  static const Color cyberBlack = Color(0xFF0A0E27);
  static const Color darkNavy = Color(0xFF0D1117);
  static const Color cyberBlue = Color(0xFF00D4FF);
  static const Color cyberBlue2 = Color(0xFF0088FF);
  static const Color neonGreen = Color(0xFF00FF88);
  static const Color neonGreen2 = Color(0xFF00CC66);
  static const Color dangerRed = Color(0xFFFF3355);
  static const Color dangerRed2 = Color(0xFFFF0044);
  static const Color warningOrange = Color(0xFFFF8800);
  static const Color warningAmber = Color(0xFFFFAA00);
  static const Color safeGreen = Color(0xFF00CC66);
  static const Color subtleBlue = Color(0xFF1A1F3A);
  static const Color cardBg = Color(0xFF131740);
  static const Color textPrimary = Color(0xFFFFFFFF);
  static const Color textSecondary = Color(0xFF8892B0);
  static const Color textDim = Color(0xFF4A4F6E);
  static const Color borderColor = Color(0xFF1E2456);

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: cyberBlack,
      colorScheme: const ColorScheme.dark(
        primary: cyberBlue,
        secondary: neonGreen,
        error: dangerRed,
        surface: cardBg,
        onPrimary: Colors.black,
        onSecondary: Colors.black,
        onSurface: textPrimary,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        iconTheme: IconThemeData(color: textPrimary),
        titleTextStyle: TextStyle(color: textPrimary, fontSize: 18, fontWeight: FontWeight.bold),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: darkNavy,
        selectedItemColor: cyberBlue,
        unselectedItemColor: textDim,
        type: BottomNavigationBarType.fixed,
        elevation: 0,
      ),
      cardTheme: CardThemeData(
        color: cardBg,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: borderColor, width: 1),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: cardBg,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: borderColor),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: borderColor),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: cyberBlue, width: 2),
        ),
        labelStyle: const TextStyle(color: textSecondary),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
    );
  }
}