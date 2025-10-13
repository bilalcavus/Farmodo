import 'package:easy_localization/easy_localization.dart';
import 'package:farmodo/data/models/user_task_model.dart';

enum BreakDurationType { short, long }

class DefaultTaskData {
  static String title = 'tasks.default_task_title'.tr();
  
  static const int shortBreakDuration = 5;
  static const int longBreakDuration = 15;
  
  static UserTaskModel getUserDefaultTaskModel({BreakDurationType breakType = BreakDurationType.short}) {
    final breakDuration = breakType == BreakDurationType.short 
      ? shortBreakDuration 
      : longBreakDuration;
      
    return UserTaskModel(
      id: 'default_task',
      focusType: "General", 
      title: title,
      xpReward: 500,
      isCompleted: false, 
      duration: 25,
      breakDuration: breakDuration,
      totalSessions: 4,
      completedSessions: 0,
      createdAt: DateTime.now()
    );
  }
}