
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
            label: 'Tümü', 
            isSelected: controller.achievementFilter.value == 'Tümü', 
            onTap: () =>controller.setAchievementFilter('Tümü')),
          FilterChipWidget(
            label: 'Açık', 
            isSelected: controller.achievementFilter.value == 'Açık', 
            onTap: () => controller.setAchievementFilter('Açık')),
          FilterChipWidget(
            label: 'Kilitli', 
            isSelected: controller.achievementFilter.value == 'Kilitli', 
            onTap: () => controller.setAchievementFilter('Kilitli')),
          FilterChipWidget(
            label: 'Yaygın', 
            isSelected: controller.achievementFilter.value == 'Yaygın', 
            onTap: () => controller.setAchievementFilter('Yaygın')),
          FilterChipWidget(
            label: 'Nadir', 
            isSelected: controller.achievementFilter.value == 'Nadir', 
            onTap: () => controller.setAchievementFilter('Nadir')),
          FilterChipWidget(
            label: 'Az Bulunur', 
            isSelected: controller.achievementFilter.value == 'Az Bulunur', 
            onTap: () => controller.setAchievementFilter('Az Bulunur')),
          FilterChipWidget(
            label: 'Efsanevi', 
            isSelected: controller.achievementFilter.value == 'Efsanevi', 
            onTap: () => controller.setAchievementFilter('Efsanevi')),
          FilterChipWidget(
            label: 'Efsane',
            isSelected: controller.achievementFilter.value == 'Efsane', 
            onTap: () => controller.setAchievementFilter('Efsane')),
        ],
      )),
    );
  }
}

