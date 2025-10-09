import 'package:farmodo/core/theme/app_colors.dart';
import 'package:farmodo/core/utility/extension/dynamic_size_extension.dart';
import 'package:flutter/material.dart';

class FilterChipWidget extends StatelessWidget {
  const FilterChipWidget({
    super.key,
    required this.label,
    required this.onTap,
    required this.isSelected,
  });

  final String label;
  final VoidCallback onTap;
  final bool isSelected;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Padding(
      padding: EdgeInsets.only(right: context.dynamicWidth(0.02)),
      child: FilterChip(
        label: Text(
          label,
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
            color: isSelected ? Colors.white : isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
        selected: isSelected,
        onSelected: (bool selected) {
          onTap();
        },
        selectedColor: AppColors.primary,
        checkmarkColor: Colors.white,
        backgroundColor: isDark ? AppColors.darkSurface : AppColors.lightSurface,
        side: BorderSide(
          color: isSelected ? AppColors.primary : isDark ? AppColors.darkBorder : AppColors.lightBorder,
          width: isSelected ? 2 : 1,
        ),
        padding: EdgeInsets.symmetric(
          horizontal: context.dynamicWidth(0.03), 
          vertical: context.dynamicHeight(0.01)
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
      ),
    );
  }
}