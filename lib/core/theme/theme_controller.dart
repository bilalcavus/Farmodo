import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app_theme.dart';

class ThemeController extends GetxController {
  ThemeData _themeData = AppTheme.light;
  final RxBool _isDarkMode = false.obs;
  static const String themeKey = 'isDarkMode';

  ThemeData get themeData => _themeData;
  bool get isDarkMode => _isDarkMode.value;

  @override
  void onInit() {
    super.onInit();
    _loadThemeFromPrefs();
  }

  Future<void> _loadThemeFromPrefs() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    _isDarkMode.value = prefs.getBool(themeKey) ?? false;
    _themeData = _isDarkMode.value ? AppTheme.dark : AppTheme.light;
    update();
  }

  Future<void> toggleTheme() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    _isDarkMode.value = !_isDarkMode.value;
    _themeData = _isDarkMode.value ? AppTheme.dark : AppTheme.light;
    await prefs.setBool(themeKey, _isDarkMode.value);
    update();
  }
}