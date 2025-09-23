import 'package:farmodo/core/utility/extension/dynamic_size_extension.dart';
import 'package:flutter/material.dart';

class LoadingIcon extends StatelessWidget {
  const LoadingIcon({
    super.key, required this.iconColor,
  });
  final Color iconColor;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: context.dynamicWidth(0.06),
      height: context.dynamicWidth(0.06),
      child: CircularProgressIndicator(
        color: iconColor,
        strokeWidth: 2.5,
      ),
    );
  }
}