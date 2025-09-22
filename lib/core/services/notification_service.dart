import 'package:farmodo/core/services/permission_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';

class NotificationService {
  static final FlutterLocalNotificationsPlugin _notifications = FlutterLocalNotificationsPlugin();
  static const int _timerNotificationId = 1001;
  static const String _timerChannelId = 'pomodoro_timer_channel';
  static const String _timerChannelName = 'Pomodoro Timer';
  static const String _timerChannelDescription = 'Pomodoro timer notifications';

  static Future<void> initialize() async {
    const androidSettings = AndroidInitializationSettings('@mipmap/launcher_icon');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );
    
    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _notifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _onNotificationTap,
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
      category: AndroidNotificationCategory.progress,
      actions: [
        AndroidNotificationAction(
          'play_pause',
          isRunning ? 'Pause' : 'Play',
          icon: const DrawableResourceAndroidBitmap('@drawable/ic_play'),
        ),
        const AndroidNotificationAction(
          'reset',
          'Reset',
          icon: DrawableResourceAndroidBitmap('@drawable/ic_refresh'),
        ),
        const AndroidNotificationAction(
          'open_app',
          'Open App',
          icon: DrawableResourceAndroidBitmap('@drawable/ic_open'),
        ),
      ],
    );

    final notificationDetails = NotificationDetails(android: androidDetails);

    try {
      await _notifications.show(
        _timerNotificationId,
        'Pomodoro Timer - $status',
        '$timeText\n$taskTitle',
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

  static void _onNotificationTap(NotificationResponse response) {
    final actionId = response.actionId;
    
    switch (actionId) {
      case 'play_pause':
        // Timer controller'dan play/pause tetikle
        try {
          final timerController = Get.find<dynamic>();
          if (timerController.isRunning.value) {
            timerController.pauseTimer();
          } else {
            timerController.startTimer();
          }
        } catch (e) {
          debugPrint('Timer controller bulunamadı: $e');
        }
        break;
      case 'reset':
        // Timer controller'dan reset tetikle
        try {
          Get.find<dynamic>().resetTimer();
        } catch (e) {
          debugPrint('Timer controller bulunamadı: $e');
        }
        break;
      case 'open_app':
        // Uygulamayı aç
        Get.toNamed('/home');
        break;
      default:
        // Notification'a tıklama - uygulamayı aç
        Get.toNamed('/home');
        break;
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
