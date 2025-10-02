
import 'package:farmodo/core/utility/extension/dynamic_size_extension.dart';
import 'package:farmodo/feature/gamification/viewmodel/gamification_controller.dart';
import 'package:farmodo/feature/gamification/widget/main/filter_chip_widget.dart';
import 'package:flutter/material.dart';
import 'package:get/get_state_manager/src/rx_flutter/rx_obx_widget.dart';

class AchievementsFilters extends StatelessWidget {
  const AchievementsFilters({
    super.key,
    required this.context,
    required this.controller,
  });

  final BuildContext context;
  final GamificationController controller;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: context.dynamicHeight(0.05),
      padding: EdgeInsets.symmetric(horizontal: context.dynamicWidth(0.02)),
      child: Obx(() => ListView(
        scrollDirection: Axis.horizontal,
        children: [
          FilterChipWidget(
            label: 'All', 
            isSelected: controller.achievementFilter.value == 'All', 
            onTap: () =>controller.setAchievementFilter('All')),
          FilterChipWidget(
            label: 'Unlocked', 
            isSelected: controller.achievementFilter.value == 'Unlocked', 
            onTap: () => controller.setAchievementFilter('Unlocked')),
          FilterChipWidget(
            label: 'Locked', 
            isSelected: controller.achievementFilter.value == 'Locked', 
            onTap: () => controller.setAchievementFilter('Locked')),
          FilterChipWidget(
            label: 'Widespread', 
            isSelected: controller.achievementFilter.value == 'Widespread', 
            onTap: () => controller.setAchievementFilter('Widespread')),
          FilterChipWidget(
            label: 'Rare', 
            isSelected: controller.achievementFilter.value == 'Rare', 
            onTap: () => controller.setAchievementFilter('Rare')),
          FilterChipWidget(
            label: 'Epic', 
            isSelected: controller.achievementFilter.value == 'Epic', 
            onTap: () => controller.setAchievementFilter('Epic')),
          FilterChipWidget(
            label: 'Legendary', 
            isSelected: controller.achievementFilter.value == 'Legendary', 
            onTap: () => controller.setAchievementFilter('Legendary')),
          FilterChipWidget(
            label: 'Legend',
            isSelected: controller.achievementFilter.value == 'Legend', 
            onTap: () => controller.setAchievementFilter('Legend')),
        ],
      )),
    );
  }
}

