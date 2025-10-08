import 'package:farmodo/core/theme/app_colors.dart';
import 'package:farmodo/core/utility/extension/dynamic_size_extension.dart';
import 'package:farmodo/core/utility/extension/sized_box_extension.dart';
import 'package:farmodo/data/services/auth_service.dart';
import 'package:flutter/material.dart';
import 'package:kartal/kartal.dart';

class LevelBar extends StatelessWidget {
  const LevelBar({
    super.key,
    required this.authService,
  });

  final AuthService authService;

  @override
  Widget build(BuildContext context) {
    final int xp = authService.currentUser?.xp ?? 0;
    final int level = authService.currentUser?.level ?? 0;
    final int xpIntoLevel = xp % 100;
    final double progress = (xpIntoLevel.clamp(0, 100)) / 100.0;


    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Container(
          padding: EdgeInsets.symmetric(horizontal: context.dynamicWidth(0.02), vertical: context.dynamicHeight(0.005)),
          decoration: BoxDecoration(
            color: AppColors.danger.withAlpha(25),
            borderRadius: context.border.normalBorderRadius,
          ),
          child: Text(
            'Lv $level',
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  color: AppColors.danger,
                  fontWeight: FontWeight.w700,
                ),
          ),
        ),
        context.dynamicWidth(0.015).width,
        SizedBox(
          width: context.dynamicWidth(0.45),
          child: ClipRRect(
            borderRadius: context.border.lowBorderRadius,
            child: Stack(
              children: [
                Container(
                  height: context.dynamicHeight(0.012),
                  color: AppColors.border,
                ),
                FractionallySizedBox(
                  widthFactor: progress,
                  child: Container(
                    height: context.dynamicHeight(0.012),
                    color: AppColors.secondary,
                  ),
                ),
              ],
            ),
          ),
        ),
        context.dynamicWidth(0.02).width,
        Text(
          '$xpIntoLevel/100',
          style: Theme.of(context).textTheme.labelMedium?.copyWith(
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w600,
              ),
        ),
      ],
    );
  }
}