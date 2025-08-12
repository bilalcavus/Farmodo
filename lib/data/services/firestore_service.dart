import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

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
}