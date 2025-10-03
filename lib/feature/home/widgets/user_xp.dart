import 'package:farmodo/core/theme/app_colors.dart';
import 'package:farmodo/core/utility/extension/dynamic_size_extension.dart';
import 'package:farmodo/core/utility/extension/sized_box_extension.dart';
import 'package:farmodo/data/services/auth_service.dart';
import 'package:farmodo/data/services/gamification/gamification_service.dart';
import 'package:farmodo/feature/leader_board/view/leader_board_view.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kartal/kartal.dart';

class UserXp extends StatelessWidget {
  const UserXp({
    super.key,
    required this.authService,
  });

  final AuthService authService;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(context.dynamicHeight(0.02)),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            height: context.dynamicHeight(0.04),
            padding: context.padding.horizontalLow,
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.border),
            ),
            child: Row(
              children: [
                Image.asset('assets/images/xp_star.png', height: context.dynamicHeight(0.03)),
                Text(
                  '${authService.currentUser?.xp ?? 0} XP',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          
          context.dynamicWidth(0.02).width,
          
          // Coin Container
          Container(
            height: context.dynamicHeight(0.04),
            padding: EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.border),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.monetization_on,
                  color: Colors.amber,
                  size: context.dynamicHeight(0.025),
                ),
                SizedBox(width: 8),
                FutureBuilder<Map<String, int>>(
                  future: GamificationService().getUserStats(),
                  builder: (context, snapshot) {
                    final coins = snapshot.data?['coins'] ?? 0;
                    return Text(
                      '$coins Coin',
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.w500,
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
          
          context.dynamicWidth(0.02).width,
          
          GestureDetector(
            onTap: () => Get.to(() => const LeaderBoardView()),
            child: Container(
              height: context.dynamicHeight(0.04),
              padding: EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color: AppColors.danger.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.danger.withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.emoji_events_rounded,
                    color: AppColors.danger,
                    size: context.dynamicHeight(0.025),
                  ),
                  context.dynamicWidth(0.01).width,
                  Text(
                    'Leaderboard',
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      color: AppColors.danger,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}