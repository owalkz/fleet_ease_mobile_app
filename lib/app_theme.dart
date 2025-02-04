import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Primary colors
  static const Color primaryColor = Color(0xFF1E3A8A); // Dark Blue
  static const Color secondaryColor = Color(0xFF8F8E8E); // Gray

  // Light Theme
  static ThemeData lightTheme = ThemeData(
    brightness: Brightness.light,
    primaryColor: primaryColor,
    scaffoldBackgroundColor: Colors.white,
    appBarTheme: AppBarTheme(
      backgroundColor: primaryColor,
      foregroundColor: Colors.white,
      elevation: 0,
    ),
    textTheme: _textTheme,
    buttonTheme: ButtonThemeData(
      buttonColor: primaryColor,
      textTheme: ButtonTextTheme.primary,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    ),
    colorScheme: ColorScheme.light(
      primary: primaryColor,
      secondary: secondaryColor,
    ),
  );

  // Dark Theme
  static ThemeData darkTheme = ThemeData(
    brightness: Brightness.dark,
    primaryColor: primaryColor,
    scaffoldBackgroundColor: Colors.black,
    appBarTheme: AppBarTheme(
      backgroundColor: Colors.black,
      foregroundColor: Colors.white,
      elevation: 0,
    ),
    textTheme:
        _textTheme.apply(bodyColor: Colors.white, displayColor: Colors.white),
    buttonTheme: ButtonThemeData(
      buttonColor: primaryColor,
      textTheme: ButtonTextTheme.primary,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    ),
    colorScheme: ColorScheme.dark(
      primary: primaryColor,
      secondary: secondaryColor,
    ),
  );

  // Text Theme
  static TextTheme _textTheme = TextTheme(
    displayLarge:
        GoogleFonts.poppins(fontSize: 32, fontWeight: FontWeight.bold),
    displayMedium:
        GoogleFonts.poppins(fontSize: 28, fontWeight: FontWeight.w600),
    displaySmall:
        GoogleFonts.poppins(fontSize: 24, fontWeight: FontWeight.w500),
    headlineMedium:
        GoogleFonts.openSans(fontSize: 20, fontWeight: FontWeight.w500),
    bodyLarge: GoogleFonts.roboto(fontSize: 16, fontWeight: FontWeight.normal),
    bodyMedium: GoogleFonts.roboto(fontSize: 14, fontWeight: FontWeight.normal),
    labelLarge: GoogleFonts.poppins(
        fontSize: 16, fontWeight: FontWeight.w600, color: Colors.white),
  );
}
