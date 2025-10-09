import 'package:farmodo/core/di/injection.dart';
import 'package:farmodo/core/init/app_initializer.dart';
import 'package:farmodo/core/theme/app_theme.dart';
import 'package:farmodo/core/theme/theme_controller.dart';
import 'package:farmodo/feature/start/splash/splash_view.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';


void main() async { 
  await AppInitializer().make();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeController = getIt<ThemeController>();
    return GetBuilder<ThemeController>(
      init: themeController,
      builder: (controller) =>  GetMaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Farmodo',
        theme: AppTheme.light,
        darkTheme: AppTheme.dark,
        themeMode: controller.isDarkMode ? ThemeMode.dark : ThemeMode.light,
        home: SplashView(),
      ),
    );
  }
}
