import 'package:farmodo/feature/tasks/constants/task_constants.dart';

class XpCalculator {
  static double calculate({int? duration, int? session}){
    if (duration == null || session == null) return 0;
    return (TaskConstants.baseXp + (duration * session * TaskConstants.multiplier)).roundToDouble();
  }
}