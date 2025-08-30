import 'package:farmodo/core/theme/app_colors.dart';
import 'package:farmodo/core/utility/extension/dynamic_size_extension.dart';
import 'package:farmodo/core/utility/extension/sized_box_extension.dart';
import 'package:farmodo/data/services/auth_service.dart';
import 'package:farmodo/data/services/gamification_service.dart';
import 'package:flutter/material.dart';

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
          // XP Container
          Container(
            height: context.dynamicHeight(0.04),
            padding: EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: [
                Color.fromARGB(255, 117, 84, 207),
                Color.fromARGB(255, 144, 93, 211),]),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: AppColors.border),
            ),
            child: Row(
              children: [
                Image.asset('assets/images/xp_star.png', height: context.dynamicHeight(0.03)),
                Text(
                  '${authService.currentUser?.xp ?? 0} XP',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        color: AppColors.surface,
                        fontWeight: FontWeight.w700,
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
              gradient: LinearGradient(colors: [
                Color(0xFFFFD700),
                Color(0xFFFFA500)
              ]),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: AppColors.border),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.monetization_on,
                  color: AppColors.surface,
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
                            color: AppColors.surface,
                            fontWeight: FontWeight.w700,
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
