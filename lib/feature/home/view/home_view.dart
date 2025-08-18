import 'package:farmodo/core/di/injection.dart';
import 'package:farmodo/core/extension/dynamic_size_extension.dart';
import 'package:farmodo/feature/home/widgets/current_task_progress.dart';
import 'package:farmodo/feature/home/widgets/home_header.dart';
import 'package:farmodo/feature/home/widgets/pomodoro_timer.dart';
import 'package:farmodo/feature/home/widgets/recent_tasks.dart';
import 'package:farmodo/feature/home/widgets/time_start_button.dart';
import 'package:farmodo/feature/tasks/viewmodel/tasks_controller.dart';
import 'package:farmodo/feature/tasks/viewmodel/timer_controller.dart';
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
      tasksController.getActiveTask();
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
              SizedBox(height: context.dynamicHeight(0.01)),
              CurrentTaskProgress(tasksController: tasksController),
              SizedBox(height: context.dynamicHeight(0.04)),
              PomodoroTimer(timerController: timerController),
              context.dynamicHeight(0.03).height,
              TimeStartButton(timerController: timerController, tasksController: tasksController),
              SizedBox(height: context.dynamicHeight(0.03)),
              Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _timerOptionChip(HugeIcons.strokeRoundedAlertDiamond, 'Strict'),
                    _timerOptionChip(Iconsax.timer, 'Timer'),
                    _timerOptionChip(HugeIcons.strokeRoundedFullScreen, 'Fullscreen'),
                  ],
                ),
              ),
              SizedBox(height: context.dynamicHeight(0.03)),
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
          Icon(icon, size: 18, color: Colors.black87),
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

extension SpaceX on num {
  SizedBox get height => SizedBox(height: toDouble());
  SizedBox get width  => SizedBox(width: toDouble());
}