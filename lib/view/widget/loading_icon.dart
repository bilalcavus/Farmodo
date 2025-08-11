import 'package:farmodo/core/extension/dynamic_size_extension.dart';
import 'package:flutter/material.dart';

class LoadingIcon extends StatelessWidget {
  const LoadingIcon({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: context.dynamicWidth(0.06),
      height: context.dynamicWidth(0.06),
      child: const CircularProgressIndicator(
        color: Colors.white,
        strokeWidth: 2.5,
      ),
    );
  }
}