import 'package:easy_localization/easy_localization.dart';
import 'package:farmodo/data/models/achievement_model.dart';
import 'package:farmodo/data/models/quest_model.dart';
import 'package:flutter/material.dart';
import 'package:get/route_manager.dart';

class SnackMessages {
  SnackMessages();

  void showErrorSnack(String message) {
    Get.closeAllSnackbars();
    Get.snackbar(
      'messages.error_title'.tr(),
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
      'messages.success_title'.tr(),
      message,
      snackPosition: SnackPosition.TOP,
      backgroundColor: Colors.green.withAlpha(30),
      colorText: Colors.green,
      duration: const Duration(seconds: 3),
    );
  }

  void showUnlockedAchievementSnack(Achievement achievement){
    Get.snackbar(
        'gamification.achievement_unlocked_title'.tr(),
        '${achievement.title.tr()}\n+${achievement.xpReward} ${'gamification.achievement_xp_gained'.tr()}',
        snackPosition: SnackPosition.TOP,
        backgroundColor: achievement.rarityColor,
        colorText: Colors.white,
        duration: const Duration(seconds: 3),
      );
  }

  void showQuestCompletedSnack(Quest quest, String rewardText){
    Get.snackbar(
      'gamification.quest_completed_title'.tr(),
      '${quest.title.tr()}\n$rewardText ${'gamification.quest_rewards_gained'.tr()}',
      snackPosition: SnackPosition.TOP,
      backgroundColor: quest.typeColor,
      colorText: Colors.white,
      duration: const Duration(seconds: 3),
    );
  }

  void showUpdateSnack(){
    Get.snackbar(
      'messages.updated'.tr(),
      'messages.animal_status_updated'.tr(),
      snackPosition: SnackPosition.TOP,
      backgroundColor: Colors.green,
      colorText: Colors.white,
      duration: const Duration(seconds: 2),
    );
  }

  void showAnimalAction(String message, Color color){
    Get.snackbar(
        'messages.successful'.tr(),
        message,
        snackPosition: SnackPosition.TOP,
        backgroundColor: color,
        colorText: Colors.white
    );
  }
}