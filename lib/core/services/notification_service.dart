import 'package:farmodo/core/services/permission_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';
import 'package:farmodo/feature/tasks/viewmodel/timer_controller.dart';

class NotificationService {
  static final FlutterLocalNotificationsPlugin _notifications = FlutterLocalNotificationsPlugin();
  static const int _timerNotificationId = 1001;
  static const String _timerChannelId = 'pomodoro_timer_channel';
  static const String _timerChannelName = 'Pomodoro Timer';
  static const String _timerChannelDescription = 'Pomodoro timer notifications';
  static const String _iosCategoryId = 'pomodoro_actions';

  static Future<void> initialize() async {
    const androidSettings = AndroidInitializationSettings('@drawable/ic_notification');
    final iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );
    
    final initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _notifications.initialize(
      initSettings,
    );

    // Android notification channel oluştur
    await _createNotificationChannel();
  }

  static Future<void> _createNotificationChannel() async {
    const androidChannel = AndroidNotificationChannel(
      _timerChannelId,
      _timerChannelName,
      description: _timerChannelDescription,
      importance: Importance.high,
      playSound: false,
      enableVibration: false,
    );

    await _notifications
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(androidChannel);
  }

  static Future<void> showTimerNotification({
    required String timeText,
    required String taskTitle,
    required String status,
    required bool isRunning,
    required double progress,
  }) async {
    debugPrint('🔔 Notification gösteriliyor: $timeText - $status');
    
    // Permission kontrolü
    final hasPermission = await PermissionService.checkNotificationPermission();
    if (!hasPermission) {
      debugPrint('❌ Notification permission yok, istiyoruz...');
      final granted = await PermissionService.requestNotificationPermission();
      if (!granted) {
        debugPrint('❌ Notification permission reddedildi');
        return;
      }
    }
    // Progress bar için custom layout
    final androidDetails = AndroidNotificationDetails(
      _timerChannelId,
      _timerChannelName,
      channelDescription: _timerChannelDescription,
      importance: Importance.high,
      priority: Priority.high,
      ongoing: true,
      autoCancel: false,
      showWhen: false,
      playSound: false,
      enableVibration: false,
      silent: true,
      colorized: true,
      color: Colors.redAccent,
      // Small icon ve large icon'u mevcut launcher ikonuyla hizala
      icon: '@drawable/ic_notification',
      largeIcon: const DrawableResourceAndroidBitmap('@drawable/ic_notification'),
      category: AndroidNotificationCategory.progress,
      subText: status,
      styleInformation: BigTextStyleInformation(
        '$status • $taskTitle',
        contentTitle: '<b>$timeText</b>',
        htmlFormatContentTitle: true,
      ),

    );

    const iosDetails = DarwinNotificationDetails(
      categoryIdentifier: _iosCategoryId,
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    final notificationDetails = NotificationDetails(android: androidDetails, iOS: iosDetails);

    try {
      await _notifications.show(
        _timerNotificationId,
        timeText,
        '$status • $taskTitle',
        notificationDetails,
      );
      debugPrint('✅ Notification başarıyla gösterildi');
    } catch (e) {
      debugPrint('❌ Notification hatası: $e');
    }
  }

  static Future<void> updateTimerNotification({
    required String timeText,
    required String taskTitle,
    required String status,
    required bool isRunning,
    required double progress,
  }) async {
    // Mevcut notification'ı güncelle
    await showTimerNotification(
      timeText: timeText,
      taskTitle: taskTitle,
      status: status,
      isRunning: isRunning,
      progress: progress,
    );
  }

  static Future<void> hideTimerNotification() async {
    await _notifications.cancel(_timerNotificationId);
  }

  

  
  // Foreground service için
  static Future<void> startForegroundService() async {
    const androidDetails = AndroidNotificationDetails(
      _timerChannelId,
      _timerChannelName,
      channelDescription: _timerChannelDescription,
      importance: Importance.low,
      priority: Priority.low,
      ongoing: true,
      autoCancel: false,
      showWhen: false,
      playSound: false,
      enableVibration: false,
      silent: true,
      icon: '@drawable/ic_notification',
      largeIcon: DrawableResourceAndroidBitmap('@drawable/ic_notification'),
    );

    const notificationDetails = NotificationDetails(android: androidDetails);

    await _notifications.show(
      _timerNotificationId,
      'Pomodoro Timer Running',
      'Timer is running in background',
      notificationDetails,
    );
  }

  static Future<void> stopForegroundService() async {
    await _notifications.cancel(_timerNotificationId);
  }
}
