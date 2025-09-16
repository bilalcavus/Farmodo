
import 'package:farmodo/core/theme/app_colors.dart';
import 'package:farmodo/core/utility/extension/dynamic_size_extension.dart';
import 'package:farmodo/core/utility/extension/ontap_extension.dart';
import 'package:farmodo/core/utility/extension/sized_box_extension.dart';
import 'package:farmodo/feature/home/widgets/full_screen_timer.dart';
import 'package:farmodo/feature/tasks/viewmodel/tasks_controller.dart';
import 'package:farmodo/feature/tasks/viewmodel/timer_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:iconsax/iconsax.dart';

class TimeStartButton extends StatefulWidget {
  const TimeStartButton({
    super.key,
    required this.timerController,
    required this.tasksController,
  });

  final TimerController timerController;
  final TasksController tasksController;

  @override
  State<TimeStartButton> createState() => _TimeStartButtonState();
}

class _TimeStartButtonState extends State<TimeStartButton> {
  
  @override
  Widget build(BuildContext context) {
    
    return Center(
      child: Obx(() {
        final selectedIndex = widget.tasksController.selctedTaskIndex.value;
        return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (widget.tasksController.selctedTaskIndex.value != -1) ...[
            SizedBox(width: context.dynamicWidth(0.03)),
            ActionButton(
              onPressed: widget.timerController.resetTimer,
              icon: Icon(HugeIcons.strokeRoundedRefresh, color: Colors.black, size: context.dynamicHeight(0.02)))
          ],
          context.dynamicWidth(0.03).width,
          PlayButton(
            selectedIndex: selectedIndex,
            tasksController: widget.tasksController,
            timerController: widget.timerController,
            shake: () => widget.tasksController.triggerShake(),
          ),
          context.dynamicWidth(0.03).width,
          ActionButton(
            onPressed: () => toggleFullScreen(context),
            icon:  Icon(HugeIcons.strokeRoundedFullScreen, color: Colors.black87, size: context.dynamicHeight(0.025),))
        ],
      );
      }),
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

class ActionButton extends StatelessWidget {
  const ActionButton({
    super.key, required this.onPressed, required this.icon,
  });

  final VoidCallback onPressed;
  final Icon icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(context.dynamicHeight(0.05)),
        color: Colors.transparent,
        border: Border.all(
          color: Colors.grey.shade300,
          width: 2
        )
      ),
      child: IconButton(
        onPressed: () => onPressed(),
        icon: icon,
    ));
  }
}

class PlayButton extends StatelessWidget {
  const PlayButton({
    super.key, required this.timerController, required this.tasksController, required this.selectedIndex,
    this.shake
  });

  final TimerController timerController;
  final TasksController tasksController;
  final int selectedIndex;
  final VoidCallback? shake;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      return CircleAvatar(
        radius: 32,
        backgroundColor: timerController.isRunning.value
                    ? AppColors.danger
                    : AppColors.primary,
        child: IconButton(onPressed: timerController.isRunning.value
          ? () => timerController.pauseTimer()
          : () {
                if (selectedIndex == -1 || 
                  tasksController.activeUserTasks.isEmpty ||
                  selectedIndex >= tasksController.activeUserTasks.length) {
                shake?.call();
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
            }, icon: Icon(timerController.isRunning.value ? Icons.pause : Icons.play_arrow, size: context.dynamicHeight(0.04)))
          );
        }
      );
    }
  }
