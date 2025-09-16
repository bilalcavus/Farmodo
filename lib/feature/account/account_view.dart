import 'package:farmodo/core/di/injection.dart';
import 'package:farmodo/core/theme/app_colors.dart';
import 'package:farmodo/core/utility/extension/dynamic_size_extension.dart';
import 'package:farmodo/core/utility/extension/ontap_extension.dart';
import 'package:farmodo/core/utility/extension/route_helper.dart';
import 'package:farmodo/core/utility/extension/sized_box_extension.dart';
import 'package:farmodo/data/services/auth_service.dart';
import 'package:farmodo/feature/auth/login/view/login_view.dart';
import 'package:farmodo/feature/auth/login/viewmodel/login_controller.dart';
import 'package:farmodo/feature/gamification/view/debug_gamification_view.dart';
import 'package:farmodo/feature/home/widgets/home_header.dart';
import 'package:farmodo/feature/navigation/navigation_controller.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hugeicons/hugeicons.dart';

class AccountView extends StatefulWidget {
  const AccountView({super.key});

  @override
  State<AccountView> createState() => _AccountViewState();
}

class _AccountViewState extends State<AccountView> {
  final AuthService _authService = AuthService();
  User? user;
  bool isDarkMode = false;
  final loginController = getIt<LoginController>();
  final navigationController = getIt<NavigationController>();

  @override
  void initState() {
    super.initState();
    _authService.loadCurrentUser();
  }

 

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: Text(
          'Profile',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: context.dynamicHeight(0.022),
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(context.dynamicHeight(0.02)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildUserProfileCard(),
            context.dynamicHeight(0.04).height,
            if (!_authService.isLoggedIn) ...[
              _buildLoginPrompt(),
              context.dynamicHeight(0.04).height,
            ],
            _authService.isLoggedIn ? _buildTermsConditionSection() : SizedBox.shrink(),
            context.dynamicHeight(0.03).height,
            _buildAccountsSubscriptionSection(_authService),
          ],
        ),
      ),
    );
  }

  Widget _buildUserProfileCard() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: context.dynamicWidth(0.015)),
          child: Text(
            _authService.firebaseUser?.displayName ?? 'Guest User',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: context.dynamicHeight(0.022),
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        context.dynamicHeight(0.005).height,
        Padding(
          padding: EdgeInsets.symmetric(horizontal: context.dynamicWidth(0.015)),
          child: Text(
            '@${_authService.currentUser?.email != null ? _authService.currentUser!.email.split('@')[0] : 'guest'}',
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: context.dynamicHeight(0.017),
            ),
          ),
        ),
        context.dynamicHeight(0.015).height,
        LevelBar(authService: _authService)
      ],
    );
  }

  Widget _buildTermsConditionSection() {
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
              icon: HugeIcons.strokeRoundedMoneyReceive01,
              title: 'Profile Details',
              onTap: () {},
            ),
            _buildSettingsItem(
              icon: HugeIcons.strokeRoundedZoomInArea,
              title: 'Farmodo Area',
              onTap: () {},
            ),
            
            _buildSettingsItem(
              icon: HugeIcons.strokeRoundedCustomerSupport,
              title: 'Support',
              onTap: () {},
              isLast: true,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildAccountsSubscriptionSection(AuthService authService) {
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
              icon: Icons.sunny ,
              title: 'Dark Mode',
              trailing: Switch(
                value: isDarkMode,
                onChanged: (value) {
                  
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

  Widget _buildDivider() {
    return Container(
      height: 1,
      margin: EdgeInsets.symmetric(horizontal: context.dynamicWidth(0.04)),
      color: Colors.grey.withAlpha(25),
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