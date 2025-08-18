import 'package:farmodo/core/extension/dynamic_size_extension.dart';
import 'package:flutter/material.dart';

class SignOptionsSection extends StatelessWidget {
  const SignOptionsSection({
    super.key,
    required this.leftText,
    required this.rightText,
    required this.onTap
  });
  final String leftText;
  final String rightText;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(leftText, style: Theme.of(context).textTheme.bodyMedium,),
        SizedBox(width: context.dynamicWidth(0.015)),
        GestureDetector(
          onTap: onTap,
          child: Text(rightText, style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: Colors.pink
          )),
        )
      ],
    );
  }
}
