import 'package:farmodo/data/models/user_task_model.dart';

enum BreakDurationType { short, long }

class DefaultTaskData {
  static const String title = 'Focus Session';
  static const String description = 'Complete focus sessions to earn XP and improve your productivity!';
  
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