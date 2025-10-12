import 'package:easy_localization/easy_localization.dart';
import 'package:farmodo/core/di/injection.dart';
import 'package:farmodo/core/services/preferences_service.dart';
import 'package:farmodo/core/utility/extension/dynamic_size_extension.dart';
import 'package:farmodo/core/utility/extension/route_helper.dart';
import 'package:farmodo/core/utility/extension/sized_box_extension.dart';
import 'package:farmodo/data/services/auth_service.dart';
import 'package:farmodo/feature/navigation/app_navigation.dart';
import 'package:farmodo/feature/start/onboard/widget/onboard_button.dart';
import 'package:farmodo/feature/start/onboard/widget/onboard_content.dart';
import 'package:farmodo/feature/start/onboard/widget/onboard_image.dart';
import 'package:farmodo/feature/start/onboard/widget/onboard_page_indicator.dart';
import 'package:farmodo/feature/tasks/viewmodel/tasks_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class OnboardData {
  final String title;
  final String description;
  final String imagePath;

  OnboardData({
    required this.title,
    required this.description,
    required this.imagePath,
  });
}

class OnboardScreen extends StatefulWidget {
  const OnboardScreen({super.key});

  @override
  State<OnboardScreen> createState() => _OnboardScreenState();
}

class _OnboardScreenState extends State<OnboardScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  final AuthService _authService = getIt<AuthService>();
  final TasksController _taskController = getIt<TasksController>();
  final PreferencesService _prefsService = getIt<PreferencesService>();
  bool _isInitializing = false;

  late final List<OnboardData> _onboardData;

  @override
  void initState() {
    super.initState();
    _onboardData = [
      OnboardData(
        title: "onboard.stay_focus_title".tr(),
        description: "onboard.stay_focus_desc".tr(),
        imagePath: "assets/images/onboard/onboard_time_bg.png",
      ),
      OnboardData(
        title: "onboard.grow_farm_title".tr(),
        description: "onboard.grow_farm_desc".tr(),
        imagePath: "assets/images/onboard/onboard_farm_bg.jpeg",
      ),
      OnboardData(
        title: "onboard.level_up_title".tr(),
        description: "onboard.level_up_desc".tr(),
        imagePath: "assets/images/onboard/level_up.png",
      ),
    ];
  }

  Future<void> _initializeUser() async {
    final userId = _authService.firebaseUser?.uid;
    if (userId != null) {
      _taskController.getActiveTask();
      _taskController.getCompletedTask();
    }
  }

  Future<void> _initializeAndNavigate() async {
    setState(() {
      _isInitializing = true;
    });

    try {
      await _prefsService.setOnboardingCompleted(true);
      await _prefsService.setFirstLaunch(false);
      
      await _authService.initializeAuthState();
      
      if (_authService.isLoggedIn) {
        await _initializeUser();
      }
      
      if (mounted) {
        RouteHelper.pushAndCloseOther(context, AppNavigation(initialIndex: 0));
      }
    } catch (e) {
      if (mounted) {
        RouteHelper.pushAndCloseOther(context, AppNavigation(initialIndex: 0));
      }
    } finally {
      if (mounted) {
        setState(() {
          _isInitializing = false;
        });
      }
    }
  }

  void _nextPage() {
    if (_currentPage < _onboardData.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      _initializeAndNavigate();
    }
  }

  void _skipToEnd() {
    _initializeAndNavigate();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        systemOverlayStyle: const SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.dark,
      ),
        elevation: 0,
        actions: [
          if (_currentPage < _onboardData.length - 1)
            TextButton(
              onPressed: _skipToEnd,
              child: Text(
                'common.skip'.tr(),
                style: TextStyle(color: Colors.grey),
              ),
            ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: PageView.builder(
              controller: _pageController,
              onPageChanged: (index) {
                setState(() {
                  _currentPage = index;
                });
              },
              itemCount: _onboardData.length,
              itemBuilder: (context, index) {
                final data = _onboardData[index];
                return Column(
                  children: [
                    Expanded(
                      flex: 3,
                      child: OnboardImage(assetPath: data.imagePath),
                    ),
                    context.dynamicHeight(0.03).height,
                    Expanded(
                      flex: 1,
                      child: OnboardContent(
                        title: data.title,
                        description: data.description,
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
          context.dynamicHeight(0.03).height,
          OnboardPageIndicator(
            currentPage: _currentPage,
            totalPages: _onboardData.length,
          ),
          context.dynamicHeight(0.02).height,
        ],
      ),
      bottomNavigationBar: OnboardButton(
        buttonText: _currentPage == _onboardData.length - 1 
            ? (_isInitializing ? 'onboard.initializing'.tr() : 'onboard.get_started'.tr()) 
            : 'common.next'.tr(),
        onPressed: _isInitializing ? null : _nextPage,
      ),
    );
  }
}




