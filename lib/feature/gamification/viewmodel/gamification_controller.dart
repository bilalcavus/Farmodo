import 'package:farmodo/data/models/achievement_model.dart';
import 'package:farmodo/data/models/quest_model.dart';
import 'package:farmodo/data/services/gamification_service.dart';
import 'package:get/get.dart';

class GamificationController extends GetxController {
  final GamificationService _gamificationService = GamificationService();

  // Başarılar
  final RxList<Achievement> achievements = <Achievement>[].obs;
  final RxList<UserAchievement> userAchievements = <UserAchievement>[].obs;
  
  // Görevler
  final RxList<Quest> quests = <Quest>[].obs;
  final RxList<UserQuest> userQuests = <UserQuest>[].obs;
  
  // Loading states
  final RxBool isLoadingAchievements = false.obs;
  final RxBool isLoadingQuests = false.obs;
  final RxBool isLoadingUserData = false.obs;
  
  // Filtreleme state'leri
  final RxString achievementFilter = 'Tümü'.obs;
  final RxString questFilter = 'Aktif'.obs;

  @override
  void onInit() {
    super.onInit();
    print('🎯 GamificationController başlatıldı. Başlangıç filtresi: ${achievementFilter.value}');
    loadAllData();
  }

  // Tüm verileri yükle
  Future<void> loadAllData() async {
    await Future.wait([
      loadAchievements(),
      loadQuests(),
      loadUserData(),
    ]);
  }

  // Başarıları yükle
  Future<void> loadAchievements() async {
    isLoadingAchievements.value = true;
    try {
      final achievementsList = await _gamificationService.getAchievements();
      print('Loaded ${achievementsList.length} achievements');
      
      // Debug: Başarıların nadirlik dağılımını göster
      for (final achievement in achievementsList) {
        print('🏆 ${achievement.title}: ${achievement.rarity}');
      }
      
      achievements.assignAll(achievementsList);
    } catch (e) {
      print('Error loading achievements: $e');
    } finally {
      isLoadingAchievements.value = false;
    }
  }

  // Görevleri yükle
  Future<void> loadQuests() async {
    isLoadingQuests.value = true;
    try {
      final questsList = await _gamificationService.getQuests();
      print('Loaded ${questsList.length} quests');
      quests.assignAll(questsList);
    } catch (e) {
      print('Error loading quests: $e');
    } finally {
      isLoadingQuests.value = false;
    }
  }

  // Kullanıcı verilerini yükle
  Future<void> loadUserData() async {
    isLoadingUserData.value = true;
    try {
      final userAchievementsList = await _gamificationService.getUserAchievements();
      final userQuestsList = await _gamificationService.getUserQuests();
      
      userAchievements.assignAll(userAchievementsList);
      userQuests.assignAll(userQuestsList);
    } catch (e) {
      print('Error loading user data: $e');
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
      print('Error updating achievement progress: $e');
    }
  }

  // Görev ilerlemesini güncelle
  Future<void> updateQuestProgress(String questId, int progress) async {
    try {
      await _gamificationService.updateQuestProgress(questId, progress);
      await loadUserData(); // Kullanıcı verilerini yenile
    } catch (e) {
      print('Error updating quest progress: $e');
    }
  }

  // Kullanıcının belirli bir başarısını getir
  UserAchievement? getUserAchievement(String achievementId) {
    try {
      return userAchievements.firstWhere((ua) => ua.achievementId == achievementId);
    } catch (e) {
      return null;
    }
  }

  // Kullanıcının belirli bir görevini getir
  UserQuest? getUserQuest(String questId) {
    try {
      return userQuests.firstWhere((uq) => uq.questId == questId);
    } catch (e) {
      return null;
    }
  }

  // Açılan başarıları getir
  List<Achievement> get unlockedAchievements {
    print('🔓 Açık başarılar aranıyor...');
    print('🔓 Toplam başarı sayısı: ${achievements.length}');
    print('🔓 Kullanıcı başarı sayısı: ${userAchievements.length}');
    
    final unlocked = achievements.where((achievement) {
      final userAchievement = getUserAchievement(achievement.id);
      final isUnlocked = userAchievement?.isUnlocked ?? false;
      print('🔓 ${achievement.title}: isUnlocked = $isUnlocked');
      return isUnlocked;
    }).toList();
    
    print('🔓 Açık başarı sayısı: ${unlocked.length}');
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
    print('🎯 Filtreleme çağrıldı. Aktif filtre: ${achievementFilter.value}');
    print('🎯 Toplam başarı sayısı: ${achievements.length}');
    
    // Debug: Mevcut başarıların nadirliklerini göster
    for (final achievement in achievements) {
      print('🏆 ${achievement.title}: ${achievement.rarity}');
    }
    
    List<Achievement> result;
    switch (achievementFilter.value) {
      case 'Tümü':
        result = achievements;
        print('🎯 Tümü filtresi seçildi');
        break;
      case 'Açık':
        result = unlockedAchievements;
        print('🎯 Açık filtresi seçildi. Açık başarı sayısı: ${unlockedAchievements.length}');
        break;
      case 'Kilitli':
        result = lockedAchievements;
        print('🎯 Kilitli filtresi seçildi. Kilitli başarı sayısı: ${lockedAchievements.length}');
        break;
      case 'Yaygın':
        result = achievements.where((a) => a.rarity == AchievementRarity.common).toList();
        print('🎯 Yaygın filtresi seçildi. Yaygın başarı sayısı: ${result.length}');
        break;
      case 'Nadir':
        result = achievements.where((a) => a.rarity == AchievementRarity.rare).toList();
        print('🎯 Nadir filtresi seçildi. Nadir başarı sayısı: ${result.length}');
        break;
      case 'Az Bulunur':
        result = achievements.where((a) => a.rarity == AchievementRarity.epic).toList();
        print('🎯 Az Bulunur filtresi seçildi. Az Bulunur başarı sayısı: ${result.length}');
        break;
      case 'Efsanevi':
        result = achievements.where((a) => a.rarity == AchievementRarity.legendary).toList();
        print('🎯 Efsanevi filtresi seçildi. Efsanevi başarı sayısı: ${result.length}');
        break;
      case 'Efsane':
        result = achievements.where((a) => a.rarity == AchievementRarity.legendary).toList();
        print('🎯 Efsane filtresi seçildi. Efsane başarı sayısı: ${result.length}');
        break;
      default:
        result = achievements;
        print('🎯 Varsayılan filtre seçildi');
    }
    
    print('🎯 Filtrelenmiş başarı sayısı: ${result.length}');
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
      case 'Aktif':
        return activeQuests;
      case 'Günlük':
        return dailyQuests;
      case 'Haftalık':
        return weeklyQuests;
      case 'Özel':
        return specialQuests;
      case 'Etkinlik':
        return eventQuests;
      case 'Tamamlanan':
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
    print('🎯 Başarı filtresi değiştiriliyor: $filter');
    achievementFilter.value = filter;
    print('🎯 Filtrelenmiş başarı sayısı: ${filteredAchievements.length}');
  }

  // Görev filtresini değiştir
  void setQuestFilter(String filter) {
    questFilter.value = filter;
  }

  // Yenile
  Future<void> refresh() async {
    await loadAllData();
  }
}
