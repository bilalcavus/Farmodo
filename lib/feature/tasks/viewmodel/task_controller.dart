import 'package:farmodo/data/models/user_task_model.dart';
import 'package:farmodo/data/services/auth_service.dart';
import 'package:farmodo/data/services/firestore_service.dart';
import 'package:farmodo/feature/auth/login/viewmodel/login_controller.dart';
import 'package:farmodo/feature/tasks/helper/timer_helper.dart';
import 'package:farmodo/feature/tasks/utility/xp_calculator.dart';
import 'package:farmodo/feature/tasks/viewmodel/tasks_controller.dart';
import 'package:farmodo/feature/tasks/viewmodel/timer_controller.dart';
import 'package:farmodo/view/success/succeed_task_page.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class TasksController extends GetxController {
  final FirestoreService firestoreService;
  final AuthService authService;
  final TimerController timerController;
  final LoginController loginController;

  final titleController = TextEditingController();
  final focusTypeController = TextEditingController();
  final durationController = TextEditingController();

  var userTasks = <UserTaskModel>[].obs;
  var completedUserTasks = <UserTaskModel>[].obs;
  var activeUserTasks = <UserTaskModel>[].obs;
  var selectedTaskIndex = (-1).obs;
  var errorMessage = ''.obs;

  RxDouble xp = 0.0.obs;
  RxnInt selectedPomodoroTime = RxnInt();
  RxnInt selectedTotalSession = RxnInt();

  final loadingStates = <LoadingType, bool>{
    LoadingType.general: false,
    LoadingType.active: false,
    LoadingType.completed: false,
  }.obs;

  TasksController(this.firestoreService, this.authService, this.timerController, this.loginController);

  @override
  void onInit() {
    everAll([selectedPomodoroTime, selectedTotalSession], (_) => _updateXp());
    super.onInit();
  }

  void _updateXp() {
    xp.value = XpCalculator.calculate(
      duration: selectedPomodoroTime.value,
      session: selectedTotalSession.value,
    );
  }

  void selectTask(int index, UserTaskModel task) {
    selectedTaskIndex.value = index;
    TimerHelper.setupTaskTimer(timerController, task, () async => await completeTaskById(task.id));
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

    try {
      await firestoreService.completeTaskAndUpdateXp(task);
      await _refreshTasks();
      await authService.fetchAndSetCurrentUser();
      loginController.refreshUserXp();

      if (task.completedSessions + 1 >= task.totalSessions) {
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

  void _clearTimer() {
    timerController.resetTimer();
    selectedTaskIndex.value = -1;
  }

  void _restartTask(UserTaskModel task) {
    final updatedTask = activeUserTasks.firstWhere((t) => t.id == task.id, orElse: () => task);
    TimerHelper.setupTaskTimer(timerController, updatedTask, () async => await completeTaskById(updatedTask.id));
    timerController.startTimer();
  }

  Future<void> addUserTask(BuildContext context) async {
    if (timerController.isRunning.value) {
      errorMessage.value = 'Cannot add task while timer is running.';
      return;
    }

    if (titleController.text.isEmpty || focusTypeController.text.isEmpty) {
      errorMessage.value = 'Fill all the blanks';
      return;
    }

    if (selectedPomodoroTime.value == null || selectedTotalSession.value == null) {
      errorMessage.value = 'Select pomodoro time and sessions';
      return;
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
      await _refreshTasks();
      errorMessage.value = '';
    } catch (e) {
      errorMessage.value = 'Error adding task: $e';
    } finally {
      _resetInputs();
      setLoading(LoadingType.general, false);
    }
  }

  Future<void> _refreshTasks() async {
    await getActiveTask();
    await getCompletedTask();
  }

  void _resetInputs() {
    titleController.clear();
    focusTypeController.clear();
  }

  // fetch functions
  getUserTasks() => _fetchTasks(userTasks, firestoreService.getUserTasks(), LoadingType.general);
  getActiveTask() => _fetchTasks(activeUserTasks, firestoreService.getActiveTask(), LoadingType.active);
  getCompletedTask() => _fetchTasks(completedUserTasks, firestoreService.getCompletedTask(), LoadingType.completed);

  Future<void> _fetchTasks(RxList<UserTaskModel> target, Future<List<UserTaskModel>> Function() fetch, LoadingType type) async {
    setLoading(type, true);
    try {
      target.assignAll(await fetch());
    } finally {
      setLoading(type, false);
    }
  }

  void setLoading(LoadingType type, bool value) {
    loadingStates[type] = value;
  }

  @override
  void onClose() {
    titleController.dispose();
    focusTypeController.dispose();
    durationController.dispose();
    super.onClose();
  }
}
