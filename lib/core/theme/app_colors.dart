import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // Light Theme Colors
  static const Color lightBackground = Color(0xFFF8FAFC);
  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color lightBorder = Color(0xFFE5E7EB);
  static const Color lightTextPrimary = Color(0xFF111827);
  static const Color lightTextSecondary = Color(0xFF6B7280);

  // Dark Theme Colors
  static const Color darkBackground = Color.fromARGB(255, 6, 9, 16);
  static const Color darkSurface = Color(0xFF1E293B);
  static const Color darkBorder = Color(0xFF334155);
  static const Color darkBottomNavbar = Color.fromARGB(255, 14, 20, 28);
  static const Color darkTextPrimary = Color(0xFFF1F5F9);
  static const Color darkTextSecondary = Color(0xFF94A3B8);

  // Shared Colors
  static const Color primary = Color(0xFF6366F1); // Indigo
  static const Color primaryDark = Color(0xFF818CF8); // Lighter Indigo for dark mode
  static const Color primaryBackgroundDark = Color.fromARGB(255, 62, 61, 119); // Lighter Indigo for dark mode

  static const Color secondary = Color(0xFFE9C515); // Yellow/Gold
  static const Color onPrimary = Color(0xFFFFFFFF);
  static const Color danger = Color(0xFFE11D48);
  static const Color dangerDark = Color.fromARGB(255, 92, 17, 29); // Lighter rose for dark mode
  static const Color timerProgress = Color(0xFF5BBCE2);
  static const Color success = Color(0xFF10B981);
  static const Color successDark = Color(0xFF34D399);
  static const Color warning = Color(0xFFF59E0B);

  // Legacy compatibility
  static const Color background = lightBackground;
  static const Color surface = lightSurface;
  static const Color border = lightBorder;
  static const Color textPrimary = lightTextPrimary;
  static const Color textSecondary = lightTextSecondary;
  static const Color header = Color(0xFFFFFFFF);
}

