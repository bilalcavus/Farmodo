import 'package:permission_handler/permission_handler.dart';

class PermissionService {
  static Future<bool> requestNotificationPermission() async {
    final status = await Permission.notification.status;
    if (status.isGranted) return true;
    if (status.isPermanentlyDenied) {
      final opened = await openAppSettings();
      return opened && (await Permission.notification.status).isGranted;
    }
    final result = await Permission.notification.request();
    return result.isGranted;
}
  
  static Future<bool> checkNotificationPermission() async {
    final status = await Permission.notification.status;
    return status.isGranted;
  }
}
