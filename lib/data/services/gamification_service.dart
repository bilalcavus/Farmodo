// ignore_for_file: unused_local_variable

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:farmodo/core/components/message/gamification_notifications.dart';
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

  List<Achievement>? _cachedAchievements;
  DateTime? _achievementsFetchedAt;
  List<Quest>? _cachedQuests;
  DateTime? _questsFetchedAt;

  List<UserAchievement>? _cachedUserAchievements;
  DateTime? _userAchievementsFetchedAt;
  List<UserQuest>? _cachedUserQuests;
  DateTime? _userQuestsFetchedAt;

  static const Duration _defaultTtl = Duration(seconds: 60);
  static const Duration _userTtl = Duration(seconds: 20);

  // Notification service
  final GamificationNotifications _notifications = GamificationNotifications();

  bool _isFresh(DateTime? fetchedAt, Duration ttl) {
    if (fetchedAt == null) return false;
    return DateTime.now().difference(fetchedAt) < ttl;
  }

  Future<List<Achievement>> getAchievements({bool forceRefresh = false}) async {
    if (!forceRefresh && _isFresh(_achievementsFetchedAt, _defaultTtl) && _cachedAchievements != null) {
      debugPrint('achievements cache get edildi');
      return _cachedAchievements!;
    }
    try {
      final snapshot = await _firestore.collection('achievements').get();
      final fetched = snapshot.docs.map((doc) => Achievement.fromFirestore(doc)).toList();
      if (fetched.isNotEmpty) {
        _cachedAchievements = fetched;
        _achievementsFetchedAt = DateTime.now();
        debugPrint('achievements get edildi');
        return _cachedAchievements!;
      } else {
        debugPrint('achievements fetch boş, cache döndürüldü');
        return _cachedAchievements ?? [];
      }
    } catch (e) {
      return _cachedAchievements ?? [];
    }
  }

  // Kullanıcının başarılarını getir
  Future<List<UserAchievement>> getUserAchievements({bool forceRefresh = false}) async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return [];

    if (!forceRefresh && _isFresh(_userAchievementsFetchedAt, _userTtl) && _cachedUserAchievements != null) {
      debugPrint('user achievements cache get edildi');
      return _cachedUserAchievements!;
    }

    try {
      final snapshot = await _firestore
          .collection('users')
          .doc(uid)
          .collection('achievements')
          .get();
      final fetched = snapshot.docs.map((doc) => UserAchievement.fromFirestore(doc)).toList();
      if (fetched.isNotEmpty) {
        _cachedUserAchievements = fetched;
        _userAchievementsFetchedAt = DateTime.now();
        debugPrint('user achievements get edildi');
        return _cachedUserAchievements!;
      } else {
        debugPrint('user achievements fetch boş, cache döndürüldü');
        return _cachedUserAchievements ?? [];
      }
    } catch (e) {
      return _cachedUserAchievements ?? [];
    }
  }

  // Görevleri getir
  Future<List<Quest>> getQuests({bool forceRefresh = false}) async {
    if (!forceRefresh && _isFresh(_questsFetchedAt, _defaultTtl) && _cachedQuests != null) {
      debugPrint('quests cache get edildi');
      return _cachedQuests!;
    }
    try {
      final snapshot = await _firestore.collection('quests').get();
      final fetched = snapshot.docs.map((doc) => Quest.fromFirestore(doc)).toList();
      if (fetched.isNotEmpty) {
        _cachedQuests = fetched;
        _questsFetchedAt = DateTime.now();
        debugPrint('quests get edildi');
        return _cachedQuests!;
      } else {
        debugPrint('quests fetch boş, cache döndürüldü');
        return _cachedQuests ?? [];
      }
    } catch (e) {
      return _cachedQuests ?? [];
    }
  }

  // Kullanıcının görevlerini getir
  Future<List<UserQuest>> getUserQuests({bool forceRefresh = false}) async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return [];

    if (!forceRefresh && _isFresh(_userQuestsFetchedAt, _userTtl) && _cachedUserQuests != null) {
      debugPrint('user quests cache get edildi');
      return _cachedUserQuests!;
    }

    try {
      final snapshot = await _firestore
          .collection('users')
          .doc(uid)
          .collection('quests')
          .get();
      final fetched = snapshot.docs.map((doc) => UserQuest.fromFirestore(doc)).toList();
      if (fetched.isNotEmpty) {
        _cachedUserQuests = fetched;
        _userQuestsFetchedAt = DateTime.now();
        debugPrint('user quests get edildi');
        return _cachedUserQuests!;
      } else {
        debugPrint('user quests fetch boş, cache döndürüldü');
        return _cachedUserQuests ?? [];
      }
    } catch (e) {
      return _cachedUserQuests ?? [];
    }
  }

  // Başarı ilerlemesini güncelle
  Future<void> updateAchievementProgress(
    String achievementId,
    int progress, {
    Achievement? achievement,
    UserAchievement? existingUserAchievement,
  }) async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return;

    try {
      final userAchievementExists = existingUserAchievement != null ||
          (await _firestore
                  .collection('users')
                  .doc(uid)
                  .collection('achievements')
                  .doc(achievementId)
                  .get())
              .exists;

      final resolvedAchievement = achievement ?? await _getAchievementById(achievementId);

      if (userAchievementExists) {
        final isUnlocked = existingUserAchievement?.isUnlocked ?? false;
        if (resolvedAchievement != null && progress >= resolvedAchievement.targetValue && !isUnlocked) {
          await _unlockAchievement(achievementId, resolvedAchievement);
        } else {
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
      _userAchievementsFetchedAt = null;
    } catch (e) {
      // Error updating achievement progress
    }
  }

  // Görev ilerlemesini güncelle
  Future<void> updateQuestProgress(
    String questId,
    int progress, {
    Quest? quest,
    UserQuest? existingUserQuest,
  }) async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return;

    try {
      final userQuestExists = existingUserQuest != null ||
          (await _firestore
                  .collection('users')
                  .doc(uid)
                  .collection('quests')
                  .doc(questId)
                  .get())
              .exists;

      final resolvedQuest = quest ?? await _getQuestById(questId);

      if (userQuestExists) {
        final isCompleted = existingUserQuest?.status == QuestStatus.completed;
        if (resolvedQuest != null && progress >= resolvedQuest.targetValue && !isCompleted) {
          await _completeQuest(questId, resolvedQuest);
        } else {
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

      // Invalidate user cache entry for accuracy
      _userQuestsFetchedAt = null;
    } catch (e) {
      // Error updating quest progress
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
      
      // UI'ya bildir
      _notifications.showAchievementUnlocked(achievement);
    } catch (e) {
      // Error unlocking achievement
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
      
      // UI'ya bildir
      _notifications.showQuestCompleted(quest);
    } catch (e) {
      // Error completing quest
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
    } catch (e) {
      // Error giving XP reward
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
    } catch (e) {
      // Error giving coin reward
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
      return null;
    }
  }

  // Hayvan bakım aksiyonları için gamification tetikle
  Future<void> triggerCareAction(String actionType, {String? animalId}) async {
    try {
      // Başarıları ve kullanıcı ilerlemelerini tek seferde al
      final achievements = await getAchievements();
      final userAchievements = await getUserAchievements(forceRefresh: true);
      for (final achievement in achievements) {
        if (achievement.type.toString().contains(actionType) ) {
          final userAchievement = userAchievements.firstWhereOrNull(
            (ua) => ua.achievementId == achievement.id,
          );
          final currentProgress = userAchievement?.progress ?? 0;
          await updateAchievementProgress(
            achievement.id,
            currentProgress + 1,
            achievement: achievement,
            existingUserAchievement: userAchievement,
          );
        }
      }

      // Görevleri ve kullanıcı görev ilerlemelerini tek seferde al
      final quests = await getQuests();
      final userQuests = await getUserQuests(forceRefresh: true);
      for (final quest in quests) {
        if (quest.action.toString().contains(actionType) && quest.isActive) {
          final userQuest = userQuests.firstWhereOrNull(
            (uq) => uq.questId == quest.id,
          );
          final currentProgress = userQuest?.progress ?? 0;
          await updateQuestProgress(
            quest.id,
            currentProgress + 1,
            quest: quest,
            existingUserQuest: userQuest,
          );
        }
      }
    } catch (e) {
      // Error triggering care action
    }
  }

  Future<void> triggerAnimalCountChange(int animalCount) async {
    try {
      final achievements = await getAchievements();
      final userAchievements = await getUserAchievements(forceRefresh: true);
      for (final achievement in achievements) {
        if (achievement.type == AchievementType.animalCount) {
          final userAchievement = userAchievements.firstWhereOrNull(
            (ua) => ua.achievementId == achievement.id,
          );
          await updateAchievementProgress(
            achievement.id,
            animalCount,
            achievement: achievement,
            existingUserAchievement: userAchievement,
          );
        }
      }

      final quests = await getQuests();
      final userQuests = await getUserQuests(forceRefresh: true);
      for (final quest in quests) {
        if (quest.action == QuestAction.collectAnimals && quest.isActive) {
          final userQuest = userQuests.firstWhereOrNull(
            (uq) => uq.questId == quest.id,
          );
          await updateQuestProgress(
            quest.id,
            animalCount,
            quest: quest,
            existingUserQuest: userQuest,
          );
        }
      }
    } catch (e) {
      // Error triggering animal count change
    }
  }

  Future<void> triggerAnimalLevelUp(int level) async {
    try {
      final achievements = await getAchievements(forceRefresh: true);
      for (final achievement in achievements) {
        if (achievement.type == AchievementType.animalLevel) {
          await updateAchievementProgress(
            achievement.id,
            level,
            achievement: achievement,
          );
        }
      }

      final quests = await getQuests();
      final userQuests = await getUserQuests();
      for (final quest in quests) {
        if (quest.action == QuestAction.levelUpAnimals && quest.isActive) {
          final userQuest = userQuests.firstWhereOrNull(
            (uq) => uq.questId == quest.id,
          );
          final currentProgress = userQuest?.progress ?? 0;
          final newProgress = currentProgress + 1;
          await updateQuestProgress(
            quest.id,
            newProgress,
            quest: quest,
            existingUserQuest: userQuest,
          );
        }
      }
    } catch (e) {
      // Error triggering animal level up
    }
  }

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
      return {'xp': 0, 'coins': 0};
    }
  }

  Future<void> triggerAnimalPurchase(String rewardId) async {
    try {
      final achievements = await getAchievements();
      final userAchievements = await getUserAchievements();
      for (final achievement in achievements) {
        if (achievement.type == AchievementType.animalCount) {
          final userAchievement = userAchievements.firstWhereOrNull(
            (ua) => ua.achievementId == achievement.id,
          );
          final currentProgress = userAchievement?.progress ?? 0;
          await updateAchievementProgress(
            achievement.id,
            currentProgress + 1,
            achievement: achievement,
            existingUserAchievement: userAchievement,
          );
        }
      }

      final quests = await getQuests();
      final userQuests = await getUserQuests();
      for (final quest in quests) {
        if (quest.action == QuestAction.buyAnimals && quest.isActive) {
          final userQuest = userQuests.firstWhereOrNull(
            (uq) => uq.questId == quest.id,
          );
          final currentProgress = userQuest?.progress ?? 0;
          await updateQuestProgress(
            quest.id,
            currentProgress + 1,
            quest: quest,
            existingUserQuest: userQuest,
          );
        }
      }
    } catch (e) {
      // Error triggering animal purchase
    }
  }

  Future<void> printUserStats() async {
    final stats = await getUserStats();
  }
}
