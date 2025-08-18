import 'package:farmodo/core/extension/dynamic_size_extension.dart';
import 'package:farmodo/core/theme/app_colors.dart';
import 'package:flutter/material.dart';

class TaskTextField extends StatelessWidget {
  const TaskTextField({
    super.key,
    required this.controller,
    required this.hintText,
  });

  final TextEditingController controller;
  final String hintText;
  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      textCapitalization: TextCapitalization.words,
      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
        color: AppColors.textPrimary,
        fontSize: context.dynamicHeight(0.018)
      ),
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: Theme.of(context).textTheme.bodyMedium?.copyWith(
          color: AppColors.textSecondary,
        ),
        filled: true,
        fillColor: AppColors.surface,
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(context.dynamicWidth(0.04)),
          borderSide: BorderSide(color: AppColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(context.dynamicWidth(0.04)),
          borderSide: BorderSide(color: AppColors.primary, width: context.dynamicWidth(0.005)),
        ),
      ),
    );
  }
}