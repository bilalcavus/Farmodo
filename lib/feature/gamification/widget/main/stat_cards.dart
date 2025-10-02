
import 'package:farmodo/core/utility/extension/dynamic_size_extension.dart';
import 'package:farmodo/core/utility/extension/sized_box_extension.dart';
import 'package:farmodo/feature/gamification/viewmodel/gamification_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get_state_manager/src/rx_flutter/rx_obx_widget.dart';

class StatCards extends StatelessWidget {
  const StatCards({
    super.key,
    required this.gamificationController,
  });

  final GamificationController gamificationController;

  @override
  Widget build(BuildContext context) {
    return Container(
          padding: EdgeInsets.all(context.dynamicWidth(0.04)),
          child: Obx(() => Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  context,
                  'Achievements',
                  '${gamificationController.totalUnlockedAchievements}/${gamificationController.totalAchievements}',
                  Icons.emoji_events,
                  Colors.orange,
                  '${gamificationController.achievementPercentage.toStringAsFixed(1)}%',
                ),
              ),
              SizedBox(width: context.dynamicWidth(0.03)),
              Expanded(
                child: _buildStatCard(
                  context,
                  'Quests',
                  '${gamificationController.totalCompletedQuests}/${gamificationController.totalQuests}',
                  Icons.assignment_turned_in,
                  Colors.blue,
                  '${gamificationController.questCompletionPercentage.toStringAsFixed(1)}%',
                ),
              ),
              SizedBox(width: context.dynamicWidth(0.03)),
              Expanded(
                child: _buildStatCard(
                  context,
                  'Total XP',
                  '${gamificationController.totalEarnedXP}',
                  Icons.star,
                  Colors.purple,
                  'Gained',
                ),
              ),
            ],
          )),
        );
  }

  Widget _buildStatCard(BuildContext context, String title, String value, IconData icon, Color color, String subtitle) {
    return Container(
      padding: EdgeInsets.all(context.dynamicWidth(0.03)),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(context.dynamicHeight(0.016)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(25),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(
            icon,
            color: color,
            size: context.dynamicHeight(0.025),
          ),
          context.dynamicHeight(0.008).height,
          Text(
            value,
            style: TextStyle(
              fontSize: context.dynamicHeight(0.016),
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            title,
            style: TextStyle(
              fontSize: context.dynamicHeight(0.013),
              color: Colors.grey.shade600,
            ),
          ),
          Text(
            subtitle,
            style: TextStyle(
              fontSize: context.dynamicHeight(0.012),
              color: Colors.grey.shade500,
            ),
          ),
        ],
      ),
    );
  }
}
