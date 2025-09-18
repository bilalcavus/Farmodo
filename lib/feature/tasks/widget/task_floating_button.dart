import 'package:farmodo/core/di/injection.dart';
import 'package:farmodo/core/utility/extension/dynamic_size_extension.dart';
import 'package:farmodo/core/utility/extension/route_helper.dart';
import 'package:farmodo/core/theme/app_colors.dart';
import 'package:farmodo/data/services/auth_service.dart';
import 'package:farmodo/feature/tasks/view/add_task_view.dart';
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';

class TaskFloatingButton extends StatefulWidget {
  const TaskFloatingButton({
    super.key,
  });

  @override
  State<TaskFloatingButton> createState() => _TaskFloatingButtonState();
}

class _TaskFloatingButtonState extends State<TaskFloatingButton> {
  final authService = getIt<AuthService>();
  void _showLoginBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => LoginBottomSheet(
        title: 'Login to create a task',
        subTitle: 'You need to log in to save your tasks and track your progress.',
      ),
    );
  }
  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
    backgroundColor: AppColors.danger,
    child: Icon(Iconsax.add, color: AppColors.onPrimary, size: context.dynamicHeight(0.03),),
    onPressed: () {
      if (!authService.isLoggedIn) {
        _showLoginBottomSheet();
      } else {
        RouteHelper.push(context, const AddTaskView());
      }
    } 
    );
  }
}
