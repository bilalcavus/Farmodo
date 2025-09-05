import 'package:farmodo/core/utility/extension/dynamic_size_extension.dart';
import 'package:farmodo/core/utility/extension/ontap_extension.dart';
import 'package:farmodo/data/models/quest_model.dart';
import 'package:flutter/material.dart';

class QuestCard extends StatelessWidget {
  final Quest quest;
  final UserQuest? userQuest;
  final VoidCallback? onTap;

  const QuestCard({
    super.key,
    required this.quest,
    this.userQuest,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isCompleted = userQuest?.status == QuestStatus.completed;
    final isExpired = quest.isExpired;
    final progress = userQuest?.progress ?? 0;
    final progressPercentage = (progress / quest.targetValue).clamp(0.0, 1.0);

    return Container(
      margin: EdgeInsets.all(context.dynamicWidth(0.02)),
      height: context.dynamicHeight(0.23),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isCompleted
              ? [
                  Colors.green.withAlpha(25),
                  Colors.green.withAlpha(15),
                ]
              : isExpired
                  ? [
                      Colors.red.withAlpha(25),
                      Colors.red.withAlpha(15),
                    ]
                  : [
                      quest.typeColor.withAlpha(25),
                      quest.typeColor.withAlpha(15),
                    ],
        ),
        border: Border.all(
          color: isCompleted
              ? Colors.green.withAlpha(75)
              : isExpired
                  ? Colors.red.withAlpha(75)
                  : quest.typeColor.withAlpha(75),
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
        mainAxisSize: MainAxisSize.min,
        children: [
          // Görev başlığı ve durumu
          Container(
            height: context.dynamicHeight(0.1),
            padding: EdgeInsets.all(context.dynamicWidth(0.03)),
            child: Row(
              children: [
                // Görev ikonu
                Container(
                  width: context.dynamicWidth(0.08),
                  height: context.dynamicHeight(0.05),
                  decoration: BoxDecoration(
                    color: quest.typeColor.withAlpha(50),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    quest.actionIcon,
                    color: quest.typeColor,
                    size: context.dynamicHeight(0.025),
                  ),
                ),
                
                SizedBox(width: context.dynamicWidth(0.03)),
                
                // Görev başlığı ve tipi
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        quest.title,
                        style: Theme.of(context).textTheme.labelLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: isCompleted || isExpired ? Colors.black87 : Colors.black87,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      
                      Text(
                        _getQuestTypeText(quest.type),
                        style: Theme.of(context).textTheme.labelMedium?.copyWith(
                          color: quest.typeColor,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                
                // Durum ikonu
                Container(
                  padding: EdgeInsets.all(context.dynamicWidth(0.01)),
                  decoration: BoxDecoration(
                    color: isCompleted
                        ? Colors.green
                        : isExpired
                            ? Colors.red
                            : quest.typeColor,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    isCompleted
                        ? Icons.check
                        : isExpired
                            ? Icons.close
                            : Icons.schedule,
                    color: Colors.white,
                    size: context.dynamicHeight(0.02),
                  ),
                ),
              ],
            ),
          ),
          
          // Görev açıklaması
          Text(
            quest.description,
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
              color: isCompleted || isExpired ? Colors.black54 : Colors.black54,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          
          // İlerleme ve ödüller
          Container(
            height: context.dynamicHeight(0.1),
            padding: EdgeInsets.all(context.dynamicWidth(0.03)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // İlerleme çubuğu
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '$progress/${quest.targetValue}',
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        fontWeight: FontWeight.w500,
                        color: isCompleted || isExpired ? Colors.black54 : Colors.black54,
                      ),
                    ),
                    if (isCompleted)
                      Text(
                        'Tamamlandı!',
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Colors.green,
                        ),
                      ),
                  ],
                ),
                
                SizedBox(height: context.dynamicHeight(0.005)),
                
                LinearProgressIndicator(
                  value: progressPercentage,
                  backgroundColor: Colors.grey.shade300,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    isCompleted
                        ? Colors.green
                        : isExpired
                            ? Colors.red
                            : quest.typeColor,
                  ),
                  minHeight: context.dynamicHeight(0.008),
                ),
                
                SizedBox(height: context.dynamicHeight(0.01)),
                
                // Ödüller
                Row(
                  children: [
                    if (quest.xpReward > 0)
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: context.dynamicWidth(0.02), 
                          vertical: context.dynamicHeight(0.005)
                        ),
                        decoration: BoxDecoration(
                          color: Colors.blue.withAlpha(25),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.star,
                              color: Colors.blue,
                              size: context.dynamicHeight(0.018),
                            ),
                            SizedBox(width: context.dynamicWidth(0.01)),
                            Text(
                              '+${quest.xpReward} XP',
                              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: Colors.blue,
                              ),
                            ),
                          ],
                        ),
                      ),
                    
                    if (quest.xpReward > 0 && quest.coinReward > 0)
                      SizedBox(width: context.dynamicWidth(0.02)),
                    
                    if (quest.coinReward > 0)
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: context.dynamicWidth(0.02), 
                          vertical: context.dynamicHeight(0.005)
                        ),
                        decoration: BoxDecoration(
                          color: Colors.orange.withAlpha(25),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.monetization_on,
                              color: Colors.orange,
                              size: context.dynamicHeight(0.018),
                            ),
                            SizedBox(width: context.dynamicWidth(0.01)),
                            Text(
                              '+${quest.coinReward} Coin',
                              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: Colors.orange,
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    ).onTap(onTap);
  }

  String _getQuestTypeText(QuestType type) {
    switch (type) {
      case QuestType.daily:
        return 'Günlük Görev';
      case QuestType.weekly:
        return 'Haftalık Görev';
      case QuestType.special:
        return 'Özel Görev';
      case QuestType.event:
        return 'Etkinlik Görevi';
    }
  }
}

