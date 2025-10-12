import 'package:easy_localization/easy_localization.dart';
import 'package:farmodo/core/di/injection.dart';
import 'package:farmodo/core/init/app_initializer.dart';
import 'package:farmodo/core/init/product_localization.dart';
import 'package:farmodo/core/theme/app_theme.dart';
import 'package:farmodo/core/theme/theme_controller.dart';
import 'package:farmodo/feature/start/splash/splash_view.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart' hide Trans;


void main() async { 
  final appInit = AppInitializer();
  await appInit.make();
  runApp(
    ProductLocalization(
      startLocale: await appInit.initializeLangPref(),
      child: const MyApp()
  ));
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  Key _key = UniqueKey();

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final currentLocale = context.locale;
    setState(() {
      _key = ValueKey(currentLocale.languageCode);
    });
  }

  @override
  Widget build(BuildContext context) {
    final themeController = getIt<ThemeController>();
    return GetBuilder<ThemeController>(
      init: themeController,
      builder: (controller) =>  GetMaterialApp(
        key: _key,
        debugShowCheckedModeBanner: false,
        title: 'Farmodo',
        locale: context.locale,
        supportedLocales: context.supportedLocales,
        localizationsDelegates: context.localizationDelegates,
        theme: AppTheme.light,
        darkTheme: AppTheme.dark,
        themeMode: controller.isDarkMode ? ThemeMode.dark : ThemeMode.light,
        home: SplashView(),
      ),
    );
  }
}
