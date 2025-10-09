import 'package:farmodo/core/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

final ThemeData lightTheme = ThemeData(
  brightness: Brightness.light,
  scaffoldBackgroundColor: AppColors.lightBackground,
  fontFamily: 'Inter',
  
  // AppBar Theme
  appBarTheme: const AppBarTheme(
    backgroundColor: AppColors.lightBackground,
    foregroundColor: AppColors.lightTextPrimary,
    elevation: 0,
    centerTitle: false,
    systemOverlayStyle: SystemUiOverlayStyle(
      statusBarBrightness: Brightness.light,
      statusBarIconBrightness: Brightness.dark,
      statusBarColor: Colors.transparent,
    ),
  ),
  
  // Color Scheme
  colorScheme: const ColorScheme.light(
    primary: AppColors.primary,
    onPrimary: AppColors.onPrimary,
    secondary: AppColors.secondary,
    surface: AppColors.lightSurface,
    onSurface: AppColors.lightTextPrimary,
    error: AppColors.danger,
    onError: Colors.white,
    outline: AppColors.lightBorder,
  ),
  
  // Card Theme
  cardTheme: CardThemeData(
    color: AppColors.lightSurface,
    elevation: 2,
    shadowColor: Colors.black.withValues(alpha: 0.1),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(12),
    ),
  ),
  
  // Input Decoration Theme
  inputDecorationTheme: InputDecorationTheme(
    filled: true,
    fillColor: AppColors.lightSurface,
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: AppColors.lightBorder),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: AppColors.lightBorder),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: AppColors.primary, width: 2),
    ),
  ),
  
  // Elevated Button Theme
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: AppColors.primary,
      foregroundColor: AppColors.onPrimary,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
    ),
  ),
  
  // Text Theme
  textTheme: const TextTheme(
    bodyLarge: TextStyle(fontFamily: 'Inter', color: AppColors.lightTextPrimary),
    bodyMedium: TextStyle(fontFamily: 'Inter', color: AppColors.lightTextPrimary),
    bodySmall: TextStyle(fontFamily: 'Inter', color: AppColors.lightTextSecondary),
    headlineLarge: TextStyle(fontFamily: 'Inter', color: AppColors.lightTextPrimary, fontWeight: FontWeight.bold),
    headlineMedium: TextStyle(fontFamily: 'Inter', color: AppColors.lightTextPrimary, fontWeight: FontWeight.bold),
    headlineSmall: TextStyle(fontFamily: 'Inter', color: AppColors.lightTextPrimary, fontWeight: FontWeight.w600),
    displayLarge: TextStyle(fontFamily: 'Inter', color: AppColors.lightTextPrimary, fontWeight: FontWeight.bold),
    displayMedium: TextStyle(fontFamily: 'Inter', color: AppColors.lightTextPrimary, fontWeight: FontWeight.bold),
    displaySmall: TextStyle(fontFamily: 'Inter', color: AppColors.lightTextPrimary, fontWeight: FontWeight.w600),
    labelLarge: TextStyle(fontFamily: 'Inter', color: AppColors.lightTextPrimary),
    labelMedium: TextStyle(fontFamily: 'Inter', color: AppColors.lightTextSecondary),
    labelSmall: TextStyle(fontFamily: 'Inter', color: AppColors.lightTextSecondary),
    titleLarge: TextStyle(fontFamily: 'Inter', color: AppColors.lightTextPrimary, fontWeight: FontWeight.w600),
    titleMedium: TextStyle(fontFamily: 'Inter', color: AppColors.lightTextPrimary, fontWeight: FontWeight.w500),
    titleSmall: TextStyle(fontFamily: 'Inter', color: AppColors.lightTextPrimary, fontWeight: FontWeight.w500),
  ),
  
  // Divider Theme
  dividerTheme: const DividerThemeData(
    color: AppColors.lightBorder,
    thickness: 1,
  ),
  
  // Icon Theme
  iconTheme: const IconThemeData(
    color: AppColors.lightTextPrimary,
  ),
  
  // Chip Theme
  chipTheme: ChipThemeData(
    backgroundColor: AppColors.lightSurface,
    selectedColor: AppColors.primary.withValues(alpha: 0.2),
    disabledColor: AppColors.lightBorder,
    deleteIconColor: AppColors.lightTextSecondary,
    labelStyle: const TextStyle(
      color: AppColors.lightTextPrimary,
      fontFamily: 'Inter',
    ),
    secondaryLabelStyle: const TextStyle(
      color: AppColors.lightTextSecondary,
      fontFamily: 'Inter',
    ),
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(8),
      side: const BorderSide(color: AppColors.lightBorder),
    ),
  ),

  bottomNavigationBarTheme: const BottomNavigationBarThemeData(
    backgroundColor: AppColors.danger,
    selectedItemColor: AppColors.danger,
    unselectedItemColor: AppColors.darkTextSecondary,
  ),
  
  // Bottom Sheet Theme
  bottomSheetTheme: const BottomSheetThemeData(
    backgroundColor: AppColors.lightSurface,
    modalBackgroundColor: AppColors.lightSurface,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    elevation: 8,
  ),
  
  // Dialog Theme
  dialogTheme: DialogThemeData(
    backgroundColor: AppColors.lightSurface,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(16),
    ),
    elevation: 8,
    titleTextStyle: const TextStyle(
      color: AppColors.lightTextPrimary,
      fontSize: 20,
      fontWeight: FontWeight.w600,
      fontFamily: 'Inter',
    ),
    contentTextStyle: const TextStyle(
      color: AppColors.lightTextSecondary,
      fontSize: 14,
      fontFamily: 'Inter',
    ),
  ),
  
  // Snackbar Theme
  snackBarTheme: SnackBarThemeData(
    backgroundColor: AppColors.lightTextPrimary,
    contentTextStyle: const TextStyle(
      color: Colors.white,
      fontFamily: 'Inter',
    ),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(8),
    ),
    behavior: SnackBarBehavior.floating,
    elevation: 4,
  ),
  
  // FloatingActionButton Theme
  floatingActionButtonTheme: const FloatingActionButtonThemeData(
    backgroundColor: AppColors.primary,
    foregroundColor: Colors.white,
    elevation: 4,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.all(Radius.circular(16)),
    ),
  ),
  
  // Switch Theme
  switchTheme: SwitchThemeData(
    thumbColor: WidgetStateProperty.resolveWith((states) {
      if (states.contains(WidgetState.selected)) {
        return AppColors.primary;
      }
      return AppColors.lightBorder;
    }),
    trackColor: WidgetStateProperty.resolveWith((states) {
      if (states.contains(WidgetState.selected)) {
        return AppColors.primary.withValues(alpha: 0.5);
      }
      return AppColors.lightBorder.withValues(alpha: 0.3);
    }),
  ),
  
  // ProgressIndicator Theme
  progressIndicatorTheme: const ProgressIndicatorThemeData(
    color: AppColors.primary,
    linearTrackColor: AppColors.lightBorder,
    circularTrackColor: AppColors.lightBorder,
  ),
);