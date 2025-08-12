
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
      child: Obx((){
        return Stack(
          alignment: Alignment.center,
          children: [
            SizedBox(
              width: 200,
              height: 200,
              child: CircularProgressIndicator(
                value: timerController.progress,
                strokeWidth: 10,
                backgroundColor: Colors.black45,
                valueColor: AlwaysStoppedAnimation(Colors.black),
              ),
            ),
            Container(
              width: 180,
              height: 180,
              decoration: BoxDecoration(
                color: Color(0xff2C2C2C),
                shape: BoxShape.circle,
                boxShadow: [
                BoxShadow(
                  color: Colors.black54,
                  offset: Offset(2, 2),
                  blurRadius: 5,
                  )
                ],
              ),
              alignment: Alignment.center,
              child: Text(
                timerController.formatTime(timerController.secondsRemaining.value),
                style: TextStyle(
                fontSize: 40,
                color: Colors.white,
                fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          );
        }
      ),
    );
  }
}
