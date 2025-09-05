import 'package:flutter/material.dart';

class ForgotPassword extends StatelessWidget {
  const ForgotPassword({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Text("Forgot password?", style: Theme.of(context).textTheme.bodySmall?.copyWith(
      color: Colors.pink
    ));
  }
}

