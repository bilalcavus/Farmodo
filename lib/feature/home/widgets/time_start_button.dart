
import 'package:farmodo/core/theme/app_colors.dart';
import 'package:farmodo/feature/tasks/view/add_task_view.dart';
import 'package:farmodo/feature/tasks/viewmodel/tasks_controller.dart';
import 'package:farmodo/feature/tasks/viewmodel/timer_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class TimeStartButton extends StatelessWidget {
  const TimeStartButton({
    super.key,
    required this.timerController,
    required this.tasksController,
  });

  final TimerController timerController;
  final TasksController tasksController;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Obx(() => ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: timerController.isRunning.value
                  ? AppColors.danger
                  : tasksController.selctedTaskIndex.value == -1
                    ? AppColors.textSecondary.withOpacity(0.5)
                    : AppColors.primary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 44, vertical: 16),
              elevation: 0,
            ),
            onPressed: timerController.isRunning.value
                ? timerController.pauseTimer
                : () {
                    final selectedIndex = tasksController.selctedTaskIndex.value;
                    if (selectedIndex == -1 || 
                        tasksController.activeUserTasks.isEmpty ||
                        selectedIndex >= tasksController.activeUserTasks.length) {
                      Get.to(AddTaskView());
                      return;
                    }
                    
                    if (timerController.isOnBreak.value) {
                      timerController.startBreakTimer();
                    } else {
                      if (timerController.totalSeconds.value == 0 ||
                          timerController.secondsRemaining.value == timerController.totalSeconds.value) {
                        tasksController.selectTask(selectedIndex, tasksController.activeUserTasks[selectedIndex]);
                      }
                      timerController.startTimer();
                    }
                  },
            child: Text(
              timerController.isRunning.value
                  ? 'Pause'
                  : tasksController.selctedTaskIndex.value == -1 
                    ? 'Select a Task'
                    : (timerController.isOnBreak.value ? 'Continue Break' : timerController.secondsRemaining.value == 0 ? 'Start' : 'Continue'),
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                  ),
            ),
          )),
    );
  }
}
