
import 'package:easy_localization/easy_localization.dart';
import 'package:farmodo/core/theme/app_container_styles.dart';
import 'package:farmodo/core/utility/extension/dynamic_size_extension.dart';
import 'package:farmodo/core/utility/extension/sized_box_extension.dart';
import 'package:farmodo/data/models/achievement_model.dart';
import 'package:farmodo/feature/gamification/viewmodel/gamification_controller.dart';
import 'package:farmodo/feature/gamification/widget/achievements/achievement_card.dart';
import 'package:farmodo/feature/gamification/widget/achievements/achievements_filters.dart';
import 'package:farmodo/feature/gamification/widget/main/empty_state.dart';
import 'package:farmodo/feature/gamification/widget/main/sheet_divider.dart';
import 'package:flutter/material.dart';
import 'package:get/get_state_manager/src/rx_flutter/rx_obx_widget.dart';
import 'package:hugeicons/hugeicons.dart';

class AchievementsTab extends StatelessWidget {
  const AchievementsTab({
    super.key,
    required this.gamificationController,
    required this.context,
  });

  final GamificationController gamificationController;
  final BuildContext context;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (gamificationController.isLoadingAchievements.value) {
        return const Center(child: CircularProgressIndicator());
      }
    
      if (gamificationController.achievements.isEmpty) {
        return EmptyState(
          icon: HugeIcons.strokeRoundedChampion,
          title: 'gamification.no_achievements'.tr(),
          subtitle: 'gamification.no_achievements_desc'.tr(),
          context: context);
        }
    
      return RefreshIndicator(
        onRefresh: () => gamificationController.refreshGamification(),
        child: Column(
          children: [
            AchievementsFilters(context: context, controller: gamificationController),
            Expanded(
              child: GridView.builder(
                padding: EdgeInsets.all(context.dynamicWidth(0.02)),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: context.dynamicWidth(0.02),
                  mainAxisSpacing: context.dynamicWidth(0.02),
                  childAspectRatio: 0.8,
                ),
                itemCount: gamificationController.filteredAchievements.length,
                itemBuilder: (context, index) {
                  final achievement = gamificationController.filteredAchievements[index];
                  final userAchievement = gamificationController.getUserAchievement(achievement.id);
                  if (gamificationController.filteredAchievements.isEmpty) {
                    return Center(child: Text('gamification.no_achievements_found'.tr()));
                    } else {
                    return AchievementCard(
                      achievement: achievement,
                      userAchievement: userAchievement,
                      onTap: () => _showAchievementDetail(achievement, userAchievement),
                    );
                  }
                },
              ),
            ),
          ],
        ),
      );
    });
  }
  void _showAchievementDetail(Achievement achievement, userAchievement) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: context.dynamicHeight(0.6),
        decoration: AppContainerStyles.secondaryContainer(context),
        padding: EdgeInsets.all(context.dynamicWidth(0.05)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SheetDivider(),
            context.dynamicHeight(0.02).height,
            Row(
              children: [
                Image.asset(
                  achievement.iconPath,
                  height: context.dynamicHeight(0.15),
                  errorBuilder: (context, error, stackTrace) {
                    return Icon(Icons.emoji_events);
                },),
                context.dynamicWidth(0.04).width,
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        achievement.title.tr(),
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold
                        )
                      ),
                      Text(
                        achievement.description.tr(),
                        style: Theme.of(context).textTheme.labelLarge
                      ),
                    ],
                  ),
                ),
              ],
            ),
            context.dynamicHeight(0.03).height,
            if (userAchievement != null) ...[
              Text(
                'gamification.progress'.tr(),
                style: Theme.of(context).textTheme.labelLarge
              ),
              context.dynamicHeight(0.01).height,
              LinearProgressIndicator(
                value: (userAchievement.progress / achievement.targetValue).clamp(0.0, 1.0),
                backgroundColor: Colors.grey.shade300,
                valueColor: AlwaysStoppedAnimation<Color>(achievement.rarityColor),
                minHeight: 8,
              ),
              context.dynamicHeight(0.01).height,
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${userAchievement.progress}/${achievement.targetValue}',
                    style: Theme.of(context).textTheme.bodyMedium
                  ),
                  if (userAchievement.isUnlocked)
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: context.dynamicWidth(0.03), 
                        vertical: context.dynamicHeight(0.005)
                      ),
                      decoration: BoxDecoration(
                        color: Colors.green.withAlpha(25),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '✅ ${'gamification.unlocked'.tr()}!',
                        style: Theme.of(context).textTheme.labelMedium?.copyWith(
                          color: Colors.green,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                ],
              ),
            ],
            context.dynamicHeight(0.03).height,
            Column(
              children: [
                RewardContainer(
                  achievement: achievement,
                  title: '+${achievement.xpReward} ${'gamification.xp_reward'.tr()}',
                  icon: Icons.star,
                ),
                context.dynamicHeight(0.01).height,
                RewardContainer(
                  achievement: achievement,
                  title: '+${achievement.coinReward} ${'gamification.coin_reward'.tr()}',
                  icon: Icons.monetization_on
                )
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class RewardContainer extends StatelessWidget {
  const RewardContainer({
    super.key, required this.achievement, required this.title, required this.icon,
  });

  final Achievement achievement;
  final String title;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(context.dynamicWidth(0.04)),
      decoration: BoxDecoration(
        color: achievement.rarityColor.withAlpha(25),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(
            icon,
            color: achievement.rarityColor,
            size: context.dynamicHeight(0.03),
          ),
          context.dynamicWidth(0.03).width,
          Text(
            title,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: achievement.rarityColor,
            ),
          ),
        ],
      ),
    );
  }
}

