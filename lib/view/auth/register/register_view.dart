import 'package:farmodo/core/di/injection.dart';
import 'package:farmodo/core/extension/dynamic_size_extension.dart';
import 'package:farmodo/core/extension/route_helper.dart';
import 'package:farmodo/view/auth/register/widget/register_button.dart';
import 'package:farmodo/view/widget/custom_text_field.dart';
import 'package:farmodo/view/widget/sign_options_section.dart';
import 'package:farmodo/view/widget/social_network_login.dart';
import 'package:farmodo/viewmodel/auth/login/login_controller.dart';
import 'package:farmodo/viewmodel/auth/register/register_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hugeicons/hugeicons.dart';

class RegisterView extends StatefulWidget {
  const RegisterView({super.key});

  @override
  State<RegisterView> createState() => _RegisterViewState();
}

class _RegisterViewState extends State<RegisterView> {
  RegisterController registerController = getIt<RegisterController>();
  LoginController loginController = getIt<LoginController>();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromARGB(255, 255, 255, 255),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
      ),
      body: SingleChildScrollView(
        child: SafeArea(
          child: Padding(
            padding:  EdgeInsets.symmetric(horizontal: context.dynamicWidth(0.05), vertical: context.dynamicHeight(0.05)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Join Farmodo Now ⚡️', style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w500,
                )),
                SizedBox(height: context.dynamicHeight(.015)),
                Text('Sign up to start your goals!', style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w400,
                  color: Colors.grey.shade700
                )),
                SizedBox(height: context.dynamicHeight(.05)),
                CustomTextField(
                  controller: registerController.displayNameController,
                  hintText: 'Display Name',
                  prefixIcon: Icon(HugeIcons.strokeRoundedUser)
                  ),
                SizedBox(height: context.dynamicHeight(.02)),
                CustomTextField(
                  controller: registerController.emailcontroller,
                  hintText: 'Email',
                  prefixIcon: Icon(HugeIcons.strokeRoundedMail01),
                  ),
                SizedBox(height: context.dynamicHeight(.02)),
                Obx((){
                  return  CustomTextField(
                    controller: registerController.passwordController,
                    hintText: 'Password',
                    suffixIcon: togglePasswordView(
                      () => registerController.togglePasswordVisibility(),
                      registerController.obsecurePassword),
                    prefixIcon: Icon(HugeIcons.strokeRoundedLockPassword),
                    obscureText: registerController.obsecurePassword.value,
                    );
                  }
                ),
                SizedBox(height: context.dynamicHeight(.02)),
                Obx((){
                  return CustomTextField(
                    controller: registerController.passwordConfirmController,
                    hintText: 'Confirm Password',
                    suffixIcon: togglePasswordView(
                      ()=> registerController.toggleConfirmPasswordVisibility(),
                      registerController.obsecureConfirmPassword),
                    prefixIcon: Icon(HugeIcons.strokeRoundedLockPassword),
                    obscureText: registerController.obsecureConfirmPassword.value,);
                  }
                ),
                SizedBox(height: context.dynamicHeight(.02)),
                RegisterButton(registerController: registerController),
                SizedBox(height: context.dynamicHeight(.03)),
                SignOptionsSection(leftText: 'Already have an account?', rightText: 'Sign in', onTap: ()=> RouteHelper.pop(context)),
                SizedBox(height: context.dynamicHeight(.05)),
                Row(
                  children: [
                    horizontalLine(),
                    horizontalLineText(context),
                    horizontalLine()
                  ],
                ),
                SizedBox(height: context.dynamicHeight(.02)),
                SocialNetworkLogin(loginController: loginController)
              ],
            ),
          )
        ),
      ),
    );
  }

  Widget togglePasswordView(VoidCallback onTap, RxBool value) {
    return Obx((){
      return GestureDetector(
        onTap: onTap,
        child: value.value ? Icon(HugeIcons.strokeRoundedViewOffSlash) : Icon(HugeIcons.strokeRoundedView));
      }
    );
  }

  Padding horizontalLineText(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: context.dynamicWidth(0.04)),
      child: Text(
        'or continue with',
        style: TextStyle(
          color: Colors.black.withOpacity(0.6),
          fontSize: context.dynamicWidth(0.035),
        ),
      ),
    );
  }

  Widget horizontalLine() {
    return Expanded(
      child: Container(
        height: 1,
        color: Colors.black.withOpacity(0.2),
      ),
    );
  }
}

