import 'package:farmodo/core/utility/extension/dynamic_size_extension.dart';
import 'package:farmodo/core/theme/app_colors.dart';
import 'package:farmodo/feature/tasks/viewmodel/tasks_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get_state_manager/src/rx_flutter/rx_obx_widget.dart';

class PomodoroTimeSelection extends StatelessWidget {
  const PomodoroTimeSelection({
    super.key,
    required this.taskController,
  });

  final TasksController taskController;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(context.dynamicHeight(0.01)),
      height: context.dynamicHeight(0.08),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text('Select farmodo minutes', style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.textPrimary, fontWeight: FontWeight.w600)),
          Obx(() {
            return DropdownButton<int>(
              borderRadius: BorderRadius.circular(16),
              dropdownColor: AppColors.surface,
              value: taskController.selectedPomodoroTime.value,
              menuWidth: context.dynamicWidth(.5),
              items: taskController.pomodoroTimes.map((time) {
                return DropdownMenuItem(
                  value: time,
                  child: Text('$time minutes', style: TextStyle(fontSize: context.dynamicHeight(0.018), color: AppColors.textPrimary)),);
              }).toList(),
              onChanged: (value) {
                taskController.setSelectedPomodoroTime(value);
              },
              hint: Text('Select time', style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.textSecondary)),
            );
          }
          ),
        ],
      ),
    );
  }
}