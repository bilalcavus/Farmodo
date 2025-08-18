import 'package:farmodo/core/extension/dynamic_size_extension.dart';
import 'package:farmodo/core/extension/route_helper.dart';
import 'package:farmodo/feature/navigation/app_navigation.dart';
import 'package:farmodo/core/components/button/button_text.dart';
import 'package:farmodo/core/components/loading_icon.dart';
import 'package:farmodo/feature/auth/login/viewmodel/login_controller.dart';
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
          if (loginController.errorMessage.value.isNotEmpty) {
            Get.snackbar(loginController.errorMessage.value, 'Try again');
            return;
          }
          if(context.mounted && loginController.errorMessage.value.isEmpty){
            RouteHelper.pushAndCloseOther(context, AppNavigation());
          }
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
            return loginController.isLoading.value ? LoadingIcon() : ButtonText(text: 'Login',);
          })
        ),
      ),
    );
  }
}
