import 'package:farmodo/core/di/injection.dart';
import 'package:farmodo/core/theme/app_colors.dart';
import 'package:farmodo/core/utility/extension/dynamic_size_extension.dart';
import 'package:farmodo/core/utility/extension/sized_box_extension.dart';
import 'package:farmodo/data/services/firestore_service.dart';
import 'package:farmodo/feature/leader_board/view/tabs/level_leader_board.dart';
import 'package:farmodo/feature/leader_board/view/tabs/pomodoro_leader_board.dart';
import 'package:farmodo/feature/leader_board/view/tabs/xp_leader_board.dart';
import 'package:farmodo/feature/leader_board/viewmodel/leader_board_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

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
        iconTheme: IconThemeData(
          color: Colors.white
        ),
        elevation: 0,
        title: Text(
          "🏆 Leaderboard",
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
            color: Colors.white
          ),
        ),
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppColors.background,
          unselectedLabelColor: AppColors.background,
          labelStyle: const TextStyle(
            fontWeight: FontWeight.bold,
          ),
          unselectedLabelStyle: const TextStyle(
            fontWeight: FontWeight.w600,
          ),
          tabs:  [
            Tab(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.star_rounded),
                  context.dynamicWidth(0.015).width,
                  Text('XP'),
                ],
              ),
            ),
            Tab(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.emoji_events_rounded),
                  context.dynamicWidth(0.015).width,
                  Text('Level'),
                ],
              ),
            ),
            Tab(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.timer_rounded),
                  context.dynamicWidth(0.015).width,
                  Text('Pomodoro'),
                ],
              ),
            ),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          XpLeaderBoard(controller: _controller),
          LevelLeaderBoard(controller: _controller),
          PomodoroLeaderBoard(controller: _controller),
        ],
      ),
    );
  }
}