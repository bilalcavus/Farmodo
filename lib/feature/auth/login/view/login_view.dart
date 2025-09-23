import 'package:farmodo/core/components/loading_icon.dart';
import 'package:farmodo/core/components/text_field/custom_text_field.dart';
import 'package:farmodo/core/utility/constants/text_strings.dart';
import 'package:farmodo/core/di/injection.dart';
import 'package:farmodo/core/utility/extension/dynamic_size_extension.dart';
import 'package:farmodo/core/utility/extension/ontap_extension.dart';
import 'package:farmodo/core/utility/extension/route_helper.dart';
import 'package:farmodo/core/theme/app_colors.dart';
import 'package:farmodo/core/utility/extension/sized_box_extension.dart';
import 'package:farmodo/feature/auth/login/viewmodel/login_controller.dart';
import 'package:farmodo/feature/auth/login/widget/forgot_password.dart';
import 'package:farmodo/feature/auth/login/widget/login_button.dart';
import 'package:farmodo/feature/auth/login/widget/sign_options_section.dart';
import 'package:farmodo/feature/auth/login/widget/social_network_login.dart';
import 'package:farmodo/feature/auth/register/view/register_view.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
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
                    Spacer(),
                    ForgotPassword()
                  ],
                ),
                
                SizedBox(height: context.dynamicHeight(.02)),
                LoginButton(loginController: loginController,),
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
                Obx((){
                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      loginController.googleLoading.value ? LoadingIcon(
                        iconColor: Colors.black,
                      ) :
                      SocialNetworkLogin(
                        assetPath: "assets/logo/google-icon.png",
                        onTap: () async => await loginController.handleGoogleSignIn(context)),
                      context.dynamicWidth(0.08).width,
                      loginController.appleLoading.value ? LoadingIcon(
                        iconColor: Colors.black,
                      ) : 
                      SocialNetworkLogin(
                        assetPath: "assets/logo/apple_icon.png",
                        onTap: () async => await loginController.handleAppleSignIn(context)),
                      ],
                    );
                  }
                ),
                SizedBox(height: context.dynamicHeight(.15)),
                _buildPrivacyTermsText(context),
              ],
            ),
          )
        ),
      ),
    );
  }

  Widget togglePasswordView() {
    return Obx((){
      return loginController.obsecurePassword.value 
      ? Icon(HugeIcons.strokeRoundedView)
      : Icon(HugeIcons.strokeRoundedViewOffSlash)
        .onTap(() => loginController.toggleLoginPasswordVisibility());
      }
    );
  }

  Padding horizontalLineText(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: context.dynamicWidth(0.04)),
      child: Text(
        'or continue with',
        style: TextStyle(
          color: Colors.black.withAlpha(150),
          fontSize: context.dynamicWidth(0.035),
        ),
      ),
    );
  }

  Widget horizontalLine() {
    return Expanded(
      child: Container(
        height: 1,
        color: Colors.black.withAlpha(50),
      ),
    );
  }

  Widget _buildPrivacyTermsText(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: context.dynamicWidth(0.02)),
      child: RichText(
        textAlign: TextAlign.center,
        text: TextSpan(
          style: TextStyle(
            fontSize: context.dynamicWidth(0.032),
            color: Colors.grey.shade600,
            height: 1.3,
          ),
          children: [
            TextSpan(text: 'Giriş yaparak veya kayıt olarak '),
            WidgetSpan(
              child: Text(
                'gizlilik sözleşmesi',
                style: TextStyle(
                  fontSize: context.dynamicWidth(0.032),
                  color: Colors.pink,
                  decoration: TextDecoration.underline,
                  decorationColor: Colors.pink,
                ),
              ).onTap(() => _showPrivacyPolicy(context)),
            ),
            TextSpan(text: ' ve '),
            WidgetSpan(
              child: Text(
                'kullanım şartlarını',
                style: TextStyle(
                  fontSize: context.dynamicWidth(0.032),
                  color: Colors.pink,
                  decoration: TextDecoration.underline,
                  decorationColor: Colors.pink,
                ),
              ).onTap(() => _showTermsOfService(context)),
            ),
            TextSpan(text: ' kabul etmiş olursunuz.'),
          ],
        ),
      ),
    );
  }

  void _showPrivacyPolicy(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Gizlilik Sözleşmesi'),
          content: SingleChildScrollView(
            child: Text(
              TextStrings.termsAndConditions,
              style: TextStyle(fontSize: 14),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Tamam', style: TextStyle(color: Colors.pink)),
            ),
          ],
        );
      },
    );
  }

  void _showTermsOfService(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Kullanım Şartları'),
          content: SingleChildScrollView(
            child: Text(
              TextStrings.privacyPolicy,
              style: TextStyle(fontSize: 14),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Tamam', style: TextStyle(color: Colors.pink)),
            ),
          ],
        );
      },
    );
  }
}

