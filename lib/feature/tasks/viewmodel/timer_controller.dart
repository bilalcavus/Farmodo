import 'dart:async';
import 'dart:io';
import 'package:easy_localization/easy_localization.dart';
import 'package:farmodo/core/utility/constants/storage_keys.dart';
import 'package:farmodo/core/services/notification_service.dart';
import 'package:farmodo/core/services/home_widget_service.dart';
import 'package:farmodo/core/services/live_activity_service.dart';
import 'package:farmodo/core/services/android_timer_service.dart';
import 'package:farmodo/core/services/preferences_service.dart';
import 'package:farmodo/data/services/auth_service.dart';
import 'package:farmodo/feature/tasks/utility/player_config.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart' hide Trans;

class TimerController extends GetxController {
  RxInt totalSeconds = RxInt(0);
  RxInt secondsRemaining = RxInt(0);
  var totalBreakSeconds = (5 * 60).obs;
  var breakSecondsRemaining = (5 * 60).obs;
  final playerConfig = PlayerConfig();
  Timer? _timer;
  Timer? get timer => _timer;
  var isRunning = false.obs;
  var isOnBreak = false.obs;
  var currentTaskTitle = ''.obs;
  var isRestoring = false.obs;
  DateTime? _lastTick;

  final PreferencesService _prefsService = PreferencesService.instance;
  final AuthService _authService = AuthService();
  
  @override
  void onInit() {
    super.onInit();
    playerConfig.configAudioPlayer();
  }

  String? get _userId => _authService.getCurrentUserId;
  
  String get _keyTotalSeconds => StorageKeys.userKey(_userId, StorageKeys.timerTotalSeconds);
  String get _keySecondsRemaining => StorageKeys.userKey(_userId, StorageKeys.timerSecondsRemaining);
  String get _keyTotalBreakSeconds => StorageKeys.userKey(_userId, StorageKeys.timerTotalBreakSeconds);
  String get _keyBreakSecondsRemaining => StorageKeys.userKey(_userId, StorageKeys.timerBreakSecondsRemaining);
  String get _keyIsOnBreak => StorageKeys.userKey(_userId, StorageKeys.timerIsOnBreak);
  String get _keyCurrentTaskTitle => StorageKeys.userKey(_userId, StorageKeys.timerCurrentTaskTitle);
  String get _keyLastTick => StorageKeys.userKey(_userId, StorageKeys.timerLastTick);
  String get _keyIsRunning => StorageKeys.userKey(_userId, StorageKeys.timerIsRunning);
  
  double get progress => totalSeconds.value == 0 ? 0.0 : (totalSeconds.value - secondsRemaining.value) / totalSeconds.value;
  double get breakProgress => totalBreakSeconds.value == 0 ? 0.0 : (totalBreakSeconds.value - breakSecondsRemaining.value) / totalBreakSeconds.value;
  double get displayProgress => isOnBreak.value ? breakProgress : progress;

  VoidCallback? onTimerComplete;
  VoidCallback? onBreakComplete;




