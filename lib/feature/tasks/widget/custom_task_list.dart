
import 'package:easy_localization/easy_localization.dart';
import 'package:farmodo/core/theme/app_colors.dart';
import 'package:farmodo/core/theme/app_container_styles.dart';
import 'package:farmodo/core/utility/extension/dynamic_size_extension.dart';
import 'package:farmodo/core/utility/extension/ontap_extension.dart';
import 'package:farmodo/core/utility/extension/sized_box_extension.dart';
import 'package:farmodo/data/models/user_task_model.dart';
import 'package:farmodo/feature/tasks/viewmodel/tasks_controller.dart';
import 'package:farmodo/feature/tasks/viewmodel/timer_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get_rx/src/rx_types/rx_types.dart';
import 'package:get/get_state_manager/src/rx_flutter/rx_obx_widget.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:kartal/kartal.dart';

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
    return Obx(() {
      final bool isLoading = taskController.loadingStates[loadingType] == true;
      
      if (isLoading && listType.isEmpty) {
        return _buildLoadingState();
      } else if (listType.isEmpty) {
        return _buildEmptyState(context);
      } else {
        return _buildTaskList(context, isLoading);
      }
    });
  }

  Widget _buildLoadingState() {
    return const Center(
      child: CircularProgressIndicator(
        color: AppColors.primary,
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.task_alt_outlined,
            size: 64,
            color: AppColors.textSecondary.withAlpha(125),
          ),
          const SizedBox(height: 16),
          Text(
            'home.no_tasks_yet_simple'.tr(),
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'home.select_or_create_task'.tr(),
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppColors.textSecondary.withAlpha(180),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTaskList(BuildContext context, bool isLoading) {
    return Stack(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('tasks.showing_last_10'.tr(), style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Colors.grey.shade500
            )),
          ],
        ),
        ListView.builder(
          controller: scrollController,
          padding: EdgeInsets.symmetric(
            horizontal: context.dynamicWidth(0.04),
            vertical: context.dynamicHeight(0.02),
          ),
          itemCount: listType.length,
          itemBuilder: (context, index) {
            final task = listType[index];
            return _buildTaskCard(context, task, index);
          },
        ),
        if (isLoading) _buildLoadingIndicator(),
      ],
    );
  }

  Widget _buildTaskCard(BuildContext context, UserTaskModel task, int index) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: context.dynamicHeight(0.008), horizontal: context.dynamicWidth(0.002)),
      padding: context.padding.normal,
      decoration: AppContainerStyles.glassContainer(context),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  task.title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                context.dynamicHeight(0.008).height,
                Row(
                  children: [
                    Container(
                      padding: context.padding.horizontalLow,
                      decoration: BoxDecoration(
                        color: focusTypeColor(task.focusType).withAlpha(75),
                        borderRadius: BorderRadius.circular(context.dynamicHeight(0.008))
                      ),
                      child: Text('#${task.focusType}',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: focusTypeColor(task.focusType),
                          fontWeight: FontWeight.bold
                      ))),
                    context.dynamicHeight(0.01).height,
                _buildTaskMetaInfo(context, task),
                  ],
                ),
              ],
            ),
          ),
          task.isCompleted
          ? Padding(
            padding: context.padding.low,
            child: Row(
              children: [
                Icon(HugeIcons.strokeRoundedCheckmarkBadge01, size: context.dynamicHeight(0.03), color: AppColors.success),
                context.dynamicWidth(0.01).width,
                IconButton(onPressed: () async {
                  await taskController.deleteUserTask(task.id);
                }, icon: Icon(HugeIcons.strokeRoundedDelete01, color: AppColors.danger, size: context.dynamicHeight(0.025)))
              ],
            )) 
          : SizedBox.shrink(),
          if (!task.isCompleted) _buildActionButton(context, task, index),
        ],
      ),
    );
  }


  Widget _buildTaskMetaInfo(BuildContext context, UserTaskModel task) {
    return Row(
      children: [
        _buildMetaItem(context, Icons.timer_sharp, '${task.duration} ${'tasks.min'.tr()}', AppColors.textSecondary),
        context.dynamicWidth(0.01).width, 
        _buildMetaItem(context, Icons.star_rounded, '${task.xpReward} XP', Colors.amber),
      ],
    );
  }

  Widget _buildMetaItem(BuildContext context, IconData icon, String text, Color iconColor) {
    return Padding(
      padding: context.padding.low,
      child: Row(
        children: [
          Icon(
            icon,
            size: context.dynamicHeight(0.018),
            color: iconColor
          ),
          Text(
            text,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(

              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(BuildContext context, UserTaskModel task, int index) {
    return Obx(() {
      final bool isSelected = taskController.selctedTaskIndex.value == index;
      final bool isRunning = timerController.isRunning.value;

      return Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Icon(
             (isRunning && isSelected) 
                ? HugeIcons.strokeRoundedPause
                : HugeIcons.strokeRoundedPlay,
            color: (isRunning && isSelected) 
                ? AppColors.danger
                : AppColors.primary,
            size: context.dynamicHeight(0.025),
          ).onTap(() => _handleTaskAction(task, index, isSelected, isRunning)),
          IconButton(
            onPressed: () async {
            if (taskController.selctedTaskIndex.value == index) {
              timerController.resetTimer();
            } else if (taskController.errorMessage.value.isNotEmpty) {
              ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(taskController.errorMessage.value))
              );
            }
            await taskController.deleteUserTask(task.id);
            taskController.selctedTaskIndex.value = -1;
            taskController.isUsingDefaultTask.value = true;
            taskController.selectDefaultTask();
          },  
            icon: Icon(HugeIcons.strokeRoundedDelete01, color: AppColors.danger, size: context.dynamicHeight(0.025)))
        ],
      );
    });
  }

  void _handleTaskAction(UserTaskModel task, int index, bool isSelected, bool isRunning) {
    if (isRunning && isSelected) {
      timerController.pauseTimer();
      return;
    }
    
    // if (timerController.totalSeconds.value == 0 ||
    //     timerController.secondsRemaining.value == timerController.totalSeconds.value) {
    //   taskController.selectTask(index, task);
    // }
    taskController.selectTask(index, task);
    timerController.startTimer();
  }

  Widget _buildLoadingIndicator() {
    return Align(
      alignment: Alignment.bottomCenter,
      child: Container(
        margin: const EdgeInsets.all(16),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: AppColors.border.withAlpha(25),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: const SizedBox(
          width: 20,
          height: 20,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            color: AppColors.primary,
          ),
        ),
      ),
    );
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