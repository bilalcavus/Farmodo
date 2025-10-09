import 'package:farmodo/core/theme/app_container_styles.dart';
import 'package:farmodo/core/utility/extension/dynamic_size_extension.dart';
import 'package:farmodo/core/utility/extension/ontap_extension.dart';
import 'package:farmodo/core/utility/extension/sized_box_extension.dart';
import 'package:farmodo/feature/farm/viewmodel/farm_controller.dart';
import 'package:flutter/material.dart';
import 'package:kartal/kartal.dart';

class FarmViewContainer extends StatelessWidget {
  const FarmViewContainer({
    super.key,
    required this.farmController,
    required this.iconContainerColor,
    required this.iconColor, 
    required this.title,
    required this.icon,
    required this.onTap, required this.widget,
  });

  final FarmController farmController;
  final Color iconContainerColor;
  final Color iconColor;
  final String title;
  final IconData icon;
  final VoidCallback onTap;
  final Widget widget;


  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(context.dynamicWidth(0.05)),
      decoration: AppContainerStyles.primaryContainer(context),
      child: Material(
        color: Colors.transparent,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Container(
                  padding: context.padding.low,
                  decoration: BoxDecoration(
                    color: iconContainerColor,
                    borderRadius: context.border.lowBorderRadius
                  ),
                  child: Icon(
                    icon,
                    size: context.dynamicHeight(0.02),
                    color: iconColor
                  ),
                ),
                context.dynamicWidth(0.04).width,
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700,)),
                    context.dynamicHeight(0.005).height,
                    widget,
                  ],
                ),
                Spacer(),
                Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: context.dynamicHeight(0.02),
                ),
              ],
            ),
          ],
        ).onTap(() => onTap()),
      ),
    );
  }
}