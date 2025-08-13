import 'package:farmodo/core/di/injection.dart';
import 'package:farmodo/core/extension/dynamic_size_extension.dart';
import 'package:farmodo/core/extension/route_helper.dart';
import 'package:farmodo/core/theme/app_colors.dart';
import 'package:farmodo/data/models/user_task_model.dart';
import 'package:farmodo/view/tasks/add_task_view.dart';
import 'package:farmodo/viewmodel/tasks/tasks_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get_rx/src/rx_types/rx_types.dart';
import 'package:get/get_state_manager/src/rx_flutter/rx_obx_widget.dart';
import 'package:iconsax/iconsax.dart';

class TaskView extends StatefulWidget {
  const TaskView({super.key});

  @override
  State<TaskView> createState() => _TaskViewState();
}

class _TaskViewState extends State<TaskView> {
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    taskController.getActiveTask();
    taskController.getCompletedTask();
  }
  final taskController = getIt<TasksController>();
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      initialIndex: 1,
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
            loadingType: taskController.activeTaskLoading.value,
            taskController: taskController),
          CustomTaskList(
            listType: taskController.completedUserTasks,
            loadingType: taskController.completedTaskLoading.value,
            taskController: taskController),
        ]),
        floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.primary,
        child: Icon(Iconsax.add, color: AppColors.onPrimary, size: context.dynamicHeight(0.03),),
        onPressed: (){
          RouteHelper.push(context, AddTaskView());
      }),
      ),
    );
  }
}

class CustomTaskList extends StatelessWidget {
  const CustomTaskList({
    super.key,
    required this.taskController,
    required this.loadingType,
    required this.listType,
  });

  final TasksController taskController;
  final bool loadingType;
  final RxList<UserTaskModel> listType;
  

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: context.dynamicHeight(0.9),
      child: Obx((){
        if (loadingType) {
          return Center(child: CircularProgressIndicator());
        } else if (listType.isEmpty) {
          return Center(child: Text('No tasks yet', style: Theme.of(context).textTheme.labelLarge?.copyWith(color: AppColors.textSecondary)));
        }
          else {
            return ListView.builder(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              itemCount: listType.length,
              itemBuilder: (context, index) {
                final task = listType[index];
                return Container(
                  margin: EdgeInsets.symmetric(
                    horizontal: context.dynamicWidth(0.05),
                    vertical: context.dynamicHeight(0.008)
                    ),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(context.dynamicHeight(0.02)),
                    border: Border.all(color: AppColors.border),
                ),
                  child: ListTile(
                  title: Text(task.title, style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: AppColors.textPrimary, fontWeight: FontWeight.w600)),
              ),
            );
          });
        }
      }));
  }
}