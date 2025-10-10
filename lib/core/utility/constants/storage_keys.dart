class StorageKeys {
  StorageKeys._();

  static const String timerTotalSeconds = 'timer_total_seconds';
  static const String timerSecondsRemaining = 'timer_seconds_remaining';
  static const String timerTotalBreakSeconds = 'timer_total_break_seconds';
  static const String timerBreakSecondsRemaining = 'timer_break_seconds_remaining';
  static const String timerIsOnBreak = 'timer_is_on_break';
  static const String timerCurrentTaskTitle = 'timer_current_task_title';

  static const String taskIsUsingDefault = 'task_is_using_default';
  static const String taskDefaultCurrentSession = 'task_default_current_session';
  static const String taskSelectedTaskId = 'task_selected_task_id';
  static const String taskDefaultBreakType = 'task_default_break_type';

  static String userKey(String? userId, String baseKey) {
    final prefix = userId ?? 'guest';
    return '${prefix}_$baseKey';
  }
}

