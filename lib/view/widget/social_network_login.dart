import 'package:farmodo/core/extension/dynamic_size_extension.dart';
import 'package:farmodo/viewmodel/auth/login/login_controller.dart';
import 'package:flutter/material.dart';

class SocialNetworkLogin extends StatelessWidget {
  const SocialNetworkLogin({
    super.key,
    required this.loginController,
  });

  final LoginController loginController;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        InkWell(
          onTap: () async  {
            await loginController.handleGoogleSignIn(context);
          },
          child: Image.asset('assets/logo/google-icon.png', height: context.dynamicHeight(0.04),)),
        Image.asset('assets/logo/facebook-icon.png', height: context.dynamicHeight(0.04)),
        Image.asset('assets/logo/x-icon.png', height: context.dynamicHeight(0.04)),
      ],
    );
  }
}