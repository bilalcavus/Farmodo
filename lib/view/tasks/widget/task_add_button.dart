import 'package:farmodo/core/extension/dynamic_size_extension.dart';
import 'package:farmodo/core/theme/app_colors.dart';
import 'package:farmodo/view/widgets/button_text.dart';
import 'package:farmodo/view/widgets/loading_icon.dart';
import 'package:farmodo/viewmodel/tasks/tasks_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get_state_manager/src/rx_flutter/rx_obx_widget.dart';

class TaskAddButton extends StatelessWidget {
  const TaskAddButton({
    super.key,
    required this.taskController,
  });

  final TasksController taskController;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () async {
        await taskController.addUserTask(context);
      },
      child: Center(
        child: Container(
          height: context.dynamicHeight(0.06),
          width: context.dynamicWidth(0.8),
          decoration: BoxDecoration(
            color: AppColors.primary,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Center(child: Obx((){
            return taskController.isLoading.value ? LoadingIcon() : ButtonText(text: 'Add',);
          })),
        ),
      ),
    );
  }
}