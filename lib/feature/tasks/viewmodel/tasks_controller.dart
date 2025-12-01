import 'package:audioplayers/audioplayers.dart';
import 'package:farmodo/core/utility/constants/storage_keys.dart';
import 'package:farmodo/core/services/preferences_service.dart';
import 'package:farmodo/data/models/user_task_model.dart';
import 'package:farmodo/data/sample_data/default_task_data.dart';
import 'package:farmodo/data/services/auth_service.dart';
import 'package:farmodo/data/services/firestore_service.dart';
import 'package:farmodo/feature/auth/login/viewmodel/login_controller.dart';
import 'package:farmodo/feature/tasks/helper/timer_helper.dart';
import 'package:farmodo/feature/tasks/utility/xp_calculator.dart';
import 'package:farmodo/feature/tasks/viewmodel/timer_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../home/widgets/succeed_task_page.dart';

enum LoadingType { general, active, completed}

class TasksController extends GetxController {
  final titleController = TextEditingController();
  final focusTypeController = TextEditingController();
  final taskSelectController = TextEditingController();
  final player = AudioPlayer();
  RxInt defaultPomodoroTime = 25.obs;
  RxInt defaultTotalSession = 4.obs;
  List<int> pomodoroTimes = List.generate(20, (index) => (index + 1) * 5);
  List<int> totalSessions = [1,2,3,4,5];
  RxnInt selectedTotalSession = RxnInt();
  RxInt selectedPomodoroTime = RxInt(5);
  var userTasks = <UserTaskModel>[].obs;
  var completedUserTasks = <UserTaskModel>[].obs;
  var activeUserTasks = <UserTaskModel>[].obs;
  var selctedTaskIndex = (-1).obs;
  var errorMessage = ''.obs;
  var shakeTaskBox = false.obs;
  RxDouble xp = 0.0.obs;
  late UserTaskModel defaultTask;
  var isUsingDefaultTask = false.obs;
  var defaultTaskCurrentSession = 0.obs;
  var defaultBreakType = BreakDurationType.short.obs;
  final FirestoreService firestoreService;
  final AuthService authService;
  final TimerController timerController;
  final LoginController loginController;

  final loadingStates = <LoadingType, bool>{
    LoadingType.general: false,
    LoadingType.active: false,
    LoadingType.completed: false
  }.obs;

  final PreferencesService _prefsService = PreferencesService.instance;

  String? get _userId => authService.getCurrentUserId;
  
  String get _keyIsUsingDefaultTask => StorageKeys.userKey(_userId, StorageKeys.taskIsUsingDefault);
  String get _keyDefaultTaskCurrentSession => StorageKeys.userKey(_userId, StorageKeys.taskDefaultCurrentSession);
  String get _keySelectedTaskId => StorageKeys.userKey(_userId, StorageKeys.taskSelectedTaskId);
  String get _keyDefaultBreakType => StorageKeys.userKey(_userId, StorageKeys.taskDefaultBreakType);

  TasksController(this.firestoreService, this.authService, this.timerController, this.loginController);

  @override
  void onInit() {
    _initializeDefaultTask();
    _updateXp();
    ever(selectedPomodoroTime, (_) => _updateXp());
    _loadInitialTasks();
    super.onInit();
  }

  Future<void> _loadInitialTasks() async {
    await getActiveTask();
    await getCompletedTask();
    
    await timerController.restoreTimerState();
    final hadSavedState = await restoreTaskState();
    
    if (!hadSavedState) {
      selectDefaultTask();
    }
  }

  void _initializeDefaultTask() {
    defaultTask = DefaultTaskData.getUserDefaultTaskModel(breakType: defaultBreakType.value);
  }

  void setDefaultBreakType(BreakDurationType breakType) {
    defaultBreakType.value = breakType;
    defaultTask = DefaultTaskData.getUserDefaultTaskModel(breakType: breakType);
    
    if (isUsingDefaultTask.value) {
      timerController.totalBreakSeconds.value = defaultTask.breakDuration * 60;
      timerController.breakSecondsRemaining.value = defaultTask.breakDuration * 60;
    }
    saveTaskState();
  }
  void setLoading(LoadingType type, bool value) {
    loadingStates[type] = value;
  }

  void triggerShake() {
    shakeTaskBox.value = true;
  }

  void resetShake() {
    shakeTaskBox.value = false;
  }

  void _updateXp() {
    xp.value = XpCalculator.calculate(
      duration: selectedPomodoroTime.value,
      session: selectedTotalSession.value
    );
  }

