import 'package:farmodo/core/theme/app_colors.dart';
import 'package:farmodo/core/utility/extension/dynamic_size_extension.dart';
import 'package:farmodo/core/utility/extension/ontap_extension.dart';
import 'package:farmodo/data/models/user_task_model.dart';
import 'package:farmodo/feature/tasks/viewmodel/tasks_controller.dart';
import 'package:farmodo/feature/tasks/viewmodel/timer_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
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
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const RecentTaskHeader(),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: context.dynamicWidth(0.035)),
              child: GridView.builder(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: context.dynamicWidth(0.03),
                  mainAxisSpacing: context.dynamicWidth(0.03),
                  childAspectRatio: 0.8,
                ),
                itemCount: tasksController.activeUserTasks.length,
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
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _taskTitle(context, task),
                          TaskFeatures(task: task, text: '🔗 ${task.focusType} '),
                          TaskFeatures(task: task, text: '⌛️ ${task.duration} min '),
                          TaskFeatures(task: task, text: '⏰ ${task.breakDuration} min break time'),
                          TaskFeatures(task: task, text: '⭐️ ${task.xpReward} XP Gain '),
                          TaskFeatures(task: task, text: '✅ ${task.completedSessions} / ${task.totalSessions} sessions completed'),
                          TimeEvent(tasksController: tasksController, timerController: timerController, index: index,),
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

class RecentTaskHeader extends StatelessWidget {
  const RecentTaskHeader({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: EdgeInsets.symmetric(horizontal: context.dynamicWidth(0.06)),
        child: Text(
          "Recent Tasks",
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
            color: Colors.grey.shade800,
          ),
        ),
      );
  }
}

class TimeEvent extends StatelessWidget {
  const TimeEvent({
    super.key,
    required this.tasksController,
    required this.timerController,
    required this.index,
  });

  final TasksController tasksController;
  final TimerController timerController;
  final int index;

  @override
  Widget build(BuildContext context) {
    return Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          TimeEventButton(
            tasksController: tasksController,
            timerController: timerController,
            index: index,
            isResetButton: false.obs,
            ),
          TimeEventButton(
            tasksController: tasksController,
            timerController: timerController,
            index: index,
            isResetButton: true.obs,
          ),
        ],
      );
  }
}

class TimeEventButton extends StatelessWidget {
  const TimeEventButton({
    super.key,
    required this.tasksController,
    required this.timerController,
    required this.index,
    required this.isResetButton
  });

  final TasksController tasksController;
  final TimerController timerController;
  final int index;
  final RxBool isResetButton;
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Obx((){
        final isSelected = tasksController.selctedTaskIndex.value == index;
        final isRunning = timerController.isRunning.value;
        return Icon(
          !isResetButton.value ?
            isRunning && isSelected ?
          HugeIcons.strokeRoundedPause : HugeIcons.strokeRoundedPlay 
          : HugeIcons.strokeRoundedRefresh ,
          color: isResetButton.value ? Colors.grey.shade800: 
        (isRunning && isSelected)
            ? AppColors.danger
            : AppColors.primary,
          size: context.dynamicHeight(0.02),
        ).onTap((){
          if(!isResetButton.value){
              if (isSelected && isRunning) {
                timerController.pauseTimer();
                return;
              }
              if (index >= tasksController.activeUserTasks.length) return;
              if (!isSelected || 
                timerController.totalSeconds.value == 0 ||
                timerController.secondsRemaining.value == timerController.totalSeconds.value) {
              tasksController.selectTask(index, tasksController.activeUserTasks[index]);
              }
            }
            isResetButton.value ? timerController.resetTimer() : timerController.startTimer();
        });
      }
      ),
    );
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


