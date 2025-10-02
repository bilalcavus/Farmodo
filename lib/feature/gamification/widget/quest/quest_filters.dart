
import 'package:farmodo/core/utility/extension/dynamic_size_extension.dart';
import 'package:farmodo/feature/gamification/viewmodel/gamification_controller.dart';
import 'package:farmodo/feature/gamification/widget/main/filter_chip_widget.dart';
import 'package:flutter/material.dart';
import 'package:get/get_state_manager/src/rx_flutter/rx_obx_widget.dart';

class QuestFilters extends StatelessWidget {
  const QuestFilters({
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
            label: 'Active', 
            isSelected: controller.questFilter.value == 'Active', 
            onTap: () => controller.setQuestFilter('Active')),
          FilterChipWidget(
            label: 'Daily',
            isSelected: controller.questFilter.value == 'Daily', 
            onTap: () => controller.setQuestFilter('Daily')),
          FilterChipWidget(
            label: 'Weekly', 
            isSelected: controller.questFilter.value == 'Weekly', 
            onTap: () => controller.setQuestFilter('Weekly')),
          FilterChipWidget(
            label: 'Special',
            isSelected: controller.questFilter.value == 'Special', 
            onTap: () => controller.setQuestFilter('Special')),
          FilterChipWidget(
            label: 'Event', 
            isSelected: controller.questFilter.value == 'Event', 
            onTap: () => controller.setQuestFilter('Event')),
          FilterChipWidget(
            label: 'Completed',
            isSelected: controller.questFilter.value == 'Completed', 
            onTap: () => controller.setQuestFilter('Completed')),
        ],
      )),
    );
  }
}
