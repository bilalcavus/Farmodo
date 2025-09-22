import 'package:farmodo/core/di/injection.dart';
import 'package:farmodo/core/theme/app_colors.dart';
import 'package:farmodo/core/utility/extension/dynamic_size_extension.dart';
import 'package:farmodo/core/utility/extension/sized_box_extension.dart';
import 'package:farmodo/feature/home/widgets/current_task_progress.dart';
import 'package:farmodo/feature/home/widgets/home_header.dart';
import 'package:farmodo/feature/home/widgets/time_start_button.dart';
import 'package:farmodo/feature/navigation/navigation_controller.dart';
import 'package:farmodo/feature/tasks/viewmodel/tasks_controller.dart';
import 'package:farmodo/feature/tasks/viewmodel/timer_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

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
  final tasksController = Get.put(getIt<TasksController>());
  final navigationController = getIt<NavigationController>();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SingleChildScrollView(
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const HomeHeader(),
              context.dynamicHeight(0.04).height,
              // PomodoroTimer(timerController: timerController),
              TimeStartButton(timerController: timerController, tasksController: tasksController),
              context.dynamicHeight(0.03).height,
              CurrentTaskProgress(tasksController: tasksController),
              context.dynamicHeight(0.03).height,
              // Test butonu - notification test için
  
            ],
        )),
      ),
      
    );
  }
}
