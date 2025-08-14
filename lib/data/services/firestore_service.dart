import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:farmodo/data/models/user_task_model.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class FirestoreService {
  static final FirestoreService _instance = FirestoreService._internal();
  factory FirestoreService() => _instance;
  FirestoreService._internal();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<void> addTask(String title, String focusType, int duration, int xpReward) async {
    await _firestore
        .collection('users')
        .doc(_auth.currentUser?.uid)
        .collection('tasks')
        .add({
          'uuid': _auth.currentUser?.uid,
          'title':title,
          'focusType': focusType,
          'duration': duration,
          'xpReward': xpReward,
          'isCompleted': false,
          'createdAt':FieldValue.serverTimestamp()
        });
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

  getUserTasks() => _getTasks();
  getCompletedTask() => _getTasks(isCompleted: true);
  getActiveTask() => _getTasks(isCompleted: false);

  Future<void> updateTask(UserTaskModel userTask) async {
    try {
      final String uuid = _auth.currentUser!.uid;
      final taskRef = _firestore
          .collection('users')
          .doc(uuid)
          .collection('tasks')
          .doc(userTask.id);

          await taskRef.update({
            'isCompleted' : true,
          });
    } catch (e) {
      debugPrint("❌ Task güncellenirken hata oluştu: $e");
      rethrow;
    }
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
      final currentTotalPomodoro = (userSnapshot.data()?['totalPomodoro']) as int;

      transaction.update(taskRef, {'isCompleted': true});

      transaction.update(userRef, {
        'xp': currentXp + task.xpReward,
        'totalPomodoro': currentTotalPomodoro + 1
      });
    });
  }
}