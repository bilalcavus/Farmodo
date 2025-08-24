import 'package:farmodo/core/theme/app_colors.dart';
import 'package:farmodo/core/utility/extension/dynamic_size_extension.dart';
import 'package:farmodo/core/utility/extension/sized_box_extension.dart';
import 'package:farmodo/data/models/quest_model.dart';
import 'package:farmodo/feature/gamification/viewmodel/gamification_controller.dart';
import 'package:farmodo/feature/gamification/widget/achievements/achievement_card.dart';
import 'package:farmodo/feature/gamification/widget/achievements/achievements_filters.dart';
import 'package:farmodo/feature/gamification/widget/main/empty_state.dart';
import 'package:farmodo/feature/gamification/widget/main/sheet_divider.dart';
import 'package:farmodo/feature/gamification/widget/main/stat_cards.dart';
import 'package:farmodo/feature/gamification/widget/quest/quest_card.dart';
import 'package:farmodo/feature/gamification/widget/quest/quest_filters.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hugeicons/hugeicons.dart';

class GamificationView extends StatefulWidget {
  const GamificationView({super.key});

  @override
  State<GamificationView> createState() => _GamificationViewState();
}

class _GamificationViewState extends State<GamificationView>
    with TickerProviderStateMixin {
  late TabController _tabController;
  late GamificationController gamificationController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    gamificationController = Get.put(GamificationController());
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title:  Text(
          'Başarılar & Görevler',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            color: Colors.white
          )
        ),
        iconTheme: const IconThemeData(color: Colors.white),
        backgroundColor: AppColors.primary,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_sharp, color: Colors.white),
            onPressed: () => gamificationController.refresh(),
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          dividerColor: Colors.white,
          tabs: const [
            Tab(
              icon: Icon(HugeIcons.strokeRoundedChampion),
              text: 'Başarılar',
            ),
            Tab(
              icon: Icon(HugeIcons.strokeRoundedStickyNote01),
              text: 'Görevler',
            ),
          ],
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            StatCards(gamificationController: gamificationController),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildAchievementsTab(),
                  _buildQuestsTab(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  

  Widget _buildAchievementsTab() {
    return Obx(() {
      if (gamificationController.isLoadingAchievements.value) {
        return const Center(child: CircularProgressIndicator());
      }

      if (gamificationController.achievements.isEmpty) {
        return EmptyState(
          icon: HugeIcons.strokeRoundedChampion,
          title: 'Henüz başarı yok',
          subtitle: 'Başarılar yakında eklenecek!',
          context: context);
        }
      // if (gamificationController.filteredAchievements.isEmpty) {
      //   return EmptyState(
      //     context: context,
      //     title: 'Filtrelenmiş başarı yok',
      //     subtitle: 'Seçilen filtrelere uygun başarı bulunamadı',
      //     icon: HugeIcons.strokeRoundedChampion);
      //   }

      return RefreshIndicator(
        onRefresh: () => gamificationController.refresh(),
        child: Column(
          children: [
            AchievementsFilters(context: context, controller: gamificationController),
            
            // Başarı listesi
            Expanded(
              child: GridView.builder(
                padding: EdgeInsets.all(context.dynamicWidth(0.02)),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: context.dynamicWidth(0.02),
                  mainAxisSpacing: context.dynamicWidth(0.02),
                  childAspectRatio: 0.8,
                ),
                itemCount: gamificationController.filteredAchievements.length,
                itemBuilder: (context, index) {
                  final achievement = gamificationController.filteredAchievements[index];
                  final userAchievement = gamificationController.getUserAchievement(achievement.id);
                  if (gamificationController.filteredAchievements.isEmpty) {
                    return Center(child: Text('No achievements found'));
                    } else {
                    return AchievementCard(
                      achievement: achievement,
                      userAchievement: userAchievement,
                      onTap: () => _showAchievementDetail(achievement, userAchievement),
                      );
                    }
                },
              ),
            ),
          ],
        ),
      );
    });
  }

  Widget _buildQuestsTab() {
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
        onRefresh: () => gamificationController.refresh(),
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
  
  void _showAchievementDetail(achievement, userAchievement) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: context.dynamicHeight(0.6),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        padding: EdgeInsets.all(context.dynamicWidth(0.05)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SheetDivider(),
            context.dynamicHeight(0.02).height,
            Row(
              children: [
                Container(
                  width: context.dynamicWidth(0.12),
                  height: context.dynamicHeight(0.08),
                  decoration: BoxDecoration(
                    color: achievement.rarityColor.withOpacity(0.2),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.emoji_events,
                    size: context.dynamicHeight(0.04),
                    color: achievement.rarityColor,
                  ),
                ),
                context.dynamicWidth(0.04).width,
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        achievement.title,
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold
                        )
                      ),
                      Text(
                        achievement.description,
                        style: Theme.of(context).textTheme.labelLarge?.copyWith(
                          color: Colors.grey.shade600,
                        )
                      ),
                    ],
                  ),
                ),
              ],
            ),
            context.dynamicHeight(0.03).height,
            if (userAchievement != null) ...[
              Text(
                'İlerleme',
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  color: Colors.grey.shade700,
                )
              ),
              context.dynamicHeight(0.01).height,
              LinearProgressIndicator(
                value: (userAchievement.progress / achievement.targetValue).clamp(0.0, 1.0),
                backgroundColor: Colors.grey.shade300,
                valueColor: AlwaysStoppedAnimation<Color>(achievement.rarityColor),
                minHeight: 8,
              ),
              context.dynamicHeight(0.01).height,
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${userAchievement.progress}/${achievement.targetValue}',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade600,
                    ),
                  ),
                  if (userAchievement.isUnlocked)
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: context.dynamicWidth(0.03), 
                        vertical: context.dynamicHeight(0.005)
                      ),
                      decoration: BoxDecoration(
                        color: Colors.green.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '✅ Açıldı!',
                        style: Theme.of(context).textTheme.labelMedium?.copyWith(
                          color: Colors.green,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                ],
              ),
            ],
            
            context.dynamicHeight(0.03).height,
            
            // Ödül
            Container(
              padding: EdgeInsets.all(context.dynamicWidth(0.04)),
              decoration: BoxDecoration(
                color: achievement.rarityColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.star,
                    color: achievement.rarityColor,
                    size: context.dynamicHeight(0.03),
                  ),
                  context.dynamicWidth(0.03).width,
                  Text(
                    '+${achievement.xpReward} XP Ödülü',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: achievement.rarityColor,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
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
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        padding: EdgeInsets.all(context.dynamicWidth(0.05)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SheetDivider(),
            context.dynamicHeight(0.02).height,
            
            // Görev başlığı
            Row(
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
                      Text(
                        quest.title,
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold
                        )
                      ),
                      Text(
                        quest.description,
                        style: Theme.of(context).textTheme.labelLarge?.copyWith(
                          color: Colors.grey.shade600,
                        )
                      ),
                    ],
                  ),
                ),
              ],
            ),
            
            context.dynamicHeight(0.03).height,
            
            // İlerleme
            if (userQuest != null) ...[
              Text(
                'İlerleme',
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  color: Colors.grey.shade700,
                )
              ),
              
              context.dynamicHeight(0.01).height,
              
              LinearProgressIndicator(
                value: (userQuest.progress / quest.targetValue).clamp(0.0, 1.0),
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
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: context.dynamicWidth(0.03), 
                        vertical: context.dynamicHeight(0.005)
                      ),
                      decoration: BoxDecoration(
                        color: Colors.green.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '✅ Tamamlandı!',
                        style: Theme.of(context).textTheme.labelMedium?.copyWith(
                          color: Colors.green,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                ],
              ),
            ],
            
            context.dynamicHeight(0.03).height,
            
            // Ödüller
            Row(
              children: [
                if (quest.xpReward > 0)
                  Expanded(
                    child: Container(
                      padding: EdgeInsets.all(context.dynamicWidth(0.04)),
                      decoration: BoxDecoration(
                        color: Colors.blue.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.star,
                            color: Colors.blue,
                            size: context.dynamicHeight(0.025),
                          ),
                          context.dynamicWidth(0.02).width,
                          Text(
                            '+${quest.xpReward} XP',
                            style: Theme.of(context).textTheme.labelMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: Colors.blue,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                
                if (quest.xpReward > 0 && quest.coinReward > 0)
                  context.dynamicWidth(0.03).width,
                
                if (quest.coinReward > 0)
                  Expanded(
                    child: Container(
                      padding: EdgeInsets.all(context.dynamicWidth(0.04)),
                      decoration: BoxDecoration(
                        color: Colors.orange.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.monetization_on,
                            color: Colors.orange,
                            size: context.dynamicHeight(0.025),
                          ),
                          context.dynamicWidth(0.02).width,
                          Text(
                            '+${quest.coinReward} Coin',
                            style: Theme.of(context).textTheme.labelMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: Colors.orange,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

}



