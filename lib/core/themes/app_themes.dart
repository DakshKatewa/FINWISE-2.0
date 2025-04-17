import 'package:budgettraker/core/themes/app_colors.dart';
import 'package:flutter/material.dart';



final ThemeData appTheme = ThemeData(
  brightness: Brightness.light,
  scaffoldBackgroundColor: AppColors.background,
  colorScheme: const ColorScheme.light(
    primary: AppColors.primary,
    onPrimary: AppColors.onPrimary,
    background: AppColors.background,
    surface: AppColors.surface,
    onSurface: AppColors.textColor,
    secondary: AppColors.primary,
    onSecondary: AppColors.onPrimary,
    error: Colors.red,
    onError: Colors.white,
  ),
  textTheme: const TextTheme(
    titleLarge: TextStyle(
      fontSize: 22,
      fontWeight: FontWeight.bold,
      color: AppColors.textColor,
    ),
    bodyLarge: TextStyle(
      fontSize: 18,
      color: AppColors.textColor,
    ),
    bodyMedium: TextStyle(
      fontSize: 16,
      color: AppColors.greyText,
    ),
    labelLarge: TextStyle(
      fontSize: 14,
      color: AppColors.primary,
    ),
  ),
  appBarTheme: const AppBarTheme(
    backgroundColor: AppColors.background,
    elevation: 0,
    titleTextStyle: TextStyle(
      fontSize: 20,
      fontWeight: FontWeight.bold,
      color: AppColors.textColor,
    ),
    iconTheme: IconThemeData(color: AppColors.textColor),
  ),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: AppColors.primary,
      foregroundColor: AppColors.onPrimary,
      textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
    ),
  ),
  textButtonTheme: TextButtonThemeData(
    style: TextButton.styleFrom(
      foregroundColor: AppColors.primary,
      textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
    ),
  ),
  inputDecorationTheme: InputDecorationTheme(
    filled: true,
    fillColor: AppColors.surface,
    hintStyle: const TextStyle(color: AppColors.greyText),
    labelStyle: const TextStyle(color: AppColors.textColor),
    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    enabledBorder: OutlineInputBorder(
      borderSide: const BorderSide(color: Colors.transparent),
      borderRadius: BorderRadius.circular(12),
    ),
    focusedBorder: OutlineInputBorder(
      borderSide: const BorderSide(color: AppColors.primary),
      borderRadius: BorderRadius.circular(12),
    ),
  ),
  dialogTheme: const DialogTheme(
    backgroundColor: AppColors.surface,
    contentTextStyle: TextStyle(color: AppColors.textColor, fontSize: 16),
  ),
);
