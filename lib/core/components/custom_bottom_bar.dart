import 'package:farmodo/core/theme/app_colors.dart';
import 'package:farmodo/core/utility/extension/dynamic_size_extension.dart';
import 'package:farmodo/core/utility/extension/ontap_extension.dart';
import 'package:flutter/material.dart';

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
            color: Colors.black.withAlpha(15),
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
              icon: Icons.timer,
              label: 'Timer'
            ),
          ),
          Expanded(
            child: _buildNavItem(
              context,
              index: 1,
              icon: Icons.list_sharp,
              label: 'Tasks'
            ),
          ),
          Expanded(
            child: _buildNavItem(
              context,
              index: 2,
              icon: Icons.pets,
              label: 'Farm'
            ),
          ),
          Expanded(
            child: _buildNavItem(
              context,
              index: 3,
              icon: Icons.leaderboard,
              label: 'Leaders'
            ),
          ),
          Expanded(
            child: _buildNavItem(
              context,
              index: 4,
              icon: Icons.account_circle,
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
    return Container(
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
            color: isSelected ? const Color.fromARGB(255, 255, 26, 26) : AppColors.textSecondary,
            size: context.dynamicWidth(0.055),
          ),
          Text(
            label,
            style: TextStyle(
              color:  isSelected ? const Color.fromARGB(255, 255, 26, 26) : AppColors.textSecondary,
              fontSize: context.dynamicHeight(0.012),
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
            ),
          ),
        ],
      ),
    ).onTap(onTapOverride ?? () => onTap(index));
  }
}