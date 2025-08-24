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
        
        print('Achievement uploaded: ${achievement.title}');
      }
      
      print('✅ All sample achievements uploaded successfully!');
    } catch (e) {
      print('❌ Error uploading sample achievements: $e');
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
        
        print('Quest uploaded: ${quest.title}');
      }
      
      print('✅ All sample quests uploaded successfully!');
    } catch (e) {
      print('❌ Error uploading sample quests: $e');
    }
  }

  // Tüm örnek verileri yükle
  Future<void> uploadAllSampleData() async {
    print('🚀 Starting sample data upload...');
    
    await uploadSampleAchievements();
    await uploadSampleQuests();
    
    print('🎉 All sample data uploaded successfully!');
  }

  // Mevcut verileri kontrol et
  Future<void> checkExistingData() async {
    try {
      final achievementsCount = await _firestore.collection('achievements').get();
      final questsCount = await _firestore.collection('quests').get();
      
      print('📊 Current data:');
      print('   Achievements: ${achievementsCount.docs.length}');
      print('   Quests: ${questsCount.docs.length}');
    } catch (e) {
      print('❌ Error checking existing data: $e');
    }
  }

  // Örnek verileri sil
  Future<void> clearSampleData() async {
    try {
      print('🗑️ Clearing sample data...');
      
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
      
      print('✅ Sample data cleared successfully!');
    } catch (e) {
      print('❌ Error clearing sample data: $e');
    }
  }
}

