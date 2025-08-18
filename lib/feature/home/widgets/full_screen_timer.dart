import 'package:farmodo/core/di/injection.dart';
import 'package:farmodo/feature/home/widgets/flip_digit.dart';
import 'package:farmodo/feature/tasks/viewmodel/timer_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get_state_manager/src/rx_flutter/rx_obx_widget.dart';

class FullScreenTimer extends StatelessWidget {
  const FullScreenTimer({super.key});

  @override
  Widget build(BuildContext context) {
    final timerController = getIt<TimerController>();
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        iconTheme: const IconThemeData(
          color: Colors.white,
        ),
        backgroundColor: Colors.black,
      ),
      body: Obx((){
        return Center(
          child: FlipTimer(
            timeString: timerController.isOnBreak.value
                ? timerController.formatTime(timerController.breakSecondsRemaining.value)
                : timerController.formatTime(timerController.secondsRemaining.value),
            timerController: timerController,
          )
        );
      }
      ),
    );
  }
}