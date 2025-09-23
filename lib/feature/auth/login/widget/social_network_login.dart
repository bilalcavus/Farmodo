import 'package:farmodo/core/utility/extension/dynamic_size_extension.dart';
import 'package:farmodo/core/utility/extension/ontap_extension.dart';
import 'package:flutter/material.dart';

class SocialNetworkLogin extends StatelessWidget {
  const SocialNetworkLogin({
    super.key,
    required this.assetPath, required this.onTap,
  });

  final String assetPath;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      assetPath,
      height: context.dynamicHeight(0.04)).onTap(
        () async => onTap()
      );
  }
}