import 'package:farmodo/core/utility/extension/dynamic_size_extension.dart';
import 'package:farmodo/core/theme/app_colors.dart';
import 'package:farmodo/feature/tasks/mixin/task_view_mixin.dart';
import 'package:farmodo/feature/tasks/viewmodel/tasks_controller.dart';
import 'package:farmodo/feature/tasks/widget/custom_task_list.dart';
import 'package:farmodo/feature/tasks/widget/task_floating_button.dart';
import 'package:flutter/material.dart';

class TaskView extends StatefulWidget {
  const TaskView({super.key});

  @override
  State<TaskView> createState() => _TaskViewState();
}

class _TaskViewState extends State<TaskView> with TaskViewMixin {

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      initialIndex: 0,
      length: 2,
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          title: Text('Tasks', style: Theme.of(context).textTheme.bodyLarge?.copyWith(
            fontWeight: FontWeight.w500
          ),),
          centerTitle: true,
          bottom: PreferredSize(
            preferredSize: Size.fromHeight(90),
            child: Container(
              margin:  EdgeInsets.all(context.dynamicHeight(0.03)),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.border),
              ),
              child: TabBar(
                indicatorColor: AppColors.primary,
                dividerHeight: 0,
                labelColor: AppColors.textPrimary,
                unselectedLabelColor: AppColors.textSecondary,
                // dividerColor: Colors.white,
                tabs: <Widget>[
                  Tab(child: Text('Active')),
                  Tab(child: Text('Completed'),)
              ]),
            ),
          ),
        ),
        body: TabBarView(children: [
          CustomTaskList(
            listType: taskController.activeUserTasks,
            loadingType: LoadingType.active,
            taskController: taskController, timerController: timerController,
            ),
          CustomTaskList(
            listType: taskController.completedUserTasks,
            loadingType: LoadingType.completed,
            taskController: taskController, timerController: timerController,
            ),
        ]),
        floatingActionButton: TaskFloatingButton(),
      ),
    );
  }
}

