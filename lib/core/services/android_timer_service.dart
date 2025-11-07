import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class AndroidTimerService {
  static const MethodChannel _channel = MethodChannel('com.bilalcavus.farmodo/timer');
  
  /// Timer service'i başlat
  static Future<bool> startTimerService({
    required int secondsRemaining,
    required int totalSeconds,
    required bool isOnBreak,
    required String taskTitle,
  }) async {
    if (!Platform.isAndroid) return false;
    
    try {
      final result = await _channel.invokeMethod('startTimerService', {
        'secondsRemaining': secondsRemaining,
        'totalSeconds': totalSeconds,
        'isOnBreak': isOnBreak,
        'taskTitle': taskTitle,
      });
      debugPrint('✅ Android timer service started: $result');
      return result == true;
    } catch (e) {
      debugPrint('❌ Android timer service start error: $e');
      return false;
    }
  }
  
  /// Timer service'i duraklat
  static Future<bool> pauseTimerService() async {
    if (!Platform.isAndroid) return false;
    
    try {
      final result = await _channel.invokeMethod('pauseTimerService');
      debugPrint('⏸️ Android timer service paused: $result');
      return result == true;
    } catch (e) {
      debugPrint('❌ Android timer service pause error: $e');
      return false;
    }
  }
  
  /// Timer service'i devam ettir
  static Future<bool> resumeTimerService() async {
    if (!Platform.isAndroid) return false;
    
    try {
      final result = await _channel.invokeMethod('resumeTimerService');
      debugPrint('▶️ Android timer service resumed: $result');
      return result == true;
    } catch (e) {
      debugPrint('❌ Android timer service resume error: $e');
      return false;
    }
  }
  
  /// Timer service'i durdur
  static Future<bool> stopTimerService() async {
    if (!Platform.isAndroid) return false;
    
    try {
      final result = await _channel.invokeMethod('stopTimerService');
      debugPrint('⏹️ Android timer service stopped: $result');
      return result == true;
    } catch (e) {
      debugPrint('❌ Android timer service stop error: $e');
      return false;
    }
  }

  static Future<void> acquireWakeLock() async {
    if (!Platform.isAndroid) return;
    
    try {
      final result = await _channel.invokeMethod<bool>('acquireWakeLock');
      debugPrint('🔒 Wake lock acquired: $result');
    } catch (e) {
      debugPrint('❌ Wake lock acquire error: $e');
    }
  }

  static Future<void> releaseWakeLock() async {
    if (!Platform.isAndroid) return;
    
    try {
      await _channel.invokeMethod('releaseWakeLock');
      debugPrint('🔓 Wake lock released');
    } catch (e) {
      debugPrint('❌ Wake lock release error: $e');
    }
  }
}
