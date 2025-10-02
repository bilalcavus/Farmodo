import 'package:farmodo/core/utility/extension/future_extension.dart';
import 'package:farmodo/data/models/achievement_model.dart';
import 'package:farmodo/data/models/quest_model.dart';
import 'package:farmodo/data/services/gamification/gamification_service.dart';
import 'package:get/get.dart';

class GamificationController extends GetxController {
  final GamificationService _gamificationService = GamificationService();

  final RxList<Achievement> achievements = <Achievement>[].obs;
  final RxList<UserAchievement> userAchievements = <UserAchievement>[].obs;
  
  final RxList<Quest> quests = <Quest>[].obs;
  final RxList<UserQuest> userQuests = <UserQuest>[].obs;
  
  final RxBool isLoadingAchievements = false.obs;
  final RxBool isLoadingQuests = false.obs;
  final RxBool isLoadingUserData = false.obs;
  
  final RxString achievementFilter = 'All'.obs;
  final RxString questFilter = 'Aktif'.obs;

  var errorMessage = ''.obs;

  @override
  void onInit() {
    super.onInit();
    loadAllData();
  }

  Future<void> loadAllData() async {
    await Future.wait([
      loadAchievements().trackTime('fetching achievements'),
      loadQuests().trackTime('fetching quests'),
      loadUserData().trackTime('fetching user data'),
    ]);
  }

  Future<void> refreshData() async {
    await Future.wait([
      loadAchievements(forceRefresh: true),
      loadQuests(forceRefresh: true),
      loadUserData(forceRefresh: true),
    ]);
  }

  Future<void> loadAchievements({bool forceRefresh = false}) async {
    isLoadingAchievements.value = true;
    try {
      final achievementsList = await _gamificationService.fetchAchievements(forceRefresh: forceRefresh);
      achievements.assignAll(achievementsList);
    } catch (e) {
      errorMessage.value = e.toString();
    } finally {
      isLoadingAchievements.value = false;
    }
  }

  // Görevleri yükle
  Future<void> loadQuests({bool forceRefresh = false}) async {
    isLoadingQuests.value = true;
    try {
      final questsList = await _gamificationService.fetchQuests(forceRefresh: forceRefresh);
      quests.assignAll(questsList);
    } catch (e) {
      errorMessage.value = e.toString();
    } finally {
      isLoadingQuests.value = false;
    }
  }

  // Kullanıcı verilerini yükle
  Future<void> loadUserData({bool forceRefresh = false}) async {
    isLoadingUserData.value = true;
    try {
      final userAchievementsList = await _gamificationService.fetchUserAchievements(forceRefresh: forceRefresh);
      final userQuestsList = await _gamificationService.fetchUserQuests(forceRefresh: forceRefresh);
      
      userAchievements.assignAll(userAchievementsList);
      userQuests.assignAll(userQuestsList);
    } catch (e) {
      errorMessage.value = e.toString();
    } finally {
      isLoadingUserData.value = false;
    }
  }

  // Başarı ilerlemesini güncelle
  Future<void> updateAchievementProgress(String achievementId, int progress) async {
    try {
      await _gamificationService.updateAchievementProgress(achievementId, progress);
      await loadUserData(); // Kullanıcı verilerini yenile
    } catch (e) {
      errorMessage.value = e.toString();
    }
  }

  // Kullanıcının belirli bir başarısını getir
  UserAchievement? getUserAchievement(String achievementId) {
    try {
      return userAchievements.firstWhere((ua) => ua.achievementId == achievementId);
    } catch (e) {
      errorMessage.value = e.toString();
      return null;
    }
  }

  // Kullanıcının belirli bir görevini getir
  UserQuest? getUserQuest(String questId) {
    try {
      return userQuests.firstWhere((uq) => uq.questId == questId);
    } catch (e) {
      errorMessage.value = e.toString();
      return null;
    }
  }

  // Açılan başarıları getir
  List<Achievement> get unlockedAchievements {
    final unlocked = achievements.where((achievement) {
      final userAchievement = getUserAchievement(achievement.id);
      final isUnlocked = userAchievement?.isUnlocked ?? false;
      return isUnlocked;
    }).toList();
    
    return unlocked;
  }

  // Kilitli başarıları getir
  List<Achievement> get lockedAchievements {
    return achievements.where((achievement) {
      final userAchievement = getUserAchievement(achievement.id);
      return !(userAchievement?.isUnlocked ?? false);
    }).toList();
  }

