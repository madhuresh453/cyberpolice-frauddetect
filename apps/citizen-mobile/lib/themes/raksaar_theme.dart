import 'package:flutter/material.dart';

class RaksaarColors {
  // Brand - CyberShield / RAKSAAR
  static const primary = Color(0xFF1A73E8);
  static const primaryDark = Color(0xFF0D47A1);
  static const primaryLight = Color(0xFF4FC3F7);
  static const accent = Color(0xFF00E5FF);
  static const accentDark = Color(0xFF00B8D4);

  // Risk Levels
  static const riskSafe = Color(0xFF00C853);
  static const riskLow = Color(0xFF69F0AE);
  static const riskMedium = Color(0xFFFFC107);
  static const riskHigh = Color(0xFFFF6D00);
  static const riskCritical = Color(0xFFD50000);

  // Security
  static const shieldBlue = Color(0xFF1565C0);
  static const shieldGreen = Color(0xFF2E7D32);
  static const shieldRed = Color(0xFFC62828);

  // Gradients
  static const gradientStart = Color(0xFF0D47A1);
  static const gradientEnd = Color(0xFF00E5FF);
  static const gradientDark = Color(0xFF0A1929);
  static const gradientSOS = Color(0xFFB71C1C);

  // Status Colors
  static const success = Color(0xFF00C853);
  static const warning = Color(0xFFFFC107);
  static const error = Color(0xFFD50000);
  static const info = Color(0xFF2196F3);

  // Dark mode specific
  static const darkBg = Color(0xFF0A1929);
  static const darkCard = Color(0xFF132F4C);
  static const darkSurface = Color(0xFF1A3A5C);
  static const darkBorder = Color(0xFF1E4976);

  // Light mode specific
  static const lightBg = Color(0xFFF5F7FA);
  static const lightCard = Color(0xFFFFFFFF);
  static const lightSurface = Color(0xFFE8F0FE);
  static const lightBorder = Color(0xFFDADCE0);
  
  // AMOLED specific
  static const amoledBg = Color(0xFF000000);
  static const amoledCard = Color(0xFF111111);
  static const amoledSurface = Color(0xFF1A1A1A);
}

class RaksaarTheme {
  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    colorScheme: const ColorScheme.light(
      primary: RaksaarColors.primary,
      secondary: RaksaarColors.accent,
      surface: RaksaarColors.lightCard,
      error: RaksaarColors.error,
      onPrimary: Colors.white,
      onSecondary: Colors.black,
      onSurface: Color(0xFF1A1A2E),
      onError: Colors.white,
      outline: RaksaarColors.lightBorder,
    ),
    scaffoldBackgroundColor: RaksaarColors.lightBg,
    appBarTheme: const AppBarTheme(
      centerTitle: false,
      elevation: 0,
      scrolledUnderElevation: 1,
      backgroundColor: RaksaarColors.lightCard,
      foregroundColor: Color(0xFF1A1A2E),
      titleTextStyle: TextStyle(
        color: Color(0xFF1A1A2E),
        fontSize: 20,
        fontWeight: FontWeight.w600,
      ),
    ),
    cardTheme: CardThemeData(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: RaksaarColors.lightBorder.withValues(alpha: 0.5)),
      ),
      color: RaksaarColors.lightCard,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
    ),
    navigationBarTheme: NavigationBarThemeData(
      height: 68,
      elevation: 0,
      indicatorColor: RaksaarColors.primary.withValues(alpha: 0.15),
      backgroundColor: RaksaarColors.lightCard,
      labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: RaksaarColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: RaksaarColors.lightSurface,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: RaksaarColors.lightBorder),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: RaksaarColors.lightBorder.withValues(alpha: 0.5)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: RaksaarColors.primary, width: 2),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
    ),
    chipTheme: ChipThemeData(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
    ),
    bottomSheetTheme: const BottomSheetThemeData(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
    ),
  );

  static ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    colorScheme: const ColorScheme.dark(
      primary: RaksaarColors.primaryLight,
      secondary: RaksaarColors.accent,
      surface: RaksaarColors.darkCard,
      error: RaksaarColors.error,
      onPrimary: Colors.white,
      onSecondary: Colors.black,
      onSurface: Color(0xFFE8EAED),
      onError: Colors.white,
      outline: RaksaarColors.darkBorder,
    ),
    scaffoldBackgroundColor: RaksaarColors.darkBg,
    appBarTheme: const AppBarTheme(
      centerTitle: false,
      elevation: 0,
      scrolledUnderElevation: 1,
      backgroundColor: RaksaarColors.darkCard,
      foregroundColor: Color(0xFFE8EAED),
      titleTextStyle: TextStyle(
        color: Color(0xFFE8EAED),
        fontSize: 20,
        fontWeight: FontWeight.w600,
      ),
    ),
    cardTheme: CardThemeData(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: RaksaarColors.darkBorder.withValues(alpha: 0.3)),
      ),
      color: RaksaarColors.darkCard,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
    ),
    navigationBarTheme: NavigationBarThemeData(
      height: 68,
      elevation: 0,
      indicatorColor: RaksaarColors.primaryLight.withValues(alpha: 0.2),
      backgroundColor: RaksaarColors.darkCard,
      labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: RaksaarColors.primaryLight,
        foregroundColor: Colors.black,
        elevation: 0,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: RaksaarColors.darkSurface,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: RaksaarColors.darkBorder),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: RaksaarColors.darkBorder.withValues(alpha: 0.3)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: RaksaarColors.primaryLight, width: 2),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
    ),
    bottomSheetTheme: const BottomSheetThemeData(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
    ),
  );

  static ThemeData amoledTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    colorScheme: const ColorScheme.dark(
      primary: RaksaarColors.primaryLight,
      secondary: RaksaarColors.accent,
      surface: RaksaarColors.amoledCard,
      error: RaksaarColors.error,
      onPrimary: Colors.white,
      onSecondary: Colors.black,
      onSurface: Color(0xFFE8EAED),
      onError: Colors.white,
      outline: Color(0xFF2A2A2A),
    ),
    scaffoldBackgroundColor: RaksaarColors.amoledBg,
    appBarTheme: const AppBarTheme(
      centerTitle: false,
      elevation: 0,
      scrolledUnderElevation: 1,
      backgroundColor: RaksaarColors.amoledCard,
      foregroundColor: Color(0xFFE8EAED),
      titleTextStyle: TextStyle(
        color: Color(0xFFE8EAED),
        fontSize: 20,
        fontWeight: FontWeight.w600,
      ),
    ),
    cardTheme: CardThemeData(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: const Color(0xFF2A2A2A).withValues(alpha: 0.5)),
      ),
      color: RaksaarColors.amoledCard,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
    ),
    navigationBarTheme: NavigationBarThemeData(
      height: 68,
      elevation: 0,
      indicatorColor: RaksaarColors.primaryLight.withValues(alpha: 0.2),
      backgroundColor: RaksaarColors.amoledCard,
      labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
    ),
  );
}