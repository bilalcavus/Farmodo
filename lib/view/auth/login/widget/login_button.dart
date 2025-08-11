import 'package:farmodo/core/extension/dynamic_size_extension.dart';
import 'package:farmodo/view/widget/loading_icon.dart';
import 'package:farmodo/viewmodel/auth/login/login_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class LoginButton extends StatelessWidget {
  const LoginButton({
    super.key,
    required this.loginController,
  });

  final LoginController loginController;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: InkWell(
        onTap: () async {
          await loginController.handleLogin(context);
        },
        child: Container(
          alignment: Alignment.center,
          width: context.dynamicWidth(0.85),
          height: context.dynamicHeight(0.06),
          decoration: BoxDecoration(
            color: Colors.black,
            borderRadius: BorderRadius.circular(16)
          ),
          child: Obx((){
            return loginController.isLoading.value ? LoadingIcon() : _logInText(context);
          })
        ),
      ),
    );
  }

  Text _logInText(BuildContext context) {
    return Text(
      'Login',
      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
            color: Colors.white
          )
    );
  }
}
