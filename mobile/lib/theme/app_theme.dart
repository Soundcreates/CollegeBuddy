import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

abstract final class AppColors {
  static const ink = Color(0xFF18372C);
  static const evergreen = Color(0xFF244537);
  static const moss = Color(0xFF61764A);
  static const cream = Color(0xFFF8F3E8);
  static const paper = Color(0xFFFFFDF7);
  static const clay = Color(0xFFD76F48);
  static const sun = Color(0xFFF5BD4C);
  static const line = Color(0xFFD9D0BB);
  static const paleMoss = Color(0xFFE6EDD6);
  static const paleClay = Color(0xFFF8DFC9);
  static const mutedPaper = Color(0xFFF0EBDF);
}

abstract final class AppText {
  static TextStyle serif({
    double size = 16,
    FontWeight weight = FontWeight.w600,
    Color color = AppColors.ink,
    double height = 1.1,
  }) => GoogleFonts.fraunces(
    fontSize: size,
    fontWeight: weight,
    color: color,
    height: height,
  );

  static TextStyle sans({
    double size = 16,
    FontWeight weight = FontWeight.w400,
    Color color = AppColors.ink,
    double height = 1.4,
  }) => GoogleFonts.dmSans(
    fontSize: size,
    fontWeight: weight,
    color: color,
    height: height,
  );
}

ThemeData collegeBuddyTheme() => ThemeData(
  useMaterial3: true,
  brightness: Brightness.light,
  scaffoldBackgroundColor: AppColors.cream,
  colorScheme: const ColorScheme.light(
    primary: AppColors.ink,
    onPrimary: Colors.white,
    secondary: AppColors.moss,
    onSecondary: Colors.white,
    surface: AppColors.paper,
    onSurface: AppColors.ink,
    outline: AppColors.line,
  ),
  textTheme: GoogleFonts.dmSansTextTheme().copyWith(
    displayLarge: AppText.serif(size: 52, height: 1),
    displayMedium: AppText.serif(size: 42, height: 1),
    headlineLarge: AppText.serif(size: 34, height: 1.02),
    headlineMedium: AppText.serif(size: 28, height: 1.05),
    titleLarge: AppText.serif(size: 22),
    bodyLarge: AppText.sans(size: 16),
    bodyMedium: AppText.sans(size: 14),
  ),
  inputDecorationTheme: InputDecorationTheme(
    filled: true,
    fillColor: AppColors.paper,
    hintStyle: AppText.sans(color: AppColors.moss),
    prefixIconColor: AppColors.moss,
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(18),
      borderSide: BorderSide.none,
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(18),
      borderSide: BorderSide.none,
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(18),
      borderSide: const BorderSide(color: AppColors.sun, width: 2),
    ),
  ),
);
