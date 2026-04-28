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

  // Dark Mode Colors - More Premium Deep Navy/Slate
  static const Color darkBackgroundColor = Color(0xFF0F172A); // Deep slate
  static const Color darkCardColor = Color(0xFF1E293B); // Slightly lighter slate
  static const Color darkTextPrimary = Colors.white; // Pure white for better visibility
  static const Color darkTextSecondary = Colors.white; // Pure white for better visibility
  
  // Accents
  static const Color orangeAccent = Color(0xFFFB923C);
  static const Color greenAccent = Color(0xFF4ADE80);
  static const Color purpleAccent = Color(0xFF818CF8);

  static ThemeData get lightTheme {
    return ThemeData(
      brightness: Brightness.light,
      primaryColor: primaryColor,
      scaffoldBackgroundColor: backgroundColor,
      colorScheme: const ColorScheme.light(
        primary: primaryColor,
        secondary: orangeAccent,
        surface: cardColor,
        onSurface: textPrimary,
      ),
      textTheme: GoogleFonts.poppinsTextTheme(ThemeData.light().textTheme).copyWith(
        displayLarge: GoogleFonts.poppins(color: textPrimary, fontWeight: FontWeight.bold),
        displayMedium: GoogleFonts.poppins(color: textPrimary, fontWeight: FontWeight.w700),
        displaySmall: GoogleFonts.poppins(color: textPrimary, fontWeight: FontWeight.w600),
        headlineMedium: GoogleFonts.poppins(color: textPrimary, fontWeight: FontWeight.w600),
        titleLarge: GoogleFonts.poppins(color: textPrimary, fontWeight: FontWeight.w600),
        titleMedium: GoogleFonts.poppins(color: textPrimary, fontWeight: FontWeight.w600),
        bodyLarge: GoogleFonts.poppins(color: textPrimary),
        bodyMedium: GoogleFonts.poppins(color: textSecondary),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: backgroundColor,
        elevation: 0,
        centerTitle: false,
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
        elevation: 0,
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
      color: Colors.black.withAlpha(10),
      blurRadius: 20,
      offset: const Offset(0, 10),
      spreadRadius: 0,
    )
  ];

  static List<BoxShadow> get darkSoftShadow => [
    BoxShadow(
      color: Colors.black.withAlpha(40),
      blurRadius: 20,
      offset: const Offset(0, 10),
      spreadRadius: 0,
    )
  ];

  static ThemeData get darkTheme {
    return ThemeData(
      brightness: Brightness.dark,
      primaryColor: primaryColor,
      scaffoldBackgroundColor: darkBackgroundColor,
      colorScheme: const ColorScheme.dark(
        primary: primaryColor,
        secondary: orangeAccent,
        surface: darkCardColor,
        onSurface: darkTextPrimary,
      ),
      textTheme: GoogleFonts.poppinsTextTheme(ThemeData.dark().textTheme).copyWith(
        displayLarge: GoogleFonts.poppins(color: darkTextPrimary, fontWeight: FontWeight.bold),
        displayMedium: GoogleFonts.poppins(color: darkTextPrimary, fontWeight: FontWeight.w700),
        displaySmall: GoogleFonts.poppins(color: darkTextPrimary, fontWeight: FontWeight.w600),
        headlineMedium: GoogleFonts.poppins(color: darkTextPrimary, fontWeight: FontWeight.w600),
        titleLarge: GoogleFonts.poppins(color: darkTextPrimary, fontWeight: FontWeight.w600),
        titleMedium: GoogleFonts.poppins(color: darkTextPrimary, fontWeight: FontWeight.w600),
        bodyLarge: GoogleFonts.poppins(color: darkTextPrimary),
        bodyMedium: GoogleFonts.poppins(color: darkTextSecondary),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: darkBackgroundColor,
        elevation: 0,
        centerTitle: false,
        iconTheme: const IconThemeData(color: darkTextPrimary),
        titleTextStyle: GoogleFonts.poppins(
          color: darkTextPrimary,
          fontSize: 22,
          fontWeight: FontWeight.w600,
        ),
      ),
      cardTheme: CardThemeData(
        color: darkCardColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        elevation: 0,
        margin: EdgeInsets.zero,
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
    );
  }
}