  void startTimer(){
    if(isRunning.value) return;
    if(totalSeconds.value == 0) return;
    
    if (Platform.isIOS) {
      if (!LiveActivityService.isActive) {
        LiveActivityService.startTimerActivity(
          taskTitle: currentTaskTitle.value.isEmpty ? 'Focus Session' : currentTaskTitle.value,
          totalSeconds: totalSeconds.value,
          remainingSeconds: secondsRemaining.value,
          isOnBreak: false,
        );
      } else {
        LiveActivityService.updateActivity(
          remainingSeconds: secondsRemaining.value,
          totalSeconds: totalSeconds.value,
          isOnBreak: false,
          isPaused: false,
        );
      }
    }
    
    AndroidTimerService.acquireWakeLock();
    _lastTick = DateTime.now();
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      _handleFocusTick();
    });
    isRunning.value = true;
    _showNotification();
    saveTimerState();
  }

  void startBreakTimer(){
    if (isRunning.value) return;
    if(totalBreakSeconds.value == 0) return;
    
    if (Platform.isIOS) {
      LiveActivityService.switchToBreak(
        breakSeconds: breakSecondsRemaining.value,
        totalBreakSeconds: totalBreakSeconds.value,
      );
    }
    
    AndroidTimerService.acquireWakeLock();
    _lastTick = DateTime.now();
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      _handleBreakTick();
    });
    isRunning.value = true;
    _showNotification();
    saveTimerState();
  }

  void pauseTimer() {
    _timer?.cancel();
    isRunning.value = false;
    _lastTick = null;
    AndroidTimerService.releaseWakeLock();
    
    if (Platform.isIOS) {
      LiveActivityService.setPaused(true);
    }
    
    _updateNotification();
    saveTimerState();
  }

  void resetTimer() {
    _timer?.cancel();
    isRunning.value = false;
    secondsRemaining.value = totalSeconds.value;
    breakSecondsRemaining.value = totalBreakSeconds.value;
    isOnBreak.value = false;
    _lastTick = null;
    AndroidTimerService.releaseWakeLock();
    _updateNotification();
    saveTimerState();
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
    _lastTick = null;
    AndroidTimerService.releaseWakeLock();
    
    if (Platform.isIOS) {
      LiveActivityService.stopActivity();
    }
    
    _hideNotification();
    clearSavedTimerState();
  }

  void setTaskTitle(String title) {
    currentTaskTitle.value = title;
    _updateNotification();
    saveTimerState();
  }
  


  String formatTime(int seconds) {
    final minutes = (seconds ~/ 60).toString().padLeft(2, '0');
    final secs = (seconds % 60).toString().padLeft(2, '0');
    return '$minutes:$secs';
  }

  Future<void> saveTimerState() async {
    if (isRestoring.value) return;
    
    try {
      await _prefsService.setInt(_keyTotalSeconds, totalSeconds.value);
      await _prefsService.setInt(_keySecondsRemaining, secondsRemaining.value);
      await _prefsService.setInt(_keyTotalBreakSeconds, totalBreakSeconds.value);
      await _prefsService.setInt(_keyBreakSecondsRemaining, breakSecondsRemaining.value);
      await _prefsService.setBool(_keyIsOnBreak, isOnBreak.value);
      await _prefsService.setString(_keyCurrentTaskTitle, currentTaskTitle.value);
      await _prefsService.setBool(_keyIsRunning, isRunning.value);
      await _prefsService.setInt(
        _keyLastTick,
        _lastTick?.millisecondsSinceEpoch ?? 0,
      );
    } catch (e) {
      debugPrint('Timer state save error: $e');
    }
  }

  Future<void> restoreTimerState() async {
    isRestoring.value = true;
    try {
      final savedTotalSeconds = _prefsService.getInt(_keyTotalSeconds, 0);
      final savedSecondsRemaining = _prefsService.getInt(_keySecondsRemaining, 0);
      final savedTotalBreakSeconds = _prefsService.getInt(_keyTotalBreakSeconds, 0);
      final savedBreakSecondsRemaining = _prefsService.getInt(_keyBreakSecondsRemaining, 0);
      final savedIsOnBreak = _prefsService.getBool(_keyIsOnBreak, false);
      final savedTaskTitle = _prefsService.getString(_keyCurrentTaskTitle, '');
      final savedIsRunning = _prefsService.getBool(_keyIsRunning, false);
      final savedLastTickMillis = _prefsService.getInt(_keyLastTick, 0);

      if (savedTotalSeconds > 0 || savedTotalBreakSeconds > 0) {
        totalSeconds.value = savedTotalSeconds;
        secondsRemaining.value = savedSecondsRemaining;
        totalBreakSeconds.value = savedTotalBreakSeconds;
        breakSecondsRemaining.value = savedBreakSecondsRemaining;
        isOnBreak.value = savedIsOnBreak;
        currentTaskTitle.value = savedTaskTitle;

        bool hasRemainingPhase = false;
        if (savedIsRunning && savedLastTickMillis > 0) {
          _lastTick = DateTime.fromMillisecondsSinceEpoch(savedLastTickMillis);
          hasRemainingPhase = _applyElapsedSinceLastTick(
            wasOnBreak: savedIsOnBreak,
            wasRunning: savedIsRunning,
          );
        } else {
          _lastTick = null;
          if (savedIsRunning) {
            hasRemainingPhase = savedIsOnBreak
                ? breakSecondsRemaining.value > 0
                : secondsRemaining.value > 0;
          }
        }

        _updateNotification();

        if (savedIsRunning && hasRemainingPhase) {
          Future.microtask(() {
            if (isOnBreak.value) {
              if (breakSecondsRemaining.value > 0) {
                startBreakTimer();
              }
            } else {
              if (secondsRemaining.value > 0) {
                startTimer();
              }
            }
          });
        } else {
          isRunning.value = false;
        }
      }
    } catch (e) {
      debugPrint('Timer state restore error: $e');
    } finally {
      isRestoring.value = false;
    }
  }

  Future<void> clearSavedTimerState() async {
    try {
      await _prefsService.remove(_keyTotalSeconds);
      await _prefsService.remove(_keySecondsRemaining);
      await _prefsService.remove(_keyTotalBreakSeconds);
      await _prefsService.remove(_keyBreakSecondsRemaining);
      await _prefsService.remove(_keyIsOnBreak);
      await _prefsService.remove(_keyCurrentTaskTitle);
      await _prefsService.remove(_keyIsRunning);
      await _prefsService.remove(_keyLastTick);
    } catch (e) {
      debugPrint('Timer state clear error: $e');
    }
  }

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

    _updateWidget();
    _updateLiveActivity();
  }
  
  void _updateLiveActivity() {
    if (LiveActivityService.isActive) {
      LiveActivityService.updateActivity(
        remainingSeconds: isOnBreak.value ? breakSecondsRemaining.value : secondsRemaining.value,
        totalSeconds: isOnBreak.value ? totalBreakSeconds.value : totalSeconds.value,
        isOnBreak: isOnBreak.value,
        isPaused: !isRunning.value,
      );
    }
  }

  void _updateWidget() {
    HomeWidgetService.updateTimerStatus(
      isRunning: isRunning.value,
      secondsRemaining: isOnBreak.value ? breakSecondsRemaining.value : secondsRemaining.value,
      isOnBreak: isOnBreak.value,
      totalSeconds: isOnBreak.value ? totalBreakSeconds.value : totalSeconds.value,
      taskTitle: currentTaskTitle.value.isEmpty ? 'No active task' : currentTaskTitle.value,
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
    HomeWidgetService.clearWidget();
  }

  @override
  void onClose() {
    timer?.cancel();
    _lastTick = null;
    AndroidTimerService.releaseWakeLock();
    super.onClose();
  }

  void _handleFocusTick() {
    final now = DateTime.now();
    final elapsed = _calculateElapsedSeconds(now);
    if (elapsed <= 0) {
      _lastTick = now;
      return;
    }

    if (secondsRemaining.value > elapsed) {
      secondsRemaining.value -= elapsed;
      _lastTick = now;
      _onTickCompleted(isBreak: false);
    } else {
      final remainingBefore = secondsRemaining.value;
      final overflow = elapsed - remainingBefore;
      secondsRemaining.value = 0;
      _lastTick = now;
      _completeFocusSession(
        overflowSeconds: overflow > 0 ? overflow : 0,
      );
    }
  }

  void _handleBreakTick() {
    final now = DateTime.now();
    final elapsed = _calculateElapsedSeconds(now);
    if (elapsed <= 0) {
      _lastTick = now;
      return;
    }

    if (breakSecondsRemaining.value > elapsed) {
      breakSecondsRemaining.value -= elapsed;
      _lastTick = now;
      _onTickCompleted(isBreak: true);
    } else {
      breakSecondsRemaining.value = 0;
      _lastTick = now;
      _completeBreakSession();
    }
  }

  int _calculateElapsedSeconds(DateTime now) {
    if (_lastTick == null) {
      return 1;
    }
    final diff = now.difference(_lastTick!).inSeconds;
    return diff <= 0 ? 1 : diff;
  }

  void _onTickCompleted({required bool isBreak}) {
    _updateNotification();
    final remaining = isBreak ? breakSecondsRemaining.value : secondsRemaining.value;
    if (remaining % 5 == 0) {
      saveTimerState();
    }
  }

  void _completeFocusSession({bool fromRestore = false, int overflowSeconds = 0}) {
    _timer?.cancel();
    isRunning.value = false;
    secondsRemaining.value = totalSeconds.value;
    isOnBreak.value = true;
    _updateNotification();
    saveTimerState();
    if (onTimerComplete != null) {
      onTimerComplete!();
    }
    if (!fromRestore) {
      playerConfig.playCompletionSound();
      NotificationService.showCompletionNotification(
        title: 'home.focus_completed'.tr(),
        body: 'home.break_time_now'.tr(),
      );
    }
    if (totalBreakSeconds.value == 0) {
      _lastTick = null;
      AndroidTimerService.releaseWakeLock();
      return;
    }
    if (overflowSeconds > 0) {
      final updatedBreak = breakSecondsRemaining.value - overflowSeconds;
      breakSecondsRemaining.value = updatedBreak > 0 ? updatedBreak : 0;
    }
    if (breakSecondsRemaining.value <= 0) {
      _completeBreakSession(fromRestore: fromRestore);
    } else {
      if (fromRestore) {
        _lastTick = DateTime.now();
      } else {
        startBreakTimer();
      }
    }
  }

  void _completeBreakSession({bool fromRestore = false}) {
    _timer?.cancel();
    isRunning.value = false;
    breakSecondsRemaining.value = totalBreakSeconds.value;
    isOnBreak.value = false;
    _lastTick = null;
    AndroidTimerService.releaseWakeLock();
    _updateNotification();
    saveTimerState();
    if (!fromRestore) {
      playerConfig.playCompletionSound();
      NotificationService.showCompletionNotification(
        title: 'home.break_over'.tr(),
        body: 'home.break_time_message'.tr(),
      );
    }
    if (onBreakComplete != null) {
      onBreakComplete!();
    }
  }

  bool _applyElapsedSinceLastTick({
    required bool wasOnBreak,
    required bool wasRunning,
  }) {
    if (!wasRunning) {
      _lastTick = null;
      return false;
    }
    if (_lastTick == null) {
      return wasOnBreak
          ? breakSecondsRemaining.value > 0
          : secondsRemaining.value > 0;
    }
    final now = DateTime.now();
    final diffSeconds = now.difference(_lastTick!).inSeconds;
    if (diffSeconds <= 0) {
      return wasOnBreak
          ? breakSecondsRemaining.value > 0
          : secondsRemaining.value > 0;
    }

    if (wasOnBreak) {
      final updated = breakSecondsRemaining.value - diffSeconds;
      if (updated > 0) {
        breakSecondsRemaining.value = updated;
        _lastTick = now;
        return true;
      } else {
        breakSecondsRemaining.value = 0;
        _completeBreakSession(fromRestore: true);
        return false;
      }
    } else {
      final updated = secondsRemaining.value - diffSeconds;
      if (updated > 0) {
        secondsRemaining.value = updated;
        _lastTick = now;
        return true;
      } else {
        secondsRemaining.value = 0;
        final overflow = updated.abs();
        _completeFocusSession(
          fromRestore: true,
          overflowSeconds: overflow,
        );
        if (isOnBreak.value && breakSecondsRemaining.value > 0) {
          return true;
        }
        return false;
      }
    }
  }
}
