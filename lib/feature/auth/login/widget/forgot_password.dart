import 'package:flutter/material.dart';

class ForgotPassword extends StatelessWidget {
  const ForgotPassword({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: (){},
      child: Text("Forgot password?", style: Theme.of(context).textTheme.bodySmall?.copyWith(
        color: Colors.pink
      )),
    );
  }
}

