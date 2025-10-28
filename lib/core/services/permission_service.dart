import 'package:permission_handler/permission_handler.dart';

class PermissionService {
  static Future<bool> requestNotificationPermission() async {
    try {
      final status = await Permission.notification.status;
      if (status.isGranted) return true;
      
      if (status.isPermanentlyDenied) {
        final opened = await openAppSettings();
        return opened && (await Permission.notification.status).isGranted;
      }
      
      final result = await Permission.notification.request();
      return result.isGranted;
    } catch (e) {
      return false;
    }
  }
  
  static Future<bool> checkNotificationPermission() async {
    try {
      final status = await Permission.notification.status;
      return status.isGranted;
    } catch (e) {
      return false;
    }
  }
  
  static Future<bool> requestBatteryOptimizationPermission() async {
    try {
      final status = await Permission.ignoreBatteryOptimizations.status;
      if (status.isGranted) return true;
      
      if (status.isPermanentlyDenied) {
        final opened = await openAppSettings();
        return opened && (await Permission.ignoreBatteryOptimizations.status).isGranted;
      }
      
      final result = await Permission.ignoreBatteryOptimizations.request();
      return result.isGranted;
    } catch (e) {
      return false;
    }
  }
  
  static Future<bool> checkBatteryOptimizationPermission() async {
    try {
      final status = await Permission.ignoreBatteryOptimizations.status;
      return status.isGranted;
    } catch (e) {
      return false;
    }
  }
}

