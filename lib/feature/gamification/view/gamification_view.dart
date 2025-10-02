import 'package:farmodo/core/di/injection.dart';
import 'package:farmodo/core/theme/app_colors.dart';
import 'package:farmodo/data/services/auth_service.dart';
import 'package:farmodo/data/services/sample_data_service.dart';
import 'package:farmodo/feature/gamification/viewmodel/gamification_controller.dart';
import 'package:farmodo/feature/gamification/widget/achievements/achievements_tab.dart';
import 'package:farmodo/feature/gamification/widget/main/stat_cards.dart';
import 'package:farmodo/feature/gamification/widget/quest/quests_tab.dart';
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
    final authService = getIt<AuthService>();
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title:  Text(
          'Achievements & Quests',
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
            onPressed: () async {
              await SampleDataService().checkExistingData(authService.firebaseUser!.uid);
              gamificationController.refreshGamification();
            } 
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
              text: 'Achievements',
            ),
            Tab(
              icon: Icon(HugeIcons.strokeRoundedStickyNote01),
              text: 'Quests',
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
                  AchievementsTab(gamificationController: gamificationController, context: context),
                  QuestsTab(gamificationController: gamificationController, context: context)
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

