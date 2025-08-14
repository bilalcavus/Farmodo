import 'dart:async';

import 'package:farmodo/view/home/widgets/full_screen_timer.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

class TimerController extends GetxController {
  var totalSeconds = (25 * 60).obs;
  var secondsRemaining = (25 * 60).obs;
  Timer? _timer;
  Timer? get timer => _timer;
  var isRunning = false.obs;
  var isFullScreen = false.obs;
  double get progress => totalSeconds.value == 0 ? 0.0 : (totalSeconds.value - secondsRemaining.value) / totalSeconds.value;

  VoidCallback? onTimerComplete;



  void startTimer(){
    if(isRunning.value) return;
    _timer = Timer.periodic(Duration(seconds: 1), (_){
      if(secondsRemaining.value > 0){
        secondsRemaining.value--;
      } else {
        _timer?.cancel();
        isRunning.value = false;
        secondsRemaining.value = totalSeconds.value;
        if (onTimerComplete != null) {
          onTimerComplete!();
        }
      }
    });
    isRunning.value = true;
  }

  void pauseTimer() {
    _timer?.cancel();
    isRunning.value = false;
  }

  void resetTimer() {
    _timer?.cancel();
    isRunning.value = false;
    secondsRemaining.value = totalSeconds.value;
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

  String formatTime(int seconds) {
    final minutes = (seconds ~/ 60).toString().padLeft(2, '0');
    final secs = (seconds % 60).toString().padLeft(2, '0');
    return '$minutes:$secs';
  }

  @override
  void onClose() {
    timer?.cancel();
    super.onClose();
  }
}
