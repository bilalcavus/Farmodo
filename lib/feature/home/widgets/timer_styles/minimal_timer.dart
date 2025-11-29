import 'package:flutter/material.dart';
import 'package:farmodo/core/utility/extension/dynamic_size_extension.dart';
import 'package:farmodo/core/theme/app_colors.dart';

class MinimalTimer extends StatelessWidget {
  const MinimalTimer({
    super.key,
    required this.minutes,
    required this.seconds,
    required this.isActive,
    this.size,
  });

  final int minutes;
  final int seconds;
  final bool isActive;
  final double? size;

  @override
  Widget build(BuildContext context) {
    final timerSize = size ?? context.dynamicWidth(0.28);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Container(
      width: timerSize,
      height: timerSize,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: isDark ? AppColors.darkSurface : Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.3 : 0.08),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Minutes
            Text(
              minutes.toString().padLeft(2, '0'),
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
                height: 1.0,
                color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
              ),
            ),
            
            // Separator
            Container(
              width: timerSize * 0.4,
              height: 2,
              margin: EdgeInsets.symmetric(vertical: context.dynamicHeight(0.005)),
              color: isDark 
                ? AppColors.darkTextPrimary.withOpacity(0.3)
                : AppColors.lightTextPrimary.withOpacity(0.3),
            ),
            
            // Seconds
            Text(
              seconds.toString().padLeft(2, '0'),
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
                height: 1.0,
                color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

