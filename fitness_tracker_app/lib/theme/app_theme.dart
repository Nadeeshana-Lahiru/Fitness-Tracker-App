import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // New Design Colors
  static const Color primaryColor = Color(0xFF5A72D8); // Main blue
  static const Color primaryLight = Color(0xFF869DF1);
  static const Color backgroundColor = Color(0xFFEEF2F9); // Light grayish blue
  static const Color cardColor = Colors.white;
  static const Color textPrimary = Color(0xFF1E2022); // Dark grey/almost black
  static const Color textSecondary = Color(0xFF8D92A3); // Soft grey
  
  // Accents
  static const Color orangeAccent = Color(0xFFFFCC99);
  static const Color greenAccent = Color(0xFF7FE0C7);
  static const Color purpleAccent = Color(0xFFD6C8FF);

  static ThemeData get lightTheme {
    return ThemeData(
      brightness: Brightness.light,
      primaryColor: primaryColor,
      scaffoldBackgroundColor: backgroundColor,
      colorScheme: const ColorScheme.light(
        primary: primaryColor,
        secondary: orangeAccent,
        surface: cardColor,
      ),
      textTheme: GoogleFonts.poppinsTextTheme(ThemeData.light().textTheme).copyWith(
        displayLarge: GoogleFonts.poppins(color: textPrimary, fontWeight: FontWeight.bold),
        displayMedium: GoogleFonts.poppins(color: textPrimary, fontWeight: FontWeight.w700),
        displaySmall: GoogleFonts.poppins(color: textPrimary, fontWeight: FontWeight.w600),
        headlineMedium: GoogleFonts.poppins(color: textPrimary, fontWeight: FontWeight.w600),
        titleLarge: GoogleFonts.poppins(color: textPrimary, fontWeight: FontWeight.w600),
        bodyLarge: GoogleFonts.poppins(color: textPrimary),
        bodyMedium: GoogleFonts.poppins(color: textSecondary),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: backgroundColor,
        elevation: 0,
        iconTheme: const IconThemeData(color: textPrimary),
        titleTextStyle: GoogleFonts.poppins(
          color: textPrimary, 
          fontSize: 22, 
          fontWeight: FontWeight.w600
        ),
      ),
      cardTheme: CardThemeData(
        color: cardColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        elevation: 0, // Using custom shadows in widgets instead for softer look
        margin: EdgeInsets.zero,
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
    );
  }

  // Soft Neumorphic / Glassmorphic shadow style used across the app
  static List<BoxShadow> get softShadow => [
    BoxShadow(
      color: Colors.black.withAlpha(10), // 0.04 * 255 ≈ 10
      blurRadius: 20,
      offset: const Offset(0, 10),
      spreadRadius: 0,
    )
  ];
}
