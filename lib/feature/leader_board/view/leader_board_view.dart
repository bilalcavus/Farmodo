import 'package:farmodo/core/di/injection.dart';
import 'package:farmodo/core/theme/app_colors.dart';
import 'package:farmodo/data/services/firestore_service.dart';
import 'package:farmodo/feature/leader_board/view/tabs/level_leader_board.dart';
import 'package:farmodo/feature/leader_board/view/tabs/pomodoro_leader_board.dart';
import 'package:farmodo/feature/leader_board/view/tabs/xp_leader_board.dart';
import 'package:farmodo/feature/leader_board/viewmodel/leader_board_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:iconsax/iconsax.dart';

class LeaderBoardView extends StatefulWidget {
  const LeaderBoardView({super.key});

  @override
  State<LeaderBoardView> createState() => _LeaderBoardViewState();
}

class _LeaderBoardViewState extends State<LeaderBoardView> with TickerProviderStateMixin{
  late TabController _tabController;
  late LeaderBoardController _controller;

  @override
  void initState() {
    _tabController = TabController(length: 3, vsync: this);
    _controller = Get.put(LeaderBoardController(getIt<FirestoreService>()));
    _controller.getXpLeaderboard();
    _controller.getLevelLeaderboard();
    _controller.getPomodoroLeaderboard();
    super.initState();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        title: Text("Leaderboard", style: theme.textTheme.bodyLarge?.copyWith(
          fontWeight: FontWeight.w600,
          color: Colors.white
        )),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          dividerColor: Colors.white,
          tabs: const [
            Tab(
              icon: Icon(Icons.star),
              text: 'XP',
            ),
            Tab(
              icon: Icon(HugeIcons.strokeRoundedCrown),
              text: 'Level',
            ),
            Tab(
              icon: Icon(Iconsax.task),
              text: 'Pomodoro',
            )
          ]
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  XpLeaderBoard(controller: _controller),
                  LevelLeaderBoard(controller: _controller),
                  PomodoroLeaderBoard(controller: _controller,),
              ]
            ))
          ],
        ),
      ),
    );
  }
}