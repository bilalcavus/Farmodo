import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

class PermissionService {
  static Future<bool> requestNotificationPermission() async {
    // Android 13+ için notification permission
    if (await Permission.notification.isDenied) {
      final status = await Permission.notification.request();
      debugPrint('🔔 Notification permission status: $status');
      return status.isGranted;
    }
    
    final status = await Permission.notification.status;
    debugPrint('🔔 Notification permission status: $status');
    return status.isGranted;
  }
  
  static Future<bool> checkNotificationPermission() async {
    final status = await Permission.notification.status;
    debugPrint('🔔 Current notification permission: $status');
    return status.isGranted;
  }
}
