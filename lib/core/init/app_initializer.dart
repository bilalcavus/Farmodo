import 'dart:async';

import 'package:farmodo/core/di/injection.dart';
import 'package:farmodo/core/init/init_billing.dart';
import 'package:farmodo/core/services/live_activity_service.dart';
import 'package:farmodo/core/services/notification_service.dart';
import 'package:farmodo/core/utility/constants/locales.dart';
import 'package:farmodo/core/utility/constants/storage_keys.dart';
import 'package:farmodo/data/services/sample_data_service.dart';
import 'package:farmodo/firebase_options.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:logger/logger.dart';
import 'package:home_widget/home_widget.dart';
import 'package:shared_preferences/shared_preferences.dart';

final class AppInitializer {
  Future<void> make() async {
    WidgetsFlutterBinding.ensureInitialized();
    await runZonedGuarded<Future<void>>(_initialize, (error, stack){
      Logger().e(error);
    });
  }
  
    Future<void> _initialize() async {
      FlutterError.onError = (details){
      Logger().e(details.exceptionAsString());
    };
    
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      systemNavigationBarColor: Colors.white,
      systemNavigationBarIconBrightness: Brightness.dark,
      statusBarBrightness: Brightness.light,
  ));
    
    try {
      await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
      await setupDependencies();
      await InitBilling().initializeBilling();
      
      await NotificationService.initialize();
      Logger().i('Notification service initialized successfully');
      
      try {
        await LiveActivityService.init();
        Logger().i('Live Activity initialized successfully');
      } catch (e) {
        Logger().e('Live Activity initialization error: $e');
      }
      
      try {
        await HomeWidget.setAppGroupId('group.com.bilalcavus.farmodo');
        await HomeWidget.updateWidget(
          name: 'PomodoroTimerWidgetProvider',
          androidName: 'PomodoroTimerWidgetProvider',
          iOSName: 'HomeScreenWidget',
        );
        Logger().i('Widget initialized successfully');
      } catch (e) {
        Logger().e('Widget initialization error: $e');
      }

      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        await SampleDataService().checkExistingData(user.uid);
      }
    } catch (e) {
      Logger().e('App initialization error: $e');
      // Notification service initialize edilemese bile uygulama açılsın
    }
  }

  Future<Locale> initializeLangPref() async {
      try {
        // Önce kaydedilmiş dili kontrol et
        final prefs = await SharedPreferences.getInstance();
        final savedLocaleCode = prefs.getString(StorageKeys.appLocale);
        
        if (savedLocaleCode != null) {
          // Kaydedilmiş dil varsa onu kullan
          final savedLocale = Locales.supportedLocales.firstWhere(
            (locale) => locale.languageCode == savedLocaleCode,
            orElse: () => const Locale('en'),
          );
          Logger().i('Using saved locale: $savedLocaleCode');
          return savedLocale;
        }
        
        // Kaydedilmiş dil yoksa cihaz dilini kullan
        Locale deviceLocale = WidgetsBinding.instance.platformDispatcher.locale;
        Locale startLocale = Locales.supportedLocales.firstWhere(
          (locale) => locale.languageCode == deviceLocale.languageCode,
          orElse: () => const Locale('en'),
        );
        Logger().i('Using device locale: ${startLocale.languageCode}');
        return startLocale;
      } catch (e) {
        Logger().e('Error loading locale preference: $e');
        return const Locale('en');
      }
  }
}