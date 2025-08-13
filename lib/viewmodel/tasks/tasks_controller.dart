import 'package:farmodo/core/di/injection.dart';
import 'package:farmodo/data/models/user_task_model.dart';
import 'package:farmodo/data/services/auth_service.dart';
import 'package:farmodo/data/services/firestore_service.dart';
import 'package:farmodo/view/succeed_task_page.dart';
import 'package:farmodo/viewmodel/auth/login/login_controller.dart';
import 'package:farmodo/viewmodel/timer/timer_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class TasksController extends GetxController {
  final titleController = TextEditingController();
  final focusTypeController = TextEditingController();
  final durationController = TextEditingController();
  List<int> pomodoroTimes = [1,25, 30, 40, 45, 50];
  RxnInt selectedPomodoroTime = RxnInt();
  var userTasks = <UserTaskModel>[].obs;
  var completedUserTasks = <UserTaskModel>[].obs;
  var activeUserTasks = <UserTaskModel>[].obs;
  var selctedTaskIndex = (-1).obs;
  RxDouble xp = 0.0.obs;
  final _isLoading = false.obs;
  final _activeTaskLoading = false.obs;
  final _completedTaskLoading = false.obs;
  RxBool get isLoading => _isLoading;
  RxBool get activeTaskLoading => _activeTaskLoading;
  RxBool get completedTaskLoading => _completedTaskLoading;
  final FirestoreService firestoreService;
  final AuthService authService;
  final TimerController timerController;

  TasksController(this.firestoreService, this.authService, this.timerController);

  @override
  void onInit() {
    calculateXp();
    ever(selectedPomodoroTime, (_) => calculateXp());
    super.onInit();
  }
  void setLoading(RxBool loadingType, bool value) {
    loadingType.value = value;
  }

  void calculateXp(){
    final int? selected = selectedPomodoroTime.value;
    if (selected == null) {
      xp.value = 0;
      return;
    }
    xp.value = 30 + (selected * 1.5);
    
  }

  void setSelectedPomodoroTime(int? duration){
    selectedPomodoroTime.value = duration;
    calculateXp();
  }

  void selectTask(int index, int pomodoroMinutes, BuildContext context){
    selctedTaskIndex.value = index;
    timerController.totalSeconds.value = pomodoroMinutes * 60;
    timerController.secondsRemaining.value = pomodoroMinutes * 60;
    
    timerController.onTimerComplete = () async {
      completeTask(index);
      Get.to(() => SucceedTaskPage());
    };
  }

  Future<void> completeTask(int index) async {
    final task = activeUserTasks[index];
    setLoading(_isLoading, true);
    try {
      final updatedTask = task.copyWith(isCompleted: true);
      await firestoreService.updateTask(updatedTask);
      await firestoreService.updateUserXp(task.xpReward);
      activeUserTasks[index] = updatedTask;
      await authService.fetchAndSetCurrentUser();

      try {
        final loginController = getIt<LoginController>();
        loginController.refreshUserXp();
      } catch (_) {}
    } catch (e) {
      Future.error(e);
    } finally {
      setLoading(_isLoading, false);
    }

    // userTasks[index] = task;
  }

  Future<void> addUserTask(BuildContext context) async {
    if (titleController.text.isEmpty || focusTypeController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Fill all blanks'))
      );
      return;
    }
    if (selectedPomodoroTime.value == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Select pomodoro time'))
      );
      return;
    }
    setLoading(_isLoading, true);
    try {
      await firestoreService.addTask(
        titleController.text.trim(),
        focusTypeController.text.trim(),
        selectedPomodoroTime.value!,
        xp.value.toInt());
        await getActiveTask();
        await getCompletedTask();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString()),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      titleController.clear();
      focusTypeController.clear();
      setLoading(_isLoading, false);
    }
  }

  Future<void> getUserTasks() async {
    setLoading(_isLoading, true);
    try {
      final tasks = await firestoreService.getUserTasks();
      debugPrint('$tasks');
      if (tasks!.isNotEmpty) {
        userTasks.assignAll(tasks);
      } else {
        userTasks.clear();
      }
    } catch (e) {
      debugPrint('Error in controller getUserTasks: $e');
    } finally {
      setLoading(_isLoading, false);
    }
  }

  Future<void> getCompletedTask() async {
    setLoading(_completedTaskLoading, true);
    try {
      final tasks = await firestoreService.getCompletedTask();
      if (tasks!.isNotEmpty) {
        completedUserTasks.assignAll(tasks);
      } else {
        completedUserTasks.clear();
      }
    } catch (e) {
      Future.error(e);
    } finally {
      setLoading(_completedTaskLoading, false);
    }
  }

  Future<void> getActiveTask() async {
    setLoading(_activeTaskLoading, true);
    try {
      final tasks = await firestoreService.getActiveTask();
      if (tasks!.isNotEmpty) {
        activeUserTasks.assignAll(tasks);
      } else {
        activeUserTasks.clear();
      }
    } catch (e) {
      Future.error(e);
    } finally {
      setLoading(_activeTaskLoading, false);
    }
  }


  Future<void> updateUserTaskCompleted(UserTaskModel userTask) async {
    setLoading(_isLoading, true);
    try {
      await firestoreService.updateTask(userTask);
    } catch (e) {
      print("❌ Controller güncelleme hatası: $e");
    } finally{
      setLoading(_isLoading, false);
    }
  }
}