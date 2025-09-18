import 'package:farmodo/core/init/app_initializer.dart';
import 'package:farmodo/core/theme/app_theme.dart';
import 'package:farmodo/feature/start/splash/splash_view.dart';
import 'package:flutter/material.dart';
import 'package:get/route_manager.dart';

void main() async { 
  await AppInitializer().make();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Farmodo',
      theme: AppTheme.light,
      themeMode: ThemeMode.light,
      home: SplashView(),
    );
  }
}
