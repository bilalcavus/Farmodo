import 'package:farmodo/core/theme/app_colors.dart';
import 'package:farmodo/core/utility/extension/dynamic_size_extension.dart';
import 'package:farmodo/core/utility/extension/route_helper.dart';
import 'package:farmodo/core/utility/extension/sized_box_extension.dart';
import 'package:farmodo/feature/auth/login/view/login_view.dart';
import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';

class LoginPrompt extends StatelessWidget {
  const LoginPrompt({
    super.key,
    required this.context,
  });

  final BuildContext context;

  @override
  Widget build(BuildContext context) {
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

