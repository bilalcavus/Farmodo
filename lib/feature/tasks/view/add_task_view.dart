import 'package:farmodo/core/components/drop_menu.dart';
import 'package:farmodo/core/di/injection.dart';
import 'package:farmodo/core/theme/app_colors.dart';
import 'package:farmodo/core/theme/app_container_styles.dart';
import 'package:farmodo/core/utility/extension/dynamic_size_extension.dart';
import 'package:farmodo/core/utility/extension/ontap_extension.dart';
import 'package:farmodo/core/utility/extension/route_helper.dart';
import 'package:farmodo/core/utility/extension/sized_box_extension.dart';
import 'package:farmodo/data/services/auth_service.dart';
import 'package:farmodo/feature/auth/login/view/login_view.dart';
import 'package:farmodo/feature/tasks/viewmodel/tasks_controller.dart';
import 'package:farmodo/feature/tasks/widget/pomodoro_time_selection.dart';
import 'package:farmodo/feature/tasks/widget/task_add_button.dart';
import 'package:farmodo/feature/tasks/widget/task_text_field.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_state_manager/get_state_manager.dart';

class AddTaskView extends StatefulWidget {
  const AddTaskView({super.key});

  @override
  State<AddTaskView> createState() => _AddTaskViewState();
}

class _AddTaskViewState extends State<AddTaskView> {
  final taskController = getIt<TasksController>();
  final authService = getIt<AuthService>();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!authService.isLoggedIn) {
        _showLoginBottomSheet();
      }
    });
  }

  void _showLoginBottomSheet() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: isDark ? AppColors.darkSurface : Colors.white,
      builder: (context) => LoginBottomSheet(
        title: 'Login to create a task',
        subTitle: 'You need to log in to save your tasks and track your progress.',
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add Custom Task', style: Theme.of(context).textTheme.titleMedium),
        centerTitle: true,
        backgroundColor: Colors.transparent,
      ),
      body: SingleChildScrollView(
        child: SafeArea(child: 
        Padding(
          padding:  EdgeInsets.all(context.dynamicHeight(0.02)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Enter the task name', style: Theme.of(context).textTheme.labelLarge),
              TaskTextField(controller: taskController.titleController, hintText: 'Task name'),
              context.dynamicHeight(0.02).height,
              DropMenu(
                controller: taskController.focusTypeController,
                label: 'Enter Focus Type',
                hint: 'Focus Type', items: [
                'General',
                'Work',
                'Study',
                'Play',
                'Sport'
              ]),
              context.dynamicHeight(0.02).height,
              SessionSelection(taskController: taskController),
              context.dynamicHeight(0.02).height,
              PomodoroTimeSelection(taskController: taskController),
              context.dynamicHeight(0.02).height,
              Row(
                children: [
                  Image.asset('assets/images/xp_star.png', height: context.dynamicHeight(0.03),),
                  Obx((){
                    final xp = taskController.xp.value;
                    return Text(
                      'XP Gain : $xp',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    );
                    }
                  ),
                ],
              ),
              context.dynamicHeight(0.04).height,
              TaskAddButton(taskController: taskController),
            ],
          ),
        )),
      ),
    );
  }
}

class LoginBottomSheet extends StatelessWidget {
  const LoginBottomSheet({
    super.key, required this.title, required this.subTitle,
  });
  final String title;
  final String subTitle;
  @override
  Widget build(BuildContext context) {
    return Container(
      height: context.dynamicHeight(0.6),
      decoration:  AppContainerStyles.primaryContainer(context),
      child: Padding(
        padding: EdgeInsets.all(context.dynamicHeight(0.03)),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: context.dynamicWidth(0.12),
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            context.dynamicHeight(0.03).height,              
            Container(
              padding: EdgeInsets.all(context.dynamicHeight(0.02)),
              decoration: BoxDecoration(
                color: AppColors.primary.withAlpha(25),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.task_alt,
                color: AppColors.primary,
                size: context.dynamicHeight(0.05),
              ),
            ),
            context.dynamicHeight(0.02).height,
            Text(
              title,
              style: TextStyle(
                fontSize: context.dynamicHeight(0.024),
                fontWeight: FontWeight.w700,
              ),
              textAlign: TextAlign.center,
            ),
            context.dynamicHeight(0.01).height,
            Text(
              subTitle,
              style: TextStyle(
                fontSize: context.dynamicHeight(0.018),
              ),
              textAlign: TextAlign.center,
            ),
            context.dynamicHeight(0.04).height,
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  RouteHelper.push(context, const LoginView());
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  padding: EdgeInsets.symmetric(vertical: context.dynamicHeight(0.018)),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(context.dynamicHeight(0.015)),
                  ),
                ),
                child: Text(
                  'Log in',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: context.dynamicHeight(0.02),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
            context.dynamicHeight(0.02).height,
            
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text(
                'Late for now',
                style: TextStyle(
                  fontSize: context.dynamicHeight(0.018),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class SessionSelection extends StatelessWidget {
  const SessionSelection({
    super.key,
    required this.taskController,
  });

  final TasksController taskController;

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
        shrinkWrap: true,
        physics: NeverScrollableScrollPhysics(),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          crossAxisSpacing: context.dynamicWidth(0.03),
          mainAxisSpacing: context.dynamicWidth(0.01),
          childAspectRatio: 3.1,
        ), 
        itemCount: taskController.totalSessions.length,
        itemBuilder: (context, index){
          final session = taskController.totalSessions[index];
          return Obx((){
            return Container(
              decoration: BoxDecoration(
                color: taskController.selectedTotalSession.value == session 
                ? AppColors.danger
                : Theme.of(context).brightness == Brightness.dark
                  ? AppColors.darkSurface
                  : AppColors.lightSurface, 
                borderRadius: BorderRadius.circular(16)
              ),
              child: Center(child: Text(
                '$session session',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  color: taskController.selectedTotalSession.value == session ? Colors.white : null
                ),
              )),
            );
          }
          ).onTap(() => taskController.setSelectedTotalSession(session));
        });
  }
}





