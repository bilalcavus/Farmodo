import 'package:easy_localization/easy_localization.dart';
import 'package:farmodo/core/utility/extension/dynamic_size_extension.dart';
import 'package:farmodo/core/utility/extension/route_helper.dart';
import 'package:farmodo/feature/account/account_deletion_view.dart';
import 'package:farmodo/feature/account/profile_detail_view.dart';
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
          'account.profile'.tr(),
          style: TextStyle(
            fontSize: context.dynamicHeight(0.015),
            fontWeight: FontWeight.w300,
          ),
        ),
        Column(
          children: [
            SettingsItemWidget(
              context: context,
              icon: HugeIcons.strokeRoundedUser,
              title: 'account.profile_detail'.tr(),
              onTap: () => RouteHelper.push(context, const ProfileDetailView()),
            ),
  
            SettingsItemWidget(
              context: context,
              icon: HugeIcons.strokeRoundedDelete04,
              title: 'account.delete_account'.tr(),
              onTap: () => RouteHelper.push(context, const AccountDeletionView()),
            ),
          ],
        ),
      ],
    );
  }
}

