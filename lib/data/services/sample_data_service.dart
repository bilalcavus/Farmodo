import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:farmodo/data/sample_data/gamification_data.dart';

class SampleDataService {
  static final SampleDataService _instance = SampleDataService._internal();
  factory SampleDataService() => _instance;
  SampleDataService._internal();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Örnek başarıları Firestore'a yükle
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

  // Örnek görevleri Firestore'a yükle
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

  // Tüm örnek verileri yükle
  Future<void> uploadAllSampleData() async {
    await uploadSampleAchievements();
    await uploadSampleQuests();
  }

  // Mevcut verileri kontrol et
  Future<void> checkExistingData() async {
    try {
      final achievementsCount = await _firestore.collection('achievements').get();
      final questsCount = await _firestore.collection('quests').get();
    } catch (e) {
      // Error checking existing data
    }
  }

  // Örnek verileri sil
  Future<void> clearSampleData() async {
    try {
      // Başarıları sil
      final achievements = await _firestore.collection('achievements').get();
      for (final doc in achievements.docs) {
        await doc.reference.delete();
      }
      
      // Görevleri sil
      final quests = await _firestore.collection('quests').get();
      for (final doc in quests.docs) {
        await doc.reference.delete();
      }
    } catch (e) {
      // Error clearing sample data
    }
  }
}

