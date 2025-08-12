import 'package:farmodo/core/di/injection.dart';
import 'package:farmodo/core/extension/dynamic_size_extension.dart';
import 'package:farmodo/view/tasks/widget/pomodoro_time_selection.dart';
import 'package:farmodo/view/tasks/widget/task_add_button.dart';
import 'package:farmodo/view/tasks/widget/task_text_field.dart';
import 'package:farmodo/view/widgets/drop_menu.dart';
import 'package:farmodo/viewmodel/tasks/tasks_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get_state_manager/get_state_manager.dart';

class TaskView extends StatefulWidget {
  const TaskView({super.key});

  @override
  State<TaskView> createState() => _TaskViewState();
}

class _TaskViewState extends State<TaskView> {
  final taskController = getIt<TasksController>();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF2F5F9),
      appBar: AppBar(
        title: Text('Add New Task', style: Theme.of(context).textTheme.titleMedium,),
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
              SizedBox(height: context.dynamicHeight(0.1)),
              Text('Enter the task name'),
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
              PomodoroTimeSelection(taskController: taskController),
              SizedBox(height: context.dynamicHeight(0.02)),
              Row(
                children: [
                  Image.asset('assets/images/xp_star.png', height: context.dynamicHeight(0.03),),
                  Obx((){
                    return Text('XP Gain : ${taskController.xp.value}', style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600
                    ),);
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





