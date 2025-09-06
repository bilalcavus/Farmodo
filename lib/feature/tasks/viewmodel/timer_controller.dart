import 'dart:async';

import 'package:farmodo/core/services/home_widget_service.dart';
import 'package:farmodo/core/services/widget_interaction_service.dart';
import 'package:farmodo/feature/home/widgets/full_screen_timer.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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

  @override
  void onInit() {
    super.onInit();
    _setupWidgetInteraction();
    _checkWidgetActions();
  }

  void _setupWidgetInteraction() {
    WidgetInteractionService.listenToWidgetActions((action) {
      _handleWidgetAction(action);
    });
  }

  void _checkWidgetActions() async {
    final action = await WidgetInteractionService.getLastWidgetAction();
    if (action != null) {
      _handleWidgetAction(action);
      await WidgetInteractionService.clearWidgetAction();
    }
  }

  void _handleWidgetAction(String action) {
    switch (action) {
      case 'start_timer':
        if (!isRunning.value && (totalSeconds.value > 0 || totalBreakSeconds.value > 0)) {
          if (isOnBreak.value) {
            startBreakTimer();
          } else {
            startTimer();
          }
        }
        break;
      case 'pause_timer':
        if (isRunning.value) {
          pauseTimer();
        }
        break;
      case 'open_app':
        break;
    }
  }

  void _updateHomeWidget() {
    HomeWidgetService.updateWidget(
      isRunning: isRunning.value,
      secondsRemaining: isOnBreak.value ? breakSecondsRemaining.value : secondsRemaining.value,
      isOnBreak: isOnBreak.value,
      totalSeconds: isOnBreak.value ? totalBreakSeconds.value : totalSeconds.value,
      taskTitle: currentTaskTitle.value,
    );
  }

  void _clearHomeWidget() {
    HomeWidgetService.clearWidget();
  }

  void startTimer(){
    if(isRunning.value) return;
    if(totalSeconds.value == 0) return;
    _timer = Timer.periodic(Duration(seconds: 1), (_){
      if(secondsRemaining.value > 0){
        secondsRemaining.value--;
        _updateHomeWidget();
      } else {
        _timer?.cancel();
        isRunning.value = false;
        secondsRemaining.value = totalSeconds.value;
        isOnBreak.value = true;
        _updateHomeWidget();
        if (onTimerComplete != null) {
          onTimerComplete!();
        }
        startBreakTimer();
      }
    });
    isRunning.value = true;
    _updateHomeWidget();
  }

  void startBreakTimer(){
    if (isRunning.value) return;
    if(totalBreakSeconds.value == 0) return;
    _timer = Timer.periodic(Duration(seconds: 1), (_){
      if(breakSecondsRemaining.value > 0){
        breakSecondsRemaining.value --;
        _updateHomeWidget();
      } else {
        _timer?.cancel();
        isRunning.value = false;
        breakSecondsRemaining.value = totalBreakSeconds.value;
        isOnBreak.value = false;
        _updateHomeWidget();
        if (onBreakComplete != null) {
          onBreakComplete!();
        }
      }
    });
    isRunning.value = true;
    _updateHomeWidget();
  }

  void pauseTimer() {
    _timer?.cancel();
    isRunning.value = false;
    _updateHomeWidget();
  }

  void resetTimer() {
    _timer?.cancel();
    isRunning.value = false;
    secondsRemaining.value = totalSeconds.value;
    breakSecondsRemaining.value = totalBreakSeconds.value;
    isOnBreak.value = false;
    _updateHomeWidget();
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
    _clearHomeWidget();
  }

  void setTaskTitle(String title) {
    currentTaskTitle.value = title;
    _updateHomeWidget();
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
