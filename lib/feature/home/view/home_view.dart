import 'package:farmodo/core/components/card/show_exit_dialog.dart';
import 'package:farmodo/core/di/injection.dart';
import 'package:farmodo/core/utility/extension/dynamic_size_extension.dart';
import 'package:farmodo/core/utility/extension/sized_box_extension.dart';
import 'package:farmodo/feature/home/widgets/current_task_progress.dart';
import 'package:farmodo/feature/home/widgets/home_header.dart';
import 'package:farmodo/feature/home/widgets/recent_tasks.dart';
import 'package:farmodo/feature/home/widgets/time_start_button.dart';
import 'package:farmodo/feature/home/widgets/widget_settings_page.dart';
import 'package:farmodo/feature/navigation/navigation_controller.dart';
import 'package:farmodo/feature/tasks/viewmodel/tasks_controller.dart';
import 'package:farmodo/feature/tasks/viewmodel/timer_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
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
  final navigationController = getIt<NavigationController>();
  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        if (navigationController.currentIndex.value == 0) {
          bool? shouldExit = await showExitDialog(context);
          return shouldExit ?? false;
        }
        navigationController.goBack();
        return false;
      },
      child: Scaffold(
        backgroundColor: const Color(0xFFF8FAFC),
        body: SingleChildScrollView(
          child: SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const HomeHeader(),
                context.dynamicHeight(0.04).height,
                // PomodoroTimer(timerController: timerController),
                TimeStartButton(timerController: timerController, tasksController: tasksController),
                context.dynamicHeight(0.03).height,
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _timerOptionChip(HugeIcons.strokeRoundedAlertDiamond, 'Strict'),
                    _timerOptionChip(Iconsax.timer, 'Timer'),
                    _timerOptionChip(HugeIcons.strokeRoundedFullScreen, 'Fullscreen'),
                    _timerOptionChip(Icons.widgets, 'Widget'),
                  ],
                ),
                context.dynamicHeight(0.03).height,
                CurrentTaskProgress(tasksController: tasksController),
                context.dynamicHeight(0.03).height,
                RecentTasks(tasksController: tasksController, timerController: timerController)
              ],
          )),
        ),
        
      ),
    );
  }

  Widget _timerOptionChip(IconData icon, String title) {
    return InkWell(
      onTap: () {
        if (title == 'Widget') {
          Get.to(() => const WidgetSettingsPage());
        } else if (title == 'Fullscreen') {
          timerController.toggleFullScreen(context);
        }
      },
      borderRadius: BorderRadius.circular(24),
      child: Row(
        children: [
          Icon(icon, size: 18, color: Colors.black87),
          context.dynamicWidth(0.03).width,
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
}
