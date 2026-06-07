import 'package:flutter/material.dart';

/// Royal Plum Design System
/// Colors: Cream (#F4ECD6) + Deep Plum (#310A31)
class AppTheme {
  // Primary Colors
  static const Color primaryPlum = Color(0xFF310A31);
  static const Color creamBackground = Color(0xFFF4ECD6);
  static const Color cardWhite = Color(0xFFFFFFFF);

  // Text Colors
  static const Color textDarkHeading = Color(0xFF310A31);
  static const Color textLightHeading = Color(0xFFF4ECD6);
  static const Color textBody = Color(0xFF5D4B5D);
  static const Color textMuted = Color(0xFF9E8D9E);

  // Status Colors
  static const Color statusGreen = Color(0xFF2E7D32); // Present/Approved/Low Priority
  static const Color statusAmber = Color(0xFFF57F17); // Pending/Medium Priority
  static const Color statusCrimson = Color(0xFFC62828); // Absent/Rejected/High Priority
  static const Color statusBlue = Color(0xFF1565C0); // In Progress/Info

  // Shadow for cards
  static BoxShadow cardShadow = BoxShadow(
    color: const Color(0x0D310A31),
    blurRadius: 20,
    offset: const Offset(0, 4),
  );

  // Theme Data
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.light(
        primary: primaryPlum,
        secondary: primaryPlum,
        surface: creamBackground,
        onPrimary: textLightHeading,
        onSecondary: textLightHeading,
        onSurface: textBody,
      ),
      scaffoldBackgroundColor: creamBackground,
      cardTheme: CardThemeData(
        color: cardWhite,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        shadowColor: primaryPlum.withValues(alpha: 0.05),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: primaryPlum,
        foregroundColor: textLightHeading,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: const TextStyle(
          color: textLightHeading,
          fontSize: 20,
          fontWeight: FontWeight.w600,
        ),
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: cardWhite,
        selectedItemColor: primaryPlum,
        unselectedItemColor: textBody,
        type: BottomNavigationBarType.fixed,
        elevation: 8,
      ),
      textTheme: const TextTheme(
        headlineLarge: TextStyle(
          color: textDarkHeading,
          fontSize: 32,
          fontWeight: FontWeight.bold,
        ),
        headlineMedium: TextStyle(
          color: textDarkHeading,
          fontSize: 24,
          fontWeight: FontWeight.bold,
        ),
        headlineSmall: TextStyle(
          color: textDarkHeading,
          fontSize: 20,
          fontWeight: FontWeight.w600,
        ),
        titleLarge: TextStyle(
          color: textDarkHeading,
          fontSize: 18,
          fontWeight: FontWeight.w600,
        ),
        titleMedium: TextStyle(
          color: textBody,
          fontSize: 16,
          fontWeight: FontWeight.w500,
        ),
        bodyLarge: TextStyle(
          color: textBody,
          fontSize: 16,
          fontWeight: FontWeight.normal,
        ),
        bodyMedium: TextStyle(
          color: textBody,
          fontSize: 14,
          fontWeight: FontWeight.normal,
        ),
        bodySmall: TextStyle(
          color: textMuted,
          fontSize: 12,
          fontWeight: FontWeight.normal,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: cardWhite,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: primaryPlum.withValues(alpha: 0.2)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: primaryPlum.withValues(alpha: 0.2)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: primaryPlum, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryPlum,
          foregroundColor: textLightHeading,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 0,
        ),
      ),
    );
  }
}
