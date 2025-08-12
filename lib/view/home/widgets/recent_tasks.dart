import 'package:farmodo/core/extension/dynamic_size_extension.dart';
import 'package:farmodo/viewmodel/tasks/tasks_controller.dart';
import 'package:farmodo/viewmodel/timer/timer_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get_state_manager/src/rx_flutter/rx_obx_widget.dart';
import 'package:hugeicons/hugeicons.dart';

class RecentTasks extends StatelessWidget {
  const RecentTasks({
    super.key,
    required this.tasksController,
    required this.timerController,
  });

  final TasksController tasksController;
  final TimerController timerController;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: context.dynamicHeight(0.65),
      child: Obx(() {
        if (tasksController.isLoading.value) {
          return Center(child: CircularProgressIndicator());
        } else if (tasksController.userTasks.isEmpty) {
          return Center(child: Text('No added task yet'));
        } else {
          return ListView.builder(
            itemCount: tasksController.userTasks.length,
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            itemBuilder: (context, index) {
              final task = tasksController.userTasks[index];
              return Container(
                margin: EdgeInsets.symmetric(horizontal: context.dynamicWidth(0.04), vertical: context.dynamicHeight(0.006)),
                decoration: BoxDecoration(
                  color: Colors.black.withAlpha(7),
                  borderRadius: BorderRadius.circular(12)
                ),
                child: ListTile(
                  title: Text(task.title, style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.w600
                  ),),
                  subtitle: Text('${task.duration} min'),
                  leading: CircleAvatar(
                    backgroundColor: Color(0xff2C2C2C),
                    child: Icon(HugeIcons.strokeRoundedTask01,
                    color: Colors.white,),),
                  trailing: InkWell(
                    onTap: (){
                      tasksController.selectTask(index, task.duration);
                      timerController.startTimer();
                    },
                    child: CircleAvatar(
                      backgroundColor: Colors.black,
                      child: Icon(HugeIcons.strokeRoundedPlay,
                      color: Colors.white,
                      size: context.dynamicHeight(0.03),)))
                ),
              );
            },
          );
        }
      }),
    );
  }
}


