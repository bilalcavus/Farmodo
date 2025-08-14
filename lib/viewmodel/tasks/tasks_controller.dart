import 'package:farmodo/data/models/user_task_model.dart';
import 'package:farmodo/data/services/auth_service.dart';
import 'package:farmodo/data/services/firestore_service.dart';
import 'package:farmodo/view/succeed_task_page.dart';
import 'package:farmodo/viewmodel/auth/login/login_controller.dart';
import 'package:farmodo/viewmodel/timer/timer_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

enum LoadingType { general, active, completed}

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
    calculateXp();
    ever(selectedPomodoroTime, (_) => calculateXp());
    super.onInit();
  }
  void setLoading(LoadingType type, bool value) {
    loadingStates[type] = value;
  }

  void calculateXp(){
    final int? selected = selectedPomodoroTime.value;
    if (selected == null) {
      xp.value = 0;
      return;
    }
    xp.value = (30 + (selected * 1.5)).roundToDouble();
    
  }

  void setSelectedPomodoroTime(int? duration){
    selectedPomodoroTime.value = duration;
    calculateXp();
  }

  void selectTask(int index, int pomodoroMinutes){
    selctedTaskIndex.value = index;
    timerController.totalSeconds.value = pomodoroMinutes * 60;
    timerController.secondsRemaining.value = pomodoroMinutes * 60;
    
    timerController.onTimerComplete = () async {
      await completeTask(index);
      Get.to(() => SucceedTaskPage());
    };
  }

  Future<void> completeTask(int index) async {
    final task = activeUserTasks[index];
    setLoading(LoadingType.general, true);
    try {
      await firestoreService.completeTaskAndUpdateXp(task);
      activeUserTasks[index] = task.copyWith(isCompleted: true);
      await authService.fetchAndSetCurrentUser();
      try {
        loginController.refreshUserXp();
      } catch (_) {}
    } catch (e) {
      rethrow;
    } finally {
      setLoading(LoadingType.general, false);
    }

    // userTasks[index] = task;
  }

  Future<void> addUserTask(BuildContext context) async {
    if (titleController.text.isEmpty || focusTypeController.text.isEmpty) {
      errorMessage.value = 'Fill all the blanks';
      return;
    }
    if (selectedPomodoroTime.value == null) {
      errorMessage.value = 'Select farmodo minutes';
      return;
    }
    setLoading(LoadingType.general, true);
    try {
      await firestoreService.addTask(
        titleController.text.trim(),
        focusTypeController.text.trim(),
        selectedPomodoroTime.value!,
        xp.value.toInt());
        await getActiveTask();
        await getCompletedTask();
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
    required Future<List<UserTaskModel>> Function() fetchFunction,
    required LoadingType loadingFlag
  }) async {
    setLoading(loadingFlag, true);
    try {
      final tasks = await fetchFunction();
      if (tasks.isNotEmpty) {
        targetList.assignAll(tasks);
      } else {
        targetList.clear();
      }
    } catch (e) {
      debugPrint('Error fetching tasks: $e');
    } finally {
      setLoading(loadingFlag, false);
    }
  }

  getUserTasks() => _fetchTasks(
    targetList: userTasks,
    fetchFunction: () => firestoreService.getUserTasks(),
    loadingFlag: LoadingType.general
  );

  getActiveTask() => _fetchTasks(
    targetList: activeUserTasks,
    fetchFunction: () => firestoreService.getActiveTask(),
    loadingFlag: LoadingType.active
  );

  getCompletedTask() => _fetchTasks(
    targetList: completedUserTasks,
    fetchFunction: () => firestoreService.getCompletedTask(),
    loadingFlag: LoadingType.completed
  );



  Future<void> updateUserTaskCompleted(UserTaskModel userTask) async {
    setLoading(LoadingType.general, true);
    try {
      await firestoreService.updateTask(userTask);
    } catch (e) {
      debugPrint("Controller güncelleme hatası: $e");
    } finally{
      setLoading(LoadingType.general, false);
    }
  }

  @override
  void onClose() {
    super.onClose();
    titleController.dispose();
    focusTypeController.dispose();
    durationController.dispose();
  }
}