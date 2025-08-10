import 'package:farmodo/core/extension/dynamic_size_extension.dart';
import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:iconsax/iconsax.dart';


class CustomBottomNavigation extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const CustomBottomNavigation({
    super.key, 
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: context.dynamicHeight(0.08),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          Expanded(
            child: _buildNavItem(
              context,
              index: 0,
              icon: HugeIcons.strokeRoundedHome01,
            ),
          ),
          Expanded(
            child: _buildNavItem(
              context,
              index: 1,
              icon: Iconsax.element_4,
            ),
          ),
          Expanded(
            child: _buildNavItem(
              context,
              index: 2,
              icon: Iconsax.shop,
            ),
          ),
          Expanded(
            child: _buildNavItem(
              context,
              index: 3,
              icon: HugeIcons.strokeRoundedUser,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavItem(
    BuildContext context, {
    required int index,
    required IconData icon,
    String? label,
    VoidCallback? onTapOverride,
  }) {
    final isSelected = currentIndex == index;
    return GestureDetector(
      onTap: onTapOverride ?? () => onTap(index),
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: context.dynamicWidth(0.02),
          // vertical: context.dynamicHeight(0.008),
        ),
        decoration: BoxDecoration(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            isSelected ? 
            Container(
              height: context.dynamicHeight(0.05),
              width: context.dynamicWidth(0.12),
              decoration: BoxDecoration(
                color: Color.fromARGB(69, 199, 199, 199),
                borderRadius: BorderRadius.circular(context.dynamicHeight(0.015))
              ),
              child: Icon(
                icon,
                color: Colors.black,
                size: context.dynamicWidth(0.07),
              ),
            ) : Icon(
                icon,
                color: Colors.black,
                size: context.dynamicWidth(0.07),
              ),
          ],
        ),
      ),
    );
  }
}