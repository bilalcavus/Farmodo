import 'package:flutter/material.dart';

final ThemeData darkTheme = ThemeData(
  brightness: Brightness.dark,
  fontFamily: 'Inter',
  appBarTheme: const AppBarTheme(
    backgroundColor: Colors.black,
    foregroundColor: Colors.white,
    elevation: 0,
  ),
  textTheme: const TextTheme(
    bodyLarge: TextStyle(fontFamily: 'Inter'),
      bodyMedium: TextStyle(fontFamily: 'Inter'),
      bodySmall: TextStyle(fontFamily: 'Inter'),
      headlineLarge: TextStyle(fontFamily: 'Inter'),
      headlineMedium: TextStyle(fontFamily: 'Inter'),
      headlineSmall: TextStyle(fontFamily: 'Inter'),
      displayLarge: TextStyle(fontFamily: 'Inter'),
      displayMedium: TextStyle(fontFamily: 'Inter'),
      displaySmall: TextStyle(fontFamily: 'Inter'),
      labelLarge: TextStyle(fontFamily: 'Inter'),
      labelMedium: TextStyle(fontFamily: 'Inter'),
      labelSmall: TextStyle(fontFamily: 'Inter'),
      titleLarge: TextStyle(fontFamily: 'Inter'),
      titleMedium: TextStyle(fontFamily: 'Inter'),
      titleSmall: TextStyle(fontFamily: 'Inter',),
  ),
);