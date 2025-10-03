import 'package:farmodo/data/models/user_model.dart';
import 'package:farmodo/data/services/firestore_service.dart';
import 'package:get/get.dart';

class LeaderBoardController extends GetxController {
  var xpLeaderboard = <UserModel>[].obs;
  var pomodoroLeaderboard = <UserModel>[].obs;
  var levelLeaderboard = <UserModel>[].obs;
  var errorMessage = ''.obs;
  var isLoading = false.obs;
  final FirestoreService _service;

  LeaderBoardController(this._service);

  void setLoading(bool value){
    isLoading.value = value;
  }
  

  Future<void> getXpLeaderboard() async {
    setLoading(true);
    try {
      final response = await _service.getXpLeaderboard();
      if (response.isNotEmpty) {
        xpLeaderboard.value = response;
      }
      setLoading(false);
    } catch (e) {
      errorMessage.value = e.toString();
    } finally {
      setLoading(false);
    }
  }

  Future<void> getLevelLeaderboard() async {
    setLoading(true);
    try {
      final response = await _service.getLevelLeaderboard();
      levelLeaderboard.clear();
      if (response.isNotEmpty) {
        levelLeaderboard.value = response;
      }
      setLoading(false);
    } catch (e) {
      errorMessage.value = e.toString();
    } finally {
      setLoading(false);
    }
  }  
  Future<void> getPomodoroLeaderboard() async {
    setLoading(true);
    try {
      final response = await _service.getTaskLeaderboard();
      pomodoroLeaderboard.clear();
      if (response.isNotEmpty) {
        pomodoroLeaderboard.value = response;
      }
      setLoading(false);
    } catch (e) {
      errorMessage.value = e.toString();
    } finally {
      setLoading(false);
    }
  } 
}