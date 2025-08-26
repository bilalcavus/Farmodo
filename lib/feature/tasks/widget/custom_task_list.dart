
import 'package:farmodo/core/theme/app_colors.dart';
import 'package:farmodo/core/utility/extension/dynamic_size_extension.dart';
import 'package:farmodo/data/models/user_task_model.dart';
import 'package:farmodo/feature/tasks/viewmodel/tasks_controller.dart';
import 'package:farmodo/feature/tasks/viewmodel/timer_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get_rx/src/rx_types/rx_types.dart';
import 'package:get/get_state_manager/src/rx_flutter/rx_obx_widget.dart';

class CustomTaskList extends StatelessWidget {
  const CustomTaskList({
    super.key,
    required this.taskController,
    required this.loadingType,
    required this.listType, 
    required this.timerController,
    required this.scrollController,
  });

  final TasksController taskController;
  final TimerController timerController;
  final LoadingType loadingType;
  final RxList<UserTaskModel> listType;
  final ScrollController scrollController;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: context.dynamicHeight(0.9),
      child: Obx((){
        final bool isLoading = taskController.loadingStates[loadingType] == true;
        if (isLoading && listType.isEmpty) {
          return Center(child: CircularProgressIndicator());
        } else if (listType.isEmpty) {
          return Center(child: Text('No tasks yet', style: Theme.of(context).textTheme.labelLarge?.copyWith(color: AppColors.textSecondary)));
        }
          else {
            return Stack(
              children: [
                TaskList(
                  listType: listType,
                  taskController: taskController,
                  timerController: timerController,
                  scrollController: scrollController
                ),
                if (isLoading)
                  Align(
                    alignment: Alignment.bottomCenter,
                    child: Padding(
                      padding: EdgeInsets.symmetric(vertical: context.dynamicHeight(0.015)),
                      child: CircularProgressIndicator(),
                    ),
                  )
              ],
            );
        }
    }));
  }
}

class TaskList extends StatelessWidget {
  const TaskList({
    super.key,
    required this.listType,
    required this.taskController,
    required this.timerController,
    required this.scrollController,
  });

  final RxList<UserTaskModel> listType;
  final TasksController taskController;
  final TimerController timerController;
  final ScrollController scrollController;

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      controller: scrollController,
      shrinkWrap: true,
      itemCount: listType.length,
      itemBuilder: (context, index) {
        final task = listType[index];
        return Container(
          margin: EdgeInsets.symmetric(
            horizontal: context.dynamicWidth(0.05),
            vertical: context.dynamicHeight(0.008)
            ),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(context.dynamicHeight(0.02)),
            border: Border.all(color: AppColors.border),
        ),
          child: ListTile(
          title: Text(
            task.title,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: AppColors.textPrimary, fontWeight: FontWeight.bold)),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('🔗 ${task.focusType}'),
              Text('⏰ ${task.duration} min'),
              Text('⭐️ ${task.xpReward} XP'),
            ],
          ),
          trailing: !task.isCompleted ? Obx(() => _taskListButton(index, task, context)) : null
        ),
      );
    });
  }

  ElevatedButton _taskListButton(int index, UserTaskModel task, BuildContext context) {
    return ElevatedButton(
      onPressed: () {
        final bool isSelected = taskController.selctedTaskIndex.value == index;
        final bool isRunning = timerController.isRunning.value;
        if (isRunning && isSelected) {
          timerController.pauseTimer();
          return;
        }
        if (timerController.totalSeconds.value == 0 ||
            timerController.secondsRemaining.value == timerController.totalSeconds.value) {
          taskController.selectTask(index, task);
        }
        timerController.startTimer();
      },
      style: ElevatedButton.styleFrom(
      backgroundColor: (timerController.isRunning.value && (taskController.selctedTaskIndex.value == index))
        ? AppColors.danger
        : AppColors.primary,
      foregroundColor: Colors.white,
      shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(14)),
      padding: const EdgeInsets.symmetric(horizontal: 44, vertical: 16),
      elevation: 0,
    ),
      child: Text(
        timerController.isRunning.value && taskController.selctedTaskIndex.value == index ? 'Running' : 'Start',
        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
        color: Colors.white,
        fontWeight: FontWeight.w700,
        ),
      ));
  }
}