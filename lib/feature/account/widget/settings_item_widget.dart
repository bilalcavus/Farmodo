import 'package:farmodo/core/theme/app_colors.dart';
import 'package:farmodo/core/utility/extension/dynamic_size_extension.dart';
import 'package:farmodo/core/utility/extension/ontap_extension.dart';
import 'package:farmodo/core/utility/extension/sized_box_extension.dart';
import 'package:flutter/material.dart';

class SettingsItemWidget extends StatelessWidget {
  const SettingsItemWidget({
    super.key,
    required this.context,
    required this.icon, required this.title, this.onTap, this.trailing,
  });

  final BuildContext context;
  final IconData icon;
  final String title;
  final VoidCallback? onTap;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Container(
        padding: EdgeInsets.symmetric(
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
}