import 'package:farmodo/core/extension/dynamic_size_extension.dart';
import 'package:farmodo/core/theme/app_colors.dart';
import 'package:farmodo/data/models/user_task_model.dart';
import 'package:farmodo/feature/tasks/viewmodel/tasks_controller.dart';
import 'package:farmodo/feature/tasks/viewmodel/timer_controller.dart';
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
      if (tasksController.loadingStates[LoadingType.active] ?? false) {
        return Center(child: CircularProgressIndicator());
      } else if (tasksController.activeUserTasks.isEmpty) {
        return Center(
          child: Text(
            'No tasks yet',
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  color: AppColors.textSecondary,
                ),
          ),
        );
      } else {
        final itemCount = tasksController.activeUserTasks.length;
        final crossAxisCount = 2;
        final spacing = context.dynamicWidth(0.03);
        final horizontalPadding = context.dynamicWidth(0.035);

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
                padding: EdgeInsets.symmetric(horizontal: context.dynamicWidth(0.06)),
                child: Text(
                  "Recent Tasks",
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: Colors.grey.shade800,
                      ),
                ),
              ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
              child: GridView.builder(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: crossAxisCount,
                  crossAxisSpacing: spacing,
                  mainAxisSpacing: spacing,
                  childAspectRatio: 1.0,
                ),
                itemCount: itemCount,
                itemBuilder: (context, index) {
                  final task = tasksController.activeUserTasks[index];
                  return Container(
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Padding(
                      padding: EdgeInsets.all(context.dynamicHeight(0.01)),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _taskTitle(context, task),
                          TaskFeatures(task: task, text: '🔗 ${task.focusType} '),
                          TaskFeatures(task: task, text: '⏰ ${task.duration} min '),
                          TaskFeatures(task: task, text: '⏰ ${task.breakDuration} min break time'),
                          TaskFeatures(task: task, text: '⭐️ ${task.xpReward} XP Gain '),
                          TaskFeatures(task: task, text: '✅ ${task.completedSessions} / ${task.totalSessions} sessions completed'),
                          SizedBox(height: context.dynamicHeight(0.0)),
                          Obx((){
                    return InkWell(
                      onTap: () {
                        final bool isThisTaskSelected = tasksController.selctedTaskIndex.value == index;
                        if (timerController.isRunning.value && isThisTaskSelected) {
                          timerController.pauseTimer();
                          return;
                        }
                        if (index >= tasksController.activeUserTasks.length) {
                          return;
                        }
                        if (!isThisTaskSelected || 
                            timerController.totalSeconds.value == 0 ||
                            timerController.secondsRemaining.value == timerController.totalSeconds.value) {
                          tasksController.selectTask(index, tasksController.activeUserTasks[index]);
                        }
                        
                        timerController.startTimer();
                      },
                      child: 
                      CircleAvatar(
                        radius: context.dynamicHeight(0.02),
                        backgroundColor: (timerController.isRunning.value && tasksController.selctedTaskIndex.value == index)
                            ? AppColors.danger
                            : AppColors.textPrimary,
                        child: Icon(
                          timerController.isRunning.value && tasksController.selctedTaskIndex.value == index ? 
                          HugeIcons.strokeRoundedPause : HugeIcons.strokeRoundedPlay,
                          color: Colors.white,
                          size: context.dynamicHeight(0.025),
                        ),
                      ),
                    );
                                        }
                                        ),
                        ],
                      ),
                    )
                    // _listTile(task, context, index),
                  );
                },
              ),
            ),
          ],
        );
      }
    });
  }

  Widget _taskTitle(BuildContext context, UserTaskModel task) {
    return Text(task.title, style: Theme.of(context).textTheme.bodyMedium?.copyWith(
      fontWeight: FontWeight.w600,
      color: AppColors.textPrimary
    ));
  }
}

class TaskFeatures extends StatelessWidget {
  const TaskFeatures({
    super.key,
    required this.task, required this.text,
  });

  final UserTaskModel task;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(text, overflow: TextOverflow.ellipsis,
      style: Theme.of(context).textTheme.labelSmall?.copyWith(
      color: AppColors.textSecondary,
    ),);
  }
}


