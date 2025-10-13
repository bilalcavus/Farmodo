import 'dart:async';
import 'dart:io';

import 'package:audioplayers/audioplayers.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:farmodo/core/utility/constants/storage_keys.dart';
import 'package:farmodo/core/services/notification_service.dart';
import 'package:farmodo/core/services/home_widget_service.dart';
import 'package:farmodo/core/services/live_activity_service.dart';
import 'package:farmodo/core/services/preferences_service.dart';
import 'package:farmodo/data/services/auth_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart' hide Trans;

class TimerController extends GetxController {
  RxInt totalSeconds = RxInt(0);
  RxInt secondsRemaining = RxInt(0);
  var totalBreakSeconds = (5 * 60).obs;
  var breakSecondsRemaining = (5 * 60).obs;
  final player = AudioPlayer();
  Timer? _timer;
  Timer? get timer => _timer;
  var isRunning = false.obs;
  var isOnBreak = false.obs;
  var currentTaskTitle = ''.obs;
  var isRestoring = false.obs;

  final PreferencesService _prefsService = PreferencesService.instance;
  final AuthService _authService = AuthService();
  
  @override
  void onInit() {
    super.onInit();
    // AudioPlayer'ı yapılandır (arka plan için)
    player.setReleaseMode(ReleaseMode.stop);
    player.setVolume(1.0);
    // Android için audio mode
    if (Platform.isAndroid) {
      player.setAudioContext(
        AudioContext(
          iOS: AudioContextIOS(
            category: AVAudioSessionCategory.playback,
            options: {AVAudioSessionOptions.mixWithOthers},
          ),
          android: AudioContextAndroid(
            isSpeakerphoneOn: false,
            stayAwake: true,
            contentType: AndroidContentType.sonification,
            usageType: AndroidUsageType.notification,
            audioFocus: AndroidAudioFocus.none,
          ),
        ),
      );
    }
  }

  String? get _userId => _authService.getCurrentUserId;
  
  String get _keyTotalSeconds => StorageKeys.userKey(_userId, StorageKeys.timerTotalSeconds);
  String get _keySecondsRemaining => StorageKeys.userKey(_userId, StorageKeys.timerSecondsRemaining);
  String get _keyTotalBreakSeconds => StorageKeys.userKey(_userId, StorageKeys.timerTotalBreakSeconds);
  String get _keyBreakSecondsRemaining => StorageKeys.userKey(_userId, StorageKeys.timerBreakSecondsRemaining);
  String get _keyIsOnBreak => StorageKeys.userKey(_userId, StorageKeys.timerIsOnBreak);
  String get _keyCurrentTaskTitle => StorageKeys.userKey(_userId, StorageKeys.timerCurrentTaskTitle);
  
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

    // Widget'ı güncelle
    _updateWidget();
    
    // Live Activity'yi güncelle
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
    // Widget'ı temizle
    HomeWidgetService.clearWidget();
  }

  

  void startTimer(){
    if(isRunning.value) return;
    if(totalSeconds.value == 0) return;
    
    // iOS için Live Activity başlat
    if (Platform.isIOS) {
      if (!LiveActivityService.isActive) {
        LiveActivityService.startTimerActivity(
          taskTitle: currentTaskTitle.value.isEmpty ? 'Focus Session' : currentTaskTitle.value,
          totalSeconds: totalSeconds.value,
          remainingSeconds: secondsRemaining.value,
          isOnBreak: false,
        );
      } else {
        // Zaten varsa sadece pause durumunu kaldır
        LiveActivityService.updateActivity(
          remainingSeconds: secondsRemaining.value,
          totalSeconds: totalSeconds.value,
          isOnBreak: false,
          isPaused: false,
        );
      }
    }
    
    _timer = Timer.periodic(Duration(seconds: 1), (_){
      if(secondsRemaining.value > 0){
        secondsRemaining.value--;
        _updateNotification();
        if (secondsRemaining.value % 5 == 0) {
          saveTimerState();
        }
      } else {
        _timer?.cancel();
        isRunning.value = false;
        secondsRemaining.value = totalSeconds.value;
        isOnBreak.value = true;
        _updateNotification();
        saveTimerState();
        if (onTimerComplete != null) {
          onTimerComplete!();
        }
        _playCompletionSound();
        // Ses ve titreşimle bildirim göster
        NotificationService.showCompletionNotification(
          title: 'home.focus_completed'.tr(),
          body: 'home.break_time_now'.tr(),
        );
        startBreakTimer();
      }
    });
    isRunning.value = true;
    _showNotification();
    saveTimerState();
  }

  void startBreakTimer(){
    if (isRunning.value) return;
    if(totalBreakSeconds.value == 0) return;
    
    // iOS için break moduna geç
    if (Platform.isIOS) {
      LiveActivityService.switchToBreak(
        breakSeconds: breakSecondsRemaining.value,
        totalBreakSeconds: totalBreakSeconds.value,
      );
    }
    
    _timer = Timer.periodic(Duration(seconds: 1), (_){
      if(breakSecondsRemaining.value > 0){
        breakSecondsRemaining.value --;
        _updateNotification();
        if (breakSecondsRemaining.value % 5 == 0) {
          saveTimerState();
        }
      } else {
        _timer?.cancel();
        isRunning.value = false;
        breakSecondsRemaining.value = totalBreakSeconds.value;
        isOnBreak.value = false;
        _updateNotification();
        saveTimerState();
        // Ses ve titreşimle bildirim göster
        _playCompletionSound();
        NotificationService.showCompletionNotification(
          title: 'home.break_over'.tr(),
          body: 'home.break_time_message'.tr(),
        );
        if (onBreakComplete != null) {
          onBreakComplete!();
        }
      }
    });
    isRunning.value = true;
    _showNotification();
    saveTimerState();
  }

  void pauseTimer() {
    _timer?.cancel();
    isRunning.value = false;
    
    // iOS için Live Activity'yi pause et
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
    
    // iOS için Live Activity'yi durdur
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
  

  Future<void> _playCompletionSound() async {
    try {
      await player.stop();
      await player.play(AssetSource('sounds/complete_sound.mp3'));
      debugPrint('✅ Sound played successfully');
    } catch (e) {
      debugPrint('❌ Sound play error: $e');
    }
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

      if (savedTotalSeconds > 0 || savedTotalBreakSeconds > 0) {
        totalSeconds.value = savedTotalSeconds;
        secondsRemaining.value = savedSecondsRemaining;
        totalBreakSeconds.value = savedTotalBreakSeconds;
        breakSecondsRemaining.value = savedBreakSecondsRemaining;
        isOnBreak.value = savedIsOnBreak;
        currentTaskTitle.value = savedTaskTitle;
        
        _updateNotification();
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
    } catch (e) {
      debugPrint('Timer state clear error: $e');
    }
  }

  @override
  void onClose() {
    timer?.cancel();
    super.onClose();
  }
}
