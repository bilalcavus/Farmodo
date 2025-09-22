import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

class PermissionService {
  static Future<bool> requestNotificationPermission() async {
    final status = await Permission.notification.status;
    if (status.isGranted) return true;
    if (status.isPermanentlyDenied) {
      debugPrint('🔔 Permission permanently denied. Opening settings...');
      final opened = await openAppSettings();
      return opened && (await Permission.notification.status).isGranted;
    }
    final result = await Permission.notification.request();
    debugPrint('🔔 Notification permission result: $result');
    return result.isGranted;
}
  
  static Future<bool> checkNotificationPermission() async {
    final status = await Permission.notification.status;
    debugPrint('🔔 Current notification permission: $status');
    return status.isGranted;
  }
}
