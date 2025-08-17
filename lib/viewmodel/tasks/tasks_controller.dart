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
    calculateXp();
    ever(selectedPomodoroTime, (_) => calculateXp());
    super.onInit();
  }
  void setLoading(LoadingType type, bool value) {
    loadingStates[type] = value;
  }

  void calculateXp(){
    final int? pomodoroDurationXp = selectedPomodoroTime.value;
    final int? sessionXp = selectedTotalSession.value;
    if (pomodoroDurationXp == null || sessionXp == null) {
      xp.value = 0;
      return;
    }
    xp.value = (30 + (pomodoroDurationXp * sessionXp * 1.5)).roundToDouble();
  }



  void setSelectedPomodoroTime(int? duration){
    selectedPomodoroTime.value = duration;
    calculateXp();
  }

  void setSelectedTotalSession(int? totalSessions){
    selectedTotalSession.value = totalSessions;
  }

  void selectTask(int index, UserTaskModel task){
    selctedTaskIndex.value = index;
    timerController.totalSeconds.value = task.duration * 60;
    timerController.secondsRemaining.value = task.duration * 60;
    final int breakMinutes = task.breakDuration > 0 ? task.breakDuration : (task.duration ~/ 5).clamp(1, 1000);
    timerController.totalBreakSeconds.value = breakMinutes * 60;
    timerController.breakSecondsRemaining.value = breakMinutes * 60;
    timerController.onTimerComplete = () async {
      timerController.onBreakComplete = () async {
        await completeTask(index);
        timerController.totalSeconds.value = 0;
        timerController.secondsRemaining.value = 0;
      };
    };
  }

  Future<void> completeTask(int index) async {
    final task = activeUserTasks[index];
    setLoading(LoadingType.general, true);
    
    final int newCompletedSessions = task.completedSessions + 1;
    final bool willBeCompleted = newCompletedSessions >= task.totalSessions;
    
    try {
      await firestoreService.completeTaskAndUpdateXp(task);
      await getActiveTask();
      await getCompletedTask();
      
      await authService.fetchAndSetCurrentUser(); 
      try {
        loginController.refreshUserXp();
      } catch (_) {
        
      }
      
      if (willBeCompleted) {
        timerController.totalSeconds.value = 0;
        timerController.secondsRemaining.value = 0;
        timerController.totalBreakSeconds.value = 0;
        timerController.breakSecondsRemaining.value = 0;
        selctedTaskIndex.value = -1;
        Get.to(() => SucceedTaskPage());
      } else {
        final updatedTask = activeUserTasks[index];
        timerController.totalSeconds.value = updatedTask.duration * 60;
        timerController.secondsRemaining.value = updatedTask.duration * 60;
        final int breakMinutes = updatedTask.breakDuration > 0 ? updatedTask.breakDuration : (updatedTask.duration ~/ 5).clamp(1, 1000);
        timerController.totalBreakSeconds.value = breakMinutes * 60;
        timerController.breakSecondsRemaining.value = breakMinutes * 60;

        timerController.onTimerComplete = () async {
          timerController.onBreakComplete = () async {
            await completeTask(index);
          };
        };

        timerController.startTimer();
      }
    } catch (e) {
      rethrow;
    } finally {
      setLoading(LoadingType.general, false);
    }
  }



  Future<void> addUserTask(BuildContext context) async {
    if (titleController.text.isEmpty || focusTypeController.text.isEmpty) {
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

  void _restoreTaskSelection(UserTaskModel previousTask) {
    for (int i = 0; i < activeUserTasks.length; i++) {
      final task = activeUserTasks[i];
      if (task.id == previousTask.id || 
          (task.title == previousTask.title && 
            task.duration == previousTask.duration &&
            task.completedSessions == previousTask.completedSessions)) {
        selctedTaskIndex.value = i;
        return;
      }
    }
    selctedTaskIndex.value = -1;
  }

  @override
  void onClose() {
    super.onClose();
    titleController.dispose();
    focusTypeController.dispose();
    durationController.dispose();
  }
}