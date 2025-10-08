
import 'package:farmodo/core/components/card/show_alert_dialog.dart';
import 'package:farmodo/core/theme/app_colors.dart';
import 'package:farmodo/core/utility/extension/dynamic_size_extension.dart';
import 'package:farmodo/core/utility/extension/route_helper.dart';
import 'package:farmodo/core/utility/extension/sized_box_extension.dart';
import 'package:farmodo/feature/home/widgets/widget_guide_view.dart';
import 'package:farmodo/feature/home/widgets/full_screen_timer.dart';
import 'package:farmodo/feature/tasks/viewmodel/tasks_controller.dart';
import 'package:farmodo/feature/tasks/viewmodel/timer_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:hugeicons/hugeicons.dart';

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
          ActionButton(
            onPressed: () => showAlertDialog(
              context: context,
              title: "Reset Timer",
              content: "Are you sure you want to reset the timer?",
              onPressed: () => widget.timerController.resetTimer(),
              buttonText: "Reset"
            ),
            icon: Icon(HugeIcons.strokeRoundedRefresh, color: Colors.black, size: context.dynamicHeight(0.02))
          ),
          context.dynamicWidth(0.03).width,
          ActionButton(
            onPressed: () => showAlertDialog(
              context: context,
              title: "End Session",
              content: "Are you sure you want to end the current session?",
              onPressed: () => widget.tasksController.endCurrentSession(),
              buttonText: "OK"
            ),
            icon: Icon(HugeIcons.strokeRoundedDelete02, color: Colors.red, size: context.dynamicHeight(0.02))
          ),
          context.dynamicWidth(0.03).width,
          PlayButton(
            selectedIndex: selectedIndex,
            tasksController: widget.tasksController,
            timerController: widget.timerController,
          ),
          context.dynamicWidth(0.03).width,
          ActionButton(
            onPressed: () => toggleFullScreen(context),
            icon:  Icon(HugeIcons.strokeRoundedFullScreen, color: Colors.black87, size: context.dynamicHeight(0.025))
          ),
          context.dynamicWidth(0.03).width,
          ActionButton(onPressed: () => RouteHelper.push(context, const WidgetGuideView()), icon: Icon(Icons.widgets_outlined))
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
  });

  final TimerController timerController;
  final TasksController tasksController;
  final int selectedIndex;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      return CircleAvatar(
        radius: 32,
        backgroundColor:AppColors.danger,
        child: IconButton(onPressed: timerController.isRunning.value
          ? () => timerController.pauseTimer()
          : () {
              // Eğer break modundaysa, break timer'ı başlat
              if (timerController.isOnBreak.value) {
                timerController.startBreakTimer();
                return;
              }

              // Eğer timer zaten ayarlanmışsa (default veya custom task seçilmiş)
              if (timerController.totalSeconds.value > 0) {
                timerController.startTimer();
                return;
              }

              // Timer ayarlanmamış, task seçmemiz gerekiyor
              
              // Eğer custom task seçiliyse, onu kullan
              if (selectedIndex != -1 && 
                  tasksController.activeUserTasks.isNotEmpty &&
                  selectedIndex < tasksController.activeUserTasks.length) {
                tasksController.selectTask(selectedIndex, tasksController.activeUserTasks[selectedIndex]);
              } else {
                // Yoksa default task'ı kullan
                tasksController.selectDefaultTask();
              }
              
              timerController.startTimer();
            }, icon: Icon(timerController.isRunning.value ? Icons.pause : Icons.play_arrow, size: context.dynamicHeight(0.04)))
          );
        }
      );
    }
  }
