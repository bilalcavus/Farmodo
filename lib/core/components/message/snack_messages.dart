import 'package:farmodo/core/utility/extension/dynamic_size_extension.dart';
import 'package:flutter/material.dart';
import 'package:get/route_manager.dart';

class SnackMessages {
  final BuildContext context;
  SnackMessages(this.context);

  void showErrorSnack(String message) {
    Get.closeAllSnackbars();
    Get.snackbar(
      'Hata',
      message,
      snackPosition: SnackPosition.TOP,
      backgroundColor: Colors.red.withOpacity(0.1),
      colorText: Colors.red,
      margin: EdgeInsets.all(context.dynamicHeight(0.012)),
      borderRadius: context.dynamicHeight(0.02),
      duration: const Duration(seconds: 3),
    );
  }

  void showSuccessSnack(String message) {
    Get.closeAllSnackbars();
    Get.snackbar(
      'Başarılı',
      message,
      snackPosition: SnackPosition.TOP,
      backgroundColor: Colors.green.withOpacity(0.1),
      colorText: Colors.green,
      margin: EdgeInsets.all(context.dynamicHeight(0.012)),
      borderRadius: context.dynamicHeight(0.02),
      duration: const Duration(seconds: 3),
    );
  }
}