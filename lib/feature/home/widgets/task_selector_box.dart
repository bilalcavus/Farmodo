import 'package:farmodo/core/components/drop_menu.dart';
import 'package:farmodo/core/di/injection.dart';
import 'package:farmodo/core/theme/app_colors.dart';
import 'package:farmodo/core/utility/extension/dynamic_size_extension.dart';
import 'package:farmodo/core/utility/extension/route_helper.dart';
import 'package:farmodo/data/services/auth_service.dart';
import 'package:farmodo/feature/tasks/view/add_task_view.dart';
import 'package:farmodo/feature/tasks/viewmodel/tasks_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get_rx/src/rx_workers/rx_workers.dart';

class CurrentTaskBox extends StatefulWidget {
  final TasksController tasksController;
  final TextEditingController controller;

  const CurrentTaskBox({
    super.key,
    required this.tasksController,
    required this.controller,
  });

  @override
  State<CurrentTaskBox> createState() => _CurrentTaskBoxState();
}

class _CurrentTaskBoxState extends State<CurrentTaskBox> with SingleTickerProviderStateMixin {
  final authService = getIt<AuthService>();
  late AnimationController _shakeController;
  late Animation<double> _shakeAnimation;
  Color _borderColor = AppColors.border;
  late Worker _shakeWorker;

  @override
  void initState() {
    super.initState();
    _shakeController = AnimationController(vsync: this, duration: Duration(milliseconds: 300));
    _shakeAnimation = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0, end: 8), weight: 1),
      TweenSequenceItem(tween: Tween(begin: 8, end: -8), weight: 2),
      TweenSequenceItem(tween: Tween(begin: -8, end: 8), weight: 2),
      TweenSequenceItem(tween: Tween(begin: 8, end: 0), weight: 1),
    ]).animate(_shakeController);
    
    _shakeWorker = ever(widget.tasksController.shakeTaskBox, (shake) {
      if (shake == true && mounted) {
        _shakeController.forward(from: 0).whenComplete(() {
          if (mounted) {
            setState(() => _borderColor = AppColors.border);
          }
        });
        setState(() => _borderColor = Colors.red);
        widget.tasksController.resetShake();
      }
    });
  }


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
  

  void shake() {
    if (mounted) {
      setState(() => _borderColor = Colors.red);
      _shakeController.forward(from: 0).whenComplete(() {
        if (mounted) {
          setState(() => _borderColor = AppColors.border);
        }
      });
    }
  }

  @override
  void dispose() {
    _shakeWorker.dispose();
    _shakeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final tasks = widget.tasksController.activeUserTasks;
    return AnimatedBuilder(
      animation: _shakeAnimation,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(_shakeAnimation.value, 0),
          child: Container(
            padding: EdgeInsets.all(context.dynamicHeight(0.016)),
            width: context.dynamicWidth(0.85),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(context.dynamicHeight(0.03)),
              border: Border.all(color: _borderColor, width: 2),
            ),
            child: Column(
              children: [
                Center(child: Text('CURRENT TASK')),
                if (tasks.isEmpty) ...[
                  Text('NO TASKS YET', style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.bold
                  )),
                  SizedBox(height: context.dynamicHeight(0.01)),
                  Text('Please create a task first.', style: Theme.of(context).textTheme.bodyMedium),
                  TextButton(
                    onPressed: () {
                      if (!authService.isLoggedIn) {
                        _showLoginBottomSheet();
                      } else {
                        RouteHelper.push(context, const AddTaskView());
                      }
                    },
                    child: Text('Create Task')
                  ),
                ] else ...[
                  Text('Select or create a task', style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w600)),
                  DropMenu(
                    controller: widget.controller,
                    hint: 'Select Task',
                    items: tasks.map((task) => task.title).toList(),
                    onChanged: (value) {
                      final index = tasks.indexWhere((task) => task.title == value);
                      if (index != -1) widget.tasksController.selectTask(index, tasks[index]);
                    },
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }
}

