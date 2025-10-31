import 'package:farmodo/core/di/injection.dart';
import 'package:farmodo/core/utility/extension/dynamic_size_extension.dart';
import 'package:farmodo/core/utility/extension/sized_box_extension.dart';
import 'package:farmodo/data/services/auth_service.dart';
import 'package:farmodo/feature/home/widgets/pomodoro_timer.dart';
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
  final timerController = getIt<TimerController>();
  final tasksController = Get.put(getIt<TasksController>());
  final navigationController = getIt<NavigationController>();
  final authService = getIt<AuthService>();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // if(authService.isLoggedIn) const HomeHeader(),
              context.dynamicHeight(0.05).height,
              PomodoroTimer(timerController: timerController),
              context.dynamicHeight(0.02).height,
              
              TimeStartButton(timerController: timerController, tasksController: tasksController),
            ],
        )),
      ),
      
    );
  }
}
