import 'package:farmodo/core/di/injection.dart';
import 'package:farmodo/core/extension/dynamic_size_extension.dart';
import 'package:farmodo/core/extension/route_helper.dart';
import 'package:farmodo/view/home/widgets/daily_goals_container.dart';
import 'package:farmodo/view/home/widgets/home_header.dart';
import 'package:farmodo/view/home/widgets/pomodoro_timer.dart';
import 'package:farmodo/view/home/widgets/recent_tasks.dart';
import 'package:farmodo/view/home/widgets/time_start_button.dart';
import 'package:farmodo/view/tasks/task_view.dart';
import 'package:farmodo/viewmodel/tasks/tasks_controller.dart';
import 'package:farmodo/viewmodel/timer/timer_controller.dart';
import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:iconsax/iconsax.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      tasksController.getUserTasks();
    });
  }
  final timerController = getIt<TimerController>();
  final tasksController = getIt<TasksController>();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF2F5F9),
      body: SingleChildScrollView(
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              HomeHeader(),
              SizedBox(height: context.dynamicHeight(0.02)),
              dailyGoalsTitle(context),
              DailyGoalsContainer(),
              SizedBox(height: context.dynamicHeight(0.07)),
              PomodoroTimer(timerController: timerController),
              SizedBox(height: context.dynamicHeight(0.04)),
              TimeStartButton(timerController: timerController),
              SizedBox(height: context.dynamicHeight(0.04)),
              Center(
                child: Container(
                  height: context.dynamicHeight(0.075),
                  width: context.dynamicWidth(0.9),
                  padding: EdgeInsets.symmetric(horizontal: context.dynamicWidth(0.01), vertical: context.dynamicHeight(0.01)),
                  decoration: BoxDecoration(
                    color: Colors.black.withAlpha(7),
                    borderRadius: BorderRadius.circular(16)
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      timerOptions(HugeIcons.strokeRoundedAlertDiamond, 'Strict Mode'),
                      timerOptions(Iconsax.timer, 'Timer Mode'),
                      timerOptions(HugeIcons.strokeRoundedFullScreen, 'Full Screen'),
                    ],
                  ),
                ),
              ),
              SizedBox(height: context.dynamicHeight(0.04)),
              Center(
                child: Text("Recent Tasks"),
              ),
              RecentTasks(tasksController: tasksController, timerController: timerController)
            ],
        )),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xffBB4F31),
        child: Icon(Iconsax.add, color: Colors.white, size: context.dynamicHeight(0.03),),
        onPressed: (){
          RouteHelper.push(context, TaskView());
      }),
    );
  }

  Column timerOptions(IconData icon, String title) {
    return Column(
      children: [
        InkWell(
          onTap: () => timerController.toggleFullScreen(context),
          child: Icon(icon)),
        Text(title),
      ],
    );
  }

  Padding dailyGoalsTitle(BuildContext context) {
    return Padding(
      padding:  EdgeInsets.symmetric(horizontal: context.dynamicHeight(0.025)),
      child: Text('Daily Goals', style: Theme.of(context).textTheme.titleMedium?.copyWith(
        color: Colors.grey.shade700,
      )),
    );
  }
}

