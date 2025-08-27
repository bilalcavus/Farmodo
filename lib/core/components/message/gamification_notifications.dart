import 'package:farmodo/data/models/achievement_model.dart';
import 'package:farmodo/data/models/quest_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class GamificationNotifications {
  static final GamificationNotifications _instance = GamificationNotifications._internal();
  factory GamificationNotifications() => _instance;
  GamificationNotifications._internal();

  // Başarı açılma snackbar'ını göster
  void showAchievementUnlocked(Achievement achievement) {
    // Animasyon sonrası snackbar göster
    Future.delayed(const Duration(seconds: 4), () {
      Get.snackbar(
        '🎉 Başarı Açıldı!',
        '${achievement.title}\n+${achievement.xpReward} XP kazandınız!',
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
      '✅ Görev Tamamlandı!',
      '${quest.title}\n$rewardText kazandınız!',
      snackPosition: SnackPosition.TOP,
      backgroundColor: quest.typeColor,
      colorText: Colors.white,
      duration: const Duration(seconds: 3),
    );
  }
}
