import 'package:flutter/material.dart';

class AppTheme {
  static final ThemeData lightTheme = ThemeData(
    brightness: Brightness.light,
    primaryColor: Colors.blue, // You can make this the primary blue color from your design
    colorScheme: ColorScheme.light(
      primary: const Color(0xFF4300FF), // Primary blue for buttons etc.
      secondary: Colors.amber, // Secondary accent color
    ),
    scaffoldBackgroundColor: Colors.white, // Default background for most screens
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.transparent, // Set to transparent for designs without a solid app bar
      foregroundColor: Colors.black, // Default text color for app bar content
      elevation: 0, // No shadow for app bar
      centerTitle: true,
    ),
    textTheme: const TextTheme(
      // Apply 'jakarta-sans' to various text styles globally
      bodyLarge: TextStyle(fontFamily: 'jakarta-sans', fontSize: 16),
      bodyMedium: TextStyle(fontFamily: 'jakarta-sans', fontSize: 14),
      titleLarge: TextStyle(fontFamily: 'jakarta-sans', fontWeight: FontWeight.bold, fontSize: 20),
      // You can define other text styles here like headlineLarge, displaySmall, etc.
    ).apply(
      // Fallback font for all text styles if not explicitly set above
      fontFamily: 'jakarta-sans'
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF4300FF), // The blue color from your design for main buttons
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10), // Apply rounded corners
        ),
        textStyle: const TextStyle(fontFamily: 'jakarta-sans', fontSize: 18, fontWeight: FontWeight.bold),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: const Color(0xFF4300FF), // Example color for outlined button
        side: const BorderSide(color: Color(0xFF4300FF)), // Example border color
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        textStyle: const TextStyle(fontFamily: 'jakarta-sans'),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: const Color(0xFFCACACA), // Light grey background like in design
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide.none, // No border visible in design for default state
      ),
      enabledBorder: OutlineInputBorder( // State when TextField is enabled but not focused
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder( // State when TextField is focused
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: Color(0xFF4300FF), width: 1.5), // Focus border
      ),
      labelStyle: TextStyle(color: Colors.grey[600], fontFamily: 'jakarta-sans'),
      hintStyle: TextStyle(color: Colors.grey[400], fontFamily: 'jakarta-sans'),
      contentPadding: const EdgeInsets.symmetric(vertical: 15, horizontal: 10),
      floatingLabelBehavior: FloatingLabelBehavior.never, // Labels stay as placeholders
    ),
  );
}