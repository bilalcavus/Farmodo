
import 'package:farmodo/core/theme/app_colors.dart';
import 'package:farmodo/core/utility/extension/dynamic_size_extension.dart';
import 'package:farmodo/core/utility/extension/sized_box_extension.dart';
import 'package:farmodo/data/models/user_task_model.dart';
import 'package:farmodo/feature/tasks/viewmodel/tasks_controller.dart';
import 'package:farmodo/feature/tasks/viewmodel/timer_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get_rx/src/rx_types/rx_types.dart';
import 'package:get/get_state_manager/src/rx_flutter/rx_obx_widget.dart';
import 'package:hugeicons/hugeicons.dart';

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
            color: AppColors.textSecondary.withOpacity(0.5),
          ),
          const SizedBox(height: 16),
          Text(
            'No tasks yet',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Create your first task to get started',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppColors.textSecondary.withOpacity(0.7),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTaskList(BuildContext context, bool isLoading) {
    return Stack(
      children: [
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
      margin: EdgeInsets.only(bottom: context.dynamicHeight(0.015)),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.border.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.all(context.dynamicHeight(0.02)),
        child: Row(
          children: [
            _buildTaskInfo(context, task),
            const Spacer(),
            if (!task.isCompleted) _buildActionButtons(context, task, index),
          ],
        ),
      ),
    );
  }

  Widget _buildTaskInfo(BuildContext context, UserTaskModel task) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            task.title,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w600,
            ),
          ),
          context.dynamicHeight(0.01).height,
          _buildTaskMetaInfo(context, task),
        ],
      ),
    );
  }

  Widget _buildTaskMetaInfo(BuildContext context, UserTaskModel task) {
    return Row(
      children: [
        _buildMetaItem(context, Icons.link, task.focusType),
        context.dynamicWidth(0.01).width,
        _buildMetaItem(context, Icons.timer_outlined, '${task.duration} min'),
        context.dynamicWidth(0.01).width, 
        _buildMetaItem(context, Icons.star_outline, '${task.xpReward} XP'),
      ],
    );
  }

  Widget _buildMetaItem(BuildContext context, IconData icon, String text) {
    return Column(
      children: [
        Icon(
          icon,
          size: 16,
          color: AppColors.textSecondary,
        ),
        Text(
          text,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: AppColors.textSecondary,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons(BuildContext context, UserTaskModel task, int index) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _buildActionButton(context, task, index, false),
        context.dynamicWidth(0.01).width,
        _buildActionButton(context, task, index, true),
      ],
    );
  }

  Widget _buildActionButton(BuildContext context, UserTaskModel task, int index, bool isResetButton) {
    return Obx(() {
      final bool isSelected = taskController.selctedTaskIndex.value == index;
      final bool isRunning = timerController.isRunning.value;

      return InkWell(
        onTap: () => _handleTaskAction(task, index, isSelected, isRunning, isResetButton),
        child: CircleAvatar(
          radius: context.dynamicHeight(0.02),
          backgroundColor: isResetButton 
            ? Colors.grey.shade200
            : (isRunning && isSelected) 
              ? AppColors.danger
              : AppColors.primary,
          child: Icon(
            isResetButton 
              ? HugeIcons.strokeRoundedRefresh
              : (isRunning && isSelected) 
                ? HugeIcons.strokeRoundedPause
                : HugeIcons.strokeRoundedPlay,
            color: isResetButton ? Colors.black : Colors.white,
            size: context.dynamicHeight(0.025),
          ),
        ),
      );
    });
  }

  void _handleTaskAction(UserTaskModel task, int index, bool isSelected, bool isRunning, bool isResetButton) {
    if (isResetButton) {
      timerController.resetTimer();
      return;
    }

    if (isRunning && isSelected) {
      timerController.pauseTimer();
      return;
    }
    
    if (timerController.totalSeconds.value == 0 ||
        timerController.secondsRemaining.value == timerController.totalSeconds.value) {
      taskController.selectTask(index, task);
    }
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
              color: AppColors.border.withOpacity(0.1),
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