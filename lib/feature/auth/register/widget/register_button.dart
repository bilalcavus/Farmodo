import 'package:farmodo/core/extension/dynamic_size_extension.dart';
import 'package:farmodo/core/components/button/button_text.dart';
import 'package:farmodo/core/components/loading_icon.dart';
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
    return Center(
      child: InkWell(
        onTap: () async {
          await registerController.handleRegister(context);
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
            return registerController.isLoading.value ? LoadingIcon() : ButtonText(text: 'Sign up',);
          })
        ),
      ),
    );
  }
}
