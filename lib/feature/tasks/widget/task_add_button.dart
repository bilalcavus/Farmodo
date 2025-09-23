import 'package:farmodo/core/components/button/button_text.dart';
import 'package:farmodo/core/components/loading_icon.dart';
import 'package:farmodo/core/theme/app_colors.dart';
import 'package:farmodo/core/utility/extension/dynamic_size_extension.dart';
import 'package:farmodo/core/utility/extension/ontap_extension.dart';
import 'package:farmodo/core/utility/extension/route_helper.dart';
import 'package:farmodo/feature/tasks/viewmodel/tasks_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/state_manager.dart';

class TaskAddButton extends StatelessWidget {
  const TaskAddButton({
    super.key,
    required this.taskController,
  });

  final TasksController taskController;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        height: context.dynamicHeight(0.06),
        width: context.dynamicWidth(0.8),
        decoration: BoxDecoration(
          color: AppColors.danger,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Center(child: Obx((){
          return (taskController.loadingStates[LoadingType.general] ?? false)
           ? LoadingIcon(iconColor: Colors.white)
           : ButtonText(text: 'Add',);
        })),
      ),
    ).onTap(() async {
      await taskController.addUserTask(context);
      if (taskController.errorMessage.isNotEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(taskController.errorMessage.value))
        );
      }
      if(context.mounted && taskController.errorMessage.isEmpty) RouteHelper.pop(context);
    });
  }
}