import 'package:farmodo/core/utility/extension/dynamic_size_extension.dart';
import 'package:farmodo/core/utility/extension/sized_box_extension.dart';
import 'package:farmodo/data/models/quest_model.dart';
import 'package:farmodo/feature/gamification/viewmodel/gamification_controller.dart';
import 'package:farmodo/feature/gamification/widget/main/empty_state.dart';
import 'package:farmodo/feature/gamification/widget/main/sheet_divider.dart';
import 'package:farmodo/feature/gamification/widget/quest/quest_card.dart';
import 'package:farmodo/feature/gamification/widget/quest/quest_filters.dart';
import 'package:flutter/material.dart';
import 'package:get/get_state_manager/src/rx_flutter/rx_obx_widget.dart';
import 'package:hugeicons/hugeicons.dart';

class QuestsTab extends StatelessWidget {
  const QuestsTab({
    super.key,
    required this.gamificationController,
    required this.context,
  });

  final GamificationController gamificationController;
  final BuildContext context;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (gamificationController.isLoadingQuests.value) {
        return const Center(child: CircularProgressIndicator());
      }
    
      if (gamificationController.quests.isEmpty) {
        return EmptyState(
          context: context,
          title: 'Henüz görev yok',
          subtitle: 'Görevler yakında eklenecek!',
          icon: HugeIcons.strokeRoundedStickyNote01,
        );
      }
    
      
    
      return RefreshIndicator(
        onRefresh: () => gamificationController.refreshGamification(),
        child: Column(
          children: [
            QuestFilters(context: context, controller: gamificationController),
            Expanded(
              child: ListView.builder(
                padding: EdgeInsets.all(context.dynamicWidth(0.02)),
                itemCount: gamificationController.filteredQuests.length,
                itemBuilder: (context, index) {
                  final quest = gamificationController.filteredQuests[index];
                  final userQuest = gamificationController.getUserQuest(quest.id);
                  if (gamificationController.filteredQuests.isEmpty) {
                    return EmptyState(
                      context: context,
                      title: 'Filtrelenmiş görev yok',
                      subtitle: 'Seçilen filtrelere uygun görev bulunamadı',
                      icon: HugeIcons.strokeRoundedStickyNote01,
                    );
                  }
                  return QuestCard(
                    quest: quest,
                    userQuest: userQuest,
                    onTap: () => _showQuestDetail(quest, userQuest),
                  );
                },
              ),
            ),
          ],
        ),
      );
    });
  }

  void _showQuestDetail(quest, userQuest) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) => Container(
      height: context.dynamicHeight(0.6),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      padding: EdgeInsets.all(context.dynamicWidth(0.05)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SheetDivider(),
          context.dynamicHeight(0.02).height,
          _buildQuestHeader(context, quest),
          context.dynamicHeight(0.03).height,
          if (userQuest != null) _buildProgress(context, quest, userQuest),
          context.dynamicHeight(0.03).height,
          _buildRewards(context, quest),
          ],
        ),
      ),
    );
  }
  Widget _buildQuestHeader(BuildContext context, quest) {
  return Row(
    children: [
      Container(
        width: context.dynamicWidth(0.12),
        height: context.dynamicHeight(0.08),
        decoration: BoxDecoration(
          color: quest.typeColor.withOpacity(0.2),
          shape: BoxShape.circle,
        ),
        child: Icon(
          quest.actionIcon,
          size: context.dynamicHeight(0.04),
          color: quest.typeColor,
        ),
      ),
      context.dynamicWidth(0.04).width,
      Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(quest.title, style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(quest.description, style: Theme.of(context).textTheme.labelLarge?.copyWith(
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ),
      ),
    ],
  );
}
Widget _buildProgress(BuildContext context, quest, userQuest) {
  final progress = (userQuest.progress / quest.targetValue).clamp(0.0, 1.0);

  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        'Progress',
        style: Theme.of(context).textTheme.labelLarge?.copyWith(
              color: Colors.grey.shade700,
            ),
      ),
      context.dynamicHeight(0.01).height,
      LinearProgressIndicator(
        value: progress,
        backgroundColor: Colors.grey.shade300,
        valueColor: AlwaysStoppedAnimation<Color>(quest.typeColor),
        minHeight: context.dynamicHeight(0.01),
      ),
      context.dynamicHeight(0.01).height,
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            '${userQuest.progress}/${quest.targetValue}',
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  color: Colors.grey.shade600,
                ),
          ),
          if (userQuest.status == QuestStatus.completed)
            _buildCompletedBadge(context),
        ],
      ),
    ],
  );
}

Widget _buildCompletedBadge(BuildContext context) {
  return Container(
    padding: EdgeInsets.symmetric(
      horizontal: context.dynamicWidth(0.03),
      vertical: context.dynamicHeight(0.005),
    ),
    decoration: BoxDecoration(
      color: Colors.green.withAlpha(25),
      borderRadius: BorderRadius.circular(12),
    ),
    child: Text(
      '✅ Completed!',
      style: Theme.of(context).textTheme.labelMedium?.copyWith(
            color: Colors.green,
            fontWeight: FontWeight.bold,
          ),
    ),
  );
}
Widget _buildRewards(BuildContext context, quest) {
  final rewards = <Widget>[];

  if (quest.xpReward > 0) {
    rewards.add(_RewardCard(
      color: Colors.blue,
      icon: Icons.star,
      text: '+${quest.xpReward} XP',
    ));
  }

  if (quest.coinReward > 0) {
    if (rewards.isNotEmpty) {
      rewards.add(SizedBox(width: context.dynamicWidth(0.03)));
    }
    rewards.add(_RewardCard(
      color: Colors.orange,
      icon: Icons.monetization_on,
      text: '+${quest.coinReward} Coin',
    ));
  }

  return Row(children: rewards);
}
}

class _RewardCard extends StatelessWidget {
  final Color color;
  final IconData icon;
  final String text;

  const _RewardCard({
    required this.color,
    required this.icon,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: EdgeInsets.all(context.dynamicWidth(0.04)),
        decoration: BoxDecoration(
          color: color.withAlpha(25),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: context.dynamicHeight(0.025)),
            SizedBox(width: context.dynamicWidth(0.02)),
            Text(
              text,
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}


