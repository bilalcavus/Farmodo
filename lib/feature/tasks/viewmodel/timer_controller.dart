import 'dart:async';

import 'package:farmodo/core/services/notification_service.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class TimerController extends GetxController {
  RxInt totalSeconds = RxInt(0);
  RxInt secondsRemaining = RxInt(0);
  var totalBreakSeconds = (5 * 60).obs;
  var breakSecondsRemaining = (5 * 60).obs;
  Timer? _timer;
  Timer? get timer => _timer;
  var isRunning = false.obs;
  var isOnBreak = false.obs;
  var currentTaskTitle = ''.obs;
  
  double get progress => totalSeconds.value == 0 ? 0.0 : (totalSeconds.value - secondsRemaining.value) / totalSeconds.value;
  double get breakProgress => totalBreakSeconds.value == 0 ? 0.0 : (totalBreakSeconds.value - breakSecondsRemaining.value) / totalBreakSeconds.value;
  double get displayProgress => isOnBreak.value ? breakProgress : progress;

  VoidCallback? onTimerComplete;
  VoidCallback? onBreakComplete;



  void _updateNotification() {
    final timeText = formatTime(isOnBreak.value ? breakSecondsRemaining.value : secondsRemaining.value);
    final status = isOnBreak.value ? 'Break' : 'Work';
    final progressValue = isOnBreak.value ? breakProgress : progress;

    NotificationService.updateTimerNotification(
      timeText: timeText,
      taskTitle: currentTaskTitle.value.isEmpty ? 'No active task' : currentTaskTitle.value,
      status: status,
      isRunning: isRunning.value,
      progress: progressValue,
    );
  }

  void _showNotification() {
    final timeText = formatTime(isOnBreak.value ? breakSecondsRemaining.value : secondsRemaining.value);
    final status = isOnBreak.value ? 'Break' : 'Work';
    final progressValue = isOnBreak.value ? breakProgress : progress;

    
    NotificationService.showTimerNotification(
      timeText: timeText,
      taskTitle: currentTaskTitle.value.isEmpty ? 'No active task' : currentTaskTitle.value,
      status: status,
      isRunning: isRunning.value,
      progress: progressValue,
    );
  }

  void _hideNotification() {
    NotificationService.hideTimerNotification();
  }

  

  void startTimer(){
    if(isRunning.value) return;
    if(totalSeconds.value == 0) return;
    _timer = Timer.periodic(Duration(seconds: 1), (_){
      if(secondsRemaining.value > 0){
        secondsRemaining.value--;
        _updateNotification();
      } else {
        _timer?.cancel();
        isRunning.value = false;
        secondsRemaining.value = totalSeconds.value;
        isOnBreak.value = true;
        _updateNotification();
        if (onTimerComplete != null) {
          onTimerComplete!();
        }
        startBreakTimer();
      }
    });
    isRunning.value = true;
    _showNotification();
  }

  void startBreakTimer(){
    if (isRunning.value) return;
    if(totalBreakSeconds.value == 0) return;
    _timer = Timer.periodic(Duration(seconds: 1), (_){
      if(breakSecondsRemaining.value > 0){
        breakSecondsRemaining.value --;
        _updateNotification();
      } else {
        _timer?.cancel();
        isRunning.value = false;
        breakSecondsRemaining.value = totalBreakSeconds.value;
        isOnBreak.value = false;
        _updateNotification();
        if (onBreakComplete != null) {
          onBreakComplete!();
        }
      }
    });
    isRunning.value = true;
    _showNotification();
  }

  void pauseTimer() {
    _timer?.cancel();
    isRunning.value = false;
    _updateNotification();
  }

  void resetTimer() {
    _timer?.cancel();
    isRunning.value = false;
    secondsRemaining.value = totalSeconds.value;
    breakSecondsRemaining.value = totalBreakSeconds.value;
    isOnBreak.value = false;
    _updateNotification();
  }

  void resetAll(){
    _timer?.cancel();
    totalSeconds.value = 0;
    secondsRemaining.value = 0;
    totalBreakSeconds.value = 0;
    breakSecondsRemaining.value = 0;
    currentTaskTitle.value = '';
    onTimerComplete = null;
    onBreakComplete = null;
    _hideNotification();
  }

  void setTaskTitle(String title) {
    currentTaskTitle.value = title;
    _updateNotification();
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
