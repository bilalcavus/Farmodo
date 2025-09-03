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
  final userQuestRef = _firestore.collection('users').doc(uid).collection('quests');
  final userQuestsSnap = await userQuestRef.get();

  final now = DateTime.now();
  final batch = _firestore.batch();

  final Map<String, Map<String, dynamic>> userQuests = {
    for (var doc in userQuestsSnap.docs) doc.id: doc.data()
  };

  for (final entry in userQuests.entries) {
    final data = entry.value;
    final endDate = (data['endDate'] as Timestamp?)?.toDate();

    if (endDate != null && now.isAfter(endDate)) {
      batch.delete(userQuestRef.doc(entry.key));
    }
  }

  final questsSnap = await _firestore.collection('quests').get();

  for (final questDoc in questsSnap.docs) {
    final questData = questDoc.data();
    final type = questData['type'];

    DateTime? startDate;
    DateTime? endDate;

    if (type == 'daily') {
      startDate = GamificationSampleData.getTodayStart();
      endDate = GamificationSampleData.getTomorrowStart();
    } else if (type == 'weekly') {
      startDate = GamificationSampleData.getWeekStart();
      endDate = GamificationSampleData.getNextWeekStart();
    } else if (type == 'special' || type == 'event') {
      startDate = questData['startDate']?.toDate();
      endDate = questData['endDate']?.toDate();
    }

    final existing = userQuests[questDoc.id];
    final existingEndDate =
        (existing?['endDate'] as Timestamp?)?.toDate();

    if (existing != null && existingEndDate != null && now.isBefore(existingEndDate)) {
      continue;
    }

    batch.set(userQuestRef.doc(questDoc.id), {
      'userId': uid,
      'questId': questDoc.id,
      'progress': 0,
      'status': 'active',
      'lastUpdated': Timestamp.now(),
      'questRef': questDoc.reference,
      'type': type,
      'startDate': startDate != null ? Timestamp.fromDate(startDate) : null,
      'endDate': endDate != null ? Timestamp.fromDate(endDate) : null,
    });
  }

  await batch.commit();
}

}