  void setSelectedPomodoroTime(int duration){
    selectedPomodoroTime.value = duration;
    _updateXp();
  }

  void setSelectedTotalSession(int? totalSessions){
    selectedTotalSession.value = totalSessions;
    _updateXp();
  }

  void selectTask(int index, UserTaskModel task){
    selctedTaskIndex.value = index;
    isUsingDefaultTask.value = false;
    defaultTaskCurrentSession.value = 0;
    timerController.setTaskTitle(task.title);
    TimerHelper.setupTaskTimer(
      timerController, task, () async => await completeTaskById(task.id));
    resetShake();
    saveTaskState();
  }

  void selectDefaultTask() {
    isUsingDefaultTask.value = true;
    selctedTaskIndex.value = -1;
    timerController.setTaskTitle(defaultTask.title);
    _setupDefaultTaskTimer();
    resetShake();
    saveTaskState();
  }

  void _setupDefaultTaskTimer() {
    timerController.totalSeconds.value = defaultTask.duration * 60;
    timerController.secondsRemaining.value = defaultTask.duration * 60;
    timerController.totalBreakSeconds.value = defaultTask.breakDuration * 60;
    timerController.breakSecondsRemaining.value = defaultTask.breakDuration * 60;
    
    timerController.onTimerComplete = () async {
      defaultTaskCurrentSession.value++;
      saveTaskState();
      
      timerController.onBreakComplete = () async {
        await _handleDefaultTaskBreakComplete();
      };
    };
  }

  Future<void> _handleDefaultTaskBreakComplete() async {
    final bool willBeCompleted = defaultTaskCurrentSession.value >= defaultTask.totalSessions;
    
    if (willBeCompleted) {
      if (authService.isLoggedIn) {
        try {
          await firestoreService.updateUserXp(defaultTask.xpReward);
          await authService.fetchAndSetCurrentUser(); 
          loginController.refreshUserXp();
        } catch (e) {
          debugPrint('XP update failed: $e');
        }
      }
      
      await _playCompletionSound();
      Get.to(() => SucceedTaskPage());
      _clearTimer();
      defaultTaskCurrentSession.value = 0;
      
      selectDefaultTask();
    } else {
      _setupDefaultTaskTimer();
      timerController.startTimer();
      saveTaskState();
    }
  }

  Future<void> completeTaskById(String taskId) async {
    final index = activeUserTasks.indexWhere((task) => task.id == taskId);
    if (index == -1) return;
    await completeTask(index);
  }

  Future<void> completeTask(int index) async {
    if (index < 0 || index >= activeUserTasks.length) return;
    final task = activeUserTasks[index];
    setLoading(LoadingType.general, true);
    
    final int newCompletedSessions = task.completedSessions + 1;
    final bool willBeCompleted = newCompletedSessions >= task.totalSessions;
    
    try {
      await firestoreService.completeTaskAndUpdateXp(task);
      await _refreshTasks();
      await authService.fetchAndSetCurrentUser(); 
      loginController.refreshUserXp();
      
      if (willBeCompleted) {
        await _playCompletionSound();
        Get.to(() => SucceedTaskPage());
        _clearTimer();
        
        selectDefaultTask();
      } else {
        _restartTask(task);
      }
    } catch (e) {
      errorMessage.value = "Task completion failed: $e";
    } finally {
      setLoading(LoadingType.general, false);
    }
  }

  Future<void> _playCompletionSound() async {
  try {
    await player.play(AssetSource('sounds/success.mp3'));
  } catch (e) {
    debugPrint('sound error: $e');
  }
}


  Future<void> _refreshTasks() async {
    await getActiveTask();
    await getCompletedTask();
  }
  

  void _clearTimer(){
    timerController.resetAll();
    selctedTaskIndex.value = -1;
    clearSavedTaskState();
  }

  void endCurrentSession() {
    timerController.resetAll();
    
    selctedTaskIndex.value = -1;
    
    defaultTaskCurrentSession.value = 0;

    timerController.isRunning.value = false;
    timerController.isOnBreak.value = false;
    
    selectDefaultTask();
    clearSavedTaskState();
  }

  Future<void> handleUserChange() async {
    timerController.pauseTimer();
    await saveTaskState();
    await timerController.saveTimerState();
    
    timerController.resetAll();
    selctedTaskIndex.value = -1;
    defaultTaskCurrentSession.value = 0;
    isUsingDefaultTask.value = false;
    
    selectDefaultTask();
    
    await Future.delayed(Duration(milliseconds: 100));
    await _loadInitialTasks();
  }

