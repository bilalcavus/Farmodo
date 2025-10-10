
import 'package:farmodo/core/utility/extension/dynamic_size_extension.dart';
import 'package:flutter/material.dart';
import 'package:kartal/kartal.dart';

class OnboardButton extends StatelessWidget {
  const OnboardButton({
    super.key, 
    required this.buttonText,
    this.onPressed,
  });

  final String buttonText;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: context.padding.high,
      child: SizedBox(
        width: double.infinity,
        height: context.dynamicHeight(0.05),
        child: ElevatedButton(
          onPressed: onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.lightGreenAccent,
            shape: RoundedRectangleBorder(
              borderRadius: context.border.lowBorderRadius
            ),
            elevation: 2,
          ),
          child: Text(
            buttonText,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              fontWeight: FontWeight.w600,
              color: Colors.black
            )
          ),
        ),
      ),
    );
  }
}