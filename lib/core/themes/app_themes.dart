import 'package:flutter/material.dart';

final ThemeData appTheme = ThemeData(
  colorScheme: const ColorScheme(
    brightness: Brightness.dark,
    primary: Color(0xFF00D09E), // Button color and highlights
    onPrimary: Color(0xFF052224), // Text on primary elements
    secondary: Color(0xFFD5F0C0), // For accentuating elements
    onSecondary: Color(0xFF093030), // Text on secondary elements
    surface: Color(0xFF093030), // Scaffold background
    onSurface: Color(0xFFD5F0C0), // Text on scaffold
    outline: Colors.grey, // For borders and dividers
    error: Colors.red, // Default error color
    onError: Colors.white, // Text on error elements
    primaryContainer: Color(0xFF052224), // Background-like containers
    onPrimaryContainer: Color(0xFFD5F0C0), // Text on containers
    inverseSurface: Color(0xFF00D09E), // Alternate surface
    onInverseSurface: Color(0xFF052224), // Text on alternate surface
  ),
  scaffoldBackgroundColor:
      const Color(0xFF093030), // Matches the scaffold color
  textTheme: const TextTheme(
    bodyLarge: TextStyle(
      color: Color(0xFF093030), // General text color
      fontSize: 18,
    ),
    bodyMedium: TextStyle(
      color: Color(0xFFD5F0C0),
      fontSize: 16,
    ),
    labelLarge: TextStyle(
      color: Color(0xFFD5F0C0),
      fontSize: 14,
    ),
    titleLarge: TextStyle(
      color: Color(0xFFD5F0C0),
      fontSize: 22,
      fontWeight: FontWeight.bold,
    ),
  ),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: const Color(0xFF00D09E), // Button color
      foregroundColor: const Color(0xFF052224), // Text on buttons
      textStyle: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.bold,
      ),
    ),
  ),
  inputDecorationTheme: InputDecorationTheme(
    filled: true,
    fillColor: const Color(0xFF052224),
    hintStyle: const TextStyle(color: Color(0xFF093030)),
    labelStyle: const TextStyle(color: Color(0xFF093030)),
    enabledBorder: OutlineInputBorder(
      borderSide: const BorderSide(color: Color(0xFFD5F0C0)),
      borderRadius: BorderRadius.circular(8.0),
    ),
    focusedBorder: OutlineInputBorder(
      borderSide: const BorderSide(color: Color(0xFF00D09E)),
      borderRadius: BorderRadius.circular(8.0),
    ),
  ),
  dialogTheme: const DialogTheme(
    backgroundColor: Color(0xFF0A3C3A), // Dialog background color
    contentTextStyle: TextStyle(
      color: Colors.white, // Dialog text color
      fontSize: 16,
    ),
  ),
  appBarTheme: const AppBarTheme(
    color: Color(0xFF052224), // Darker color for AppBar
    elevation: 0, // Optional: remove shadow
    // titleTextStyle: const TextStyle(
    //   color: Color(0xFFD5F0C0), // Text color in AppBar
    //   fontSize: 20,
    //   fontWeight: FontWeight.bold,
    // ),
  ),
);
