// ignore_for_file: unused_local_variable

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:farmodo/core/components/message/gamification_notifications.dart';
import 'package:farmodo/data/models/achievement_model.dart';
import 'package:farmodo/data/models/quest_model.dart';
import 'package:farmodo/data/services/gamification/gamification_cache.dart';
import 'package:farmodo/data/services/gamification/gamification_repository.dart';
import 'package:farmodo/feature/gamification/widget/achievements/achievement_unlock_animation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class GamificationService {
  static GamificationService? _instance;

  factory GamificationService({
    GamificationRepository? repository,
    GamificationCache? cache,
  }) {
    _instance ??= GamificationService._internal(
      repository ?? GamificationRepository(),
      cache ?? GamificationCache(),
    );
    return _instance!;
  }

  GamificationService._internal(this._repository, this._cache);

  final GamificationRepository _repository;
  final GamificationCache _cache;



  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  DateTime? userAchievementsFetchedAt;
  DateTime? userQuestsFetchedAt;


  final GamificationNotifications _notifications = GamificationNotifications();

  Future<List<Achievement>> fetchAchievements({bool forceRefresh = false}) async {
    final cacheKey = "achievements";
    if (forceRefresh == false) {
      final cached = _cache.get<Achievement>(cacheKey);
      debugPrint('achievements cache fetched.');
      if (cached != null) return cached;
    }
    
    final achievements = await _repository.fetchCollection(
      path: 'achievements',
      fromFirestore: (doc) => Achievement.fromFirestore(doc)
    );
    _cache.set(cacheKey, achievements);
    return achievements;
  } 


  Future<List<UserAchievement>> fetchUserAchievements({bool forceRefresh = false}) async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return [];

    final cacheKey = "user_achievements";
    if (forceRefresh == false) {
      final cached = _cache.get<UserAchievement>(cacheKey);
      debugPrint('user achievements cache fetched.');
      if(cached != null) return cached;
    }

    final userAchievements = await _repository.fetchSubCollection(
      parentCollection: 'users',
      parentId: uid,
      subCollection: 'achievements',
      fromFirestore: (doc) => UserAchievement.fromFirestore(doc),
    );
    _cache.set(cacheKey, userAchievements);
    return userAchievements;
  }


  Future<List<Quest>> fetchQuests({bool forceRefresh = false}) async {
    final cacheKey = "quests";
    if(forceRefresh == false){
      final cached = _cache.get<Quest>(cacheKey);
      debugPrint('quest cache fetched.');
      if(cached != null) return cached;
    }

    final quests = await _repository.fetchCollection(
      path: 'quests',
      fromFirestore: (doc) => Quest.fromFirestore(doc));

      _cache.set(cacheKey, quests);
      return quests;
  }


  Future<List<UserQuest>> fetchUserQuests({bool forceRefresh = false}) async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return [];

    final cacheKey = "user_quests";
    if(forceRefresh == false){
      final cached = _cache.get<UserQuest>(cacheKey);
      debugPrint('user quest cache fetched.');
      if(cached != null) return cached;
    }

    final quests = await _repository.fetchSubCollection(
      parentCollection: "users",
      parentId: uid,
      subCollection: "quests",
      fromFirestore: (doc) => UserQuest.fromFirestore(doc)
    );

    _cache.set(cacheKey, quests);
    return quests;
  }


  Future<void> updateAchievementProgress(
  String achievementId,
  int progress, {
  Achievement? achievement,
  UserAchievement? existingUserAchievement,
}) async {
  final uid = _auth.currentUser?.uid;
  if (uid == null) return;

  final collectionPath = 'users/$uid/achievements';
  final exists = existingUserAchievement != null ||
      await _repository.documentExists(
        collectionPath: collectionPath,
        docId: achievementId,
      );

  final resolvedAchievement = achievement ?? await _getAchievementById(achievementId);

  if (exists) {
    final isUnlocked = existingUserAchievement?.isUnlocked ?? false;
    if (resolvedAchievement != null &&
        progress >= resolvedAchievement.targetValue &&
        !isUnlocked) {
      await _unlockAchievement(achievementId, resolvedAchievement);
    } else {
      await _repository.updateDocument(
        collectionPath: collectionPath,
        docId: achievementId,
        data: {
          'progress': progress,
          'lastUpdated': Timestamp.fromDate(DateTime.now()),
        },
      );
    }
  } else {
    await _repository.setDocument(
      collectionPath: collectionPath,
      docId: achievementId,
      data: {
        'userId': uid,
        'achievementId': achievementId,
        'progress': progress,
        'isUnlocked': false,
        'lastUpdated': Timestamp.fromDate(DateTime.now()),
      },
    );
  }

  userAchievementsFetchedAt = null;
  // final cached = await fetchUserAchievements(forceRefresh: true);
  // _cache.set("user_achievements", cached);
}

