
import 'package:farmodo/core/di/injection.dart';
import 'package:farmodo/core/extension/dynamic_size_extension.dart';
import 'package:farmodo/core/theme/app_colors.dart';
import 'package:farmodo/data/services/auth_service.dart';
import 'package:flutter/material.dart';

class HomeHeader extends StatelessWidget {
  const HomeHeader({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final authService = getIt<AuthService>();
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: context.dynamicWidth(0.05),
        vertical: context.dynamicHeight(0.02)),
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
          Row(
            children: [
              Expanded(child: LevelBar(authService: authService)),
              SizedBox(width: 24),
              UserXp(authService: authService),
            ],
          ),
          
        ],
      ),
    );
  }
}

class UserXp extends StatelessWidget {
  const UserXp({
    super.key,
    required this.authService,
  });

  final AuthService authService;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: context.dynamicHeight(0.05),
      padding: EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: [
          Color(0xff81BAE9),
          Color(0xff54CFA0)
        ]),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Image.asset('assets/images/xp_star.png', height: context.dynamicHeight(0.03)),
          SizedBox(width: 8),
          Text(
            '${authService.currentUser?.xp ?? 0} XP',
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  color: AppColors.surface,
                  fontWeight: FontWeight.w700,
                ),
          ),
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
              color: AppColors.danger.withOpacity(0.1),
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