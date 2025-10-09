import 'package:farmodo/core/theme/app_colors.dart';
import 'package:farmodo/core/theme/app_container_styles.dart';
import 'package:farmodo/core/utility/extension/dynamic_size_extension.dart';
import 'package:farmodo/core/utility/extension/sized_box_extension.dart';
import 'package:farmodo/data/services/auth_service.dart';
import 'package:farmodo/data/services/gamification/gamification_service.dart';
import 'package:flutter/material.dart';
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
            decoration: AppContainerStyles.secondaryContainer(context),
            child: Row(
              children: [
                Image.asset('assets/images/xp_star.png', height: context.dynamicHeight(0.03)),
                Text(
                  '${authService.currentUser?.xp ?? 0} XP',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          
          context.dynamicWidth(0.02).width,
          
          Container(
            height: context.dynamicHeight(0.04),
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: AppContainerStyles.secondaryContainer(context),
            child: Row(
              children: [
                Icon(
                  Icons.monetization_on,
                  color: AppColors.warning,
                  size: context.dynamicHeight(0.025),
                ),
                const SizedBox(width: 8),
                FutureBuilder<Map<String, int>>(
                  future: GamificationService().getUserStats(),
                  builder: (context, snapshot) {
                    final coins = snapshot.data?['coins'] ?? 0;
                    return Text(
                      '$coins Coin',
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
          
        ],
      ),
    );
  }
}