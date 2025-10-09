import 'package:farmodo/core/theme/app_colors.dart';
import 'package:farmodo/core/utility/extension/dynamic_size_extension.dart';
import 'package:farmodo/core/components/button/button_text.dart';
import 'package:farmodo/core/components/loading_icon.dart';
import 'package:farmodo/core/utility/extension/ontap_extension.dart';
import 'package:farmodo/feature/auth/register/viewmodel/register_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get_state_manager/src/rx_flutter/rx_obx_widget.dart';

class RegisterButton extends StatelessWidget {
  const RegisterButton({
    super.key,
    required this.registerController,
  });

  final RegisterController registerController;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    return Center(
      child: Container(
        alignment: Alignment.center,
        width: context.dynamicWidth(0.85),
        height: context.dynamicHeight(0.06),
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
          borderRadius: BorderRadius.circular(16)
        ),

        child: Obx((){
          return registerController.isLoading.value ? LoadingIcon(iconColor: Colors.black,) : ButtonText(text: 'Sign up',);
        })
      ).onTap(() async => await registerController.handleRegister(context)),
    );
  }
}
