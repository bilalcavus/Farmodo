import 'package:farmodo/core/extension/dynamic_size_extension.dart';
import 'package:farmodo/view/widget/loading_icon.dart';
import 'package:farmodo/viewmodel/auth/register/register_controller.dart';
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
            return registerController.isLoading.value ? LoadingIcon() : _logInText(context);
          })
        ),
      ),
    );
  }

  Text _logInText(BuildContext context) {
    return Text(
      'Sign up',
      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
        color: Colors.white
      )
    );
  }
}
