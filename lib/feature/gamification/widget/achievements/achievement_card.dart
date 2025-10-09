import 'package:farmodo/core/theme/app_colors.dart';
import 'package:farmodo/core/utility/extension/dynamic_size_extension.dart';
import 'package:farmodo/core/utility/extension/ontap_extension.dart';
import 'package:farmodo/core/utility/extension/sized_box_extension.dart';
import 'package:farmodo/data/models/achievement_model.dart';
import 'package:flutter/material.dart';

class AchievementCard extends StatelessWidget {
  final Achievement achievement;
  final UserAchievement? userAchievement;
  final VoidCallback? onTap;

  const AchievementCard({
    super.key,
    required this.achievement,
    this.userAchievement,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isUnlocked = userAchievement?.isUnlocked ?? false;
    final progress = userAchievement?.progress ?? 0;
    final progressPercentage = (progress / achievement.targetValue).clamp(0.0, 1.0);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      margin: EdgeInsets.all(context.dynamicWidth(0.02)),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: isUnlocked ? achievement.rarityColor.withAlpha(25) : isDark ? AppColors.darkSurface : AppColors.lightSurface,
        border: Border.all(
          color: isUnlocked
              ? achievement.rarityColor.withAlpha(75)
              : isDark ? AppColors.darkBorder : AppColors.lightBorder,
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(25),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // Başarı ikonu ve durumu
          Expanded(
            flex: 3,
            child: Stack(
              children: [
                // Ana ikon
                Center(
                  child: Image.asset(
                    achievement.iconPath,
                    height: context.dynamicHeight(0.055),
                  
                  ),
                ),
                
                // Nadirlik ikonu
                Positioned(
                  top: context.dynamicHeight(0.01),
                  right: context.dynamicWidth(0.02),
                  child: Icon(
                    achievement.rarityIcon,
                    color: achievement.rarityColor,
                    size: context.dynamicHeight(0.025),
                  ),
                ),
                
                // Kilit durumu
                if (!isUnlocked)
                  Positioned(
                    top: context.dynamicHeight(0.01),
                    left: context.dynamicWidth(0.02),
                    child: Container(
                      padding: EdgeInsets.all(context.dynamicWidth(0.01)),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade600,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.lock,
                        color: Colors.white,
                        size: context.dynamicHeight(0.02),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          
          // Başarı bilgileri
          Expanded(
            flex: 4,
            child: Padding(
              padding: EdgeInsets.all(context.dynamicWidth(0.03)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Başlık
                  Text(
                    achievement.title,
                    style: Theme.of(context).textTheme.labelLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  
                  SizedBox(height: context.dynamicHeight(0.005)),
                  
                  // Açıklama
                  Text(
                    achievement.description,
                    style: Theme.of(context).textTheme.labelMedium,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  
                  const Spacer(),
                  
                  // İlerleme çubuğu
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            '$progress/${achievement.targetValue}',
                            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          if (isUnlocked)
                            Text(
                              '+${achievement.xpReward} XP',
                              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: achievement.rarityColor,
                              ),
                            ),
                        ],
                      ),
                      context.dynamicHeight(0.005).height,
                      LinearProgressIndicator(
                        value: progressPercentage,
                        backgroundColor: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          isUnlocked ? achievement.rarityColor : Colors.amber
                        ),
                        minHeight: context.dynamicHeight(0.008),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    ).onTap(onTap);
  }
}

