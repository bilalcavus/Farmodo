
import 'package:farmodo/feature/auth/login/viewmodel/login_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get_state_manager/src/rx_flutter/rx_obx_widget.dart';

class RememberMe extends StatelessWidget {
  const RememberMe({
    super.key,
    required this.loginController,
  });

  final LoginController loginController;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Obx((){
          return Checkbox(
            value: loginController.rememberMeCheckBox.value,
            onChanged: (bool? value) => loginController.toggleRememberMe(value),
            activeColor: Colors.deepPurple,
            
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
            );
          }
        ),
        Text('Remember me')
      ],
    );
  }
}