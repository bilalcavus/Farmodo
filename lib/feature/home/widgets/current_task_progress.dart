import 'package:farmodo/core/theme/app_colors.dart';
import 'package:farmodo/core/utility/extension/dynamic_size_extension.dart';
import 'package:farmodo/core/utility/extension/sized_box_extension.dart';
import 'package:farmodo/feature/tasks/viewmodel/tasks_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:percent_indicator/percent_indicator.dart';

class CurrentTaskProgress extends StatelessWidget {
  final TasksController tasksController;

  const CurrentTaskProgress({
    super.key,
    required this.tasksController,
  });

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final selectedIndex = tasksController.selctedTaskIndex.value;
      if (selectedIndex == -1 || 
          tasksController.activeUserTasks.isEmpty ||
          selectedIndex >= tasksController.activeUserTasks.length) {
        return SizedBox.shrink();
      }

      final task = tasksController.activeUserTasks[selectedIndex];
      final progress = task.completedSessions / task.totalSessions;
      
      return Container(
        margin: EdgeInsets.symmetric(horizontal: context.dynamicWidth(0.04)),
        padding: EdgeInsets.all(context.dynamicHeight(0.02)),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(context.dynamicHeight(0.03)),
          border: Border.all(color: AppColors.border),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: context.dynamicWidth(0.025),
                    vertical: context.dynamicHeight(0.005),
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(context.dynamicHeight(0.02)),
                  ),
                  child: Text(
                    'Current Task',
                    style: Theme.of(context).textTheme.labelMedium?.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                ),
                Spacer(),
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: context.dynamicWidth(0.025),
                    vertical: context.dynamicHeight(0.005),
                  ),
                  decoration: BoxDecoration(
                    color:  AppColors.danger.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    task.focusType,
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: AppColors.danger,
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                ),
              ],
            ),
            context.dynamicHeight(0.01).height,
            Text(
              task.title,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            context.dynamicHeight(0.01).height,
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Session Progress',
                        style: Theme.of(context).textTheme.labelLarge?.copyWith(
                              color: AppColors.textSecondary,
                              fontWeight: FontWeight.w500,
                            ),
                      ),
                      SizedBox(height: context.dynamicHeight(0.008)),
                      LinearPercentIndicator(
                        padding: EdgeInsets.zero,
                        lineHeight: 8,
                        percent: progress.clamp(0.0, 1.0),
                        backgroundColor: AppColors.border,
                        progressColor: _getProgressColor(progress),
                        barRadius: Radius.circular(4),
                        animation: true,
                        animationDuration: 500,
                      ),
                      SizedBox(height: context.dynamicHeight(0.008)),
                      Text(
                        '${task.completedSessions}/${task.totalSessions} sessions completed',
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                              color: AppColors.textSecondary,
                              fontWeight: FontWeight.w500,
                            ),
                      ),
                    ],
                  ),
                ),
                SizedBox(width: context.dynamicWidth(0.04)),
                CircularPercentIndicator(
                  radius: context.dynamicHeight(0.035),
                  lineWidth: 6,
                  percent: progress.clamp(0.0, 1.0),
                  center: Text(
                    '${(progress * 100).round()}%',
                    style: Theme.of(context).textTheme.labelLarge?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                  ),
                  backgroundColor: AppColors.border,
                  progressColor: _getProgressColor(progress),
                  animation: true,
                  animationDuration: 500,
                ),
              ],
            ),
          ],
        ),
      );
    });
  }

  Color _getProgressColor(double progress) {
    if (progress < 0.33) {
      return AppColors.danger;
    } else if (progress < 0.66) {
      return AppColors.primary;
    } else {
      return AppColors.secondary;
    }
  }
}
