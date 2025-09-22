import 'package:farmodo/core/di/injection.dart';
import 'package:farmodo/core/theme/app_colors.dart';
import 'package:farmodo/core/utility/extension/dynamic_size_extension.dart';
import 'package:farmodo/core/utility/extension/ontap_extension.dart';
import 'package:farmodo/core/utility/extension/route_helper.dart';
import 'package:farmodo/core/utility/extension/sized_box_extension.dart';
import 'package:farmodo/data/services/auth_service.dart';
import 'package:farmodo/data/services/firestore_service.dart';
import 'package:farmodo/feature/auth/login/view/login_view.dart';
import 'package:farmodo/feature/auth/login/viewmodel/login_controller.dart';
import 'package:farmodo/feature/gamification/view/debug_gamification_view.dart';
import 'package:farmodo/feature/navigation/navigation_controller.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:kartal/kartal.dart';

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
      setState(() {
        totalXp = 0;
        tasksCompleted = 0;
        daysActive = 0;
        joinedYearText = '';
        handleText = '@guest';
        isLoadingStats = false;
      });
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
            _buildHeaderSection(),
            context.dynamicHeight(0.04).height,
            if (!_authService.isLoggedIn) ...[
              _buildLoginPrompt(),
              context.dynamicHeight(0.04).height,
            ],
            if (_authService.isLoggedIn) _buildAccountSection(),
            context.dynamicHeight(0.03).height,
            _buildPreferencesSection(_authService),
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderSection() {
    final user = _authService.firebaseUser;
    final displayName = _authService.currentUser?.displayName.isNotEmpty == true
        ? _authService.currentUser!.displayName
        : (_authService.firebaseUser?.displayName ?? 'Guest User');
    return Container(
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: context.border.highBorderRadius,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(25),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          context.dynamicHeight(0.01).height,
          Center(
            child: UserAvatar(user: user, fontSize: 16, radius: context.dynamicHeight(0.05))
          ),
          context.dynamicHeight(0.02).height,
          Text(
            displayName,
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: context.dynamicHeight(0.028),
              fontWeight: FontWeight.w700,
            ),
            textAlign: TextAlign.center,
          ),
          context.dynamicHeight(0.006).height,
          Text(
            handleText,
            style: TextStyle(color: AppColors.textPrimary, fontSize: context.dynamicHeight(0.017), fontWeight: FontWeight.w500),
          ),
          context.dynamicHeight(0.006).height,
          if (joinedYearText.isNotEmpty)
            Text(
              'Joined $joinedYearText',
              style: TextStyle(color: AppColors.textPrimary, fontSize: context.dynamicHeight(0.017)),
            ),
          context.dynamicHeight(0.02).height,
          if (isLoadingStats)
            Center(child: CircularProgressIndicator(color: AppColors.primary))
          else ...[
            _buildStatsRow(),
            context.dynamicHeight(0.015).height,
            _buildDaysActiveCard()
          ],
          context.dynamicHeight(0.02).height,
        ],
      ),
    );
  }

  Widget _buildStatsRow() {
    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            title: 'Tasks Completed',
            value: tasksCompleted.toString(),
          ),
        ),
        context.dynamicWidth(0.03).width,
        Expanded(
          child: _buildStatCard(
            title: 'Total XP',
            value: totalXp.toString(),
          ),
        ),
      ],
    );
  }

  Widget _buildDaysActiveCard() {
    return _buildStatCard(title: 'Days Active', value: daysActive.toString(), isWide: true);
  }

  Widget _buildStatCard({required String title, required String value, bool isWide = false}) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          value,
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: context.dynamicHeight(0.025),
            fontWeight: FontWeight.w700,
          ),
        ),
        context.dynamicHeight(0.006).height,
        Text(
          title,
          style: TextStyle(color: Colors.grey.shade600, fontSize: context.dynamicHeight(0.016)),
        ),
      ],
    );
  }

  Widget _buildAccountSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Account',
          style: TextStyle(
           color: AppColors.textPrimary,
            fontSize: context.dynamicHeight(0.015),
            fontWeight: FontWeight.w300,
          ),
        ),
        context.dynamicHeight(0.02).height,
        Column(
          children: [
            _buildSettingsItem(
              icon: HugeIcons.strokeRoundedUser,
              title: 'Edit Profile',
              onTap: () {},
            ),
            _buildSettingsItem(
              icon: HugeIcons.strokeRoundedNotification02,
              title: 'Notifications',
              onTap: () {},
            ),
            
            _buildSettingsItem(
              icon: HugeIcons.strokeRoundedCustomerSupport,
              title: 'Help & Support',
              onTap: () {},
              isLast: true,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildPreferencesSection(AuthService authService) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Preferences & Logout',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: context.dynamicHeight(0.015),
            fontWeight: FontWeight.w300,
          ),
        ),
        context.dynamicHeight(0.02).height,
        Column(
          children: [
           
            _buildSettingsItem(
              icon: HugeIcons.strokeRoundedLanguageSkill,
              title: 'Language',
              onTap: () {},
            ),
             _buildSettingsItem(
              icon: HugeIcons.strokeRoundedNotification02,
              title: 'Notification',
              trailing: Switch(
                value: isDarkMode,
                onChanged: (value) {
                  
                },
                activeThumbColor: AppColors.textPrimary,
                inactiveThumbColor: Colors.grey[400],
                inactiveTrackColor: Colors.grey[300],
              ),
            ),
            _buildSettingsItem(
              icon: Icons.dark_mode,
              title: 'Dark Mode',
              trailing: Switch(
                value: isDarkMode,
                onChanged: (value) {
                  setState(() { isDarkMode = value; });
                },
                activeThumbColor: AppColors.textPrimary,
                inactiveThumbColor: Colors.grey[400],
                inactiveTrackColor: Colors.grey[300],
              ),
            ),
            kDebugMode ? 
            _buildSettingsItem(
              icon: Icons.bug_report,
              title: 'Debug Gamification',
              onTap: () => Get.to(() => const DebugGamificationView()),
            ) : const SizedBox.shrink(),
            authService.isLoggedIn ? _buildSettingsItem(
              icon: HugeIcons.strokeRoundedLogout04,
              title: 'Logout',
              onTap: () async {
                await loginController.handleLogout();
                if (context.mounted && !_authService.isLoggedIn) {
                  RouteHelper.pushAndCloseOther(context, const LoginView());
                }
              },
              isLast: true,
            ) : SizedBox.shrink(),
          ],
        ),
      ],
    );
  }




  Widget _buildSettingsItem({
    required IconData icon,
    required String title,
    VoidCallback? onTap,
    Widget? trailing,
    bool isLast = false,
  }) {
    return Material(
      color: Colors.transparent,
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: context.dynamicWidth(0.05),
          vertical: context.dynamicHeight(0.02)
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: title == 'Logout' ? AppColors.danger : AppColors.textPrimary,
              size: context.dynamicHeight(0.028 ),
            ),
            context.dynamicWidth(0.04).width,
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: context.dynamicHeight(0.016),
                  fontWeight: FontWeight.w400,
                ),
              ),
            ),
            trailing ?? Icon(
              Icons.chevron_right,
              color: AppColors.textPrimary,
              size: context.dynamicHeight(0.02),
            ),
          ],
        ),
      ).onTap(onTap),
    );
  }

  Widget _buildLoginPrompt() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(context.dynamicHeight(0.02)),
      decoration: BoxDecoration(
        color: AppColors.primary.withAlpha(25),
        borderRadius: BorderRadius.circular(context.dynamicHeight(0.02)),
        border: Border.all(color: AppColors.primary.withAlpha(50)),
      ),
      child: Column(
        children: [
          Icon(
            HugeIcons.strokeRoundedLogin01,
            color: AppColors.primary,
            size: context.dynamicHeight(0.04),
          ),
          context.dynamicHeight(0.01).height,
          Text(
            'Log in to access all features',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: context.dynamicHeight(0.018),
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.center,
          ),
          context.dynamicHeight(0.01).height,
          Text(
            'Sync your data and buy your animals',
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: context.dynamicHeight(0.015),
            ),
            textAlign: TextAlign.center,
          ),
          context.dynamicHeight(0.02).height,
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                RouteHelper.push(context, const LoginView());
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                padding: EdgeInsets.symmetric(vertical: context.dynamicHeight(0.015)),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(context.dynamicHeight(0.015)),
                ),
              ),
              child: Text(
                'Log in',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: context.dynamicHeight(0.018),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }


}

class UserAvatar extends StatelessWidget {
  const UserAvatar({
    super.key,
    required this.user,
    required this.fontSize,
    required this.radius
  });

  final User? user;
  final double fontSize;
  final double radius;

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      radius: radius,
      backgroundColor: Colors.white,
      backgroundImage: user?.photoURL != null 
          ? NetworkImage(user!.photoURL!) 
          : null,
      child: user?.photoURL == null 
          ? Text(
              user?.displayName?.isNotEmpty == true 
                  ? user!.displayName![0].toUpperCase()
                  : '👤',
              style: TextStyle(
                fontSize: fontSize,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF8B5CF6),
              ),
            )
          : null,
    );
  }
} 