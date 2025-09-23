import 'package:farmodo/core/components/loading_icon.dart';
import 'package:farmodo/core/components/message/snack_messages.dart';
import 'package:farmodo/core/di/injection.dart';
import 'package:farmodo/core/theme/app_colors.dart';
import 'package:farmodo/core/utility/extension/dynamic_size_extension.dart';
import 'package:farmodo/core/utility/extension/sized_box_extension.dart';
import 'package:farmodo/feature/auth/login/viewmodel/login_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:kartal/kartal.dart';

class AccountDeletionView extends StatefulWidget {
  const AccountDeletionView({super.key});

  @override
  State<AccountDeletionView> createState() => _AccountDeletionViewState();
}

class _AccountDeletionViewState extends State<AccountDeletionView> {
  final LoginController _loginController = getIt<LoginController>();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmationController = TextEditingController();

  @override
  void dispose() {
    _passwordController.dispose();
    _confirmationController.dispose();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('Delete account', style: theme.textTheme.bodyLarge),
        centerTitle: true,
        elevation: 0,
      ),
      body: SafeArea(child: SingleChildScrollView(
        padding: context.padding.normal,
        child: Column(
          children: [
            WarningBox(context: context),
            context.dynamicHeight(0.05).height,
            Obx(() {
              if (_loginController.errorMessage.value.isNotEmpty) {
                SnackMessages().showErrorSnack(_loginController.errorMessage.value);
              }
              return Column(
                children: [
                  Text('Confirm Deletion', style: theme.textTheme.bodyLarge),
                  context.dynamicHeight(0.02).height,
                  TextFormField(
                    controller: _passwordController,
                    obscureText: _loginController.deletionObscurePassword.value,
                    decoration: InputDecoration(
                      labelText: "Current password",
                      border: OutlineInputBorder(
                        borderRadius: context.border.normalBorderRadius,
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: context.border.normalBorderRadius,
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: context.border.normalBorderRadius,
                        borderSide: const BorderSide(color: Colors.red),
                      ),
                      suffixIcon: IconButton(
                        onPressed: () =>
                          _loginController.deletionObscurePassword.value = !_loginController.deletionObscurePassword.value,
                        icon: Icon(_loginController.deletionObscurePassword.value ? Icons.visibility : Icons.visibility_off))
                    ),
                  ),
                  context.dynamicHeight(0.02).height,
                  TextFormField(
                    controller: _confirmationController,
                    decoration: InputDecoration(
                      labelText: "Text 'delete' to confirm deletion",
                      border: OutlineInputBorder(
                        borderRadius: context.border.normalBorderRadius,
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: context.border.normalBorderRadius,
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: context.border.normalBorderRadius,
                        borderSide: const BorderSide(color: Colors.red),
                      ),
                    ),
                  ),
                  context.dynamicHeight(0.02).height,
                  CheckboxListTile(
                    value: _loginController.agreeToTerms.value,
                    onChanged: (value) {
                      _loginController.agreeToTerms.value = value ?? false;
                    },
                    title: Text('Agree to deletion'),
                    controlAffinity: ListTileControlAffinity.platform,
                    activeColor: Colors.red,
                  ),
                  context.dynamicHeight(0.02).height,
                  SizedBox(
                    height: context.dynamicHeight(0.06),
                    child: ElevatedButton(onPressed: () async {
                      final isFormValid = _passwordController.text.isNotEmpty && 
                            _confirmationController.text.isNotEmpty && 
                            _confirmationController.text.toLowerCase() == 'delete' &&
                            _loginController.agreeToTerms.value;
                        isFormValid && !_loginController.isLoading.value 
                        ? await _loginController.handleDeleteAccount(context, password: _passwordController.text)
                        : null;
                    },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.danger,
                        foregroundColor: AppColors.surface,
                        shape: RoundedRectangleBorder(
                          borderRadius: context.border.normalBorderRadius
                        )
                      ),
                      child: _loginController.isLoading.value 
                        ? LoadingIcon(
                          iconColor: Colors.white,
                        ) : Text('Delete Account permamently')),
                  )
                ],
              );
            }
            )
          ],
        ),
      )),
    );
  }
}

class WarningBox extends StatelessWidget {
  const WarningBox({
    super.key,
    required this.context,
  });

  final BuildContext context;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: context.dynamicWidth(0.8),
        padding: context.padding.low,
        decoration: BoxDecoration(
          color: Colors.red.withOpacity(0.1),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.red.withOpacity(0.3)),
        ),
        child: Row(
          children: [
            Icon(
              Iconsax.warning_2,
              color: Colors.red,
              size: context.dynamicHeight(0.02),
            ),
            SizedBox(width: context.dynamicWidth(0.03)),
            Expanded(
              child: Text(
                'This action cannot be undone. Your account and all associated data will be permanently deleted.',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.red,
                  fontWeight: FontWeight.w600,
                )
              ),
            ),
          ],
        ),
      ),
    );
  }
}