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

  Future<List<UserTaskModel>?> getUserTasks() async {
    try {
      final currentUserId = _auth.currentUser?.uid;
      if(currentUserId == null) return [];
      final query = await _firestore
        .collection('users')
        .doc(currentUserId)
        .collection('tasks')
        .orderBy('createdAt', descending: true)
        .get();
      final tasks = query.docs.map((doc) => UserTaskModel.fromFirestore(doc)).toList();
      return tasks;
    } catch (e) {
      debugPrint('Error getting user tasks');
      return [];
    }
  }

  Future<List<UserTaskModel>?> getCompletedTask() async {
    try {
      final currentUserId = _auth.currentUser?.uid;
      if(currentUserId == null) return [];
    final snapshot = await _firestore
          .collection('users')
          .doc(currentUserId)
          .collection('tasks')
          .where('isCompleted', isEqualTo: true)
          .orderBy('createdAt', descending: true)
          .get();
          return snapshot.docs.map((doc) => UserTaskModel.fromFirestore(doc)).toList();
    } catch (e) {
      Future.error(e);
      return [];
    }
  }

  Future<List<UserTaskModel>?> getActiveTask() async {
    try {
      final currentUserId = _auth.currentUser?.uid;
      if(currentUserId == null) return [];
      final snapshot = await _firestore
          .collection('users')
          .doc(currentUserId)
          .collection('tasks')
          .where('isCompleted', isEqualTo: false)
          .orderBy('createdAt', descending: true)
          .get();
      return snapshot.docs.map((doc,) => UserTaskModel.fromFirestore(doc)).toList();
    } catch (e) {
      Future.error(e);
      return [];
    }
  }

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
      print("❌ Task güncellenirken hata oluştu: $e");
    }
  }

  Future<void> updateUserXp(int xpToAdd) async {
    try {
      final String uid = _auth.currentUser!.uid;
      final userRef = _firestore.collection('users').doc(uid);

      final userDoc = await userRef.get();
      final currentXp = userDoc.data()?['xp'] ?? 0;
      final currentTotalPomodoro = userDoc.data()?['totalPomodoro'] ?? 0;

      await userRef.update({
        'xp': currentXp + xpToAdd,
        'totalPomodoro': currentTotalPomodoro + 1
      });
    } catch (e) {
      Future.error(e);
    }
  }
}