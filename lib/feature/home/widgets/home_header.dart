
import 'package:farmodo/core/di/injection.dart';
import 'package:farmodo/core/theme/app_colors.dart';
import 'package:farmodo/core/utility/extension/dynamic_size_extension.dart';
import 'package:farmodo/data/services/auth_service.dart';
import 'package:farmodo/feature/tasks/widget/user_xp.dart';
import 'package:flutter/material.dart';

class HomeHeader extends StatelessWidget {
  const HomeHeader({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final authService = getIt<AuthService>();
    return Container(
      height: context.dynamicHeight(0.22),
      padding:EdgeInsets.symmetric(
        horizontal: context.dynamicWidth(0.05),
        vertical: context.dynamicHeight(0.02)), 
        decoration: BoxDecoration(
          color: AppColors.header,
          borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(context.dynamicHeight(0.05)),
            bottomRight: Radius.circular(context.dynamicHeight(0.05))
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.07),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.all(context.dynamicHeight(0.01)),
            child: Text(
              'Welcome, ${authService.currentUser?.displayName ?? ''} 👋',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          SizedBox(height: context.dynamicHeight(0.017)),
          UserXp(authService: authService),
          SizedBox(height: context.dynamicHeight(0.017)),
          LevelBar(authService: authService),
          
        ],
      ),
    );
  }
}


class LevelBar extends StatelessWidget {
  const LevelBar({
    super.key,
    required this.authService,
  });

  final AuthService authService;

  @override
  Widget build(BuildContext context) {
    final int xp = authService.currentUser?.xp ?? 0;
    final int level = (xp ~/ 100) + 1;
    final int xpIntoLevel = xp % 100;
    final double progress = (xpIntoLevel.clamp(0, 100)) / 100.0;

    return Container(
      height: context.dynamicHeight(0.05),
      padding: EdgeInsets.symmetric(horizontal: context.dynamicHeight(0.012)),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(context.dynamicHeight(0.024)),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.symmetric(horizontal: context.dynamicWidth(0.02), vertical: context.dynamicHeight(0.005)),
            decoration: BoxDecoration(
              color: AppColors.danger.withAlpha(25),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Text(
              'Lv $level',
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    color: AppColors.danger,
                    fontWeight: FontWeight.w700,
                  ),
            ),
          ),
          SizedBox(width: context.dynamicWidth(0.015)),
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Stack(
                children: [
                  Container(
                    height: 10,
                    color: AppColors.border,
                  ),
                  FractionallySizedBox(
                    widthFactor: progress,
                    child: Container(
                      height: 10,
                      color: AppColors.secondary,
                    ),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(width: 12),
          Text(
            '$xpIntoLevel/100',
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w600,
                ),
          ),
        ],
      ),
    );
  }
}