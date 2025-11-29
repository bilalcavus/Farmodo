import 'package:easy_localization/easy_localization.dart';
import 'package:farmodo/core/components/card/show_alert_dialog.dart';
import 'package:farmodo/core/di/injection.dart';
import 'package:farmodo/core/theme/theme_controller.dart';
import 'package:farmodo/core/utility/extension/dynamic_size_extension.dart';
import 'package:farmodo/core/utility/extension/route_helper.dart';
import 'package:farmodo/core/utility/extension/sized_box_extension.dart';
import 'package:farmodo/data/services/auth_service.dart';
import 'package:farmodo/feature/account/widget/settings_item_widget.dart';
import 'package:farmodo/feature/auth/login/viewmodel/login_controller.dart';
import 'package:farmodo/feature/home/widgets/widget_guide_view.dart';
import 'package:farmodo/feature/locale/locale_controller.dart';
import 'package:farmodo/feature/locale/locale_select_view.dart';
import 'package:farmodo/feature/navigation/app_navigation.dart';
import 'package:farmodo/feature/tasks/viewmodel/tasks_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart' hide Trans;
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
    final localeController = getIt<LocaleController>();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'account.preferences_and_logout'.tr(),
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
              icon: HugeIcons.strokeRoundedTranslate,
              title: "account.language".tr(),
              onTap: () => RouteHelper.push(context, const LocaleSelectView()),
              trailing: Obx(() {
                final currentLocale = localeController.getCurrentLocaleEnum();
                return Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      localeController.getLocaleName(currentLocale),
                      style: TextStyle(
                        fontSize: context.dynamicHeight(0.016),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    SizedBox(width: context.dynamicWidth(0.02)),
                    Icon(
                      Icons.chevron_right,
                      size: context.dynamicHeight(0.02),
                    ),
                  ],
                );
              }),
            ),
            SettingsItemWidget(
              context: context,
              icon: HugeIcons.strokeRoundedMoon02,
              title: "account.dark_mode".tr(),
              trailing: Obx(() => Switch.adaptive(
                inactiveTrackColor: Colors.grey.shade800,
                value: themeController.isDarkMode,
                onChanged: (value) => themeController.toggleTheme(),
                ),
              )
            ),
            SettingsItemWidget(
              context: context,
              icon: Icons.widgets_outlined,
              title: "account.home_screen_widget".tr(),
              onTap: () => RouteHelper.push(context, const WidgetGuideView()),
            ),
            
            // kDebugMode ? 
            // SettingsItemWidget(
            //   icon: Icons.bug_report,
            //   title: 'Debug Gamification',
            //   onTap: () => Get.to(() => const DebugGamificationView()),
            //   context: context,
            // ) : const SizedBox.shrink(),
            widget.authService.isLoggedIn ? SettingsItemWidget(
              icon: HugeIcons.strokeRoundedLogout04,
              title: 'auth.logout'.tr(),
              onTap: () async {
                showAlertDialog(
                  context: context,
                  title: "account.exit_app".tr(),
                  content: "account.confirm_logout".tr(),
                  onPressed: () async {
                    final tasksController = getIt<TasksController>();
                    await tasksController.handleUserChange();
                    await widget.loginController.handleLogout();
                      if (context.mounted && !widget.authService.isLoggedIn) {
                        RouteHelper.pushAndCloseOther(context, AppNavigation(initialIndex: 0));
                      }
                  },
                  buttonText: "account.exit".tr());
              },
              context: context,
            ) : SizedBox.shrink(),
          ],
        ),
      ],
    );
  }
}


