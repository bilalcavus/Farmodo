import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:farmodo/data/models/achievement_model.dart';
import 'package:farmodo/data/models/quest_model.dart';
import 'package:farmodo/feature/gamification/widget/achievements/achievement_unlock_animation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class GamificationService {
  static final GamificationService _instance = GamificationService._internal();
  factory GamificationService() => _instance;
  GamificationService._internal();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  // final AnimalService _animalService = AnimalService();

  Future<List<Achievement>> getAchievements() async {
    try {
      print('Fetching achievements from Firestore...');
      final snapshot = await _firestore.collection('achievements').get();
      print('Found ${snapshot.docs.length} achievements in Firestore');
      return snapshot.docs.map((doc) => Achievement.fromFirestore(doc)).toList();
    } catch (e) {
      print('Error getting achievements: $e');
      return [];
    }
  }

  // Kullanıcının başarılarını getir
  Future<List<UserAchievement>> getUserAchievements() async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return [];

    try {
      final snapshot = await _firestore
          .collection('users')
          .doc(uid)
          .collection('achievements')
          .get();
      return snapshot.docs.map((doc) => UserAchievement.fromFirestore(doc)).toList();
    } catch (e) {
      print('Error getting user achievements: $e');
      return [];
    }
  }

  // Görevleri getir
  Future<List<Quest>> getQuests() async {
    try {
      print('Fetching quests from Firestore...');
      final snapshot = await _firestore.collection('quests').get();
      print('Found ${snapshot.docs.length} quests in Firestore');
      return snapshot.docs.map((doc) => Quest.fromFirestore(doc)).toList();
    } catch (e) {
      print('Error getting quests: $e');
      return [];
    }
  }

  // Kullanıcının görevlerini getir
  Future<List<UserQuest>> getUserQuests() async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return [];

    try {
      final snapshot = await _firestore
          .collection('users')
          .doc(uid)
          .collection('quests')
          .get();
      return snapshot.docs.map((doc) => UserQuest.fromFirestore(doc)).toList();
    } catch (e) {
      print('Error getting user quests: $e');
      return [];
    }
  }

  // Başarı ilerlemesini güncelle
  Future<void> updateAchievementProgress(String achievementId, int progress) async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return;

    try {
      final userAchievementDoc = await _firestore
          .collection('users')
          .doc(uid)
          .collection('achievements')
          .doc(achievementId)
          .get();

      if (userAchievementDoc.exists) {
        final userAchievement = UserAchievement.fromFirestore(userAchievementDoc);
        final achievement = await _getAchievementById(achievementId);
        
        if (achievement != null && progress >= achievement.targetValue && !userAchievement.isUnlocked) {
          // Başarıyı aç
          await _unlockAchievement(achievementId, achievement);
        } else {
          // Sadece ilerlemeyi güncelle
          await _firestore
              .collection('users')
              .doc(uid)
              .collection('achievements')
              .doc(achievementId)
              .update({
                'progress': progress,
                'lastUpdated': Timestamp.fromDate(DateTime.now()),
              });
        }
      } else {
        // Yeni başarı kaydı oluştur
        await _firestore
            .collection('users')
            .doc(uid)
            .collection('achievements')
            .doc(achievementId)
            .set({
              'userId': uid,
              'achievementId': achievementId,
              'progress': progress,
              'isUnlocked': false,
              'lastUpdated': Timestamp.fromDate(DateTime.now()),
            });
      }
    } catch (e) {
      print('Error updating achievement progress: $e');
    }
  }

  // Görev ilerlemesini güncelle
  Future<void> updateQuestProgress(String questId, int progress) async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return;

    try {
      final userQuestDoc = await _firestore
          .collection('users')
          .doc(uid)
          .collection('quests')
          .doc(questId)
          .get();

      if (userQuestDoc.exists) {
        final userQuest = UserQuest.fromFirestore(userQuestDoc);
        final quest = await _getQuestById(questId);
        
        if (quest != null && progress >= quest.targetValue && userQuest.status != QuestStatus.completed) {
          // Görevi tamamla
          await _completeQuest(questId, quest);
        } else {
          // Sadece ilerlemeyi güncelle
          await _firestore
              .collection('users')
              .doc(uid)
              .collection('quests')
              .doc(questId)
              .update({
                'progress': progress,
                'lastUpdated': Timestamp.fromDate(DateTime.now()),
              });
        }
      } else {
        // Yeni görev kaydı oluştur
        await _firestore
            .collection('users')
            .doc(uid)
            .collection('quests')
            .doc(questId)
            .set({
              'userId': uid,
              'questId': questId,
              'progress': progress,
              'status': 'active',
              'lastUpdated': Timestamp.fromDate(DateTime.now()),
            });
      }
    } catch (e) {
      print('Error updating quest progress: $e');
    }
  }

  // Başarıyı aç
  Future<void> _unlockAchievement(String achievementId, Achievement achievement) async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return;

    try {
      await _firestore
          .collection('users')
          .doc(uid)
          .collection('achievements')
          .doc(achievementId)
          .update({
            'progress': achievement.targetValue,
            'isUnlocked': true,
            'unlockedAt': Timestamp.fromDate(DateTime.now()),
            'lastUpdated': Timestamp.fromDate(DateTime.now()),
          });

      // XP ödülü ver
      await _giveXpReward(achievement.xpReward);
      
      // Başarı açılma animasyonu göster
      _showAchievementUnlockAnimation(achievement);
      
      // Başarı bildirimi göster (animasyon sonrası)
      Future.delayed(const Duration(seconds: 4), () {
        Get.snackbar(
          '🎉 Başarı Açıldı!',
          '${achievement.title}\n+${achievement.xpReward} XP kazandınız!',
          snackPosition: SnackPosition.TOP,
          backgroundColor: achievement.rarityColor,
          colorText: Colors.white,
          duration: const Duration(seconds: 3),
        );
      });
    } catch (e) {
      print('Error unlocking achievement: $e');
    }
  }

  // Görevi tamamla
  Future<void> _completeQuest(String questId, Quest quest) async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return;

    try {
      await _firestore
          .collection('users')
          .doc(uid)
          .collection('quests')
          .doc(questId)
          .update({
            'progress': quest.targetValue,
            'status': 'completed',
            'completedAt': Timestamp.fromDate(DateTime.now()),
            'lastUpdated': Timestamp.fromDate(DateTime.now()),
          });

      // XP ödülü ver
      await _giveXpReward(quest.xpReward);
      
      // Coin ödülü ver
      if (quest.coinReward > 0) {
        await _giveCoinReward(quest.coinReward);
      }
      
      // Görev tamamlama bildirimi göster
      String rewardText = '+${quest.xpReward} XP';
      if (quest.coinReward > 0) {
        rewardText += ' +${quest.coinReward} Coin';
      }
      
      Get.snackbar(
        '✅ Görev Tamamlandı!',
        '${quest.title}\n$rewardText kazandınız!',
        snackPosition: SnackPosition.TOP,
        backgroundColor: quest.typeColor,
        colorText: Colors.white,
        duration: const Duration(seconds: 3),
      );
    } catch (e) {
      print('Error completing quest: $e');
    }
  }

  // XP ödülü ver
  Future<void> _giveXpReward(int xpAmount) async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return;

    try {
      await _firestore.collection('users').doc(uid).update({
        'xp': FieldValue.increment(xpAmount),
      });
      print('✅ XP ödülü verildi: +$xpAmount XP');
    } catch (e) {
      print('Error giving XP reward: $e');
    }
  }

  // Coin ödülü ver
  Future<void> _giveCoinReward(int coinAmount) async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return;

    try {
      await _firestore.collection('users').doc(uid).update({
        'coins': FieldValue.increment(coinAmount),
      });
      print('✅ Coin ödülü verildi: +$coinAmount Coin');
    } catch (e) {
      print('Error giving coin reward: $e');
    }
  }

  // Başarı açılma animasyonu göster
  void _showAchievementUnlockAnimation(Achievement achievement) {
    if (Get.context != null) {
      showDialog(
        context: Get.context!,
        barrierDismissible: false,
        builder: (context) => AchievementUnlockAnimation(
          achievement: achievement,
          onComplete: () {
            // Animasyon tamamlandıktan sonra yapılacak işlemler
            print('Achievement unlock animation completed: ${achievement.title}');
          },
        ),
      );
    }
  }

  // Başarıyı ID ile getir
  Future<Achievement?> _getAchievementById(String achievementId) async {
    try {
      final doc = await _firestore.collection('achievements').doc(achievementId).get();
      if (doc.exists) {
        return Achievement.fromFirestore(doc);
      }
      return null;
    } catch (e) {
      print('Error getting achievement by ID: $e');
      return null;
    }
  }

  // Görevi ID ile getir
  Future<Quest?> _getQuestById(String questId) async {
    try {
      final doc = await _firestore.collection('quests').doc(questId).get();
      if (doc.exists) {
        return Quest.fromFirestore(doc);
      }
      return null;
    } catch (e) {
      print('Error getting quest by ID: $e');
      return null;
    }
  }

  // Hayvan bakım aksiyonları için gamification tetikle
  Future<void> triggerCareAction(String actionType, {String? animalId}) async {
    try {
      // Başarıları kontrol et
      final achievements = await getAchievements();
      for (final achievement in achievements) {
        if (achievement.type == AchievementType.careActions) {
          final userAchievements = await getUserAchievements();
          final userAchievement = userAchievements.firstWhereOrNull(
            (ua) => ua.achievementId == achievement.id,
          );
          
          final currentProgress = userAchievement?.progress ?? 0;
          await updateAchievementProgress(achievement.id, currentProgress + 1);
        }
      }

      // Görevleri kontrol et
      final quests = await getQuests();
      for (final quest in quests) {
        if (quest.action.toString().contains(actionType) && quest.isActive) {
          final userQuests = await getUserQuests();
          final userQuest = userQuests.firstWhereOrNull(
            (uq) => uq.questId == quest.id,
          );
          
          final currentProgress = userQuest?.progress ?? 0;
          await updateQuestProgress(quest.id, currentProgress + 1);
        }
      }
    } catch (e) {
      print('Error triggering care action: $e');
    }
  }

  // Hayvan sayısı değişikliği için gamification tetikle
  Future<void> triggerAnimalCountChange(int animalCount) async {
    try {
      // Başarıları kontrol et
      final achievements = await getAchievements();
      for (final achievement in achievements) {
        if (achievement.type == AchievementType.animalCount) {
          await updateAchievementProgress(achievement.id, animalCount);
        }
      }

      // Görevleri kontrol et
      final quests = await getQuests();
      for (final quest in quests) {
        if (quest.action == QuestAction.collectAnimals && quest.isActive) {
          await updateQuestProgress(quest.id, animalCount);
        }
      }
    } catch (e) {
      print('Error triggering animal count change: $e');
    }
  }

  // Hayvan seviye atlaması için gamification tetikle
  Future<void> triggerAnimalLevelUp(int level) async {
    try {
      // Başarıları kontrol et
      final achievements = await getAchievements();
      for (final achievement in achievements) {
        if (achievement.type == AchievementType.animalLevel) {
          await updateAchievementProgress(achievement.id, level);
        }
      }

      // Görevleri kontrol et
      final quests = await getQuests();
      for (final quest in quests) {
        if (quest.action == QuestAction.levelUpAnimals && quest.isActive) {
          final userQuests = await getUserQuests();
          final userQuest = userQuests.firstWhereOrNull(
            (uq) => uq.questId == quest.id,
          );
          
          final currentProgress = userQuest?.progress ?? 0;
          await updateQuestProgress(quest.id, currentProgress + 1);
        }
      }
    } catch (e) {
      print('Error triggering animal level up: $e');
    }
  }

  // Kullanıcının mevcut XP ve coin bilgilerini getir
  Future<Map<String, int>> getUserStats() async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return {'xp': 0, 'coins': 0};

    try {
      final doc = await _firestore.collection('users').doc(uid).get();
      if (doc.exists) {
        final data = doc.data() as Map<String, dynamic>;
        return {
          'xp': data['xp'] ?? 0,
          'coins': data['coins'] ?? 0,
        };
      }
      return {'xp': 0, 'coins': 0};
    } catch (e) {
      print('Error getting user stats: $e');
      return {'xp': 0, 'coins': 0};
    }
  }

  // Kullanıcının mevcut XP ve coin bilgilerini yazdır
  Future<void> printUserStats() async {
    final stats = await getUserStats();
    print('📊 Kullanıcı İstatistikleri:');
    print('   XP: ${stats['xp']}');
    print('   Coin: ${stats['coins']}');
  }
}
