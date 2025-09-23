import 'package:farmodo/core/di/injection.dart';
import 'package:farmodo/core/services/permission_service.dart';
import 'package:farmodo/core/services/preferences_service.dart';
import 'package:farmodo/core/utility/extension/route_helper.dart';
import 'package:farmodo/data/services/auth_service.dart';
import 'package:farmodo/feature/navigation/app_navigation.dart';
import 'package:farmodo/feature/start/onboard/onboard_screen.dart';
import 'package:farmodo/feature/tasks/viewmodel/tasks_controller.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class SplashView extends StatefulWidget {
  const SplashView({super.key});

  @override
  State<SplashView> createState() => _SplashViewState();
}

class _SplashViewState extends State<SplashView> {
   final AuthService _authService = getIt<AuthService>();
   final TasksController taskController = getIt<TasksController>();
   final PreferencesService _prefsService = getIt<PreferencesService>();
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_){
      _initializeUser();
    });
    _initializeAndNavigate();
  }

  Future<void> _initializeUser() async {
    final userId = _authService.firebaseUser?.uid;
    if (userId != null) {
      taskController.getActiveTask();
      taskController.getCompletedTask();
    }
  }

  void _initializeAndNavigate() async {
    try {
      await _authService.initializeAuthState();
      
      // Notification permission kontrolü ve isteği
      await _requestNotificationPermission();
      
      await Future.delayed(const Duration(seconds: 2));
      
      if (_authService.isLoggedIn) {
        await _initializeUser();
      }
      
      if (mounted) {
        if (_prefsService.isOnboardingCompleted) {
          RouteHelper.pushAndCloseOther(context, AppNavigation());
        } else {
          RouteHelper.pushAndCloseOther(context, OnboardScreen());
        }
      }
    } catch (e) {
      debugPrint('Splash initialization error: $e');
      if (mounted) {
        if (_prefsService.isOnboardingCompleted) {
          RouteHelper.pushAndCloseOther(context, AppNavigation());
        } else {
          RouteHelper.pushAndCloseOther(context, OnboardScreen());
        }
      }
    }
  }

  Future<void> _requestNotificationPermission() async {
    try {
      // Notification permission kontrolü
      final hasPermission = await PermissionService.checkNotificationPermission();
      if (!hasPermission) {
        // Permission yoksa iste, ama uygulama açılmaya devam etsin
        await PermissionService.requestNotificationPermission();
      }
    } catch (e) {
      debugPrint('Notification permission error: $e');
      // Permission hatası olsa bile uygulama açılsın
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Lottie.asset('assets/lottie/blue_loading.json', height: 150)
      ),
    );
  }
}