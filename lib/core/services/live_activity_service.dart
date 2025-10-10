import 'package:flutter/material.dart';
import 'package:live_activities/live_activities.dart';

class LiveActivityService {
  static final _liveActivitiesPlugin = LiveActivities();
  static String? _currentActivityId;
  static bool _isInitialized = false;

  /// Live Activity servisini başlat (App Group ID ile)
  static Future<void> init() async {
    if (_isInitialized) return;
    
    try {
      await _liveActivitiesPlugin.init(
        appGroupId: 'group.com.bilalcavus.farmodo',
      );
      _isInitialized = true;
      debugPrint('✅ Live Activity service initialized');
    } catch (e) {
      debugPrint('❌ Live Activity init error: $e');
    }
  }

  /// Live Activity başlat
  static Future<void> startTimerActivity({
    required String taskTitle,
    required int totalSeconds,
    required int remainingSeconds,
    required bool isOnBreak,
  }) async {
    try {
      // Eğer zaten bir activity varsa, önce durdur
      if (_currentActivityId != null) {
        await stopActivity();
      }

      final activityData = {
        'taskTitle': taskTitle,
        'startTime': DateTime.now().millisecondsSinceEpoch ~/ 1000,
        'remainingSeconds': remainingSeconds,
        'totalSeconds': totalSeconds,
        'isOnBreak': isOnBreak,
        'isPaused': false,
      };

      // iOS için activity oluştur
      _currentActivityId = await _liveActivitiesPlugin.createActivity(
        activityData,
      );

      debugPrint('✅ Live Activity started: $_currentActivityId');
    } catch (e) {
      debugPrint('❌ Live Activity başlatma hatası: $e');
    }
  }

  /// Live Activity güncelle
  static Future<void> updateActivity({
    required int remainingSeconds,
    required int totalSeconds,
    required bool isOnBreak,
    required bool isPaused,
  }) async {
    if (_currentActivityId == null) return;

    try {
      final contentState = {
        'remainingSeconds': remainingSeconds,
        'totalSeconds': totalSeconds,
        'isOnBreak': isOnBreak,
        'isPaused': isPaused,
      };

      await _liveActivitiesPlugin.updateActivity(
        _currentActivityId!,
        contentState,
      );

      debugPrint('🔄 Live Activity updated - Remaining: $remainingSeconds sec');
    } catch (e) {
      debugPrint('❌ Live Activity güncelleme hatası: $e');
    }
  }

  /// Live Activity durdur
  static Future<void> stopActivity() async {
    if (_currentActivityId == null) return;

    try {
      await _liveActivitiesPlugin.endActivity(_currentActivityId!);
      debugPrint('⏹️ Live Activity stopped');
      _currentActivityId = null;
    } catch (e) {
      debugPrint('❌ Live Activity durdurma hatası: $e');
    }
  }

  /// Pause durumunu güncelle
  static Future<void> setPaused(bool isPaused) async {
    if (_currentActivityId == null) return;

    try {
      await _liveActivitiesPlugin.updateActivity(
        _currentActivityId!,
        {'isPaused': isPaused},
      );
      debugPrint('⏸️ Live Activity pause state: $isPaused');
    } catch (e) {
      debugPrint('❌ Live Activity pause güncelleme hatası: $e');
    }
  }

  /// Break moduna geç
  static Future<void> switchToBreak({
    required int breakSeconds,
    required int totalBreakSeconds,
  }) async {
    if (_currentActivityId == null) return;

    try {
      final contentState = {
        'remainingSeconds': breakSeconds,
        'totalSeconds': totalBreakSeconds,
        'isOnBreak': true,
        'isPaused': false,
      };

      await _liveActivitiesPlugin.updateActivity(
        _currentActivityId!,
        contentState,
      );
      debugPrint('🌿 Live Activity switched to break mode');
    } catch (e) {
      debugPrint('❌ Live Activity break modu hatası: $e');
    }
  }

  /// Live Activity aktif mi?
  static bool get isActive => _currentActivityId != null;

  /// Tüm aktif activity'leri al
  static Future<List<String>> getAllActivities() async {
    try {
      final activities = await _liveActivitiesPlugin.getAllActivitiesIds();
      return activities;
    } catch (e) {
      debugPrint('❌ Live Activity listesi alma hatası: $e');
      return [];
    }
  }

  /// Tüm activity'leri temizle
  static Future<void> endAllActivities() async {
    try {
      await _liveActivitiesPlugin.endAllActivities();
      _currentActivityId = null;
      debugPrint('🧹 Tüm Live Activity\'ler temizlendi');
    } catch (e) {
      debugPrint('❌ Live Activity temizleme hatası: $e');
    }
  }

  /// Live Activity'nin desteklenip desteklenmediğini kontrol et
  static Future<bool> areActivitiesEnabled() async {
    try {
      final enabled = await _liveActivitiesPlugin.areActivitiesEnabled();
      return enabled;
    } catch (e) {
      debugPrint('❌ Live Activity destek kontrolü hatası: $e');
      return false;
    }
  }
}

