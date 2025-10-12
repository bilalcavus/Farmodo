import 'package:easy_localization/easy_localization.dart';
import 'package:farmodo/core/theme/app_colors.dart';
import 'package:farmodo/core/utility/extension/dynamic_size_extension.dart';
import 'package:farmodo/core/utility/extension/sized_box_extension.dart';
import 'package:farmodo/feature/home/widgets/task_selector_box.dart';
import 'package:farmodo/feature/tasks/viewmodel/tasks_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart' hide Trans;
import 'package:kartal/kartal.dart';
import 'package:percent_indicator/percent_indicator.dart';

class CurrentTaskProgress extends StatefulWidget {
  final TasksController tasksController;

  const CurrentTaskProgress({
    super.key,
    required this.tasksController,
  });

  @override
  State<CurrentTaskProgress> createState() => _CurrentTaskProgressState();
}

class _CurrentTaskProgressState extends State<CurrentTaskProgress> {
  late final TextEditingController _controller;
  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final selectedIndex = widget.tasksController.selctedTaskIndex.value;
      final isUsingDefault = widget.tasksController.isUsingDefaultTask.value;
      
      // Default task kullanılıyorsa, default task bilgilerini göster
      if (isUsingDefault) {
        final task = widget.tasksController.defaultTask;
        final currentSession = widget.tasksController.defaultTaskCurrentSession.value;
        final progress = currentSession / task.totalSessions;
        return _buildTaskCard(context, task, progress, currentSession);
      }
      
      // Custom task seçilmişse, o task'ın bilgilerini göster
      if (selectedIndex != -1 && 
          widget.tasksController.activeUserTasks.isNotEmpty &&
          selectedIndex < widget.tasksController.activeUserTasks.length) {
        final task = widget.tasksController.activeUserTasks[selectedIndex];
        final progress = task.completedSessions / task.totalSessions;
        return _buildTaskCard(context, task, progress, task.completedSessions);
      }

      // Hiçbir task seçilmemişse, task seçim kutusunu göster
      return CurrentTaskBox(
          tasksController: widget.tasksController, controller: _controller);
    });
  }

  Widget _buildTaskCard(BuildContext context, task, double progress, int completedSessions) {
      return Container(
        width: context.dynamicWidth(0.85),
        margin: EdgeInsets.symmetric(horizontal: context.dynamicWidth(0.04)),
        padding: context.padding.normal,
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: context.border.normalBorderRadius,
          border: Border.all(color: AppColors.border),
          
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(15),
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
                    color: AppColors.primary.withAlpha(25),
                    borderRadius: BorderRadius.circular(context.dynamicHeight(0.02)),
                  ),
                  child: Text(
                    'home.current_task_label'.tr(),
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
                    color:  focusTypeColor(task.focusType).withAlpha(25),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    task.focusType,
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: focusTypeColor(task.focusType),
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
            Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'home.session_progress'.tr(),
                      style: Theme.of(context).textTheme.labelLarge?.copyWith(
                            color: AppColors.textSecondary,
                            fontWeight: FontWeight.w500,
                          ),
                    ),
                    Text('${(progress * 100).round()}%',
                      style: Theme.of(context).textTheme.labelLarge?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ],
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
                  '$completedSessions/${task.totalSessions} ${'home.sessions_completed'.tr()}',
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.w500,
                      ),
                ),
              ],
            ),
          ],
        ),
      );
  }

  Color _getProgressColor(double progress) {
    if (progress < 0.33) {
      return AppColors.secondary;
    } else if (progress < 0.66) {
      return AppColors.textPrimary;
    } else {
      return AppColors.secondary;
    }
  }

  Color focusTypeColor(String focus) {
  switch(focus) {
    case 'General':
      return Colors.green;
    case 'Work':
      return Colors.red;
    case 'Study':
      return Colors.amber;
    case 'Play': 
      return Colors.indigo;
    case 'Sport':
      return Colors.pink;
    default:
      return Colors.green;
  }
}
}
