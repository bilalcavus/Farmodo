import 'package:farmodo/data/models/achievement_model.dart';
import 'package:farmodo/data/models/quest_model.dart';
import 'package:flutter/material.dart';
import 'package:get/route_manager.dart';

class SnackMessages {
  SnackMessages();

  void showErrorSnack(String message) {
    Get.closeAllSnackbars();
    Get.snackbar(
      'Hata',
      message,
      snackPosition: SnackPosition.TOP,
      backgroundColor: Colors.red,
      colorText: Colors.white,
      duration: const Duration(seconds: 3),
    );
  }

  void showSuccessSnack(String message) {
    Get.closeAllSnackbars();
    Get.snackbar(
      'Başarılı',
      message,
      snackPosition: SnackPosition.TOP,
      backgroundColor: Colors.green.withAlpha(30),
      colorText: Colors.green,
      duration: const Duration(seconds: 3),
    );
  }

  void showUnlockedAchievementSnack(Achievement achievement){
    Get.snackbar(
        '🎉 Başarı Açıldı!',
        '${achievement.title}\n+${achievement.xpReward} XP kazandınız!',
        snackPosition: SnackPosition.TOP,
        backgroundColor: achievement.rarityColor,
        colorText: Colors.white,
        duration: const Duration(seconds: 3),
      );
  }

  void showQuestCompletedSnack(Quest quest, String rewardText){
    Get.snackbar(
      '✅ Görev Tamamlandı!',
      '${quest.title}\n$rewardText kazandınız!',
      snackPosition: SnackPosition.TOP,
      backgroundColor: quest.typeColor,
      colorText: Colors.white,
      duration: const Duration(seconds: 3),
    );
  }

  void showUpdateSnack(){
    Get.snackbar(
      'Updated!',
      'Updated animal status!',
      snackPosition: SnackPosition.TOP,
      backgroundColor: Colors.green,
      colorText: Colors.white,
      duration: const Duration(seconds: 2),
    );
  }

  void showAnimalAction(String message, Color color){
    Get.snackbar(
        'Başarılı!',
        message,
        snackPosition: SnackPosition.TOP,
        backgroundColor: color,
        colorText: Colors.white
    );
  }
}