Future<void> updateQuestProgress(
  String questId,
  int progress, {
  Quest? quest,
  UserQuest? existingUserQuest,
}) async {
  final uid = _auth.currentUser?.uid;
  if (uid == null) return;

  final collectionPath = 'users/$uid/quests';
  final exists = existingUserQuest != null ||
      await _repository.documentExists(
        collectionPath: collectionPath,
        docId: questId,
      );

  final resolvedQuest = quest ?? await _getQuestById(questId);

  if (exists) {
    final isCompleted = existingUserQuest?.status == QuestStatus.completed;
    if (resolvedQuest != null && progress >= resolvedQuest.targetValue && !isCompleted) {
      await _completeQuest(questId, resolvedQuest);
    } else {
      await _repository.updateDocument(
        collectionPath: collectionPath,
        docId: questId,
        data: {
          'progress': progress,
          'lastUpdated': Timestamp.fromDate(DateTime.now()),
        },
      );
    }
  } else {
    await _repository.setDocument(
      collectionPath: collectionPath,
      docId: questId,
      data: {
        'userId': uid,
        'questId': questId,
        'progress': progress,
        'status': 'active',
        'lastUpdated': Timestamp.fromDate(DateTime.now()),
        'questRef': _firestore.collection('quests').doc(questId),
        'type': resolvedQuest?.type.name,
        'startDate': resolvedQuest?.startDate,
        'endDate': resolvedQuest?.endDate,
      },
    );
  }

  userQuestsFetchedAt = null;
  // final cached = await fetchUserQuests(forceRefresh: true);
  // _cache.set("user_quests", cached);
}


  Future<void> _unlockAchievement(String achievementId, Achievement achievement) async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return;

    try {
      final collectionPath = 'users/$uid/achievements';
      await _repository.updateDocument(
        collectionPath: collectionPath,
        docId: achievementId,
        data: {
          'progress': achievement.targetValue,
          'isUnlocked': true,
          'unlockedAt': Timestamp.fromDate(DateTime.now()),
          'lastUpdated': Timestamp.fromDate(DateTime.now()),
        });
      await _giveXpReward(achievement.xpReward);
      _showAchievementUnlockAnimation(achievement);
      _notifications.showAchievementUnlocked(achievement);
      final cached = await fetchUserAchievements(forceRefresh: true);
      _cache.set("user_achievements", cached);
    } catch (e) {
      // Error unlocking achievement
    }
  }

  Future<void> _completeQuest(String questId, Quest quest) async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return;

    try {
      await _repository.updateDocument(
        collectionPath: 'users/$uid/quests',
        docId: questId,
        data: {
          'progress': quest.targetValue,
          'status': 'completed',
          'completedAt': Timestamp.now(),
          'lastUpdated': Timestamp.now(),
        },
      );

      await _giveXpReward(quest.xpReward);
      if (quest.coinReward > 0) await _giveCoinReward(quest.coinReward);
      
      _notifications.showQuestCompleted(quest);
      final cached = await fetchUserQuests(forceRefresh: true);
      _cache.set("user_quests", cached);
    } catch (e) {
      // Error completing quest
    }
  }

  Future<void> _giveXpReward(int xpAmount) async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return;

      await _repository.updateDocument(
        collectionPath: 'users',
        docId: uid,
        data: {'xp': FieldValue.increment(xpAmount)},
      );
  }

  Future<void> _giveCoinReward(int coinAmount) async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return;

      await _repository.updateDocument(
        collectionPath: 'users',
        docId: uid,
        data: {'coins': FieldValue.increment(coinAmount)},
      );
    
  }

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
      final achievements = await fetchAchievements();
      final userAchievements = await fetchUserAchievements(forceRefresh: true);
      for (final achievement in achievements) {
        if (achievement.type.toString().contains(actionType) ) {
          final userAchievement = userAchievements.firstWhereOrNull(
            (ua) => ua.achievementId == achievement.id,
          );
          final currentProgress = userAchievement?.progress ?? 0;
          if (currentProgress >= achievement.targetValue) {
            continue; // Zaten tamamlanmış
          }
          await updateAchievementProgress(
            achievement.id,
            currentProgress + 1,
            achievement: achievement,
            existingUserAchievement: userAchievement,
          );
        }
      }

      // Görevleri ve kullanıcı görev ilerlemelerini tek seferde al
      final quests = await fetchQuests();
      final userQuests = await fetchUserQuests(forceRefresh: true);
      for (final quest in quests) {
        if (quest.action.toString().contains(actionType) && quest.isActive) {
          final userQuest = userQuests.firstWhereOrNull(
            (uq) => uq.questId == quest.id,
          );
          final currentProgress = userQuest?.progress ?? 0;
          if (currentProgress >= quest.targetValue) {
            continue; // Zaten tamamlanmış
          }
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
      final achievements = await fetchAchievements();
      final userAchievements = await fetchUserAchievements(forceRefresh: true);
      for (final achievement in achievements) {
        if (achievement.type == AchievementType.animalCount) {
          final userAchievement = userAchievements.firstWhereOrNull(
            (ua) => ua.achievementId == achievement.id,
          );
          final currentProgress = userAchievement?.progress ?? 0;
          if (currentProgress >= achievement.targetValue) {
            continue; // Zaten tamamlanmış
          }
          await updateAchievementProgress(
            achievement.id,
            animalCount,
            achievement: achievement,
            existingUserAchievement: userAchievement,
          );
        }
      }

      final quests = await fetchQuests();
      final userQuests = await fetchUserQuests(forceRefresh: true);
      for (final quest in quests) {
        if (quest.action == QuestAction.collectAnimals && quest.isActive) {
          final userQuest = userQuests.firstWhereOrNull(
            (uq) => uq.questId == quest.id,
          );
          final currentProgress = userQuest?.progress ?? 0;
          if (currentProgress >= quest.targetValue) {
            continue; // Zaten tamamlanmış
          }
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
      final achievements = await fetchAchievements(forceRefresh: true);
      for (final achievement in achievements) {
        if (achievement.type == AchievementType.animalLevel) {
          await updateAchievementProgress(
            achievement.id,
            level,
            achievement: achievement,
          );
        }
      }

      final quests = await fetchQuests();
      final userQuests = await fetchUserQuests();
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
      final achievements = await fetchAchievements();
      final userAchievements = await fetchUserAchievements();
      for (final achievement in achievements) {
        if (achievement.type == AchievementType.animalCount) {
          final userAchievement = userAchievements.firstWhereOrNull(
            (ua) => ua.achievementId == achievement.id,
          );
          final currentProgress = userAchievement?.progress ?? 0;
          if (currentProgress >= achievement.targetValue) {
            continue; // Zaten tamamlanmış
          }
          await updateAchievementProgress(
            achievement.id,
            currentProgress + 1,
            achievement: achievement,
            existingUserAchievement: userAchievement,
          );
        }
      }

      final quests = await fetchQuests();
      final userQuests = await fetchUserQuests();
      for (final quest in quests) {
        if (quest.action == QuestAction.buyAnimals && quest.isActive) {
          final userQuest = userQuests.firstWhereOrNull(
            (uq) => uq.questId == quest.id,
          );
          final currentProgress = userQuest?.progress ?? 0;
          if (currentProgress >= quest.targetValue) {
            continue; // Zaten tamamlanmış
          }
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

}
