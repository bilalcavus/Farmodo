import 'package:farmodo/core/di/injection.dart';
import 'package:farmodo/core/extension/dynamic_size_extension.dart';
import 'package:farmodo/core/extension/route_helper.dart';
import 'package:farmodo/core/theme/app_colors.dart';
import 'package:farmodo/view/auth/login/widget/forgot_password.dart';
import 'package:farmodo/view/auth/login/widget/login_button.dart';
import 'package:farmodo/view/auth/login/widget/remember_me.dart';
import 'package:farmodo/view/auth/register/register_view.dart';
import 'package:farmodo/view/widgets/custom_text_field.dart';
import 'package:farmodo/view/widgets/sign_options_section.dart';
import 'package:farmodo/view/widgets/social_network_login.dart';
import 'package:farmodo/viewmodel/auth/login/login_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get_state_manager/src/rx_flutter/rx_obx_widget.dart';
import 'package:hugeicons/hugeicons.dart';

class LoginView extends StatefulWidget {
  const LoginView({super.key});

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  LoginController loginController = getIt<LoginController>();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
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
                Text('Welcome back! 👋', style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w500,
                )),
                SizedBox(height: context.dynamicHeight(.015)),
                Text('Sign in to continue your goals!', style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w400,
                  color: Colors.grey.shade700
                )),
                SizedBox(height: context.dynamicHeight(.05)),
                CustomTextField(
                  controller: loginController.emailController,
                  hintText: 'Email',
                  prefixIcon: Icon(HugeIcons.strokeRoundedMail01)
                  ),
                SizedBox(height: context.dynamicHeight(.02)),
                Obx((){
                  return CustomTextField(
                    controller: loginController.passwordController,
                    hintText: 'Password',
                    prefixIcon: Icon(HugeIcons.strokeRoundedLockPassword),
                    suffixIcon: togglePasswordView(),
                    obscureText: loginController.obsecurePassword.value
                    );
                }
                ),
                SizedBox(height: context.dynamicHeight(.02)),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    RememberMe(loginController: loginController),
                    ForgotPassword()
                  ],
                ),
                
                SizedBox(height: context.dynamicHeight(.02)),
                LoginButton(loginController: loginController),
                SizedBox(height: context.dynamicHeight(.04)),
                SignOptionsSection(
                  leftText: "Don't have an account?",
                  rightText: "Sign up",
                  onTap: () => RouteHelper.push(context, RegisterView()),),
                SizedBox(height: context.dynamicHeight(.04)),
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

  Widget togglePasswordView() {
    return Obx((){
      return GestureDetector(
        onTap: (){
          loginController.toggleLoginPasswordVisibility();
        },
        child: loginController.obsecurePassword.value ? Icon(HugeIcons.strokeRoundedView) : Icon(HugeIcons.strokeRoundedViewOffSlash));
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

