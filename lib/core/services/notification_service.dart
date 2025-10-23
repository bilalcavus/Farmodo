import 'dart:typed_data';

import 'package:farmodo/core/services/permission_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationService {
  static final FlutterLocalNotificationsPlugin _notifications = FlutterLocalNotificationsPlugin();
  static const int _timerNotificationId = 1001;
  static const int _completionNotificationId = 1002;
  static const String _timerChannelId = 'pomodoro_timer_channel';
  static const String _timerChannelName = 'Pomodoro Timer';
  static const String _timerChannelDescription = 'Pomodoro timer notifications';
  static const String _completionChannelId = 'pomodoro_completion_channel';
  static const String _completionChannelName = 'Timer Completed';
  static const String _completionChannelDescription = 'Notifications when timer completes';
  static const String _iosCategoryId = 'pomodoro_actions';

  static Future<void> initialize() async {
    try {
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

      final initialized = await _notifications.initialize(
        initSettings,
        onDidReceiveNotificationResponse: _onNotificationTapped,
      );

      if (initialized == true) {
        debugPrint('✅ Notification service initialized successfully');
        
        // Android notification channel oluştur
        await _createNotificationChannel();
      } else {
        debugPrint('❌ Notification service initialization failed');
      }
    } catch (e) {
      debugPrint('❌ Notification service initialization error: $e');
      rethrow;
    }
  }

  static void _onNotificationTapped(NotificationResponse response) {
    debugPrint('🔔 Notification tapped: ${response.payload}');
    // Notification'a tıklandığında yapılacak işlemler
  }

  static Future<void> _createNotificationChannel() async {
    // Silent channel for ongoing timer
    const timerChannel = AndroidNotificationChannel(
      _timerChannelId,
      _timerChannelName,
      description: _timerChannelDescription,
      importance: Importance.high,
      playSound: false,
      enableVibration: false,
    );

    // Sound channel for completion
    const completionChannel = AndroidNotificationChannel(
      _completionChannelId,
      _completionChannelName,
      description: _completionChannelDescription,
      importance: Importance.max,
      playSound: true,
      enableVibration: true,
      // Android default notification sound kullan
    );

    final plugin = _notifications
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
    
    await plugin?.createNotificationChannel(timerChannel);
    await plugin?.createNotificationChannel(completionChannel);
  }

  static Future<void> showTimerNotification({
    required String timeText,
    required String taskTitle,
    required String status,
    required bool isRunning,
    required double progress,
  }) async {    
    // Permission kontrolü
    final hasPermission = await PermissionService.checkNotificationPermission();
    if (!hasPermission) {
      final granted = await PermissionService.requestNotificationPermission();
      if (!granted) {
        return;
      }
    }
    // Samsung cihazları için özel optimizasyon
    final androidDetails = AndroidNotificationDetails(
      _timerChannelId,
      _timerChannelName,
      channelDescription: _timerChannelDescription,
      importance: Importance.low, // Samsung için düşük önem
      priority: Priority.low, // Samsung için düşük öncelik
      ongoing: true,
      autoCancel: false,
      showWhen: false,
      playSound: false,
      enableVibration: false,
      silent: true,
      icon: '@drawable/ic_notification',
      largeIcon: const DrawableResourceAndroidBitmap('@drawable/ic_notification'),
      category: AndroidNotificationCategory.progress,
      subText: status,
      // Samsung için özel ayarlar
      visibility: NotificationVisibility.private,
      onlyAlertOnce: true, // Samsung için sadece bir kez uyar
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

  /// Timer tamamlandığında ses ve titreşimle bildirim göster
  static Future<void> showCompletionNotification({
    required String title,
    required String body,
  }) async {
    try {
      final androidDetails = AndroidNotificationDetails(
        _completionChannelId,
        _completionChannelName,
        channelDescription: _completionChannelDescription,
        importance: Importance.max,
        priority: Priority.max,
        playSound: true,
        enableVibration: true,
        vibrationPattern: Int64List.fromList(const [0, 200, 100, 200, 100, 200]),
        autoCancel: true,
        icon: '@drawable/ic_notification',
        largeIcon: const DrawableResourceAndroidBitmap('@drawable/ic_notification'),
      );

      const iosDetails = DarwinNotificationDetails(
        categoryIdentifier: _iosCategoryId,
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
        sound: 'complete_sound.mp3',
      );

      final notificationDetails = NotificationDetails(
        android: androidDetails,
        iOS: iosDetails,
      );

      await _notifications.show(
        _completionNotificationId,
        title,
        body,
        notificationDetails,
      );
      
      debugPrint('✅ Completion notification shown with sound');
    } catch (e) {
      debugPrint('❌ Completion notification error: $e');
    }
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
