import 'package:easy_localization/easy_localization.dart';
import 'package:farmodo/core/theme/app_colors.dart';
import 'package:farmodo/core/utility/extension/dynamic_size_extension.dart';
import 'package:farmodo/core/utility/extension/ontap_extension.dart';
import 'package:farmodo/core/utility/extension/route_helper.dart';
import 'package:farmodo/feature/navigation/app_navigation.dart';
import 'package:farmodo/core/components/button/button_text.dart';
import 'package:farmodo/core/components/loading_icon.dart';
import 'package:farmodo/feature/auth/login/viewmodel/login_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart' hide Trans;

class LoginButton extends StatelessWidget {
  const LoginButton({
    super.key,
    required this.loginController
  });

  final LoginController loginController;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    return Center(
      child: Container(
        alignment: Alignment.center,
        width: context.dynamicWidth(0.8),
        height: context.dynamicHeight(0.06),
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
          borderRadius: BorderRadius.circular(16)
        ),

        child: Obx((){
          return loginController.isLoading.value ? LoadingIcon(iconColor: Colors.white,) : ButtonText(text: 'auth.sign_in'.tr());
        })
      ).onTap(() async {
        await loginController.handleLogin(context);
          if (loginController.errorMessage.value.isNotEmpty) {
            Get.snackbar(loginController.errorMessage.value, 'Try again');
            return;
          }
          if(context.mounted && loginController.errorMessage.value.isEmpty){
            RouteHelper.pushAndCloseOther(context, AppNavigation(initialIndex: 0));
          }
        }
      ),
    );
  }
}
