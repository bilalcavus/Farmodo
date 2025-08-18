import 'dart:ui';

import 'package:farmodo/data/models/user_task_model.dart';
import 'package:farmodo/feature/tasks/viewmodel/timer_controller.dart';

class TimerHelper {
  static void setupTaskTimer(TimerController timerController, UserTaskModel task, VoidCallback onComplete) {
    timerController.totalSeconds.value = task.duration * 60;
    timerController.secondsRemaining.value = task.duration * 60;

    final int breakMinutes = task.breakDuration > 0
        ? task.breakDuration
        : (task.duration ~/ 5).clamp(1, 1000);

    timerController.totalBreakSeconds.value = breakMinutes * 60;
    timerController.breakSecondsRemaining.value = breakMinutes * 60;

    // final taskId = task.id;
    timerController.onTimerComplete = () async {
      timerController.onBreakComplete = () async {
        onComplete();
      };
    };
  }
}
