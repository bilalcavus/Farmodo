import 'package:farmodo/core/utility/extension/dynamic_size_extension.dart';
import 'package:farmodo/core/utility/extension/ontap_extension.dart';
import 'package:farmodo/core/utility/extension/sized_box_extension.dart';
import 'package:flutter/material.dart';
import 'package:kartal/kartal.dart';

class SocialNetworkLogin extends StatelessWidget {
  const SocialNetworkLogin({
    super.key,
    required this.assetPath, required this.onTap, required this.text,
  });

  final String assetPath;
  final VoidCallback onTap;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: context.dynamicHeight(0.055),
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: context.border.normalBorderRadius
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(
            assetPath,
            height: context.dynamicHeight(0.035)),
          context.dynamicWidth(0.01).width,
          Text(text, style: Theme.of(context).textTheme.bodyLarge,)
        ],
      ),
    ).onTap(() async => onTap());
  }
}