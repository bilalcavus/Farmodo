import 'package:farmodo/core/components/card/show_alert_dialog.dart';
import 'package:farmodo/core/di/injection.dart';
import 'package:farmodo/core/theme/theme_controller.dart';
import 'package:farmodo/core/utility/extension/dynamic_size_extension.dart';
import 'package:farmodo/core/utility/extension/route_helper.dart';
import 'package:farmodo/core/utility/extension/sized_box_extension.dart';
import 'package:farmodo/data/services/auth_service.dart';
import 'package:farmodo/feature/account/widget/settings_item_widget.dart';
import 'package:farmodo/feature/auth/login/viewmodel/login_controller.dart';
import 'package:farmodo/feature/gamification/view/debug_gamification_view.dart';
import 'package:farmodo/feature/navigation/app_navigation.dart';
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
  @override
  Widget build(BuildContext context) {
    final themeController = getIt<ThemeController>();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Preferences & Logout',
          style: TextStyle(
            fontSize: context.dynamicHeight(0.015),
            fontWeight: FontWeight.w300,
          ),
        ),
        context.dynamicHeight(0.02).height,
        Column(
          children: [
            SettingsItemWidget(
              context: context,
              icon: HugeIcons.strokeRoundedMoon02,
              title: "Dark Mode",
              trailing: Obx(() => Switch.adaptive(
                inactiveTrackColor: Colors.grey.shade800,
                value: themeController.isDarkMode,
                onChanged: (value) => themeController.toggleTheme(),
                ),
              )
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
                showAlertDialog(
                  context: context,
                  title: "Exit App",
                  content: "Are you sure to want you exit the app?",
                  onPressed: () async {
                    await widget.loginController.handleLogout();
                      if (context.mounted && !widget.authService.isLoggedIn) {
                        RouteHelper.pushAndCloseOther(context, AppNavigation(initialIndex: 0));
                      }
                  },
                  buttonText: "Exit");
              },
              context: context,
            ) : SizedBox.shrink(),
          ],
        ),
      ],
    );
  }
}



