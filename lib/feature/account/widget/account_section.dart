import 'package:farmodo/core/theme/app_colors.dart';
import 'package:farmodo/core/utility/extension/dynamic_size_extension.dart';
import 'package:farmodo/core/utility/extension/route_helper.dart';
import 'package:farmodo/core/utility/extension/sized_box_extension.dart';
import 'package:farmodo/feature/account/account_deletion_view.dart';
import 'package:farmodo/feature/account/widget/settings_item_widget.dart';
import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';

class AccountSection extends StatelessWidget {
  const AccountSection({
    super.key,
    required this.context,
  });

  final BuildContext context;

  @override
  Widget build(BuildContext context) {
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
            SettingsItemWidget(
              context: context,
              icon: HugeIcons.strokeRoundedUser,
              title: 'Profile Detail',
              onTap: () {},
            ),
          
            SettingsItemWidget(
              context: context,
              icon: HugeIcons.strokeRoundedCustomerSupport,
              title: 'Help & Support',
              onTap: () {},
            ),
            SettingsItemWidget(
              context: context,
              icon: HugeIcons.strokeRoundedDelete04,
              title: 'Delete Account',
              onTap: () => RouteHelper.push(context, const AccountDeletionView()),
            ),
          ],
        ),
      ],
    );
  }
}

