import 'package:farmodo/core/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:kartal/kartal.dart';

class AppContainerStyles {
  AppContainerStyles._();

  static BoxDecoration lightPrimaryContainer({double borderRadius = 12}) {
    return BoxDecoration(
      color: AppColors.lightSurface,
      borderRadius: BorderRadius.circular(borderRadius),
      border: Border.all(color: AppColors.lightBorder),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.05),
          blurRadius: 4,
          offset: const Offset(0, 2),
        ),
      ],
    );
  }

  static BoxDecoration lightSecondaryContainer(BuildContext context,) {
    return BoxDecoration(
      color: AppColors.lightBackground,
      borderRadius: context.border.normalBorderRadius,
      border: Border.all(color: AppColors.lightBorder),
    );
  }

  static BoxDecoration lightCardContainer({double borderRadius = 12}) {
    return BoxDecoration(
      color: AppColors.lightSurface,
      borderRadius: BorderRadius.circular(borderRadius),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.08),
          blurRadius: 8,
          offset: const Offset(0, 2),
        ),
      ],
    );
  }

  static BoxDecoration lightAccentContainer({
    required Color accentColor,
    BorderRadius borderRadius = BorderRadius.zero,
    double opacity = 0.1,
  }) {
    return BoxDecoration(
      color: accentColor.withValues(alpha: opacity),
      borderRadius: borderRadius,
      border: Border.all(color: accentColor.withValues(alpha: 0.3)),
    );
  }

  static BoxDecoration darkPrimaryContainer({double borderRadius = 12}) {
    return BoxDecoration(
      color: AppColors.darkSurface,
      borderRadius: BorderRadius.circular(borderRadius),
      border: Border.all(color: AppColors.darkBorder),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.3),
          blurRadius: 8,
          offset: const Offset(0, 2),
        ),
      ],
    );
  }

  static BoxDecoration darkSecondaryContainer(BuildContext context) {
    return BoxDecoration(
      color: AppColors.darkBackground,
      borderRadius: context.border.normalBorderRadius,
      border: Border.all(color: AppColors.darkBorder),
    );
  }

  static BoxDecoration darkCardContainer({double borderRadius = 12}) {
    return BoxDecoration(
      color: AppColors.darkSurface,
      borderRadius: BorderRadius.circular(borderRadius),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.5),
          blurRadius: 12,
          offset: const Offset(0, 4),
        ),
      ],
    );
  }

  static BoxDecoration darkAccentContainer({
    required Color accentColor,
    BorderRadius borderRadius = BorderRadius.zero,
    double opacity = 0.15,
  }) {
    return BoxDecoration(
      color: accentColor.withValues(alpha: opacity),
      borderRadius: borderRadius,
      border: Border.all(color: accentColor.withValues(alpha: 0.4)),
    );
  }

  static BoxDecoration primaryContainer(BuildContext context, {double borderRadius = 12}) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return isDark
        ? darkPrimaryContainer(borderRadius: borderRadius)
        : lightPrimaryContainer(borderRadius: borderRadius);
  }

  static BoxDecoration secondaryContainer(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return isDark
        ? darkSecondaryContainer(context)
        : lightSecondaryContainer(context);
  }

  static BoxDecoration cardContainer(BuildContext context, {double borderRadius = 12}) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return isDark
        ? darkCardContainer(borderRadius: borderRadius)
        : lightCardContainer(borderRadius: borderRadius);
  }

  static BoxDecoration accentContainer(
    BuildContext context, {
    required Color accentColor,
    required BorderRadius borderRadius,
    double opacity = 0.1,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return isDark
        ? darkAccentContainer(
            accentColor: accentColor,
            borderRadius: borderRadius,
            opacity: opacity + 0.05,
          )
        : lightAccentContainer(
            accentColor: accentColor,
            borderRadius: borderRadius,
            opacity: opacity,
          );
  }

  static BoxDecoration gradientContainer({
    required List<Color> colors,
    double borderRadius = 12,
    AlignmentGeometry begin = Alignment.topLeft,
    AlignmentGeometry end = Alignment.bottomRight,
  }) {
    return BoxDecoration(
      gradient: LinearGradient(
        colors: colors,
        begin: begin,
        end: end,
      ),
      borderRadius: BorderRadius.circular(borderRadius),
      boxShadow: [
        BoxShadow(
          color: colors.first.withValues(alpha: 0.3),
          blurRadius: 12,
          offset: const Offset(0, 4),
        ),
      ],
    );
  }

  static BoxDecoration glassContainer(BuildContext context, {double borderRadius = 12}) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return BoxDecoration(
      color: isDark
          ? AppColors.darkSurface.withValues(alpha: 0.7)
          : AppColors.lightSurface.withValues(alpha: 0.7),
      borderRadius: context.border.normalBorderRadius,
      border: Border.all(
        color: isDark
            ? AppColors.darkSurface.withValues(alpha: 0.5)
            : AppColors.lightBorder.withValues(alpha: 0.5),
      ),
      boxShadow: [
        BoxShadow(
          color:  Colors.black.withValues(alpha: isDark ? 0.3 : 0.1),
          blurRadius: 16,
          offset: const Offset(0, 4),
        ),
      ],
    );
  }
}

