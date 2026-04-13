import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

const _parchment = Color(0xFFF2DFA7);
const _parchmentCard = Color(0xFFE8D090);
const _ink = Color(0xFF2B1A0E);
const _brownDark = Color(0xFF3A1C0A);
const _brownMid = Color(0xFF7B4A24);

/// A warm parchment theme evoking the feel of an aged spell book.
ThemeData parchmentTheme() {
  final colorScheme = ColorScheme.fromSeed(
    seedColor: _brownMid,
    brightness: Brightness.light,
  ).copyWith(
    primary: _brownDark,
    onPrimary: _parchment,
    primaryContainer: _brownMid,
    onPrimaryContainer: _parchment,
    secondary: _brownMid,
    onSecondary: _parchment,
    secondaryContainer: const Color(0xFFDEC898),
    onSecondaryContainer: _ink,
    surface: _parchment,
    onSurface: _ink,
    onSurfaceVariant: _brownMid,
    outline: _brownMid,
    outlineVariant: const Color(0xFFC4A07A),
  );

  final textTheme = TextTheme(
    displayLarge: GoogleFonts.cinzel(fontWeight: FontWeight.bold),
    displayMedium: GoogleFonts.cinzel(fontWeight: FontWeight.bold),
    displaySmall: GoogleFonts.cinzel(),
    headlineLarge: GoogleFonts.cinzel(fontWeight: FontWeight.bold),
    headlineMedium: GoogleFonts.cinzel(),
    headlineSmall: GoogleFonts.cinzel(),
    titleLarge: GoogleFonts.cinzel(fontWeight: FontWeight.w600),
    titleMedium: GoogleFonts.cinzel(
      fontWeight: FontWeight.w500,
      letterSpacing: 0.3,
    ),
    titleSmall: GoogleFonts.cinzel(fontWeight: FontWeight.w600),
    bodyLarge: GoogleFonts.lora(),
    bodyMedium: GoogleFonts.lora(),
    bodySmall: GoogleFonts.lora(),
    labelLarge: GoogleFonts.lora(fontWeight: FontWeight.w500),
    labelMedium: GoogleFonts.lora(),
    labelSmall: GoogleFonts.lora(),
  );

  return ThemeData(
    colorScheme: colorScheme,
    textTheme: textTheme,
    scaffoldBackgroundColor: _parchment,
    appBarTheme: AppBarTheme(
      backgroundColor: _brownDark,
      foregroundColor: _parchment,
      elevation: 4,
      shadowColor: _brownDark,
      titleTextStyle: GoogleFonts.cinzel(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: _parchment,
        letterSpacing: 1.5,
      ),
      iconTheme: const IconThemeData(color: _parchment),
    ),
    cardTheme: CardThemeData(
      color: _parchmentCard,
      elevation: 2,
      shadowColor: _brownDark.withValues(alpha: 0.4),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(4),
        side: const BorderSide(color: Color(0xFFA07840), width: 0.5),
      ),
    ),
    dividerTheme: const DividerThemeData(
      color: Color(0xFFC4A07A),
      thickness: 1,
    ),
    chipTheme: ChipThemeData(
      backgroundColor: const Color(0xFFDEC898),
      selectedColor: _brownDark,
      checkmarkColor: _parchment,
      showCheckmark: true,
      labelStyle: GoogleFonts.lora(fontSize: 12, color: _ink),
      side: const BorderSide(color: Color(0xFFA07840)),
      padding: const EdgeInsets.symmetric(horizontal: 4),
    ),
    listTileTheme: const ListTileThemeData(
      tileColor: Colors.transparent,
    ),
    iconTheme: const IconThemeData(color: _brownMid),
    progressIndicatorTheme: const ProgressIndicatorThemeData(
      color: _brownMid,
    ),
  );
}
