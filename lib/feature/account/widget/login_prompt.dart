import 'package:easy_localization/easy_localization.dart';
import 'package:farmodo/core/theme/app_colors.dart';
import 'package:farmodo/core/theme/app_container_styles.dart';
import 'package:farmodo/core/utility/extension/dynamic_size_extension.dart';
import 'package:farmodo/core/utility/extension/route_helper.dart';
import 'package:farmodo/core/utility/extension/sized_box_extension.dart';
import 'package:farmodo/feature/auth/login/view/login_view.dart';
import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:kartal/kartal.dart';

class LoginPrompt extends StatelessWidget {
  const LoginPrompt({
    super.key,
    required this.context, required this.title, required this.subtitle,
  });

  final BuildContext context;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(context.dynamicHeight(0.02)),
      decoration: AppContainerStyles.accentContainer(context, accentColor: AppColors.primary, borderRadius: context.border.normalBorderRadius),
      child: Column(
        children: [
          Icon(
            HugeIcons.strokeRoundedLogin01,
            color: AppColors.primary,
            size: context.dynamicHeight(0.04),
          ),
          context.dynamicHeight(0.01).height,
          Text(
            title,
            style: TextStyle(
              fontSize: context.dynamicHeight(0.018),
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.center,
          ),
          context.dynamicHeight(0.01).height,
          Text(
            subtitle,
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
                padding: context.padding.verticalLow,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(context.dynamicHeight(0.015)),
                ),
              ),
              child: Text(
                'common.login'.tr(),
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

