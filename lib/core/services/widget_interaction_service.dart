import 'package:flutter/material.dart';
import 'package:home_widget/home_widget.dart';

class WidgetInteractionService {
  static const String _widgetActionKey = 'widget_action';
  static const String _actionStartTimer = 'start_timer';
  static const String _actionPauseTimer = 'pause_timer';
  static const String _actionOpenApp = 'open_app';

  // Widget'tan gelen aksiyonları dinle
  static void listenToWidgetActions(Function(String action) onAction) {
    HomeWidget.setAppGroupId('your_app_group_id'); // iOS için gerekli
    
    HomeWidget.registerBackgroundCallback(backgroundCallback);
    
    // Widget aksiyonlarını dinle
    HomeWidget.widgetClicked.listen((uri) {
      if (uri != null) {
        final action = uri.queryParameters['action'];
        if (action != null) {
          onAction(action);
        }
      }
    });
  }

  // Background callback
  static Future<void> backgroundCallback(Uri? uri) async {
    if (uri != null) {
      final action = uri.queryParameters['action'];
      debugPrint('Widget action received: $action');
      
      // Widget verilerini güncelle
      await HomeWidget.saveWidgetData(_widgetActionKey, action);
    }
  }

  // Widget'tan gelen aksiyonu kontrol et
  static Future<String?> getLastWidgetAction() async {
    try {
      return await HomeWidget.getWidgetData<String>(_widgetActionKey);
    } catch (e) {
      debugPrint('Widget action alınırken hata: $e');
      return null;
    }
  }

  // Widget aksiyonunu temizle
  static Future<void> clearWidgetAction() async {
    try {
      await HomeWidget.saveWidgetData(_widgetActionKey, null);
    } catch (e) {
      debugPrint('Widget action temizlenirken hata: $e');
    }
  }

  // Widget'ı güncelle
  static Future<void> updateWidget() async {
    try {
      await HomeWidget.updateWidget(
        androidName: 'PomodoroTimerWidgetProvider',
        iOSName: 'PomodoroTimerWidget',
        qualifiedAndroidName: 'com.bilalcavus.farmodo.PomodoroTimerWidgetProvider',
      );
    } catch (e) {
      debugPrint('Widget güncellenirken hata: $e');
    }
  }
}
