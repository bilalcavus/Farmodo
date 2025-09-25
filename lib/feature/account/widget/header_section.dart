import 'package:farmodo/core/theme/app_colors.dart';
import 'package:farmodo/core/utility/extension/dynamic_size_extension.dart';
import 'package:farmodo/core/utility/extension/sized_box_extension.dart';
import 'package:farmodo/data/services/auth_service.dart';
import 'package:farmodo/feature/account/widget/user_avatar.dart';
import 'package:flutter/material.dart';
import 'package:kartal/kartal.dart';

class HeaderSection extends StatelessWidget {
  const HeaderSection({
    super.key,
    required this.context,
    required this.handleText,
    required this.joinedYearText,
    required this.isLoadingStats,
    required this.authService,
    required this.tasksCompleted,
    required this.totalXp, required this.daysActive
  });

  final BuildContext context;
  final AuthService authService;
  final String handleText;
  final String joinedYearText;
  final bool isLoadingStats;
  final int tasksCompleted;
  final int totalXp;
  final int daysActive;

  @override
  Widget build(BuildContext context) {
    final user = authService.firebaseUser;
    final displayName = authService.currentUser?.displayName.isNotEmpty == true
        ? authService.currentUser!.displayName
        : (authService.firebaseUser?.displayName ?? 'Guest User');
    return Container(
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: context.border.highBorderRadius,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(25),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          context.dynamicHeight(0.01).height,
          Center(
            child: UserAvatar(user: user, fontSize: 16, radius: context.dynamicHeight(0.05))
          ),
          context.dynamicHeight(0.02).height,
          Text(
            displayName,
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: context.dynamicHeight(0.028),
              fontWeight: FontWeight.w700,
            ),
            textAlign: TextAlign.center,
          ),
          context.dynamicHeight(0.006).height,
          Text(
            handleText,
            style: TextStyle(color: AppColors.textPrimary, fontSize: context.dynamicHeight(0.017), fontWeight: FontWeight.w500),
          ),
          context.dynamicHeight(0.006).height,
          if (joinedYearText.isNotEmpty)
            Text(
              'Joined $joinedYearText',
              style: TextStyle(color: AppColors.textPrimary, fontSize: context.dynamicHeight(0.017)),
            ),
          context.dynamicHeight(0.02).height,
          if (isLoadingStats)
            Center(child: CircularProgressIndicator(color: AppColors.primary))
          else ...[
            Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    title: 'Tasks Completed',
                    value: tasksCompleted.toString(),
                  ),
                ),
                context.dynamicWidth(0.03).width,
                Expanded(
                  child: _buildStatCard(
                    title: 'Total XP',
                    value: totalXp.toString(),
                  ),
                ),
              ],
            ),
            context.dynamicHeight(0.015).height,
            _buildStatCard(title: 'Days Active', value: daysActive.toString(), isWide: true)
          ],
          context.dynamicHeight(0.02).height,
        ],
      ),
    );
  }
    Widget _buildStatCard({required String title, required String value, bool isWide = false}) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          value,
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: context.dynamicHeight(0.025),
            fontWeight: FontWeight.w700,
          ),
        ),
        context.dynamicHeight(0.006).height,
        Text(
          title,
          style: TextStyle(color: Colors.grey.shade600, fontSize: context.dynamicHeight(0.016)),
        ),
      ],
    );
  }
}
