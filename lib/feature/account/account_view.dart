import 'package:easy_localization/easy_localization.dart';
import 'package:farmodo/core/di/injection.dart';
import 'package:farmodo/core/utility/extension/dynamic_size_extension.dart';
import 'package:farmodo/core/utility/extension/ontap_extension.dart';
import 'package:farmodo/core/utility/extension/sized_box_extension.dart';
import 'package:farmodo/data/services/auth_service.dart';
import 'package:farmodo/data/services/firestore_service.dart';
import 'package:farmodo/feature/account/widget/account_section.dart';
import 'package:farmodo/feature/account/widget/level_bar.dart';
import 'package:farmodo/feature/account/widget/login_prompt.dart';
import 'package:farmodo/feature/account/widget/preferences_section.dart';
import 'package:farmodo/feature/auth/login/viewmodel/login_controller.dart';
import 'package:farmodo/feature/home/widgets/leader_board_button.dart';
import 'package:farmodo/feature/home/widgets/user_xp.dart';
import 'package:farmodo/feature/leader_board/view/leader_board_view.dart';
import 'package:farmodo/feature/navigation/navigation_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart' hide Trans;
import 'package:get/get_core/src/get_main.dart';

class AccountView extends StatefulWidget {
  const AccountView({super.key});

  @override
  State<AccountView> createState() => _AccountViewState();
}

class _AccountViewState extends State<AccountView> {
  final AuthService _authService = AuthService();
  final FirestoreService _firestoreService = FirestoreService();
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
      appBar: AppBar(
      elevation: 0,
      systemOverlayStyle: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
      ),
      toolbarHeight: context.dynamicHeight(0.08),
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'account.profile'.tr(),
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.w700,
              letterSpacing: -0.5,
            ),
          ),
          Text(
            _authService.isLoggedIn 
              ? 'account.your_account'.tr()
              : 'account.personalize_experience'.tr(),
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              fontWeight: FontWeight.w400,
            ),
          ),
        ],
      ),
      centerTitle: false,
    ),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(
          horizontal: context.dynamicWidth(0.04),
          vertical: context.dynamicHeight(0.02),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (!_authService.isLoggedIn) ...[
              LoginPrompt(
                context: context, 
                title: 'account.login_to_unlock'.tr(), 
                subtitle: 'account.sync_data'.tr()
              ),
              context.dynamicHeight(0.03).height,
            ],
            if (_authService.isLoggedIn) ...[
              LevelBar(authService: _authService),
              UserXp(authService: _authService),
              context.dynamicWidth(0.02).width,
          LeaderBoardButton().onTap(() => Get.to(() => const LeaderBoardView())),
              context.dynamicHeight(0.015).height,
              AccountSection(context: context),
              context.dynamicHeight(0.03).height,
            ],
            PreferencesSection(
              context: context, 
              authService: _authService, 
              loginController: loginController
            ),
          ],
        ),
      ),
    );
  }
}