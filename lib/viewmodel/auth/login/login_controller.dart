import 'package:farmodo/core/extension/route_helper.dart';
import 'package:farmodo/data/services/auth_service.dart';
import 'package:farmodo/view/navigation/app_navigation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class LoginController extends GetxController {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final AuthService authService;

  LoginController(this.authService);
  

  final _isLoading = false.obs;
  final _googleLoading = false.obs;
  final _rememberMeCheckbox = false.obs;
  RxBool get isLoading => _isLoading;
  RxBool get googleLoading => _googleLoading;
  RxBool get rememberMeCheckBox => _rememberMeCheckbox;

  final _obsecurePassword = true.obs;
  RxBool get obsecurePassword => _obsecurePassword;

  @override
  void onClose() {
    emailController.clear();
    passwordController.clear();
    super.onClose();
  }

  void toggleLoginPasswordVisibility() {
    _obsecurePassword.value = !_obsecurePassword.value;
  }

  void setLoading(RxBool value){
    isLoading.value = value.value;
  }

  void setGoogleLoading(RxBool value){
    googleLoading.value = value.value;
  }

  void toggleRememberMe(bool? value){
    _rememberMeCheckbox.value = value ?? false;
  }


  Future<void> handleLogin(BuildContext context) async {
    if(emailController.text.isEmpty || passwordController.text.isEmpty){
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Fill all blanks'), backgroundColor: Colors.red)
      );
      return;
    }
    setLoading(true.obs);
    try {
      await authService.loginUser(email: emailController.text.trim(), password: passwordController.text);
      if (context.mounted && authService.isLoggedIn) {
        RouteHelper.pushAndCloseOther(context, AppNavigation());
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString()),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      emailController.clear();
      passwordController.clear();
      setLoading(false.obs);
    }
  }

  Future<void> handleGoogleSignIn(BuildContext context) async {
    setGoogleLoading(true.obs);
    
    try {
      await authService.signInWithGoogle();
      if (context.mounted) {
        RouteHelper.pushAndCloseOther(context, AppNavigation());
      }
    } catch (e) {
      if (context.mounted) {
        String errorMessage = 'error: ${e.toString()}';
        
        if (e.toString().contains('network')) {
          errorMessage = 'network_error';
        } else if (e.toString().contains('account-exists-with-different-credential')) {
          errorMessage = 'account_exists_different_credential';
        } else if (e.toString().contains('invalid-credential')) {
          errorMessage = 'invalid_credential';
        } else if (e.toString().contains('operation-not-allowed')) {
          errorMessage = 'operation_not_allowed';
        } else if (e.toString().contains('user-disabled')) {
          errorMessage = 'user_disabled';
        } else if (e.toString().contains('user-not-found')) {
          errorMessage = 'user_not_found_google';
        }
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage),
            backgroundColor: Colors.redAccent,
            duration: const Duration(seconds: 4),
          ),
        );
      }
      rethrow;
    } finally {
      setGoogleLoading(false.obs);
    }
  }
}