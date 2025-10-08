
import 'package:farmodo/core/di/injection.dart';
import 'package:farmodo/core/theme/app_colors.dart';
import 'package:farmodo/core/utility/extension/dynamic_size_extension.dart';
import 'package:farmodo/core/utility/extension/sized_box_extension.dart';
import 'package:farmodo/data/services/auth_service.dart';
import 'package:farmodo/feature/leader_board/view/leader_board_view.dart';
import 'package:farmodo/feature/home/widgets/user_xp.dart';
import 'package:flutter/material.dart';
import 'package:get/route_manager.dart';
import 'package:kartal/kartal.dart';


class HomeHeader extends StatefulWidget {
  const HomeHeader({
    super.key,
  });

  @override
  State<HomeHeader> createState() => _HomeHeaderState();
}

class _HomeHeaderState extends State<HomeHeader> {
  @override
  Widget build(BuildContext context) {
    final authService = getIt<AuthService>();
    return 
      Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          UserXp(authService: authService),
           GestureDetector(
            onTap: () => Get.to(() => const LeaderBoardView()),
            child: Container(
              height: context.dynamicHeight(0.04),
              padding: context.padding.horizontalLow,
              decoration: BoxDecoration(
                color: AppColors.danger.withOpacity(0.1),
                borderRadius: context.border.lowBorderRadius,
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
      );
    }
  }



