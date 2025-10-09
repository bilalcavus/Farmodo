import 'package:farmodo/core/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

final ThemeData darkTheme = ThemeData(
  brightness: Brightness.dark,
  scaffoldBackgroundColor: AppColors.darkBackground,
  fontFamily: 'Inter',
  
  // AppBar Theme
  appBarTheme: const AppBarTheme(
    backgroundColor: AppColors.darkBackground,
    foregroundColor: AppColors.darkTextPrimary,
    elevation: 0,
    centerTitle: false,
    systemOverlayStyle: SystemUiOverlayStyle(
      statusBarBrightness: Brightness.dark,
      statusBarIconBrightness: Brightness.light,
      statusBarColor: Colors.transparent,
    ),
  ),
  
  // Color Scheme
  colorScheme: const ColorScheme.dark(
    primary: AppColors.primaryDark,
    onPrimary: AppColors.onPrimary,
    secondary: AppColors.secondary,
    surface: AppColors.darkSurface,
    onSurface: AppColors.darkTextPrimary,
    error: AppColors.dangerDark,
    onError: Colors.white,
    outline: AppColors.darkBorder,
  ),
  
  // Card Theme
  cardTheme: CardThemeData(
    color: AppColors.darkSurface,
    elevation: 4,
    shadowColor: Colors.black.withValues(alpha: 0.3),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(12),
    ),
  ),
  
  // Input Decoration Theme
  inputDecorationTheme: InputDecorationTheme(
    filled: true,
    fillColor: AppColors.darkSurface,
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: AppColors.darkBorder),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: AppColors.darkBorder),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: AppColors.primaryDark, width: 2),
    ),
  ),
  
  // Elevated Button Theme
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: AppColors.primaryDark,
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
    bodyLarge: TextStyle(fontFamily: 'Inter', color: AppColors.darkTextPrimary),
    bodyMedium: TextStyle(fontFamily: 'Inter', color: AppColors.darkTextPrimary),
    bodySmall: TextStyle(fontFamily: 'Inter', color: AppColors.darkTextSecondary),
    headlineLarge: TextStyle(fontFamily: 'Inter', color: AppColors.darkTextPrimary, fontWeight: FontWeight.bold),
    headlineMedium: TextStyle(fontFamily: 'Inter', color: AppColors.darkTextPrimary, fontWeight: FontWeight.bold),
    headlineSmall: TextStyle(fontFamily: 'Inter', color: AppColors.darkTextPrimary, fontWeight: FontWeight.w600),
    displayLarge: TextStyle(fontFamily: 'Inter', color: AppColors.darkTextPrimary, fontWeight: FontWeight.bold),
    displayMedium: TextStyle(fontFamily: 'Inter', color: AppColors.darkTextPrimary, fontWeight: FontWeight.bold),
    displaySmall: TextStyle(fontFamily: 'Inter', color: AppColors.darkTextPrimary, fontWeight: FontWeight.w600),
    labelLarge: TextStyle(fontFamily: 'Inter', color: AppColors.darkTextPrimary),
    labelMedium: TextStyle(fontFamily: 'Inter', color: AppColors.darkTextSecondary),
    labelSmall: TextStyle(fontFamily: 'Inter', color: AppColors.darkTextSecondary),
    titleLarge: TextStyle(fontFamily: 'Inter', color: AppColors.darkTextPrimary, fontWeight: FontWeight.w600),
    titleMedium: TextStyle(fontFamily: 'Inter', color: AppColors.darkTextPrimary, fontWeight: FontWeight.w500),
    titleSmall: TextStyle(fontFamily: 'Inter', color: AppColors.darkTextPrimary, fontWeight: FontWeight.w500),
  ),
  
  // Divider Theme
  dividerTheme: const DividerThemeData(
    color: AppColors.darkBorder,
    thickness: 1,
  ),
  
  // Icon Theme
  iconTheme: const IconThemeData(
    color: AppColors.darkTextPrimary,
  ),
  
  // Bottom Navigation Bar Theme
  bottomNavigationBarTheme: const BottomNavigationBarThemeData(
    backgroundColor: AppColors.darkSurface,
    selectedItemColor: AppColors.primaryDark,
    unselectedItemColor: AppColors.darkTextSecondary,
  ),
  
  // Chip Theme
  chipTheme: ChipThemeData(
    backgroundColor: AppColors.darkSurface,
    selectedColor: AppColors.primaryDark.withValues(alpha: 0.3),
    disabledColor: AppColors.darkBorder,
    deleteIconColor: AppColors.darkTextSecondary,
    labelStyle: const TextStyle(
      color: AppColors.darkTextPrimary,
      fontFamily: 'Inter',
    ),
    secondaryLabelStyle: const TextStyle(
      color: AppColors.darkTextSecondary,
      fontFamily: 'Inter',
    ),
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(8),
      side: const BorderSide(color: AppColors.darkBorder),
    ),
  ),
  
  // Bottom Sheet Theme
  bottomSheetTheme: const BottomSheetThemeData(
    backgroundColor: AppColors.darkSurface,
    modalBackgroundColor: AppColors.darkSurface,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    elevation: 12,
  ),
  
  // Dialog Theme
  dialogTheme: DialogThemeData(
    backgroundColor: AppColors.darkSurface,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(16),
    ),
    elevation: 12,
    titleTextStyle: const TextStyle(
      color: AppColors.darkTextPrimary,
      fontSize: 20,
      fontWeight: FontWeight.w600,
      fontFamily: 'Inter',
    ),
    contentTextStyle: const TextStyle(
      color: AppColors.darkTextSecondary,
      fontSize: 14,
      fontFamily: 'Inter',
    ),
  ),
  
  // Snackbar Theme
  snackBarTheme: SnackBarThemeData(
    backgroundColor: AppColors.darkSurface,
    contentTextStyle: const TextStyle(
      color: AppColors.darkTextPrimary,
      fontFamily: 'Inter',
    ),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(8),
    ),
    behavior: SnackBarBehavior.floating,
    elevation: 8,
  ),
  
  // FloatingActionButton Theme
  floatingActionButtonTheme: const FloatingActionButtonThemeData(
    backgroundColor: AppColors.primaryDark,
    foregroundColor: Colors.white,
    elevation: 6,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.all(Radius.circular(16)),
    ),
  ),
  
  // Switch Theme
  switchTheme: SwitchThemeData(
    thumbColor: WidgetStateProperty.resolveWith((states) {
      if (states.contains(WidgetState.selected)) {
        return AppColors.primaryDark;
      }
      return AppColors.darkBorder;
    }),
    trackColor: WidgetStateProperty.resolveWith((states) {
      if (states.contains(WidgetState.selected)) {
        return AppColors.primaryDark.withValues(alpha: 0.5);
      }
      return AppColors.darkBorder.withValues(alpha: 0.3);
    }),
  ),
  
  // ProgressIndicator Theme
  progressIndicatorTheme: const ProgressIndicatorThemeData(
    color: AppColors.primaryDark,
    linearTrackColor: AppColors.darkBorder,
    circularTrackColor: AppColors.darkBorder,
  ),
);