  // Filtrelenmiş başarıları getir
  List<Achievement> get filteredAchievements {
    List<Achievement> result;
    switch (achievementFilter.value) {
      case 'All':
        result = achievements;
        break;
      case 'Unlocked':
        result = unlockedAchievements;
        break;
      case 'Locked':
        result = lockedAchievements;
        break;
      case 'Widespread':
        result = achievements.where((a) => a.rarity == AchievementRarity.common).toList();
        break;
      case 'Rare':
        result = achievements.where((a) => a.rarity == AchievementRarity.rare).toList();
        break;
      case 'Epic':
        result = achievements.where((a) => a.rarity == AchievementRarity.epic).toList();
        break;
      case 'Legendary':
        result = achievements.where((a) => a.rarity == AchievementRarity.legendary).toList();
        break;
      case 'Legend':
        result = achievements.where((a) => a.rarity == AchievementRarity.legendary).toList();
        break;
      default:
        result = achievements;
    }
    
    return result;
  }

  // Aktif görevleri getir
  List<Quest> get activeQuests {
    return quests.where((quest) {
      final userQuest = getUserQuest(quest.id);
      return quest.isActive && (userQuest?.status != QuestStatus.completed);
    }).toList();
  }

  // Tamamlanan görevleri getir
  List<Quest> get completedQuests {
    return quests.where((quest) {
      final userQuest = getUserQuest(quest.id);
      return userQuest?.status == QuestStatus.completed;
    }).toList();
  }

  // Süresi dolmuş görevleri getir
  List<Quest> get expiredQuests {
    return quests.where((quest) {
      return quest.isExpired;
    }).toList();
  }

  // Günlük görevleri getir
  List<Quest> get dailyQuests {
    return quests.where((quest) => quest.type == QuestType.daily).toList();
  }

  // Haftalık görevleri getir
  List<Quest> get weeklyQuests {
    return quests.where((quest) => quest.type == QuestType.weekly).toList();
  }

  // Özel görevleri getir
  List<Quest> get specialQuests {
    return quests.where((quest) => quest.type == QuestType.special).toList();
  }

  // Etkinlik görevlerini getir
  List<Quest> get eventQuests {
    return quests.where((quest) => quest.type == QuestType.event).toList();
  }

  // Filtrelenmiş görevleri getir
  List<Quest> get filteredQuests {
    switch (questFilter.value) {
      case 'Active':
        return activeQuests;
      case 'Daily':
        return dailyQuests;
      case 'Weekly':
        return weeklyQuests;
      case 'Special':
        return specialQuests;
      case 'Event':
        return eventQuests;
      case 'Completed':
        return completedQuests;
      default:
        return activeQuests;
    }
  }

  // Toplam açılan başarı sayısı
  int get totalUnlockedAchievements => unlockedAchievements.length;

  // Toplam başarı sayısı
  int get totalAchievements => achievements.length;

  // Başarı yüzdesi
  double get achievementPercentage {
    if (totalAchievements == 0) return 0.0;
    return (totalUnlockedAchievements / totalAchievements) * 100;
  }

  // Toplam aktif görev sayısı
  int get totalActiveQuests => activeQuests.length;

  // Toplam tamamlanan görev sayısı
  int get totalCompletedQuests => completedQuests.length;

  // Toplam görev sayısı
  int get totalQuests => quests.length;

  // Görev tamamlama yüzdesi
  double get questCompletionPercentage {
    if (totalQuests == 0) return 0.0;
    return (totalCompletedQuests / totalQuests) * 100;
  }

  // Kullanıcının toplam kazandığı XP
  int get totalEarnedXP {
    int total = 0;
    
    // Başarı XP'leri
    for (final achievement in unlockedAchievements) {
      total += achievement.xpReward;
    }
    
    // Görev XP'leri
    for (final quest in completedQuests) {
      total += quest.xpReward;
    }
    
    return total;
  }

  // Kullanıcının toplam kazandığı coin
  int get totalEarnedCoins {
    int total = 0;
    
    // Görev coin'leri
    for (final quest in completedQuests) {
      total += quest.coinReward;
    }
    
    return total;
  }

  // Nadirlik bazında başarı sayıları
  Map<AchievementRarity, int> get achievementsByRarity {
    final Map<AchievementRarity, int> rarityCount = {};
    
    for (final rarity in AchievementRarity.values) {
      rarityCount[rarity] = unlockedAchievements
          .where((achievement) => achievement.rarity == rarity)
          .length;
    }
    
    return rarityCount;
  }

  // Görev tipi bazında tamamlanan görev sayıları
  Map<QuestType, int> get completedQuestsByType {
    final Map<QuestType, int> typeCount = {};
    
    for (final type in QuestType.values) {
      typeCount[type] = completedQuests
          .where((quest) => quest.type == type)
          .length;
    }
    
    return typeCount;
  }

  // Başarı filtresini değiştir
  void setAchievementFilter(String filter) {
    achievementFilter.value = filter;
  }

  // Görev filtresini değiştir
  void setQuestFilter(String filter) {
    questFilter.value = filter;
  }

  Future<void> refreshGamification() async {
    await refreshData();
  }
}
