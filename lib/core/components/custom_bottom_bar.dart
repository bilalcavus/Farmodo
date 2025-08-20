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
        color: Colors.grey.shade300,
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
              label: 'Home'
            ),
          ),
          Expanded(
            child: _buildNavItem(
              context,
              index: 1,
              icon: Iconsax.note_favorite,
              label: 'Tasks'
            ),
          ),
          Expanded(
            child: _buildNavItem(
              context,
              index: 2,
              icon: Iconsax.shop,
              label: 'Store'
            ),
          ),
          Expanded(
            child: _buildNavItem(
              context,
              index: 3,
              icon: HugeIcons.strokeRoundedUser,
              label: 'Profile'
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
    required String label,
    VoidCallback? onTapOverride,
  }) {
    final isSelected = currentIndex == index;
    return GestureDetector(
      onTap: onTapOverride ?? () => onTap(index),
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: context.dynamicWidth(0.04),
          // vertical: context.dynamicHeight(0.008),
        ),
        decoration: BoxDecoration(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: isSelected ? const Color(0xff1A5CFF) : null,
              size: context.dynamicWidth(0.06),
            ),
            SizedBox(height: context.dynamicHeight(0.005)),
            Text(
              label,
              style: TextStyle(
                color:  isSelected ? const Color(0xff1A5CFF) : null,
                fontSize: context.dynamicHeight(0.014),
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}