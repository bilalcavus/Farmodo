import 'package:farmodo/core/di/injection.dart';
import 'package:farmodo/core/theme/app_colors.dart';
import 'package:farmodo/core/utility/extension/dynamic_size_extension.dart';
import 'package:farmodo/core/utility/extension/sized_box_extension.dart';
import 'package:farmodo/data/services/auth_service.dart';
import 'package:farmodo/data/services/firestore_service.dart';
import 'package:farmodo/feature/account/widget/account_section.dart';
import 'package:farmodo/feature/account/widget/header_section.dart';
import 'package:farmodo/feature/account/widget/login_prompt.dart';
import 'package:farmodo/feature/account/widget/preferences_section.dart';
import 'package:farmodo/feature/auth/login/viewmodel/login_controller.dart';
import 'package:farmodo/feature/navigation/navigation_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class AccountView extends StatefulWidget {
  const AccountView({super.key});

  @override
  State<AccountView> createState() => _AccountViewState();
}

class _AccountViewState extends State<AccountView> {
  final AuthService _authService = AuthService();
  final FirestoreService _firestoreService = FirestoreService();
  bool isDarkMode = false;
  bool isLoadingStats = true;
  int tasksCompleted = 0;
  int totalXp = 0;
  int daysActive = 0;
  String joinedYearText = '';
  String handleText = '@guest';

  final loginController = getIt<LoginController>();
  final navigationController = getIt<NavigationController>();

  @override
  void initState() {
    super.initState();
    _authService.loadCurrentUser().then((_) => _loadProfileStats());
  }

  Future<void> _loadProfileStats() async {
    if (!_authService.isLoggedIn) {
        totalXp = 0;
        tasksCompleted = 0;
        daysActive = 0;
        joinedYearText = '';
        handleText = '@guest';
        isLoadingStats = false;
      return;
    }

    await _authService.fetchAndSetCurrentUser();
    final user = _authService.currentUser;

    int computedTasks = 0;
    bool first = true;
    while (true) {
      final items = await _firestoreService.getCompletedTask(loadMore: !first);
      computedTasks += items.length;
      first = false;
      if (items.length < 10) break;
    }

    final createdAt = user?.createdAt;
    final joinedYear = createdAt != null ? createdAt.year.toString() : '';
    final computedDays = createdAt != null
        ? DateTime.now().difference(createdAt).inDays.clamp(0, 100000)
        : 0;

    setState(() {
      totalXp = user?.xp ?? 0;
      tasksCompleted = computedTasks;
      daysActive = computedDays;
      joinedYearText = joinedYear;
      handleText = '@${_authService.firebaseUser?.email?.split('@').first ?? 'guest'}';
      isLoadingStats = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        systemOverlayStyle: SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.dark,
        ),
        backgroundColor: Colors.transparent,
        title: Text('Profile', style: TextStyle(color: AppColors.textPrimary, fontSize: context.dynamicHeight(0.022), fontWeight: FontWeight.w600)),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(context.dynamicHeight(0.02)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            HeaderSection(
              context: context,
              handleText: handleText,
              joinedYearText: joinedYearText,
              isLoadingStats: isLoadingStats,
              authService: _authService,
              tasksCompleted: tasksCompleted,
              totalXp: totalXp,
              daysActive: daysActive,
            ),
            context.dynamicHeight(0.04).height,
            if (!_authService.isLoggedIn) ...[
              LoginPrompt(context: context),
              context.dynamicHeight(0.04).height,
            ],
            if (_authService.isLoggedIn)
            AccountSection(context: context),
            context.dynamicHeight(0.03).height,
            PreferencesSection(context: context, authService: _authService, loginController: loginController)
          ],
        ),
      ),
    );
  }
}