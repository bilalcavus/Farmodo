import 'package:farmodo/core/di/injection.dart';
import 'package:farmodo/core/extension/dynamic_size_extension.dart';
import 'package:farmodo/core/theme/app_colors.dart';
import 'package:farmodo/view/tasks/widget/pomodoro_time_selection.dart';
import 'package:farmodo/view/tasks/widget/task_add_button.dart';
import 'package:farmodo/view/tasks/widget/task_text_field.dart';
import 'package:farmodo/view/widgets/drop_menu.dart';
import 'package:farmodo/viewmodel/tasks/tasks_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get_state_manager/get_state_manager.dart';
import 'package:hugeicons/hugeicons.dart';

class AddTaskView extends StatefulWidget {
  const AddTaskView({super.key});

  @override
  State<AddTaskView> createState() => _AddTaskViewState();
}

class _AddTaskViewState extends State<AddTaskView> {
  final taskController = getIt<TasksController>();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('Add New Task', style: Theme.of(context).textTheme.titleMedium?.copyWith(color: AppColors.textPrimary)),
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
              Center(
                child: CircleAvatar(
                  radius: context.dynamicHeight(0.05),
                  backgroundColor: Colors.black,
                  child: Icon(HugeIcons.strokeRoundedTask02, size: context.dynamicHeight(0.04)))),
              SizedBox(height: context.dynamicHeight(0.05)),
              Text('Enter the task name', style: Theme.of(context).textTheme.labelLarge?.copyWith(color: AppColors.textSecondary)),
              TaskTextField(controller: taskController.titleController, hintText: 'Task name'),
              SizedBox(height: context.dynamicHeight(0.02)),
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
              SizedBox(height: context.dynamicHeight(0.02)),
              GridView.builder(
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
                    return InkWell(
                      onTap: (){
                        taskController.setSelectedTotalSession(session);
                      },
                      child: Obx((){
                        return Container(
                          decoration: BoxDecoration(
                            color: taskController.selectedTotalSession.value == session ? Colors.orange.shade400 : Colors.grey.shade200,
                            borderRadius: BorderRadius.circular(16)
                          ),
                          child: Center(child: Text('$session session', textAlign: TextAlign.center,)),
                        );
                      }
                      ),
                    );
                  }),
              SizedBox(height: context.dynamicHeight(0.02)),
              PomodoroTimeSelection(taskController: taskController),
              SizedBox(height: context.dynamicHeight(0.02)),
              Row(
                children: [
                  Image.asset('assets/images/xp_star.png', height: context.dynamicHeight(0.03),),
                  Obx((){
                    final xp = taskController.xp.value;
                    final hasSelection = taskController.selectedPomodoroTime.value != null;
                    return Text(
                      hasSelection ? 'XP Gain : $xp' : 'Select time to see XP',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    );
                    }
                  ),
                ],
              ),
              SizedBox(height: context.dynamicHeight(0.04)),
              TaskAddButton(taskController: taskController),
            ],
          ),
        )),
      ),
    );
  }
}





