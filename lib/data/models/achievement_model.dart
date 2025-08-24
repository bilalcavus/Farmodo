import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

enum AchievementType {
  animalCount,      // Belirli sayıda hayvan sahibi olma
  careActions,      // Bakım aksiyonları (besleme, sevgi, oyun)
  animalLevel,      // Hayvan seviyesi
  streak,           // Ardışık günler
  collection,       // Koleksiyon tamamlama
  special,          // Özel başarılar
}

enum AchievementRarity {
  common,     // Yaygın
  uncommon,   // Nadir
  rare,       // Az bulunur
  epic,       // Efsanevi
  legendary,  // Efsane
}

class Achievement {
  final String id;
  final String title;
  final String description;
  final String iconPath;
  final AchievementType type;
  final AchievementRarity rarity;
  final int targetValue;
  final int xpReward;
  final bool isUnlocked;
  final DateTime? unlockedAt;
  final Map<String, dynamic>? metadata;

  Achievement({
    required this.id,
    required this.title,
    required this.description,
    required this.iconPath,
    required this.type,
    required this.rarity,
    required this.targetValue,
    required this.xpReward,
    this.isUnlocked = false,
    this.unlockedAt,
    this.metadata,
  });

  factory Achievement.fromJson(Map<String, dynamic> json) {
    return Achievement(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      iconPath: json['iconPath'],
      type: AchievementType.values.firstWhere(
        (e) => e.toString() == 'AchievementType.${json['type']}',
      ),
      rarity: AchievementRarity.values.firstWhere(
        (e) => e.toString() == 'AchievementRarity.${json['rarity']}',
      ),
      targetValue: json['targetValue'],
      xpReward: json['xpReward'],
      isUnlocked: json['isUnlocked'] ?? false,
      unlockedAt: json['unlockedAt'] != null 
          ? DateTime.parse(json['unlockedAt']) 
          : null,
      metadata: json['metadata'],
    );
  }

  factory Achievement.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Achievement(
      id: doc.id,
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      iconPath: data['iconPath'] ?? '',
      type: AchievementType.values.firstWhere(
        (e) => e.toString() == 'AchievementType.${data['type']}',
      ),
      rarity: AchievementRarity.values.firstWhere(
        (e) => e.toString() == 'AchievementRarity.${data['rarity']}',
      ),
      targetValue: data['targetValue'] ?? 0,
      xpReward: data['xpReward'] ?? 0,
      isUnlocked: data['isUnlocked'] ?? false,
      unlockedAt: data['unlockedAt'] != null 
          ? (data['unlockedAt'] as Timestamp).toDate() 
          : null,
      metadata: data['metadata'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'iconPath': iconPath,
      'type': type.toString().split('.').last,
      'rarity': rarity.toString().split('.').last,
      'targetValue': targetValue,
      'xpReward': xpReward,
      'isUnlocked': isUnlocked,
      'unlockedAt': unlockedAt?.toIso8601String(),
      'metadata': metadata,
    };
  }

  Map<String, dynamic> toFirestore() {
    return {
      'title': title,
      'description': description,
      'iconPath': iconPath,
      'type': type.toString().split('.').last,
      'rarity': rarity.toString().split('.').last,
      'targetValue': targetValue,
      'xpReward': xpReward,
      'isUnlocked': isUnlocked,
      'unlockedAt': unlockedAt != null ? Timestamp.fromDate(unlockedAt!) : null,
      'metadata': metadata,
    };
  }

  Achievement copyWith({
    String? id,
    String? title,
    String? description,
    String? iconPath,
    AchievementType? type,
    AchievementRarity? rarity,
    int? targetValue,
    int? xpReward,
    bool? isUnlocked,
    DateTime? unlockedAt,
    Map<String, dynamic>? metadata,
  }) {
    return Achievement(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      iconPath: iconPath ?? this.iconPath,
      type: type ?? this.type,
      rarity: rarity ?? this.rarity,
      targetValue: targetValue ?? this.targetValue,
      xpReward: xpReward ?? this.xpReward,
      isUnlocked: isUnlocked ?? this.isUnlocked,
      unlockedAt: unlockedAt ?? this.unlockedAt,
      metadata: metadata ?? this.metadata,
    );
  }

  // Başarı rengini döndür
  Color get rarityColor {
    switch (rarity) {
      case AchievementRarity.common:
        return Colors.grey;
      case AchievementRarity.uncommon:
        return Colors.green;
      case AchievementRarity.rare:
        return Colors.blue;
      case AchievementRarity.epic:
        return Colors.purple;
      case AchievementRarity.legendary:
        return Colors.orange;
    }
  }

  // Başarı ikonunu döndür
  IconData get rarityIcon {
    switch (rarity) {
      case AchievementRarity.common:
        return Icons.star_border;
      case AchievementRarity.uncommon:
        return Icons.star_half;
      case AchievementRarity.rare:
        return Icons.star;
      case AchievementRarity.epic:
        return Icons.star;
      case AchievementRarity.legendary:
        return Icons.auto_awesome;
    }
  }
}

class UserAchievement {
  final String id;
  final String userId;
  final String achievementId;
  final int progress;
  final bool isUnlocked;
  final DateTime? unlockedAt;
  final DateTime lastUpdated;

  UserAchievement({
    required this.id,
    required this.userId,
    required this.achievementId,
    required this.progress,
    this.isUnlocked = false,
    this.unlockedAt,
    required this.lastUpdated,
  });

  factory UserAchievement.fromJson(Map<String, dynamic> json) {
    return UserAchievement(
      id: json['id'],
      userId: json['userId'],
      achievementId: json['achievementId'],
      progress: json['progress'] ?? 0,
      isUnlocked: json['isUnlocked'] ?? false,
      unlockedAt: json['unlockedAt'] != null 
          ? DateTime.parse(json['unlockedAt']) 
          : null,
      lastUpdated: DateTime.parse(json['lastUpdated']),
    );
  }

  factory UserAchievement.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return UserAchievement(
      id: doc.id,
      userId: data['userId'] ?? '',
      achievementId: data['achievementId'] ?? '',
      progress: data['progress'] ?? 0,
      isUnlocked: data['isUnlocked'] ?? false,
      unlockedAt: data['unlockedAt'] != null 
          ? (data['unlockedAt'] as Timestamp).toDate() 
          : null,
      lastUpdated: (data['lastUpdated'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'achievementId': achievementId,
      'progress': progress,
      'isUnlocked': isUnlocked,
      'unlockedAt': unlockedAt?.toIso8601String(),
      'lastUpdated': lastUpdated.toIso8601String(),
    };
  }

  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'achievementId': achievementId,
      'progress': progress,
      'isUnlocked': isUnlocked,
      'unlockedAt': unlockedAt != null ? Timestamp.fromDate(unlockedAt!) : null,
      'lastUpdated': Timestamp.fromDate(lastUpdated),
    };
  }

  UserAchievement copyWith({
    String? id,
    String? userId,
    String? achievementId,
    int? progress,
    bool? isUnlocked,
    DateTime? unlockedAt,
    DateTime? lastUpdated,
  }) {
    return UserAchievement(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      achievementId: achievementId ?? this.achievementId,
      progress: progress ?? this.progress,
      isUnlocked: isUnlocked ?? this.isUnlocked,
      unlockedAt: unlockedAt ?? this.unlockedAt,
      lastUpdated: lastUpdated ?? this.lastUpdated,
    );
  }
}
