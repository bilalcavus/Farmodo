import 'package:farmodo/data/models/achievement_model.dart';
import 'package:farmodo/data/models/quest_model.dart';

class GamificationSampleData {
    static DateTime getTodayStart(){
      final now = DateTime.now();
      return DateTime(now.year, now.month, now.day);
    }

      static DateTime getTomorrowStart(){
      final todayStart = getTodayStart();
      return todayStart.add(const Duration(days: 1));
    }

    static DateTime getWeekStart(){
      final now = DateTime.now();
      return DateTime(now.year, now.month, now.day)
            .subtract(Duration(days: now.weekday - 1));
    }
    
    static DateTime getNextWeekStart() {
      return getWeekStart().add(const Duration(days: 7));
    }
  // Örnek başarılar
  static List<Achievement> getSampleAchievements() {
    return [
      // Hayvan sayısı başarıları
      Achievement(
        id: 'first_animal',
        title: 'İlk Arkadaşım',
        description: 'İlk hayvanınızı satın aldınız!',
        iconPath: 'assets/icons/achievements/first_animal.png',
        type: AchievementType.animalCount,
        rarity: AchievementRarity.common,
        targetValue: 1,
        xpReward: 50,
      ),
      
      Achievement(
        id: 'animal_collector',
        title: 'Hayvan Koleksiyoncusu',
        description: '5 farklı hayvan edinin.',
        iconPath: 'assets/icons/achievements/animal_collector.png',
        type: AchievementType.animalCount,
        rarity: AchievementRarity.uncommon,
        targetValue: 5,
        xpReward: 150,
      ),
      
      Achievement(
        id: 'zoo_keeper',
        title: 'Hayvanat Bahçesi Sahibi',
        description: '10 hayvanınız olsun.',
        iconPath: 'assets/icons/achievements/zoo_keeper.png',
        type: AchievementType.animalCount,
        rarity: AchievementRarity.rare,
        targetValue: 10,
        xpReward: 300,
      ),
      
      Achievement(
        id: 'mega_farm',
        title: 'Mega Çiftlik',
        description: '25 hayvanınız olsun.',
        iconPath: 'assets/icons/achievements/mega_farm.png',
        type: AchievementType.animalCount,
        rarity: AchievementRarity.epic,
        targetValue: 25,
        xpReward: 500,
      ),
      
      Achievement(
        id: 'ultimate_farmer',
        title: 'Efsane Çiftçi',
        description: '50 hayvanınız olsun.',
        iconPath: 'assets/icons/achievements/ultimate_farmer.png',
        type: AchievementType.animalCount,
        rarity: AchievementRarity.legendary,
        targetValue: 50,
        xpReward: 1000,
      ),
      
      // Bakım aksiyonları başarıları
      Achievement(
        id: 'feeder',
        title: 'Beslenme Uzmanı',
        description: '100 kez hayvan besleyin.',
        iconPath: 'assets/icons/achievements/feeder.png',
        type: AchievementType.feedAnimals,
        rarity: AchievementRarity.common,
        targetValue: 100,
        xpReward: 100,
      ),
      
      Achievement(
        id: 'love_giver',
        title: 'Sevgi Dolu Kalp',
        description: '100 kez hayvanlara sevgi gösterin.',
        iconPath: 'assets/icons/achievements/love_giver.png',
        type: AchievementType.loveAnimals,
        rarity: AchievementRarity.common,
        targetValue: 100,
        xpReward: 100,
      ),
      
      Achievement(
        id: 'play_master',
        title: 'Oyun Ustası',
        description: '100 kez hayvanlarla oynayın.',
        iconPath: 'assets/icons/achievements/play_master.png',
        type: AchievementType.playWithAnimals,
        rarity: AchievementRarity.common,
        targetValue: 100,
        xpReward: 100,
      ),
      
      Achievement(
        id: 'healer',
        title: 'Şifacı',
        description: '50 kez hayvan iyileştirin.',
        iconPath: 'assets/icons/achievements/healer.png',
        type: AchievementType.healAnimals,
        rarity: AchievementRarity.uncommon,
        targetValue: 50,
        xpReward: 150,
      ),
      
      Achievement(
        id: 'care_legend',
        title: 'Bakım Efsanesi',
        description: '1000 bakım aksiyonu gerçekleştirin.',
        iconPath: 'assets/icons/achievements/care_legend.png',
        type: AchievementType.healAnimals,
        rarity: AchievementRarity.legendary,
        targetValue: 1000,
        xpReward: 1500,
      ),
      
      // Özel başarılar
      Achievement(
        id: 'early_bird',
        title: 'Erken Kalkan',
        description: 'Sabah 7\'den önce çiftliğinizi ziyaret edin.',
        iconPath: 'assets/icons/achievements/early_bird.png',
        type: AchievementType.special,
        rarity: AchievementRarity.uncommon,
        targetValue: 1,
        xpReward: 75,
      ),
      
      Achievement(
        id: 'night_owl',
        title: 'Gece Kuşu',
        description: 'Gece 22\'den sonra çiftliğinizi ziyaret edin.',
        iconPath: 'assets/icons/achievements/night_owl.png',
        type: AchievementType.special,
        rarity: AchievementRarity.uncommon,
        targetValue: 1,
        xpReward: 75,
      ),
      
      Achievement(
        id: 'perfect_day',
        title: 'Mükemmel Gün',
        description: 'Bir günde tüm hayvanlarınızı besleyin, sevin ve iyileştirin.',
        iconPath: 'assets/icons/achievements/perfect_day.png',
        type: AchievementType.special,
        rarity: AchievementRarity.rare,
        targetValue: 1,
        xpReward: 200,
      ),
    ];
  }
  
