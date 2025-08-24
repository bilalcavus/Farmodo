import 'package:farmodo/core/utility/extension/dynamic_size_extension.dart';
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

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: EdgeInsets.all(context.dynamicWidth(0.02)),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: isUnlocked
                ? [
                    achievement.rarityColor.withOpacity(0.1),
                    achievement.rarityColor.withOpacity(0.05),
                  ]
                : [
                    Colors.grey.shade100,
                    Colors.grey.shade50,
                  ],
          ),
          border: Border.all(
            color: isUnlocked
                ? achievement.rarityColor.withOpacity(0.3)
                : Colors.grey.shade300,
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
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
                    child: Container(
                      width: context.dynamicWidth(0.12),
                      height: context.dynamicHeight(0.08),
                      decoration: BoxDecoration(
                        color: isUnlocked
                            ? achievement.rarityColor.withOpacity(0.2)
                            : Colors.grey.shade200,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.emoji_events,
                        size: context.dynamicHeight(0.04),
                        color: isUnlocked
                            ? achievement.rarityColor
                            : Colors.grey.shade400,
                      ),
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
                        color: isUnlocked ? Colors.black87 : Colors.grey.shade600,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    
                    SizedBox(height: context.dynamicHeight(0.005)),
                    
                    // Açıklama
                    Text(
                      achievement.description,
                      style: Theme.of(context).textTheme.labelMedium?.copyWith(
                        color: isUnlocked ? Colors.black54 : Colors.grey.shade500,
                      ),
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
                                color: isUnlocked ? Colors.black54 : Colors.grey.shade600,
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
                          backgroundColor: Colors.grey.shade300,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            isUnlocked ? achievement.rarityColor : Colors.grey.shade400,
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
      ),
    );
  }
}

