import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:farmodo/data/sample_data/gamification_data.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class SampleDataService {
  static final SampleDataService _instance = SampleDataService._internal();
  factory SampleDataService() => _instance;
  SampleDataService._internal();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> uploadSampleAchievements() async {
    try {
      final achievements = GamificationSampleData.getSampleAchievements();
      
      for (final achievement in achievements) {
        await _firestore
            .collection('achievements')
            .doc(achievement.id)
            .set(achievement.toFirestore());
      }
    } catch (e) {
      // Error uploading sample achievements
    }
  }

  Future<void> uploadSampleQuests() async {
    try {
      final quests = GamificationSampleData.getSampleQuests();
      
      for (final quest in quests) {
        await _firestore
            .collection('quests')
            .doc(quest.id)
            .set(quest.toFirestore());
      }
    } catch (e) {
      // Error uploading sample quests
    }
  }

  Future<void> uploadAllSampleData() async {
    await uploadSampleAchievements();
    await uploadSampleQuests();
  }


  Future<void> checkExistingData(String uid) async {
    try {
      final achievementsCount = await _firestore.collection('achievements').get();
      final questsCount = await _firestore.collection('quests').get();
      await checkAndResetQuests();
      debugPrint('quests checked');
      await checkAndResetUserQuests(FirebaseAuth.instance.currentUser!.uid);
      debugPrint('user quests checked');
    } catch (e) {
      // Error checking existing data
    }
  }

  Future<void> clearSampleData() async {
    try {
      final achievements = await _firestore.collection('achievements').get();
      for (final doc in achievements.docs) {
        await doc.reference.delete();
      }
      
      final quests = await _firestore.collection('quests').get();
      for (final doc in quests.docs) {
        await doc.reference.delete();
      }
    } catch (e) {
      // Error clearing sample data
    }
  }

  Future<void> checkAndResetQuests() async {
  final quests = await _firestore.collection('quests').get();
  final batch = _firestore.batch();

  for (final doc in quests.docs) {
    final data = doc.data();
    final endDate = (data['endDate'] as Timestamp).toDate();
    final type = data['type'];

    if (DateTime.now().isAfter(endDate)) {
      if (type == 'daily') {
        batch.update(doc.reference, {
          'status': 'active',
          'startDate': GamificationSampleData.getTodayStart(),
          'endDate': GamificationSampleData.getTomorrowStart(),
          'lastReset': FieldValue.serverTimestamp(),
        });
      } else if (type == 'weekly') {
        batch.update(doc.reference, {
          'status': 'active',
          'startDate': GamificationSampleData.getWeekStart(),
          'endDate': GamificationSampleData.getNextWeekStart(),
          'lastReset': FieldValue.serverTimestamp(),
        });
      } else if (type == 'special' || type == 'event') {
        batch.update(doc.reference, {
          'status': 'expired',
          'lastReset': FieldValue.serverTimestamp(),
        });
      }
    }
  }

  await batch.commit();
}


Future<void> checkAndResetUserQuests(String uid) async {
  final userQuests = await _firestore
      .collection('users')
      .doc(uid)
      .collection('quests')
      .get();

  final batch = _firestore.batch();

  for (final doc in userQuests.docs) {
    final data = doc.data();
    final endDate = (data['endDate'] as Timestamp?)?.toDate();
    final type = data['type'];

    if (endDate != null && DateTime.now().isAfter(endDate)) {
      if (type == 'daily') {
        batch.update(doc.reference, {
          'status': 'active',
          'progress': 0,
          'completedAt': null,
          'startDate': GamificationSampleData.getTodayStart(),
          'endDate': GamificationSampleData.getTomorrowStart(),
          'lastReset': FieldValue.serverTimestamp(),
        });
      } else if (type == 'weekly') {
        batch.update(doc.reference, {
          'status': 'active',
          'progress': 0,
          'completedAt': null,
          'startDate': GamificationSampleData.getWeekStart(),
          'endDate': GamificationSampleData.getNextWeekStart(),
          'lastReset': FieldValue.serverTimestamp(),
        });
      } else if (type == 'special' || type == 'event') {
        batch.update(doc.reference, {
          'status': 'expired',
          'lastReset': FieldValue.serverTimestamp(),
        });
      }
    }
  }

  await batch.commit();
}


}

