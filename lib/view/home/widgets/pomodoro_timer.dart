
import 'package:farmodo/core/theme/app_colors.dart';
import 'package:farmodo/viewmodel/timer/timer_controller.dart';
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
                value: timerController.progress,
                strokeWidth: 12,
                backgroundColor: AppColors.border,
                valueColor: const AlwaysStoppedAnimation(AppColors.primary),
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
              child: Text(
                timerController.formatTime(timerController.secondsRemaining.value),
                style: const TextStyle(
                  fontSize: 40,
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        );
      }),
    );
  }
}
