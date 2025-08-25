import 'package:farmodo/feature/farm/viewmodel/farm_controller.dart';
import 'package:flutter/material.dart';

class RefreshButton extends StatelessWidget {
  const RefreshButton({
    super.key,
    required this.farmController,
    required this.icon,
    required this.toolTip,
    required this.onTap,
  });

  final FarmController farmController;
  final IconData icon;
  final String toolTip;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: onTap,
      icon: Icon(icon),
      tooltip: toolTip
    );
  }
}