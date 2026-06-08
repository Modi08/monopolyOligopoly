import 'package:flutter/material.dart';

class AppTheme {
  // Core Colors - Swap these out with the hex codes from your images!
  static const Color primaryBackground = Color(0xFF0A192F); // Dark Navy Base
  static const Color secondaryBackground = Color(
    0xFF112240,
  ); // Lighter Navy/Gray for cards
  static const Color primaryAccent = Color(
    0xFF64FFDA,
  ); // Neon Green for actions
  static const Color textPrimary = Color.fromARGB(
    255,
    255,
    255,
    255,
  ); // Off-White/Light Blue for main text
  static const Color textSecondary = Color(
    0xFF8892B0,
  ); // Muted Slate for subtitles
  static const Color textFlare = Color(
    0xFFFFC107,
  ); // to highlight important text (e.g. "Go", "Free Parking")
  static const Color successGreen = Color(
    0xFF4CAF50,
  ); // Positive actions (Buy, Pass Go)
  static const Color errorRed = Color(
    0xFFFF5252,
  ); // Critical alerts (Hostile Takeovers)

  static ThemeData get darkTheme {
    return ThemeData(
      brightness: Brightness.dark,
      scaffoldBackgroundColor: primaryBackground,
      primaryColor: primaryAccent,
      cardColor: secondaryBackground,

      // Color Scheme
      colorScheme: const ColorScheme.dark(
        primary: primaryAccent,
        secondary: primaryBackground,
        tertiary: successGreen,
        surface: secondaryBackground,
        error: errorRed,
        onPrimary: textSecondary, // Text on primary buttons
        inversePrimary: textFlare,
        onSurface: textPrimary,
      ),

      // App Bar Theme (The "Terminal" Header)
      appBarTheme: const AppBarTheme(
        backgroundColor: primaryBackground,
        elevation: 0,
        centerTitle: true,
        iconTheme: IconThemeData(color: textPrimary),
        titleTextStyle: TextStyle(
          color: textPrimary,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),

      // Card Theme (For Properties, Loans, and Governance)
      cardTheme: CardThemeData(
        color: secondaryBackground,
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      ),

      // ElevatedButton Theme (Primary Action Buttons)
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ButtonStyle(
          backgroundColor: WidgetStateProperty.resolveWith<Color>((states) {
            if (states.contains(WidgetState.pressed)) {
              return textFlare; // Brighter color on hover
            }
            return primaryAccent;
          }),
          padding: WidgetStateProperty.all(
            const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
          ),
          shape: WidgetStateProperty.all(
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
        ),
      ),

      // Text Theme
      textTheme: const TextTheme(
        displayLarge: TextStyle(
          color: textFlare,
          fontSize: 50,
          fontWeight: FontWeight.bold,
        ),
        titleLarge: TextStyle(
          color: textPrimary,
          fontSize: 20,
          fontWeight: FontWeight.w600,
        ),
        bodyLarge: TextStyle(color: textPrimary, fontSize: 16),
        bodyMedium: TextStyle(color: textSecondary, fontSize: 14),
        bodySmall: TextStyle(color: textPrimary, fontSize: 10),
      ),

      // Bottom Navigation Bar Theme (Global Nav)
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: secondaryBackground,
        selectedItemColor: primaryAccent,
        unselectedItemColor: textSecondary,
        type: BottomNavigationBarType.fixed,
        elevation: 8,
      ),

      // Progress Indicator Theme (For Ownership/Voting splits)
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: primaryAccent,
        linearTrackColor: primaryBackground,
      ),
    );
  }
}
