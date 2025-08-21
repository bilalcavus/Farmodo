import 'package:farmodo/core/utility/extension/dynamic_size_extension.dart';
import 'package:farmodo/core/utility/extension/route_helper.dart';
import 'package:farmodo/core/theme/app_colors.dart';
import 'package:farmodo/feature/tasks/view/add_task_view.dart';
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';

class TaskFloatingButton extends StatelessWidget {
  const TaskFloatingButton({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
    backgroundColor: AppColors.primary,
    child: Icon(Iconsax.add, color: AppColors.onPrimary, size: context.dynamicHeight(0.03),),
    onPressed: () => RouteHelper.push(context, AddTaskView())
    );
  }
}
