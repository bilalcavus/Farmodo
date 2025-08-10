import 'package:farmodo/core/di/injection.dart';
import 'package:farmodo/core/theme/app_theme.dart';
import 'package:farmodo/firebase_options.dart';
import 'package:farmodo/view/navigation/app_navigation.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await setupDependencies();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Farmodo',
      theme: AppTheme.light,
      themeMode: ThemeMode.system,
      home: AppNavigation(),
    );
  }
}
