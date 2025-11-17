import 'dart:ui';

import 'package:easy_localization/easy_localization.dart';
import 'package:farmodo/core/theme/app_container_styles.dart';
import 'package:farmodo/core/utility/extension/dynamic_size_extension.dart';
import 'package:farmodo/feature/store/viewmodel/reward_controller.dart';
import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';

class CategorySelector extends StatelessWidget {
  const CategorySelector({
    super.key, 
    required this.selectedCategory, 
    required this.onCategoryChanged,
  });

  final StoreCategory selectedCategory;
  final Function(StoreCategory) onCategoryChanged;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: context.dynamicWidth(0.04)),
      child: Container(
        decoration: AppContainerStyles.glassContainer(context),
        child: Row(
          children: [
            CategoryButton(
              category: StoreCategory.animals,
              label: 'store.category_animals'.tr(),
              icon: Icons.pets,
              isSelected: selectedCategory == StoreCategory.animals,
              onTap: () => onCategoryChanged(StoreCategory.animals),
            ),
            CategoryButton(
              category: StoreCategory.coins,
              label: 'store.category_coins'.tr(),
              icon: HugeIcons.strokeRoundedDollarCircle, 
              isSelected: selectedCategory == StoreCategory.coins,
              onTap: () => onCategoryChanged(StoreCategory.coins),
            ),
            CategoryButton(
              category: StoreCategory.lotties,
              label: 'store.category_lotties'.tr(),
              icon: Icons.animation, 
              isSelected: selectedCategory == StoreCategory.lotties,
              onTap: () => onCategoryChanged(StoreCategory.lotties),
            ),
          ],
        ),
      ),
    );
  }
}

class CategoryButton extends StatelessWidget {
  const CategoryButton({
    super.key,
    required this.category,
    required this.label,
    required this.icon,
    required this.isSelected,
    required this.onTap
  });

  final StoreCategory category;
  final String label;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: EdgeInsets.symmetric(
            vertical: context.dynamicHeight(0.015),
            horizontal: context.dynamicWidth(0.02),
          ),
          decoration: BoxDecoration(
            color: isSelected
                ? (isDark ? Colors.green.shade700 : Colors.green)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(context.dynamicHeight(0.015)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                color: isSelected
                    ? Colors.white
                    : (isDark ? Colors.grey.shade400 : Colors.grey.shade800),
                size: context.dynamicHeight(0.025),
              ),
              SizedBox(height: context.dynamicHeight(0.005)),
              Text(
                label,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: isSelected
                      ? Colors.white
                      : (isDark ? Colors.grey.shade400 : Colors.grey.shade800),
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}