import 'dart:async';

import 'package:farmodo/core/di/injection.dart';
import 'package:farmodo/data/services/sample_data_service.dart';
import 'package:farmodo/firebase_options.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:logger/logger.dart';

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
      systemNavigationBarColor: Colors.transparent,
      statusBarBrightness: Brightness.dark,
  ));
    await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
    await setupDependencies();

    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      await SampleDataService().checkExistingData(user.uid);
    }
  }
}