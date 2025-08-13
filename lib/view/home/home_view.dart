import 'package:farmodo/core/di/injection.dart';
import 'package:farmodo/core/extension/dynamic_size_extension.dart';
import 'package:farmodo/view/home/widgets/daily_goals_container.dart';
import 'package:farmodo/view/home/widgets/home_header.dart';
import 'package:farmodo/view/home/widgets/pomodoro_timer.dart';
import 'package:farmodo/view/home/widgets/recent_tasks.dart';
import 'package:farmodo/view/home/widgets/time_start_button.dart';
import 'package:farmodo/viewmodel/tasks/tasks_controller.dart';
import 'package:farmodo/viewmodel/timer/timer_controller.dart';
import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:iconsax/iconsax.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      tasksController.getUserTasks();
    });
  }
  final timerController = getIt<TimerController>();
  final tasksController = getIt<TasksController>();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: SingleChildScrollView(
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              HomeHeader(),
              SizedBox(height: context.dynamicHeight(0.015)),
              dailyGoalsTitle(context),
              DailyGoalsContainer(),
              SizedBox(height: context.dynamicHeight(0.06)),
              PomodoroTimer(timerController: timerController),
              SizedBox(height: context.dynamicHeight(0.03)),
              TimeStartButton(timerController: timerController),
              SizedBox(height: context.dynamicHeight(0.03)),
              Center(
                child: Container(
                  height: context.dynamicHeight(0.085),
                  width: context.dynamicWidth(0.9),
                  padding: EdgeInsets.symmetric(horizontal: context.dynamicWidth(0.03)),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: Colors.black12),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _timerOptionChip(HugeIcons.strokeRoundedAlertDiamond, 'Strict'),
                      _timerOptionChip(Iconsax.timer, 'Timer'),
                      _timerOptionChip(HugeIcons.strokeRoundedFullScreen, 'Fullscreen'),
                    ],
                  ),
                ),
              ),
              SizedBox(height: context.dynamicHeight(0.03)),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: context.dynamicWidth(0.05)),
                child: Text(
                  "Recent Tasks",
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: Colors.grey.shade800,
                      ),
                ),
              ),
              RecentTasks(tasksController: tasksController, timerController: timerController)
            ],
        )),
      ),
      
    );
  }

  Widget _timerOptionChip(IconData icon, String title) {
    return InkWell(
      onTap: () => timerController.toggleFullScreen(context),
      borderRadius: BorderRadius.circular(24),
      child: Row(
        children: [
          Container(
            height: 36,
            width: 36,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.black12),
            ),
            alignment: Alignment.center,
            child: Icon(icon, size: 18, color: Colors.black87),
          ),
          SizedBox(width: 8),
          Text(
            title,
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  color: Colors.grey.shade700,
                  fontWeight: FontWeight.w500,
                ),
          ),
        ],
      ),
    );
  }

  Padding dailyGoalsTitle(BuildContext context) {
    return Padding(
      padding:  EdgeInsets.symmetric(horizontal: context.dynamicHeight(0.025)),
      child: Text('Daily Goals', style: Theme.of(context).textTheme.titleMedium?.copyWith(
        color: Colors.grey.shade700,
      )),
    );
  }
}

