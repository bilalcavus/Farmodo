
import 'package:farmodo/core/theme/app_colors.dart';
import 'package:farmodo/core/utility/extension/dynamic_size_extension.dart';
import 'package:farmodo/core/utility/extension/ontap_extension.dart';
import 'package:farmodo/core/utility/extension/sized_box_extension.dart';
import 'package:farmodo/feature/home/widgets/full_screen_timer.dart';
import 'package:farmodo/feature/tasks/view/add_task_view.dart';
import 'package:farmodo/feature/tasks/viewmodel/tasks_controller.dart';
import 'package:farmodo/feature/tasks/viewmodel/timer_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:hugeicons/hugeicons.dart';

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
      child: Obx(() => Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Start/Pause Button
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: timerController.isRunning.value
                  ? AppColors.danger
                  : tasksController.selctedTaskIndex.value == -1
                    ? AppColors.textPrimary
                    : AppColors.primary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(6),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 44, vertical: 10),
              elevation: 0,
            ),
            onPressed: timerController.isRunning.value
                ? () {
                    timerController.pauseTimer();
                    debugPrint('Pause button pressed');
                  }
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
                    ? 'Start to Focus'
                    : (timerController.isOnBreak.value ? 'Continue Break' : timerController.secondsRemaining.value == 0 ? 'Start' : 'Continue'),
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                  ),
            ),
          ),
          
          // Reset Button
          if (tasksController.selctedTaskIndex.value != -1) ...[
            SizedBox(width: context.dynamicWidth(0.03)),
            CircleAvatar(
              backgroundColor: Colors.grey.shade900,
              child: Icon(
                HugeIcons.strokeRoundedRefresh,
                color: Colors.white,
                size: context.dynamicHeight(0.025),
              ),
            ).onTap(() => timerController.resetTimer()),
          ],
          context.dynamicWidth(0.03).width,
          CircleAvatar(
            child: IconButton(onPressed: () => toggleFullScreen(context), icon: Icon(HugeIcons.strokeRoundedFullScreen)),
          )
        ],
      )),
    );
  }

  void toggleFullScreen(BuildContext context) async {
    await SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    await SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);

    Get.to(() => FullScreenTimer())?.then((_) async {
      await SystemChrome.setPreferredOrientations([
        DeviceOrientation.portraitUp,
        DeviceOrientation.portraitDown,
      ]);
      await SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    });
  }
}
