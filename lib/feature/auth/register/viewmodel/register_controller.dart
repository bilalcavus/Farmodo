import 'package:farmodo/core/utility/extension/route_helper.dart';
import 'package:farmodo/data/services/auth_service.dart';
import 'package:farmodo/feature/auth/login/view/login_view.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class RegisterController extends GetxController {
  final emailcontroller = TextEditingController();
  final passwordController = TextEditingController();
  final displayNameController = TextEditingController();
  final passwordConfirmController = TextEditingController();

  final AuthService authService;

  RegisterController(this.authService);

  final _isLoading = false.obs;
  RxBool get isLoading => _isLoading;
  final _obsecurePassword = true.obs;
  RxBool get obsecurePassword => _obsecurePassword;
  final _obsecureConfirmPassword = true.obs;
  RxBool get obsecureConfirmPassword => _obsecureConfirmPassword;

  void togglePasswordVisibility(){
    _obsecurePassword.value = !_obsecurePassword.value;
  }

  void toggleConfirmPasswordVisibility(){
    _obsecureConfirmPassword.value = !_obsecureConfirmPassword.value;
  }

  void setLoading(bool value) {
    _isLoading.value = value;
  }


  Future<void> handleRegister(BuildContext context) async {
    if(
      emailcontroller.text.isEmpty ||
      passwordController.text.isEmpty ||
      passwordConfirmController.text.isEmpty ||
      displayNameController.text.isEmpty
      ) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Fill all blanks'), backgroundColor: Colors.red)
      );
      return;
    }
    setLoading(true);
    try {
      await authService.registerUser(email: emailcontroller.text.trim(), password: passwordController.text, displayName: displayNameController.text.trim());
      if (context.mounted) {
        RouteHelper.pushAndCloseOther(context, LoginView());
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Successfully registered. Please confirm your email and don't forget look at the Spam folder"),
            backgroundColor: Colors.green,
            )
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString()),
          backgroundColor: Colors.red,
        ),
      );
    } finally{
      emailcontroller.clear();
      passwordController.clear();
      passwordConfirmController.clear();
      displayNameController.clear();
      setLoading(false);
    }
  }

  @override
  void onClose() {
    emailcontroller.clear();
    passwordController.clear();
    passwordConfirmController.clear();
    displayNameController.clear();
    super.onClose();
  }

}