  void _restartTask(UserTaskModel task){
    final updatedTask = activeUserTasks.firstWhere((t) => t.id == task.id, orElse: () => task);
    TimerHelper.setupTaskTimer(timerController, task, () async => await completeTaskById(updatedTask.id));
    timerController.startTimer();
  }

  Future<void> addUserTask(BuildContext context) async {
    if (timerController.isRunning.value) {
      errorMessage.value = 'Cannot add task while timer is running. Please pause the timer first.';
      return;
    }
    
    if (titleController.text.trim().isEmpty || focusTypeController.text.trim().isEmpty) {
      errorMessage.value = 'Fill all the blanks';
      return;
    }

    if (selectedTotalSession.value == null) {
      errorMessage.value = 'Select pomodoro minutes or session';
      return;
    }

    if (selectedTotalSession.value == null) {
      errorMessage.value = 'Select pomodoro session';
      return;
    }
    
    UserTaskModel? currentlySelectedTask;
    if (selctedTaskIndex.value >= 0 && selctedTaskIndex.value < activeUserTasks.length) {
      currentlySelectedTask = activeUserTasks[selctedTaskIndex.value];
    }
    
    setLoading(LoadingType.general, true);
    try {
      await firestoreService.addTask(
        titleController.text.trim(),
        focusTypeController.text.trim(),
        selectedPomodoroTime.value,
        xp.value.toInt(),
        selectedTotalSession.value!,
      );
      await getActiveTask();
      await getCompletedTask();
      
      if (currentlySelectedTask != null) {
        _restoreTaskSelection(currentlySelectedTask);
      }
      errorMessage.value = '';
    } catch (e) {
      errorMessage.value = '$e';
    } finally {
      titleController.clear();
      focusTypeController.clear();
      setLoading(LoadingType.general, false);
    }
  }

  Future<void> deleteUserTask(String taskId) async {
    if (timerController.isRunning.value) {
      errorMessage.value = 'Cannot delete task while timer is running. Please pause the timer first.';
      return;
    }
    
    UserTaskModel? currentlySelectedTask;
    if (selctedTaskIndex.value >= 0 && selctedTaskIndex.value < activeUserTasks.length) {
      currentlySelectedTask = activeUserTasks[selctedTaskIndex.value];
    }
    
    setLoading(LoadingType.general, true);
    try {
      await firestoreService.deleteTask(taskId);
      await getActiveTask();
      await getCompletedTask();
      
      if (currentlySelectedTask != null) {
        _restoreTaskSelection(currentlySelectedTask);
      }
      errorMessage.value = '';
    } catch (e) {
      errorMessage.value = '$e';
    } finally {
      setLoading(LoadingType.general, false);
    }
  }


  Future<void> _fetchTasks({
    required RxList<UserTaskModel> targetList,
    required Future<List<UserTaskModel>> Function({bool loadMore}) fetchFunction,
    required LoadingType loadingFlag,
    bool loadMore = false
  }) async {
    setLoading(loadingFlag, true);
    try {
      final tasks = await fetchFunction(loadMore: loadMore);
      if (tasks.isNotEmpty) {
        if (loadMore) {
          targetList.addAll(tasks);
        } else {
          targetList.assignAll(tasks);
        }
      } else if (!loadMore) {
        targetList.clear();
      }
      if (loadingFlag == LoadingType.active && targetList == activeUserTasks) {
        if (selctedTaskIndex.value >= activeUserTasks.length) {
          selctedTaskIndex.value = -1;
        }
      }
    } catch (e) {
      errorMessage.value = '$e';
    } finally {
      setLoading(loadingFlag, false);
    }
  }


  Future<void> getActiveTask({bool loadMore = false}) => _fetchTasks(
    targetList: activeUserTasks,
    fetchFunction: ({bool loadMore = false}) => firestoreService.getActiveTask(loadMore: loadMore),
    loadingFlag: LoadingType.active,
    loadMore: loadMore
  );

  Future<void> getCompletedTask({bool loadMore = false}) => _fetchTasks(
    targetList: completedUserTasks,
    fetchFunction: ({bool loadMore = false}) => firestoreService.getCompletedTask(loadMore: loadMore),
    loadingFlag: LoadingType.completed,
    loadMore: loadMore
  );

  int _findTaskIndex(UserTaskModel targetTask) {
    for (int i = 0; i < activeUserTasks.length; i++) {
      final task = activeUserTasks[i];
      if (task.id == targetTask.id || 
          (task.title == targetTask.title && 
            task.duration == targetTask.duration)) {
        return i;
      }
    }
    return -1;
  }

