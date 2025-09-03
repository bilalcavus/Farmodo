import 'package:flutter/material.dart';
import 'package:home_widget/home_widget.dart';

class HomeWidgetService {
  static const String _timerRunningKey = 'timer_running';
  static const String _secondsRemainingKey = 'seconds_remaining';
  static const String _isOnBreakKey = 'is_on_break';
  static const String _totalSecondsKey = 'total_seconds';
  static const String _taskTitleKey = 'task_title';
  static const String _lastUpdateKey = 'last_update';

  // Widget'ı güncelle
  static Future<void> updateWidget({
    required bool isRunning,
    required int secondsRemaining,
    required bool isOnBreak,
    required int totalSeconds,
    String? taskTitle,
  }) async {
    try {
      
      await HomeWidget.saveWidgetData(_timerRunningKey, isRunning);
      await HomeWidget.saveWidgetData(_secondsRemainingKey, secondsRemaining);
      await HomeWidget.saveWidgetData(_isOnBreakKey, isOnBreak);
      await HomeWidget.saveWidgetData(_totalSecondsKey, totalSeconds);
      await HomeWidget.saveWidgetData(_taskTitleKey, taskTitle ?? '');
      await HomeWidget.saveWidgetData(_lastUpdateKey, DateTime.now().millisecondsSinceEpoch);
      
      // Widget'ı güncelle
      await HomeWidget.updateWidget(
        androidName: 'PomodoroTimerWidgetProvider',
        iOSName: 'PomodoroTimerWidget',
        qualifiedAndroidName: 'com.bilalcavus.farmodo.PomodoroTimerWidgetProvider',
      );
    } catch (e) {
      debugPrint('Home widget güncellenirken hata: $e');
    }
  }

  // Widget'ı temizle
  static Future<void> clearWidget() async {
    try {
      await HomeWidget.saveWidgetData(_timerRunningKey, false);
      await HomeWidget.saveWidgetData(_secondsRemainingKey, 0);
      await HomeWidget.saveWidgetData(_isOnBreakKey, false);
      await HomeWidget.saveWidgetData(_totalSecondsKey, 0);
      await HomeWidget.saveWidgetData(_taskTitleKey, '');
      await HomeWidget.saveWidgetData(_lastUpdateKey, 0);
      
      await HomeWidget.updateWidget(
        androidName: 'PomodoroTimerWidgetProvider',
        iOSName: 'PomodoroTimerWidget',
        qualifiedAndroidName: 'com.bilalcavus.farmodo.PomodoroTimerWidgetProvider',
      );
    } catch (e) {
      debugPrint('Home widget temizlenirken hata: $e');
    }
  }

  // Widget verilerini oku
  static Future<Map<String, dynamic>> getWidgetData() async {
    try {
      final isRunning = await HomeWidget.getWidgetData<bool>(_timerRunningKey) ?? false;
      final secondsRemaining = await HomeWidget.getWidgetData<int>(_secondsRemainingKey) ?? 0;
      final isOnBreak = await HomeWidget.getWidgetData<bool>(_isOnBreakKey) ?? false;
      final totalSeconds = await HomeWidget.getWidgetData<int>(_totalSecondsKey) ?? 0;
      final taskTitle = await HomeWidget.getWidgetData<String>(_taskTitleKey) ?? '';
      final lastUpdate = await HomeWidget.getWidgetData<int>(_lastUpdateKey) ?? 0;

      return {
        'isRunning': isRunning,
        'secondsRemaining': secondsRemaining,
        'isOnBreak': isOnBreak,
        'totalSeconds': totalSeconds,
        'taskTitle': taskTitle,
        'lastUpdate': lastUpdate,
      };
    } catch (e) {
      debugPrint('Widget verileri okunurken hata: $e');
      return {
        'isRunning': false,
        'secondsRemaining': 0,
        'isOnBreak': false,
        'totalSeconds': 0,
        'taskTitle': '',
        'lastUpdate': 0,
      };
    }
  }

  // Zamanı formatla
  static String formatTime(int seconds) {
    final minutes = (seconds ~/ 60).toString().padLeft(2, '0');
    final secs = (seconds % 60).toString().padLeft(2, '0');
    return '$minutes:$secs';
  }

  // İlerleme yüzdesini hesapla
  static double calculateProgress(int totalSeconds, int secondsRemaining) {
    if (totalSeconds == 0) return 0.0;
    return (totalSeconds - secondsRemaining) / totalSeconds;
  }
}
