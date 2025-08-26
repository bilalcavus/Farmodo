import 'package:farmodo/core/di/injection.dart';
import 'package:farmodo/feature/tasks/view/task_view.dart';
import 'package:farmodo/feature/tasks/viewmodel/tasks_controller.dart';
import 'package:farmodo/feature/tasks/viewmodel/timer_controller.dart';
import 'package:flutter/material.dart';

mixin TaskViewMixin on State<TaskView> {
  final taskController = getIt<TasksController>();
  final timerController = getIt<TimerController>();
  final ScrollController activeScrollController = ScrollController();
  final ScrollController completedScrollController = ScrollController();
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      taskController.getActiveTask();
      taskController.getCompletedTask();
    activeScrollController.addListener(() {
        if (activeScrollController.position.pixels >=
            activeScrollController.position.maxScrollExtent - 200) {
          taskController.getActiveTask(loadMore: true);
        }
      });

      completedScrollController.addListener(() {
        if (completedScrollController.position.pixels >=
            completedScrollController.position.maxScrollExtent - 200) {
          taskController.getCompletedTask(loadMore: true);
        }
      });
    });
  }
  @override
  void dispose() {
    activeScrollController.dispose();
    completedScrollController.dispose();
    super.dispose();
  }
}