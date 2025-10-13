import 'package:easy_localization/easy_localization.dart';
import 'package:farmodo/data/models/achievement_model.dart';
import 'package:farmodo/data/models/quest_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart' hide Trans;

class GamificationNotifications {
  static final GamificationNotifications _instance = GamificationNotifications._internal();
  factory GamificationNotifications() => _instance;
  GamificationNotifications._internal();

  // Başarı açılma snackbar'ını göster
  void showAchievementUnlocked(Achievement achievement) {
    Future.delayed(const Duration(seconds: 4), () {
      Get.snackbar(
        'gamification.achievement_unlocked_title'.tr(),
        '${achievement.title.tr()}\n+${achievement.xpReward} ${'gamification.achievement_xp_gained'.tr()}',
        snackPosition: SnackPosition.TOP,
        backgroundColor: achievement.rarityColor,
        colorText: Colors.white,
        duration: const Duration(seconds: 3),
      );
    });
  }

  // Görev tamamlama snackbar'ını göster
  void showQuestCompleted(Quest quest) {
    String rewardText = '+${quest.xpReward} XP';
    if (quest.coinReward > 0) {
      rewardText += ' +${quest.coinReward} Coin';
    }
    
    Get.snackbar(
      'gamification.quest_completed_title'.tr(),
      '${quest.title.tr()}\n$rewardText ${'gamification.quest_rewards_gained'.tr()}',
      snackPosition: SnackPosition.TOP,
      backgroundColor: quest.typeColor,
      colorText: Colors.white,
      duration: const Duration(seconds: 3),
    );
  }
}