  void _restoreTaskSelection(UserTaskModel previousTask) {
    final index = _findTaskIndex(previousTask);
    selctedTaskIndex.value = index;
  }

  Future<void> saveTaskState() async {
    try {
      await _prefsService.setBool(_keyIsUsingDefaultTask, isUsingDefaultTask.value);
      await _prefsService.setInt(_keyDefaultTaskCurrentSession, defaultTaskCurrentSession.value);
      await _prefsService.setString(_keyDefaultBreakType, defaultBreakType.value.toString());
      
      if (!isUsingDefaultTask.value && selctedTaskIndex.value >= 0 && selctedTaskIndex.value < activeUserTasks.length) {
        final selectedTask = activeUserTasks[selctedTaskIndex.value];
        await _prefsService.setString(_keySelectedTaskId, selectedTask.id);
      } else {
        await _prefsService.remove(_keySelectedTaskId);
      }
    } catch (e) {
      debugPrint('Task state save error: $e');
    }
  }

  Future<bool> restoreTaskState() async {
    timerController.isRestoring.value = true;
    bool hadSavedState = false;
    
    try {
      final savedIsUsingDefaultTask = _prefsService.getBool(_keyIsUsingDefaultTask, false);
      final savedDefaultTaskCurrentSession = _prefsService.getInt(_keyDefaultTaskCurrentSession, 0);
      final savedDefaultBreakType = _prefsService.getString(_keyDefaultBreakType, '');
      final savedSelectedTaskId = _prefsService.getString(_keySelectedTaskId, '');

      if (savedDefaultBreakType.isNotEmpty) {
        if (savedDefaultBreakType.contains('short')) {
          defaultBreakType.value = BreakDurationType.short;
        } else if (savedDefaultBreakType.contains('long')) {
          defaultBreakType.value = BreakDurationType.long;
        }
        _initializeDefaultTask();
      }

      if (savedIsUsingDefaultTask) {
        hadSavedState = true;
        defaultTaskCurrentSession.value = savedDefaultTaskCurrentSession;
        isUsingDefaultTask.value = true;
        selctedTaskIndex.value = -1;
        
        timerController.currentTaskTitle.value = defaultTask.title;
        
        if (timerController.totalSeconds.value == 0) {
          timerController.totalSeconds.value = defaultTask.duration * 60;
          timerController.secondsRemaining.value = defaultTask.duration * 60;
          timerController.totalBreakSeconds.value = defaultTask.breakDuration * 60;
          timerController.breakSecondsRemaining.value = defaultTask.breakDuration * 60;
        }
        
        timerController.onTimerComplete = () async {
          defaultTaskCurrentSession.value++;
          saveTaskState();
          
          timerController.onBreakComplete = () async {
            await _handleDefaultTaskBreakComplete();
          };
        };
      } else if (savedSelectedTaskId.isNotEmpty) {
        hadSavedState = true;
        final taskIndex = activeUserTasks.indexWhere((task) => task.id == savedSelectedTaskId);
        if (taskIndex >= 0) {
          final task = activeUserTasks[taskIndex];
          selctedTaskIndex.value = taskIndex;
          isUsingDefaultTask.value = false;
          
          timerController.currentTaskTitle.value = task.title;
          
          if (timerController.totalSeconds.value == 0) {
            timerController.totalSeconds.value = task.duration * 60;
            timerController.secondsRemaining.value = task.duration * 60;
            timerController.totalBreakSeconds.value = task.breakDuration * 60;
            timerController.breakSecondsRemaining.value = task.breakDuration * 60;
          }
          
          timerController.onTimerComplete = () async {
            await completeTaskById(task.id);
          };
        } else {
          hadSavedState = false;
        }
      }
    } catch (e) {
      debugPrint('Task state restore error: $e');
    } finally {
      timerController.isRestoring.value = false;
    }
    
    return hadSavedState;
  }

  Future<void> clearSavedTaskState() async {
    try {
      await _prefsService.remove(_keyIsUsingDefaultTask);
      await _prefsService.remove(_keyDefaultTaskCurrentSession);
      await _prefsService.remove(_keySelectedTaskId);
      await _prefsService.remove(_keyDefaultBreakType);
    } catch (e) {
      debugPrint('Task state clear error: $e');
    }
  }



  @override
  void onClose() {
    super.onClose();
    titleController.dispose();
    focusTypeController.dispose();
    taskSelectController.dispose();
    player.dispose();
  }
}