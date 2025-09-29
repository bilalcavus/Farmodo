import 'package:farmodo/core/utility/mixin/loading_mixin.dart';
import 'package:farmodo/data/models/user_model.dart';
import 'package:farmodo/data/services/firestore_service.dart';
import 'package:get/get.dart';

class LeaderBoardController extends GetxController with LoadingMixin {
  var xpLeaderboard = <UserModel>[].obs;
  var pomodoroLeaderboard = <UserModel>[].obs;
  var levelLeaderboard = <UserModel>[].obs;
  var errorMessage = ''.obs;
  final FirestoreService _service;

  LeaderBoardController(this._service);
  

  Future<void> getXpLeaderboard() async {
    setLoading(true);
    try {
      final response = await _service.getXpLeaderboard();
      if (response.isNotEmpty) {
        xpLeaderboard.addAll(response);
      }
      toggleLoading();
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
      if (response.isNotEmpty) {
        levelLeaderboard.addAll(response);
      }
      toggleLoading();
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
      if (response.isNotEmpty) {
        pomodoroLeaderboard.addAll(response);
      }
      toggleLoading();
    } catch (e) {
      errorMessage.value = e.toString();
    } finally {
      setLoading(false);
    }
  } 
}