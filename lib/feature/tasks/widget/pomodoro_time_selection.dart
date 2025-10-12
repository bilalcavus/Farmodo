import 'package:farmodo/core/theme/app_container_styles.dart';
import 'package:farmodo/core/utility/extension/dynamic_size_extension.dart';
import 'package:farmodo/feature/tasks/viewmodel/tasks_controller.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get_state_manager/src/rx_flutter/rx_obx_widget.dart';
import 'package:easy_localization/easy_localization.dart';

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
      height: context.dynamicHeight(0.1),
      decoration: AppContainerStyles.secondaryContainer(context),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text('home.select_pomodoro_minutes'.tr(), style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600)),
          Obx(() {
            return SizedBox(
              height: context.dynamicHeight(0.2),
              width: context.dynamicWidth(0.35),
              child: CupertinoPicker(
                itemExtent: 28,
                scrollController: FixedExtentScrollController(
                  initialItem: taskController.pomodoroTimes.indexOf(taskController.defaultPomodoroTime.value),
                ),
                onSelectedItemChanged: (index){
                  taskController.setSelectedPomodoroTime(taskController.pomodoroTimes[index]);
                },
                children: taskController.pomodoroTimes.map((time) => 
                  Center(
                    child: Text('$time minutes', style: Theme.of(context).textTheme.bodyLarge)
                  )).toList()
                ),
              );
            }
          ),
        ],
      ),
    );
  }
}