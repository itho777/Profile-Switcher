import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Light Theme Colors
  static const Color lightPrimary = Color(0xFF002B6C);
  static const Color lightOnPrimary = Color(0xFFFFFFFF);
  static const Color lightPrimaryContainer = Color(0xFF124191);
  static const Color lightOnPrimaryContainer = Color(0xFF92B1FF);
  static const Color lightSecondary = Color(0xFF5D5F5F);
  static const Color lightSecondaryContainer = Color(0xFFDCDDDD);
  static const Color lightOnSecondaryContainer = Color(0xFF5F6161);
  static const Color lightBackground = Color(0xFFFBF9F9);
  static const Color lightOnBackground = Color(0xFF1B1C1C);
  static const Color lightSurface = Color(0xFFFBF9F9);
  static const Color lightSurfaceContainerLow = Color(0xFFF5F3F3);
  static const Color lightSurfaceContainerLowest = Color(0xFFFFFFFF);
  static const Color lightSurfaceContainerHigh = Color(0xFFE9E8E7);
  static const Color lightOutline = Color(0xFF747783);
  static const Color lightOutlineVariant = Color(0xFFC4C6D3);

  // Dark Theme Colors
  static const Color darkPrimary = Color(0xFFABC7FF);
  static const Color darkOnPrimary = Color(0xFF002F66);
  static const Color darkPrimaryContainer = Color(0xFF2E72D2);
  static const Color darkOnPrimaryContainer = Color(0xFFFBFAFF);
  static const Color darkSecondary = Color(0xFF8FD8FF);
  static const Color darkSecondaryContainer = Color(0xFF00C1FD);
  static const Color darkOnSecondaryContainer = Color(0xFF004B65);
  static const Color darkBackground = Color(0xFF10131A);
  static const Color darkOnBackground = Color(0xFFE1E2EB);
  static const Color darkSurface = Color(0xFF10131A);
  static const Color darkSurfaceDim = Color(0xFF10131A);
  static const Color darkSurfaceContainer = Color(0xFF1D2026);
  static const Color darkSurfaceContainerLow = Color(0xFF191C22);
  static const Color darkSurfaceContainerLowest = Color(0xFF0B0E14);
  static const Color darkSurfaceContainerHigh = Color(0xFF272A31);
  static const Color darkOutline = Color(0xFF8C919E);
  static const Color darkOutlineVariant = Color(0xFF424752);

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: const ColorScheme.light(
        primary: lightPrimary,
        onPrimary: lightOnPrimary,
        primaryContainer: lightPrimaryContainer,
        onPrimaryContainer: lightOnPrimaryContainer,
        secondary: lightSecondary,
        secondaryContainer: lightSecondaryContainer,
        onSecondaryContainer: lightOnSecondaryContainer,
        surface: lightSurface,
        onSurface: lightOnBackground,
        outline: lightOutline,
        outlineVariant: lightOutlineVariant,
      ),
      scaffoldBackgroundColor: lightBackground,
      appBarTheme: const AppBarTheme(
        backgroundColor: lightSurface,
        foregroundColor: lightPrimary,
        elevation: 0,
      ),
      textTheme: GoogleFonts.interTextTheme(ThemeData.light().textTheme),
    );
  }

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: const ColorScheme.dark(
        primary: darkPrimary,
        onPrimary: darkOnPrimary,
        primaryContainer: darkPrimaryContainer,
        onPrimaryContainer: darkOnPrimaryContainer,
        secondary: darkSecondary,
        secondaryContainer: darkSecondaryContainer,
        onSecondaryContainer: darkOnSecondaryContainer,
        surface: darkSurface,
        onSurface: darkOnBackground,
        outline: darkOutline,
        outlineVariant: darkOutlineVariant,
      ),
      scaffoldBackgroundColor: darkBackground,
      appBarTheme: const AppBarTheme(
        backgroundColor: darkSurfaceDim,
        foregroundColor: darkPrimary,
        elevation: 0,
      ),
      textTheme: GoogleFonts.interTextTheme(ThemeData.dark().textTheme),
    );
  }
}
