import 'package:flutter/material.dart';
import 'package:home_widget/home_widget.dart';

class HomeWidgetService {
  static const String _widgetName = 'HomeScreenWidget';
  static const String _appGroupId = 'group.com.bilalcavus.farmodo';

  /// Widget verilerini günceller
  static Future<void> updateWidget({
    required bool timerRunning,
    required int secondsRemaining,
    required bool isOnBreak,
    required int totalSeconds,
    required String taskTitle,
  }) async {
    try {
      // App Group ID'yi set et (iOS için gerekli)
      await HomeWidget.setAppGroupId(_appGroupId);
      
      await HomeWidget.saveWidgetData<bool>('timer_running', timerRunning);
      await HomeWidget.saveWidgetData<int>('seconds_remaining', secondsRemaining);
      await HomeWidget.saveWidgetData<bool>('is_on_break', isOnBreak);
      await HomeWidget.saveWidgetData<int>('total_seconds', totalSeconds);
      await HomeWidget.saveWidgetData<String>('task_title', taskTitle);
      
      // Widget'ı güncelle
      await HomeWidget.updateWidget(
        name: _widgetName,
        androidName: 'PomodoroTimerWidgetProvider',
        iOSName: _widgetName,
      );
    } catch (e) {
      debugPrint('Widget güncelleme hatası: $e');
    }
  }

  /// Timer durumunu günceller
  static Future<void> updateTimerStatus({
    required bool isRunning,
    required int secondsRemaining,
    required bool isOnBreak,
    required int totalSeconds,
    required String taskTitle,
  }) async {
    await updateWidget(
      timerRunning: isRunning,
      secondsRemaining: secondsRemaining,
      isOnBreak: isOnBreak,
      totalSeconds: totalSeconds,
      taskTitle: taskTitle,
    );
  }

  /// Widget'ı temizler
  static Future<void> clearWidget() async {
    try {
      await HomeWidget.setAppGroupId(_appGroupId);
      
      await HomeWidget.saveWidgetData<bool>('timer_running', false);
      await HomeWidget.saveWidgetData<int>('seconds_remaining', 0);
      await HomeWidget.saveWidgetData<bool>('is_on_break', false);
      await HomeWidget.saveWidgetData<int>('total_seconds', 0);
      await HomeWidget.saveWidgetData<String>('task_title', 'No active task');
      
      await HomeWidget.updateWidget(
        name: _widgetName,
        androidName: 'PomodoroTimerWidgetProvider',
        iOSName: _widgetName,
      );
    } catch (e) {
      debugPrint('Widget temizleme hatası: $e');
    }
  }

  /// Widget'ın desteklenip desteklenmediğini kontrol eder
  static Future<bool> isWidgetSupported() async {
    try {
      // Widget desteğini test etmek için basit bir veri kaydetme işlemi yapalım
      await HomeWidget.saveWidgetData<String>('test_key', 'test_value');
      return true;
    } catch (e) {
      debugPrint('Widget desteği kontrolü hatası: $e');
      return false;
    }
  }
}
