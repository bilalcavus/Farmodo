import 'package:farmodo/core/di/injection.dart';
import 'package:farmodo/core/theme/app_colors.dart';
import 'package:farmodo/core/utility/extension/dynamic_size_extension.dart';
import 'package:farmodo/core/utility/extension/sized_box_extension.dart';
import 'package:farmodo/core/utility/mixin/loading_mixin.dart';
import 'package:farmodo/data/services/auth_service.dart';
import 'package:farmodo/feature/account/widget/login_prompt.dart';
import 'package:farmodo/feature/leader_board/viewmodel/leader_board_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get_state_manager/src/rx_flutter/rx_obx_widget.dart';
import 'package:kartal/kartal.dart';

class XpLeaderBoard extends StatefulWidget {
  const XpLeaderBoard({super.key, required this.controller});

  final LeaderBoardController controller;

  @override
  State<XpLeaderBoard> createState() => _XpLeaderBoardState();
}

const Map<int, String> thirdMap = {
  1: 'assets/images/first.png',
  2: 'assets/images/second.png',
  3: 'assets/images/third.png',
};

class _XpLeaderBoardState extends State<XpLeaderBoard> with LoadingMixin {
  @override
  Widget build(BuildContext context) {
    final authService = getIt<AuthService>();
    bool isLoggedIn = authService.isLoggedIn;
    if (!isLoggedIn) {
    return Center(
      child: Padding(
        padding: context.padding.horizontalNormal,
        child: LoginPrompt(
          context: context,
          title: "Log in to access all features",
          subtitle: "Log in to see leaderboard",
        ),
      ),
    );
  }
    
    return Obx(() {
  if (widget.controller.isLoading.value) {
    return const Center(child: CircularProgressIndicator());
  }

  if (widget.controller.xpLeaderboard.isEmpty) {
    return Center(
      child: Text("No leaderboard data yet"),
    );
  }

  return ListView.builder(
    padding: const EdgeInsets.symmetric(vertical: 8),
    itemCount: widget.controller.xpLeaderboard.length,
    itemBuilder: (context, index) {
      final user = widget.controller.xpLeaderboard[index];
      final isCurrentUser = getIt<AuthService>().currentUser?.id == user.id;
      final rank = index + 1;

      return _buildLeaderboardItem(
        context: context,
        theme: Theme.of(context),
        user: user,
        rank: rank,
        isCurrentUser: isCurrentUser,
        value: user.xp,
      );
    },
  );
});
    }
  
  }

  Widget _buildLeaderboardItem({
    required BuildContext context,
    required ThemeData theme,
    required dynamic user,
    required int rank,
    required bool isCurrentUser,
    required int value,
  }) {
    final rankColor = _getRankColor(rank);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: isCurrentUser 
            ? AppColors.primary.withAlpha(20) 
            : rank <= 3 
                ? rankColor.withAlpha(35)
                : isDark ? AppColors.darkSurface :  AppColors.surface,
        borderRadius: context.border.normalBorderRadius,
        border: isCurrentUser 
            ? Border.all(color: AppColors.primary.withAlpha(75), width: 1.5)
            : null
      ),
      child: Row(
        children: [
          Center(
            child: rank <= 3
            ? Image.asset(
                thirdMap[rank] ?? 'assets/images/user_avatar.png',
                height: 40,
                width: 40,
              )
            : Text(
                "$rank",
                style: theme.textTheme.bodySmall?.copyWith(
                  color: const Color(0xFF10B981),
                  fontWeight: FontWeight.w600,
                ),
              ),
          ),
          
          context.dynamicWidth(0.017).width,
          
          Expanded(
            child: Text(
              user.displayName,
              style: theme.textTheme.bodyLarge?.copyWith(
                color: isCurrentUser ? AppColors.primary : null,
                fontWeight: isCurrentUser ? FontWeight.w600 : FontWeight.w500,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: const Color(0xFFFFB800).withOpacity(0.1),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              "$value XP",
              style: theme.textTheme.bodyMedium?.copyWith(
                color: const Color(0xFFFFB800),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color _getRankColor(int rank) {
    switch (rank) {
      case 1:
        return const Color(0xFFFFD700); // Gold
      case 2:
        return const Color(0xFFC0C0C0); // Silver
      case 3:
        return const Color(0xFFCD7F32); // Bronze
      default:
        return AppColors.primary;
    }
  }

