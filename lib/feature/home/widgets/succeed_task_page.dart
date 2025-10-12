import 'package:easy_localization/easy_localization.dart';
import 'package:farmodo/core/utility/extension/dynamic_size_extension.dart';
import 'package:farmodo/core/utility/extension/ontap_extension.dart';
import 'package:farmodo/core/utility/extension/route_helper.dart';
import 'package:farmodo/feature/navigation/app_navigation.dart';
import 'package:flutter/material.dart';

class SucceedTaskPage extends StatelessWidget {
  const SucceedTaskPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(child: Center(
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: context.dynamicHeight(0.08)),
          child: Column(
            children: [
              Image.asset('assets/images/medal.png', height: context.dynamicHeight(0.4)),
              Text('home.congratulations'.tr(), style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold
              )),
              Text('home.task_completed'.tr(), style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                fontWeight: FontWeight.w500
              )),
              SizedBox(height: context.dynamicHeight(0.1)),
              Container(
                alignment: Alignment.center,
                width: context.dynamicWidth(0.7),
                height: context.dynamicHeight(0.07),
                decoration: BoxDecoration(
                  color: Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(context.dynamicHeight(.02))
                ),
                child: Text('home.back_to_home'.tr(), style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: Colors.black87,
                  fontWeight: FontWeight.w600
                ),),
              ).onTap(() => RouteHelper.pushAndCloseOther(context, AppNavigation(initialIndex: 0)))
            ],
          ),
        ),
      )),
    );
  }
}