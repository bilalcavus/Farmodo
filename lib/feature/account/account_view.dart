import 'package:farmodo/core/di/injection.dart';
import 'package:farmodo/core/utility/extension/dynamic_size_extension.dart';
import 'package:farmodo/core/utility/extension/route_helper.dart';
import 'package:farmodo/core/utility/extension/sized_box_extension.dart';
import 'package:farmodo/core/theme/app_colors.dart';
import 'package:farmodo/data/services/auth_service.dart';
import 'package:farmodo/feature/auth/login/view/login_view.dart';
import 'package:farmodo/feature/auth/login/viewmodel/login_controller.dart';
import 'package:farmodo/feature/home/widgets/home_header.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
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
            _buildTermsConditionSection(),
            context.dynamicHeight(0.03).height,
            _buildAccountsSubscriptionSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildUserProfileCard() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(context.dynamicHeight(0.02)),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(context.dynamicHeight(0.03)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: context.dynamicWidth(0.015)),
            child: Text(
              _authService.firebaseUser!.displayName ?? '',
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
              '@${_authService.currentUser?.email != null ? _authService.currentUser!.email.split('@')[0] : 'alishon35'}',
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: context.dynamicHeight(0.017),
              ),
            ),
          ),
          context.dynamicHeight(0.005).height,
          LevelBar(authService: _authService)
        ],
      ),
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
            fontSize: context.dynamicHeight(0.02),
            fontWeight: FontWeight.w600,
          ),
        ),
        context.dynamicHeight(0.02).height,
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(context.dynamicHeight(0.02)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: context.dynamicHeight(0.012),
                offset: Offset(0, context.dynamicHeight(0.002)),
              ),
            ],
          ),
          child: Column(
            children: [
              _buildSettingsItem(
                icon: HugeIcons.strokeRoundedMoneyReceive01,
                title: 'Profile Details',
                onTap: () {},
              ),
              _buildDivider(),
              _buildSettingsItem(
                icon: HugeIcons.strokeRoundedZoomInArea,
                title: 'Farmodo Area',
                onTap: () {},
              ),
              _buildDivider(),
              _buildSettingsItem(
                icon: HugeIcons.strokeRoundedLanguageSkill,
                title: 'Language',
                onTap: () {},
              ),
              _buildDivider(),
              _buildSettingsItem(
                icon: HugeIcons.strokeRoundedCustomerSupport,
                title: 'Support',
                onTap: () {},
                isLast: true,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildAccountsSubscriptionSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Preferences & Logout',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: context.dynamicHeight(0.02),
            fontWeight: FontWeight.w600,
          ),
        ),
        context.dynamicHeight(0.02).height,
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(context.dynamicHeight(0.02)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: context.dynamicHeight(0.012),
                offset: Offset(0, context.dynamicHeight(0.002)),
              ),
            ],
          ),
          child: Column(
            children: [
              _buildSettingsItem(
                icon: HugeIcons.strokeRoundedNotification02,
                title: 'Notification',
                trailing: Switch(
                  value: isDarkMode,
                  onChanged: (value) {
                    
                  },
                  activeColor: AppColors.textPrimary,
                  inactiveThumbColor: Colors.grey[400],
                  inactiveTrackColor: Colors.grey[300],
                ),
              ),
              _buildDivider(),
              _buildSettingsItem(
                icon: HugeIcons.strokeRoundedDarkMode,
                title: 'Dark Mode',
                trailing: Switch(
                  value: isDarkMode,
                  onChanged: (value) {
                    
                  },
                  activeColor: AppColors.textPrimary,
                  inactiveThumbColor: Colors.grey[400],
                  inactiveTrackColor: Colors.grey[300],
                ),
              ),
              _buildSettingsItem(
                icon: HugeIcons.strokeRoundedLogout04,
                title: 'Logout',
                onTap: () async {
                  await loginController.handleLogout();
                  if (context.mounted && !_authService.isLoggedIn) {
                    RouteHelper.pushAndCloseOther(context, const LoginView());
                  }
                },
                isLast: true,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDivider() {
    return Container(
      height: 1,
      margin: EdgeInsets.symmetric(horizontal: context.dynamicWidth(0.04)),
      color: Colors.grey.withOpacity(0.1),
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
      child: InkWell(
        onTap: onTap,
        child: Container(
          padding: EdgeInsets.symmetric(
            horizontal: context.dynamicWidth(0.05),
            vertical: context.dynamicHeight(0.02)
          ),
          child: Row(
            children: [
              Container(
                padding: EdgeInsets.all(context.dynamicHeight(0.01)),
                decoration: BoxDecoration(
                  color: title == 'Logout' ? AppColors.danger.withOpacity(0.1) : AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(context.dynamicHeight(0.01)),
                ),
                child: Icon(
                  icon,
                  color: title == 'Logout' ? AppColors.danger : AppColors.textPrimary,
                  size: context.dynamicHeight(0.025),
                ),
              ),
              context.dynamicWidth(0.04).width,
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: context.dynamicHeight(0.018),
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ),
              trailing ?? Icon(
                Icons.chevron_right,
                color: AppColors.textSecondary,
                size: context.dynamicHeight(0.025),
              ),
            ],
          ),
        ),
      ),
    );
  }


}