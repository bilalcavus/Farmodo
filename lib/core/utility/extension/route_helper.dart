import 'package:flutter/material.dart';

class RouteHelper {
  static Future<T?> pushReplacement<T, TO>(BuildContext context, Widget view) async {
    return Navigator.pushReplacement<T, TO>(
      context,
      MaterialPageRoute(builder: (BuildContext context) => view),
    );
  }

  static Future<T?> push<T>(BuildContext context, Widget view) async {
    return Navigator.push<T>(
      context,
      MaterialPageRoute(builder: (BuildContext context) => view),
    );
  }

  static void pop<T>(BuildContext context, [T? result]) {
    Navigator.pop(context, result);
  }

  static Future<T?> pushAndCloseOther<T>(BuildContext context, Widget view) async {
    return Navigator.pushAndRemoveUntil<T>(
      context,
      MaterialPageRoute(builder: (BuildContext context) => view),
      (route) => false,
    );
  }

  static void popUntil(BuildContext context, String view) {
    Navigator.popUntil(
      context,
      ModalRoute.withName(view),
    );
  }
}