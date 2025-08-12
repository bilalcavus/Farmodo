import 'package:farmodo/core/extension/dynamic_size_extension.dart';
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
        color: Colors.black,
        fontSize: context.dynamicHeight(0.018)
      ),
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: Theme.of(context).textTheme.bodyMedium?.copyWith(
          color: Colors.black.withAlpha(36)
        ),
        filled: true,
        fillColor: Colors.black.withAlpha(7),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(context.dynamicWidth(0.04)),
          borderSide: BorderSide.none
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(context.dynamicWidth(0.04)),
          borderSide: BorderSide(color: const Color(0xFFB983FF), width: context.dynamicWidth(0.005)),
        ),
      ),
    );
  }
}