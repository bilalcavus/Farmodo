import 'package:farmodo/core/extension/dynamic_size_extension.dart';
import 'package:farmodo/core/theme/app_colors.dart';
import 'package:farmodo/viewmodel/tasks/tasks_controller.dart';
import 'package:farmodo/viewmodel/timer/timer_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get_state_manager/src/rx_flutter/rx_obx_widget.dart';
import 'package:hugeicons/hugeicons.dart';

class RecentTasks extends StatelessWidget {
  const RecentTasks({
    super.key,
    required this.tasksController,
    required this.timerController,
  });

  final TasksController tasksController;
  final TimerController timerController;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (tasksController.isLoading.value) {
        return Center(child: CircularProgressIndicator());
      } else if (tasksController.userTasks.isEmpty) {
        return Center(
          child: Text(
            'No tasks yet',
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  color: AppColors.textSecondary,
                ),
          ),
        );
      } else {
        final itemCount = tasksController.userTasks.length;
        final crossAxisCount = 2;
        final spacing = context.dynamicWidth(0.03);
        final horizontalPadding = context.dynamicWidth(0.05);

        return Padding(
          padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
          child: GridView.builder(
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: crossAxisCount,
              crossAxisSpacing: spacing,
              mainAxisSpacing: spacing,
              childAspectRatio: 2,
            ),
            itemCount: itemCount,
            itemBuilder: (context, index) {
              final task = tasksController.userTasks[index];
              return Container(
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppColors.border),
                ),
                child: ListTile(
                  dense: true,
                  title: Text(
                    task.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                  ),
                  subtitle: Text(
                    '${task.duration} min',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: AppColors.textSecondary,
                        ),
                  ),
                  // leading: CircleAvatar(
                  //   backgroundColor: AppColors.primaryOpacity,
                  //   child: Icon(
                  //     HugeIcons.strokeRoundedTask01,
                  //     color: Colors.white,
                  //     size: context.dynamicHeight(0.025),
                  //   ),
                  // ),
                  trailing: InkWell(
                    onTap: () {
                      tasksController.selectTask(index, task.duration, context);
                      timerController.startTimer();
                    },
                    child: CircleAvatar(
                      backgroundColor: AppColors.danger,
                      child: Icon(
                        HugeIcons.strokeRoundedPlay,
                        color: Colors.white,
                        size: context.dynamicHeight(0.025),
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        );
      }
    });
  }
}


