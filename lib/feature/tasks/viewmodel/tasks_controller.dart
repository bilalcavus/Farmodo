import 'package:farmodo/data/models/user_task_model.dart';
import 'package:farmodo/data/services/auth_service.dart';
import 'package:farmodo/data/services/firestore_service.dart';
import 'package:farmodo/feature/auth/login/viewmodel/login_controller.dart';
import 'package:farmodo/feature/tasks/helper/timer_helper.dart';
import 'package:farmodo/feature/tasks/utility/xp_calculator.dart';
import 'package:farmodo/feature/tasks/viewmodel/timer_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../home/view/succeed_task_page.dart';

enum LoadingType { general, active, completed}

class TasksController extends GetxController {
  final titleController = TextEditingController();
  final focusTypeController = TextEditingController();
  final taskSelectController = TextEditingController();
  List<int> pomodoroTimes = List.generate(20, (index) => (index + 1) * 5);
  List<int> totalSessions = [1,2,3,4,5];
  RxnInt selectedTotalSession = RxnInt();
  RxnInt selectedPomodoroTime = RxnInt();
  var userTasks = <UserTaskModel>[].obs;
  var completedUserTasks = <UserTaskModel>[].obs;
  var activeUserTasks = <UserTaskModel>[].obs;
  var selctedTaskIndex = (-1).obs;
  var errorMessage = ''.obs;
  RxDouble xp = 0.0.obs;
  final FirestoreService firestoreService;
  final AuthService authService;
  final TimerController timerController;
  final LoginController loginController;

  final loadingStates = <LoadingType, bool>{
    LoadingType.general: false,
    LoadingType.active: false,
    LoadingType.completed: false
  }.obs;

  TasksController(this.firestoreService, this.authService, this.timerController, this.loginController);

  @override
  void onInit() {
    _updateXp();
    ever(selectedPomodoroTime, (_) => _updateXp());
    // Trigger initial task loads
    getActiveTask();
    getCompletedTask();
    super.onInit();
  }
  void setLoading(LoadingType type, bool value) {
    loadingStates[type] = value;
  }

  void _updateXp() {
    xp.value = XpCalculator.calculate(
      duration: selectedPomodoroTime.value,
      session: selectedTotalSession.value
    );
  }

  void setSelectedPomodoroTime(int? duration){
    selectedPomodoroTime.value = duration;
    _updateXp();
  }

  void setSelectedTotalSession(int? totalSessions){
    selectedTotalSession.value = totalSessions;
    _updateXp();
  }

  void selectTask(int index, UserTaskModel task){
    selctedTaskIndex.value = index;
    timerController.setTaskTitle(task.title); // Görev başlığını ayarla
    TimerHelper.setupTaskTimer(
      timerController, task, () async => await completeTaskById(task.id));
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
        _clearTimer();
        Get.to(() => SucceedTaskPage());
      } else {
        _restartTask(task);
      }
    } catch (e) {
      errorMessage.value = "Task completion failed: $e";
    } finally {
      setLoading(LoadingType.general, false);
    }
  }

  Future<void> _refreshTasks() async {
    await getActiveTask();
    await getCompletedTask();
  }
  

  void _clearTimer(){
    timerController.resetAll();
    selctedTaskIndex.value = -1;
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

    if (selectedPomodoroTime.value == null && selectedTotalSession.value == null) {
      errorMessage.value = 'Select farmodo minutes or session';
      return;
    }

    if (selectedTotalSession.value == null) {
      errorMessage.value = 'Select farmodo session';
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
        selectedPomodoroTime.value!,
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
      // Error fetching tasks
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

  @override
  void onClose() {
    super.onClose();
    titleController.dispose();
    focusTypeController.dispose();
    taskSelectController.dispose();
  }
}