import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:farmodo/data/models/reward_model.dart';
import 'package:farmodo/data/models/user_task_model.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FirestoreService {
  static final FirestoreService _instance = FirestoreService._internal();
  factory FirestoreService() => _instance;
  FirestoreService._internal();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  DocumentSnapshot? lastActiveDoc;
  DocumentSnapshot? lastCompletedDoc;


  Future<void> addTask(String title, String focusType, int duration, int xpReward, int totalSessions) async {
    final int computedBreakDurationRaw = (duration ~/ 5);
    final int computedBreakDuration = computedBreakDurationRaw > 0 ? computedBreakDurationRaw : 1;
    await _firestore
        .collection('users')
        .doc(_auth.currentUser?.uid)
        .collection('tasks')
        .add({
          'uuid': _auth.currentUser?.uid,
          'title':title,
          'focusType': focusType,
          'duration': duration,
          'breakDuration': computedBreakDuration,
          'totalSessions': totalSessions,
          'completedSessions': 0,
          'xpReward': xpReward,
          'isCompleted': false,
          'createdAt':FieldValue.serverTimestamp()
        });
  }

  Future<List<UserTaskModel>> _getTasks({required isCompleted, bool loadMore = false} ) async {
  final uid = _auth.currentUser?.uid;
  if (uid == null) return [];

  var query = _firestore
      .collection('users')
      .doc(uid)
      .collection('tasks')
      .orderBy('createdAt', descending: true)
      .limit(10);

  if (isCompleted != null) {
    query = query.where('isCompleted', isEqualTo: isCompleted);
  }

  final lastDoc = isCompleted ? lastCompletedDoc : lastActiveDoc;

  if(loadMore && lastDoc != null){
    query = query.startAfterDocument(lastDoc);
  }

  final snapshot = await query.get();
  if(snapshot.docs.isNotEmpty){
    if(isCompleted){
      lastCompletedDoc = snapshot.docs.last;
    } else {
      lastActiveDoc = snapshot.docs.last;
    }
  }
  return snapshot.docs.map((doc) => UserTaskModel.fromFirestore(doc)).toList();
}

  Future<List<UserTaskModel>> getCompletedTask({bool loadMore = false}) => _getTasks(isCompleted: true, loadMore: loadMore);
  Future<List<UserTaskModel>> getActiveTask({bool loadMore = false}) => _getTasks(isCompleted: false, loadMore: loadMore);

Future<List<Reward>> getStoreItems() async {
    var query = _firestore.collection('rewards').orderBy('createdAt', descending: true).where('isAvailable', isEqualTo: true);
    final snapshot = await query.get();
    return snapshot.docs.map((doc) => Reward.fromFirestore(doc)).toList();
  }

  Future<void> updateUserXp(int xpToAdd) async {
    try {
      final String uid = _auth.currentUser!.uid;
      final userRef = _firestore.collection('users').doc(uid);

      final userDoc = await userRef.get();
      final currentXp = (userDoc.data()?['xp'] as int?) ?? 0;
      final currentTotalPomodoro = userDoc.data()?['totalPomodoro'] ?? 0;

      await userRef.update({
        'xp': currentXp + xpToAdd,
        'totalPomodoro': currentTotalPomodoro + 1
      });
    } catch (e) {
      rethrow;
    }
  }

  Future<void> completeTaskAndUpdateXp(UserTaskModel task) async {
    final String uid = _auth.currentUser!.uid;
    final taskRef = _firestore
          .collection('users')
          .doc(uid)
          .collection('tasks')
          .doc(task.id);
    final userRef = _firestore.collection('users').doc(uid);
    
    await _firestore.runTransaction((transaction) async {
      final taskSnapshot = await transaction.get(taskRef);
      if(!taskSnapshot.exists) {
        throw Exception("Task bulunamadı");
      }

      final userSnapshot = await transaction.get(userRef);
      if (!userSnapshot.exists) {
        throw Exception("Kullanıcı bulunamadı");
      }

      final currentXp = (userSnapshot.data()?['xp'] ?? 0) as int;
      final currentTotalPomodoro = (userSnapshot.data()?['totalPomodoro'] ?? 0) as int;
      int newCompletedSessions = task.completedSessions + 1;
      bool taskDone = newCompletedSessions >= task.totalSessions;

      transaction.update(taskRef, {
        'isCompleted': taskDone,
        'completedSessions': newCompletedSessions,
        });

      transaction.update(userRef, {
        'xp': currentXp + task.xpReward,
        'totalPomodoro': currentTotalPomodoro + 1,
      });
    });
  }

  Future<void> addStoreReward({
    required String rewardId,
    required String name,
    required String imageUrl,
    required int xpCost,
    required String description,
    String type = 'customization',
    required bool isPremium,
    Map<String, dynamic>? metadata
  }) async {
    await _firestore.collection('rewards').doc(rewardId).set({
      'name': name,
      'imageUrl': imageUrl,
      'xpCost': xpCost,
      'description': description,
      'type': type,
      'isAvailable': true,
      'isPremium': isPremium,
      'metadata' : metadata,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }
  
}