import 'package:farmodo/data/models/user_task_model.dart';
import 'package:farmodo/data/services/auth_service.dart';
import 'package:farmodo/data/services/firestore_service.dart';
import 'package:farmodo/viewmodel/timer/timer_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class TasksController extends GetxController {
  final titleController = TextEditingController();
  final focusTypeController = TextEditingController();
  final durationController = TextEditingController();
  List<int> pomodoroTimes = [25, 30, 40, 45, 50];
  var selectedPomodoroTime = 25.obs;
  var userTasks = <UserTaskModel>[].obs;
  var selctedTaskIndex = (-1).obs;
  RxDouble xp = 0.0.obs;
  final _isLoading = false.obs;
  RxBool get isLoading => _isLoading;
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
  void setLoading(bool value) {
    _isLoading.value = value;
  }

  void calculateXp(){
    xp.value = 30 + (selectedPomodoroTime.value * 1.5);
    
  }

  void setSelectedPomodoroTime(int duration){
    selectedPomodoroTime.value = duration;
    calculateXp();
  }

  void selectTask(int index, int pomodoroMinutes){
    selctedTaskIndex.value = index;
    timerController.totalSeconds.value = pomodoroMinutes * 60;
    timerController.secondsRemaining.value = pomodoroMinutes * 60;
    
    timerController.onTimerComplete = () async {
      completeTask(index);
    };
  }

  Future<void> completeTask(int index) async {
    final task = userTasks[index];
    setLoading(true);
    try {
      final updatedTask = task.copyWith(isCompleted: true);
      await firestoreService.updateTask(updatedTask);
      await firestoreService.updateUserXp(task.xpReward);
      userTasks[index] = updatedTask;
    } catch (e) {
      Future.error(e);
    } finally {
      setLoading(false);
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
    setLoading(true);
    try {
      await firestoreService.addTask(
        titleController.text.trim(),
        focusTypeController.text.trim(),
        selectedPomodoroTime.value,
        xp.value.toInt());
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
      setLoading(false);
    }
  }

  Future<void> getUserTasks() async {
    setLoading(true);
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
      setLoading(false);
    }
  }

  Future<void> updateUserTaskCompleted(UserTaskModel userTask) async {
    setLoading(true);
    try {
      await firestoreService.updateTask(userTask);
    } catch (e) {
      print("❌ Controller güncelleme hatası: $e");
    } finally{
      setLoading(false);
    }
  }
}