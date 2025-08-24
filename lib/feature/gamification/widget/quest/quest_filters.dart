
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
            label: 'Aktif', 
            isSelected: controller.questFilter.value == 'Aktif', 
            onTap: () => controller.setQuestFilter('Aktif')),
          FilterChipWidget(
            label: 'Günlük',
            isSelected: controller.questFilter.value == 'Günlük', 
            onTap: () => controller.setQuestFilter('Günlük')),
          FilterChipWidget(
            label: 'Haftalık', 
            isSelected: controller.questFilter.value == 'Haftalık', 
            onTap: () => controller.setQuestFilter('Haftalık')),
          FilterChipWidget(
            label: 'Özel',
            isSelected: controller.questFilter.value == 'Özel', 
            onTap: () => controller.setQuestFilter('Özel')),
          FilterChipWidget(
            label: 'Etkinlik', 
            isSelected: controller.questFilter.value == 'Etkinlik', 
            onTap: () => controller.setQuestFilter('Etkinlik')),
          FilterChipWidget(
            label: 'Tamamlanan',
            isSelected: controller.questFilter.value == 'Tamamlanan', 
            onTap: () => controller.setQuestFilter('Tamamlanan')),
        ],
      )),
    );
  }
}