  // Örnek görevler
  static List<Quest> getSampleQuests() {
    final now = DateTime.now();
    
    return [
      // Günlük görevler
      Quest(
        id: 'daily_feed_5',
        title: 'Günlük Beslenme',
        description: '5 hayvanınızı besleyin.',
        iconPath: 'assets/icons/quests/daily_feed.png',
        type: QuestType.daily,
        action: QuestAction.feedAnimals,
        status: QuestStatus.active,
        targetValue: 5,
        xpReward: 50,
        coinReward: 25,
        startDate: getTodayStart(),
        endDate: getTomorrowStart(),
        lastReset: now,
      ),
      
      Quest(
        id: 'daily_love_3',
        title: 'Günlük Sevgi',
        description: '3 hayvanınıza sevgi gösterin.',
        iconPath: 'assets/icons/quests/daily_love.png',
        type: QuestType.daily,
        action: QuestAction.loveAnimals,
        status: QuestStatus.active,
        targetValue: 3,
        xpReward: 40,
        coinReward: 20,
        startDate: getTodayStart(),
        endDate: getTomorrowStart(),
        lastReset: now,
      ),
      
      Quest(
        id: 'daily_play_2',
        title: 'Günlük Oyun',
        description: '2 hayvanınızla oynayın.',
        iconPath: 'assets/icons/quests/daily_play.png',
        type: QuestType.daily,
        action: QuestAction.playWithAnimals,
        status: QuestStatus.active,
        targetValue: 2,
        xpReward: 30,
        coinReward: 15,
        startDate: getTodayStart(),
        endDate: getTomorrowStart(),
        lastReset: now,
      ),
      
      // Haftalık görevler
      Quest(
        id: 'weekly_feed_50',
        title: 'Haftalık Beslenme Şampiyonu',
        description: '50 hayvan besleyin.',
        iconPath: 'assets/icons/quests/weekly_feed.png',
        type: QuestType.weekly,
        action: QuestAction.feedAnimals,
        status: QuestStatus.active,
        targetValue: 50,
        xpReward: 200,
        coinReward: 100,
        startDate: getWeekStart(),
        endDate: getNextWeekStart(),
        lastReset: now,
      ),
      
      Quest(
        id: 'weekly_buy_animal',
        title: 'Yeni Arkadaş Edinin',
        description: '1 yeni hayvan satın alın.',
        iconPath: 'assets/icons/quests/weekly_buy.png',
        type: QuestType.weekly,
        action: QuestAction.buyAnimals,
        status: QuestStatus.active,
        targetValue: 1,
        xpReward: 150,
        coinReward: 75,
        startDate: getWeekStart(),
        endDate: getNextWeekStart(),
        lastReset: now,
      ),
      
      Quest(
        id: 'weekly_level_up',
        title: 'Seviye Atlama',
        description: '3 hayvanınızı seviye atlatin.',
        iconPath: 'assets/icons/quests/weekly_level.png',
        type: QuestType.weekly,
        action: QuestAction.levelUpAnimals,
        status: QuestStatus.active,
        targetValue: 3,
        xpReward: 250,
        coinReward: 125,
        startDate: getWeekStart(),
        endDate: getNextWeekStart(),
        lastReset: now,
      ),
      
      // Özel görevler
      Quest(
        id: 'special_heal_sick',
        title: 'Şifa Dağıtın',
        description: '10 hasta hayvanı iyileştirin.',
        iconPath: 'assets/icons/quests/special_heal.png',
        type: QuestType.special,
        action: QuestAction.healAnimals,
        status: QuestStatus.active,
        targetValue: 10,
        xpReward: 300,
        coinReward: 150,
        startDate: now,
        endDate: now.add(const Duration(days: 3)),
        lastReset: now,
      ),
      
      Quest(
        id: 'special_collection',
        title: 'Koleksiyon Başlangıcı',
        description: '5 farklı türde hayvan edinin.',
        iconPath: 'assets/icons/quests/special_collection.png',
        type: QuestType.special,
        action: QuestAction.collectAnimals,
        status: QuestStatus.active,
        targetValue: 5,
        xpReward: 400,
        coinReward: 200,
        startDate: now,
        endDate: now.add(const Duration(days: 5)),
        lastReset: now
      ),
      
      // Etkinlik görevleri
      Quest(
        id: 'event_weekend',
        title: 'Hafta Sonu Şenliği',
        description: 'Hafta sonu boyunca 20 bakım aksiyonu yapın.',
        iconPath: 'assets/icons/quests/event_weekend.png',
        type: QuestType.event,
        action: QuestAction.feedAnimals, // Mixed actions için feedAnimals base
        status: QuestStatus.active,
        targetValue: 20,
        xpReward: 500,
        coinReward: 250,
        startDate: now,
        endDate: now.add(const Duration(days: 2)),
      ),
    ];
  }
}

