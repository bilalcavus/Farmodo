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
    return !isLoggedIn ? Center(
            child: Padding(
              padding: context.padding.horizontalNormal,
              child: LoginPrompt(context: context, title: "Log in to access all features", subtitle: "Log in to see leaderboard",),
        )
      ): Scaffold(
      body: ValueListenableBuilder<bool>(
        valueListenable: isLoadingNotifier,
        builder: (context, loading, _) {
          if (loading) {
            return const Center(child: CircularProgressIndicator());
          }
          return SizedBox(
            height: double.infinity,
            child: ListView.builder(
              itemCount: widget.controller.pomodoroLeaderboard.length,
              itemBuilder: (context, index) {
                final user = widget.controller.pomodoroLeaderboard[index];
                final authService = getIt<AuthService>();
                bool isCurrentUser = authService.currentUser?.id == user.id; 
                return Column(
                  children: [
                    ListTile(
                      title: Row(
                        children: [
                          Image.asset(thirdMap[index + 1] ?? 'assets/images/user_avatar.png', height: context.dynamicHeight(.05)),
                          Text(user.displayName, style: theme.textTheme.bodyLarge?.copyWith(
                            color: isCurrentUser ? AppColors.primary : null,
                            fontWeight: isCurrentUser ? FontWeight.bold : FontWeight.w500
                          )),
                          context.dynamicWidth(0.01).width,
                          if(isCurrentUser) Text('(You)', style: theme.textTheme.bodySmall?.copyWith(
                            color: Colors.grey.shade600
                          ))
                        ],
                      ),
                      leading: Text("${index + 1}"),
                      trailing: Text("${user.totalPomodoro}", style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.bold
                      )),
                    ),
                    
                  ],
                );
              },
            ),
          );
        },
      ),
    );
  }
}
