import 'package:farmodo/core/di/injection.dart';
import 'package:farmodo/core/services/preferences_service.dart';
import 'package:farmodo/core/theme/app_colors.dart';
import 'package:farmodo/core/utility/extension/dynamic_size_extension.dart';
import 'package:farmodo/core/utility/extension/route_helper.dart';
import 'package:farmodo/core/utility/extension/sized_box_extension.dart';
import 'package:farmodo/data/services/auth_service.dart';
import 'package:farmodo/feature/account/widget/settings_item_widget.dart';
import 'package:farmodo/feature/auth/login/view/login_view.dart';
import 'package:farmodo/feature/auth/login/viewmodel/login_controller.dart';
import 'package:farmodo/feature/gamification/view/debug_gamification_view.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hugeicons/hugeicons.dart';

class PreferencesSection extends StatefulWidget {
  const PreferencesSection({
    super.key,
    required this.context, required this.authService, required this.loginController,
  });

  final BuildContext context;
  final AuthService authService;
  final LoginController loginController;

  @override
  State<PreferencesSection> createState() => _PreferencesSectionState();
}

class _PreferencesSectionState extends State<PreferencesSection> {
  final PreferencesService _preferencesService = getIt<PreferencesService>();
  bool _notificationsEnabled = true;

  @override
  void initState() {
    super.initState();
    _loadNotificationSettings();
  }

  Future<void> _loadNotificationSettings() async {
    final isEnabled = await _preferencesService.getBool('notifications_enabled', true);
    setState(() {
      _notificationsEnabled = isEnabled;
    });
  }

  Future<void> _toggleNotifications(bool value) async {
    setState(() {
      _notificationsEnabled = value;
    });
    await _preferencesService.setBool('notifications_enabled', value);
  }

  @override
  Widget build(BuildContext context) {
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
          
             SettingsItemWidget(
              context: context,
              icon: HugeIcons.strokeRoundedNotification02,
              title: 'Notification',
              trailing: Switch(
                value: _notificationsEnabled,
                onChanged: _toggleNotifications,
                activeThumbColor: AppColors.textPrimary,
                inactiveThumbColor: Colors.grey[400],
                inactiveTrackColor: Colors.grey[300],
              ),
            ),
           
            kDebugMode ? 
            SettingsItemWidget(
              icon: Icons.bug_report,
              title: 'Debug Gamification',
              onTap: () => Get.to(() => const DebugGamificationView()),
              context: context,
            ) : const SizedBox.shrink(),
            widget.authService.isLoggedIn ? SettingsItemWidget(
              icon: HugeIcons.strokeRoundedLogout04,
              title: 'Logout',
              onTap: () async {
                await widget.loginController.handleLogout();
                if (context.mounted && !widget.authService.isLoggedIn) {
                  RouteHelper.pushAndCloseOther(context, const LoginView());
                }
              },
              context: context,
            ) : SizedBox.shrink(),
          ],
        ),
      ],
    );
  }
}



