
import 'package:farmodo/viewmodel/timer/timer_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get_state_manager/src/rx_flutter/rx_obx_widget.dart';

class TimeStartButton extends StatelessWidget {
  const TimeStartButton({
    super.key,
    required this.timerController,
  });

  final TimerController timerController;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Obx(() => ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: timerController.isRunning.value 
              ? Color.fromARGB(255, 153, 26, 26)
              : Color(0xff2C2C2C),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              padding: EdgeInsets.symmetric(horizontal: 40, vertical: 15),
            ),
            onPressed: timerController.isRunning.value ? timerController.pauseTimer : timerController.startTimer,
            child: Text(timerController.isRunning.value ? 'Pause' : 'Start', style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold
            )),
          )),
    );
  }
}
