import 'package:easy_localization/easy_localization.dart';
import 'package:farmodo/core/components/loading_icon.dart';
import 'package:farmodo/core/components/text_field/custom_text_field.dart';
import 'package:farmodo/core/di/injection.dart';
import 'package:farmodo/core/utility/extension/dynamic_size_extension.dart';
import 'package:farmodo/core/utility/extension/ontap_extension.dart';
import 'package:farmodo/core/utility/extension/route_helper.dart';
import 'package:farmodo/core/utility/extension/sized_box_extension.dart';
import 'package:farmodo/feature/auth/login/viewmodel/login_controller.dart';
import 'package:farmodo/feature/auth/login/widget/sign_options_section.dart';
import 'package:farmodo/feature/auth/login/widget/social_network_login.dart';
import 'package:farmodo/feature/auth/register/viewmodel/register_controller.dart';
import 'package:farmodo/feature/auth/register/widget/register_button.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart' hide Trans;
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
      appBar: AppBar(
        backgroundColor: Colors.transparent,
      ),
      body: SingleChildScrollView(
        child: SafeArea(
          child: Padding(
            padding:  EdgeInsets.symmetric(horizontal: context.dynamicWidth(0.05)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('auth.join_farmodo'.tr(), style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w500,
                )),
                SizedBox(height: context.dynamicHeight(.015)),
                Text('auth.sign_up_subtitle'.tr(), style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w400,
                  color: Colors.grey.shade600
                )),
                SizedBox(height: context.dynamicHeight(.05)),
                CustomTextField(
                  controller: registerController.displayNameController,
                  hintText: 'auth.display_name'.tr(),
                  prefixIcon: Icon(HugeIcons.strokeRoundedUser)
                  ),
                SizedBox(height: context.dynamicHeight(.015)),
                CustomTextField(
                  controller: registerController.emailcontroller,
                  hintText: 'auth.email'.tr(),
                  prefixIcon: Icon(HugeIcons.strokeRoundedMail01),
                  ),
                SizedBox(height: context.dynamicHeight(.015)),
                Obx((){
                  return  CustomTextField(
                    controller: registerController.passwordController,
                    hintText: 'auth.password'.tr(),
                    suffixIcon: togglePasswordView(
                      () => registerController.togglePasswordVisibility(),
                      registerController.obsecurePassword),
                    prefixIcon: Icon(HugeIcons.strokeRoundedLockPassword),
                    obscureText: registerController.obsecurePassword.value,
                    );
                  }
                ),
                SizedBox(height: context.dynamicHeight(.015)),
                Obx((){
                  return CustomTextField(
                    controller: registerController.passwordConfirmController,
                    hintText: 'auth.confirm_password'.tr(),
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
                SignOptionsSection(leftText: 'auth.already_have_account'.tr(), rightText: 'auth.sign_in'.tr(), onTap: ()=> RouteHelper.pop(context)),
                SizedBox(height: context.dynamicHeight(.02)),
                Row(
                  children: [
                    horizontalLine(),
                    horizontalLineText(context),
                    horizontalLine()
                  ],
                ),
                context.dynamicHeight(.01).height,
                Obx((){
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      loginController.googleLoading.value ? LoadingIcon(iconColor: Colors.black,) :
                      SocialNetworkLogin(
                        assetPath: "assets/logo/google-icon.png",
                        onTap: () async => await loginController.handleGoogleSignIn(context),
                        text: "auth.sign_in_with_google".tr(),
                        ),
                      context.dynamicHeight(0.01).height,
                      loginController.appleLoading.value ? LoadingIcon(iconColor: Colors.black,) : 
                      SocialNetworkLogin(
                        assetPath: "assets/logo/apple_icon.png",
                        onTap: () async => await loginController.handleAppleSignIn(context),
                        text: "auth.sign_in_with_apple".tr(),
                        ),
                      ],
                    );
                  }
                ),
                SizedBox(height: context.dynamicHeight(.03)),
                _buildPrivacyTermsText(context),
              ],
            ),
          )
        ),
      ),
    );
  }

  Widget togglePasswordView(VoidCallback onTap, RxBool value) {
    return Obx((){
      return value.value 
      ? Icon(HugeIcons.strokeRoundedViewOffSlash) 
      : Icon(HugeIcons.strokeRoundedView);
      }
    ).onTap(onTap);
  }

  Padding horizontalLineText(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: context.dynamicWidth(0.04)),
      child: Text(
        'common.or_continue_with'.tr(),
        style: TextStyle(
          fontSize: context.dynamicWidth(0.035),
        ),
      ),
    );
  }

  Widget horizontalLine() {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    return Expanded(
      child: Container(
        height: 1,
        color: isDark ? Colors.white.withAlpha(50) :  Colors.black.withAlpha(50),
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
            TextSpan(text: 'auth.agree_to_terms'.tr()),
            WidgetSpan(
              child: Text(
                'auth.privacy_policy'.tr(),
                style: TextStyle(
                  fontSize: context.dynamicWidth(0.032),
                  color: Colors.pink,
                  decoration: TextDecoration.underline,
                  decorationColor: Colors.pink,
                ),
              ).onTap(() => _showPrivacyPolicy(context)),
            ),
            TextSpan(text: 'auth.and'.tr()),
            WidgetSpan(
              child: Text(
                'auth.terms_of_service'.tr(),
                style: TextStyle(
                  fontSize: context.dynamicWidth(0.032),
                  color: Colors.pink,
                  decoration: TextDecoration.underline,
                  decorationColor: Colors.pink,
                ),
              ).onTap(() => _showTermsOfService(context)),
            ),
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
          title: Text('auth.privacy_policy_title'.tr()),
          content: SingleChildScrollView(
            child: Text(
              'privacy.privacy_policy_text'.tr(),
              style: TextStyle(fontSize: 14),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('common.done'.tr(), style: TextStyle(color: Colors.pink)),
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
          title: Text('auth.terms_of_service_title'.tr()),
          content: SingleChildScrollView(
            child: Text(
              'terms.terms_and_conditions_text'.tr(),
              style: TextStyle(fontSize: 14),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('common.done'.tr(), style: TextStyle(color: Colors.pink)),
            ),
          ],
        );
      },
    );
  }
}

