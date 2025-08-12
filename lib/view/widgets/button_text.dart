
import 'package:flutter/material.dart';

class ButtonText extends StatelessWidget {
  const ButtonText({
    super.key, required this.text,
  });

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text, style: Theme.of(context).textTheme.bodyLarge?.copyWith(
        color: Colors.white
      )
    );
  }
}
