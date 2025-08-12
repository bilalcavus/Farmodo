import 'package:farmodo/core/extension/dynamic_size_extension.dart';
import 'package:farmodo/viewmodel/tasks/tasks_controller.dart';
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
        color: Colors.black.withAlpha(7),
        borderRadius: BorderRadius.circular(16)
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text('Select pomodoro minutes'),
          Obx(() {
            return DropdownButton<int>(
              borderRadius: BorderRadius.circular(16),
              dropdownColor: Colors.white,
              value: taskController.selectedPomodoroTime.value,
              menuWidth: context.dynamicWidth(.5),
              items: taskController.pomodoroTimes.map((time) {
                return DropdownMenuItem(
                  value: time,
                  child: Text('$time minutes', style: TextStyle(fontSize: context.dynamicHeight(0.018)),));
              }).toList(),
              onChanged: (value) {
                taskController.setSelectedPomodoroTime(value!);
              },
            );
          }
          ),
        ],
      ),
    );
  }
}