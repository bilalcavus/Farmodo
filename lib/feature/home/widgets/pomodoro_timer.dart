
import 'package:farmodo/core/theme/app_colors.dart';
import 'package:farmodo/feature/tasks/viewmodel/timer_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get_state_manager/src/rx_flutter/rx_obx_widget.dart';

class PomodoroTimer extends StatelessWidget {
  const PomodoroTimer({
    super.key,
    required this.timerController,
  });

  final TimerController timerController;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Obx(() {
        return Stack(
          alignment: Alignment.center,
          children: [
            SizedBox(
              width: 220,
              height: 220,
              child: CircularProgressIndicator(
                value: timerController.displayProgress,
                strokeWidth: 12,
                backgroundColor: AppColors.border,
                valueColor: AlwaysStoppedAnimation(
                  timerController.isOnBreak.value ? AppColors.secondary : AppColors.primary
                ),
              ),
            ),
            Container(
              width: 190,
              height: 190,
              decoration: BoxDecoration(
                color: AppColors.surface,
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.border),
              ),
              alignment: Alignment.center,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    timerController.isOnBreak.value
                        ? timerController.formatTime(timerController.breakSecondsRemaining.value)
                        : timerController.formatTime(timerController.secondsRemaining.value),
                    style: const TextStyle(
                      fontSize: 40,
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  timerController.isOnBreak.value == true ?
                  Text('Break Time', style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w700,
                  )) :
                  SizedBox.shrink()
                ],
              ),
            ),
          ],
        );
      }),
    );
  }
  
}
