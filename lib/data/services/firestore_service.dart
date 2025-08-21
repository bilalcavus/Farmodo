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

  Future<void> buyStoreItem({
    required String rewardId,
    required int xpCost
    }) async {
      final uid = _auth.currentUser?.uid;
      final userRef = _firestore.collection('users').doc(uid);
      final rewardRef = _firestore.collection('rewards').doc(rewardId);

      await _firestore.runTransaction((transaction) async {
        final userSnapshot = await transaction.get(userRef);
        final rewardSnapshot = await transaction.get(rewardRef);
        if(!userSnapshot.exists) throw Exception('User not found');
        if(!rewardSnapshot.exists) throw Exception('Reward not found');

        final currentXp = userSnapshot['xp'] as int;

        if(currentXp < xpCost) {
          throw Exception('Not enough XP to buy this item');
        }

        transaction.update(userRef, {
          'xp': currentXp - xpCost,
        });
        final userStoreItemRef = userRef.collection('userStoreItems').doc(rewardId);

        transaction.set(userStoreItemRef, {
          'rewardId': rewardId,
          'xpCost': xpCost,
          'purchasedAt': FieldValue.serverTimestamp(),
          'isOwned': true,
        });
      });
  }

  Future<List<Reward>> getUserStoreItems() async {
    final uid = _auth.currentUser?.uid;
    if(uid == null) return [];

    var query = _firestore
        .collection('users')
        .doc(uid)
        .collection('userStoreItems')
        .where('isOwned', isEqualTo: true)
        .orderBy('purchasedAt', descending: true);

    final snapshot = await query.get();
    return snapshot.docs.map((doc) => Reward.fromFirestore(doc)).toList();
  }

  Future<List<Reward>> getUserPurchasedRewards() async {
    final uid = _auth.currentUser?.uid;
    if(uid == null) return [];

    // Önce kullanıcının satın aldığı item ID'lerini al
    final userItemsSnapshot = await _firestore
        .collection('users')
        .doc(uid)
        .collection('userStoreItems')
        .where('isOwned', isEqualTo: true)
        .get();

    if(userItemsSnapshot.docs.isEmpty) return [];

    // Satın alınan reward ID'lerini topla
    final List<String> rewardIds = userItemsSnapshot.docs
        .map((doc) => doc.data()['rewardId'] as String)
        .toList();

    // Bu ID'lerle tam reward bilgilerini getir
    final List<Reward> purchasedRewards = [];
    for(String rewardId in rewardIds) {
      try {
        final rewardDoc = await _firestore.collection('rewards').doc(rewardId).get();
        if(rewardDoc.exists) {
          purchasedRewards.add(Reward.fromFirestore(rewardDoc));
        }
      } catch (e) {
        // Eğer reward bulunamazsa atla
        continue;
      }
    }

    return purchasedRewards;
  }

  Future<List<UserTaskModel>> _getTasks({bool? isCompleted}) async {
  final uid = _auth.currentUser?.uid;
  if (uid == null) return [];

  var query = _firestore
      .collection('users')
      .doc(uid)
      .collection('tasks')
      .orderBy('createdAt', descending: true);

  if (isCompleted != null) {
    query = query.where('isCompleted', isEqualTo: isCompleted);
  }

  final snapshot = await query.get();
  return snapshot.docs.map((doc) => UserTaskModel.fromFirestore(doc)).toList();
}

Future<List<Reward>> getStoreItems() async {
    var query = _firestore.collection('rewards').orderBy('createdAt', descending: true).where('isAvailable', isEqualTo: true);
    final snapshot = await query.get();
    return snapshot.docs.map((doc) => Reward.fromFirestore(doc)).toList();
  }

  getUserTasks() => _getTasks();
  getCompletedTask() => _getTasks(isCompleted: true);
  getActiveTask() => _getTasks(isCompleted: false);


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