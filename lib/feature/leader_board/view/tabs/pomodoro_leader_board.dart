import 'package:farmodo/core/di/injection.dart';
import 'package:farmodo/core/theme/app_colors.dart';
import 'package:farmodo/core/utility/extension/dynamic_size_extension.dart';
import 'package:farmodo/core/utility/extension/sized_box_extension.dart';
import 'package:farmodo/core/utility/mixin/loading_mixin.dart';
import 'package:farmodo/data/services/auth_service.dart';
import 'package:farmodo/feature/account/widget/login_prompt.dart';
import 'package:farmodo/feature/leader_board/viewmodel/leader_board_controller.dart';
import 'package:flutter/material.dart';
import 'package:kartal/kartal.dart';

class PomodoroLeaderBoard extends StatefulWidget {
  const PomodoroLeaderBoard({super.key, required this.controller});

  final LeaderBoardController controller;

  @override
  State<PomodoroLeaderBoard> createState() => _XpLeaderBoardState();
}

class _XpLeaderBoardState extends State<PomodoroLeaderBoard> with LoadingMixin {
  final thirdMap = {
    1: 'assets/images/first.png',
    2: 'assets/images/second.png',
    3: 'assets/images/third.png',
  };
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final authService = getIt<AuthService>();
    bool isLoggedIn = authService.isLoggedIn;
    
    return ValueListenableBuilder<bool>(
      valueListenable: isLoadingNotifier,
      builder: (context, loading, _) {
        if (loading) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }
        
        return !isLoggedIn ? Center(
          child: Padding(
            padding: context.padding.horizontalNormal,
            child: LoginPrompt(
              context: context, 
              title: "Log in to access all features", 
              subtitle: "Log in to see leaderboard",
            ),
          )
        ) : ListView.builder(
          padding: const EdgeInsets.symmetric(vertical: 8),
          itemCount: widget.controller.pomodoroLeaderboard.length,
          itemBuilder: (context, index) {
            final user = widget.controller.pomodoroLeaderboard[index];
            final authService = getIt<AuthService>();
            bool isCurrentUser = authService.currentUser?.id == user.id;
            final rank = index + 1;
            
            return _buildLeaderboardItem(
              context: context,
              theme: theme,
              user: user,
              rank: rank,
              isCurrentUser: isCurrentUser,
              value: user.totalPomodoro,
            );
          },
        );
      },
    );
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
                ? rankColor.withAlpha(15)
                : isDark ? AppColors.darkSurface :  AppColors.surface,
        borderRadius: context.border.normalBorderRadius,
        border: isCurrentUser 
            ? Border.all(color: AppColors.primary.withAlpha(75), width: 1)
            : null,
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
              color: const Color(0xFF10B981).withOpacity(0.1),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              "$value Pomodoros",
              style: theme.textTheme.bodyMedium?.copyWith(
                color: const Color(0xFF10B981),
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
}
