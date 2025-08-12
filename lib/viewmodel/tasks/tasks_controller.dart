import 'package:farmodo/data/services/auth_service.dart';
import 'package:farmodo/data/services/firestore_service.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class TasksController extends GetxController {
  final titleController = TextEditingController();
  final focusTypeController = TextEditingController();
  final durationController = TextEditingController();
  List<int> pomodoroTimes = [25, 30, 40, 45, 50];
  var selectedPomodoroTime = 25.obs;
  RxDouble xp = 0.0.obs;
  final _isLoading = false.obs;
  RxBool get isLoading => _isLoading;
  final FirestoreService firestoreService;
  final AuthService authService;

  TasksController(this.firestoreService, this.authService);

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
}