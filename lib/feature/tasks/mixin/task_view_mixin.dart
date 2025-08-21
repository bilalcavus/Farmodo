import 'package:farmodo/core/di/injection.dart';
import 'package:farmodo/feature/tasks/view/task_view.dart';
import 'package:farmodo/feature/tasks/viewmodel/tasks_controller.dart';
import 'package:farmodo/feature/tasks/viewmodel/timer_controller.dart';
import 'package:flutter/material.dart';

mixin TaskViewMixin on State<TaskView> {
    final taskController = getIt<TasksController>();
  final timerController = getIt<TimerController>();
  
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      taskController.getActiveTask();
      taskController.getCompletedTask();
    });
  }
}