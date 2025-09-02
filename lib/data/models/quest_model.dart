import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

enum QuestType {
  daily,      // Günlük görevler
  weekly,     // Haftalık görevler
  special,    // Özel görevler
  event,      // Etkinlik görevleri
}

enum QuestStatus {
  active,     // Aktif
  completed,  // Tamamlandı
  expired,    // Süresi dolmuş
  locked,     // Kilitli
}

enum QuestAction {
  feedAnimals,        // Hayvan besleme
  loveAnimals,        // Hayvan sevme
  playWithAnimals,    // Hayvanla oynama
  healAnimals,        // Hayvan iyileştirme
  buyAnimals,         // Hayvan satın alma
  levelUpAnimals,     // Hayvan seviye atlatma
  collectAnimals,     // Hayvan toplama
  streakDays,         // Ardışık günler
  spendXP,            // XP harcama
  earnXP,             // XP kazanma
}

class Quest {
  final String id;
  final String title;
  final String description;
  final String iconPath;
  final QuestType type;
  final QuestAction action;
  final QuestStatus status;
  final int targetValue;
  final int xpReward;
  final int coinReward;
  final DateTime? startDate;
  final DateTime? endDate;
  final DateTime? lastReset;
  final Map<String, dynamic>? metadata;

  Quest({
    required this.id,
    required this.title,
    required this.description,
    required this.iconPath,
    required this.type,
    required this.action,
    required this.status,
    required this.targetValue,
    required this.xpReward,
    this.coinReward = 0,
    this.startDate,
    this.endDate,
    this.lastReset,
    this.metadata,
  });

  factory Quest.fromJson(Map<String, dynamic> json) {
    return Quest(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      iconPath: json['iconPath'],
      type: QuestType.values.firstWhere(
        (e) => e.toString() == 'QuestType.${json['type']}',
      ),
      action: QuestAction.values.firstWhere(
        (e) => e.toString() == 'QuestAction.${json['action']}',
      ),
      status: QuestStatus.values.firstWhere(
        (e) => e.toString() == 'QuestStatus.${json['status']}',
      ),
      targetValue: json['targetValue'],
      xpReward: json['xpReward'],
      coinReward: json['coinReward'] ?? 0,
      startDate: json['startDate'] != null 
          ? DateTime.parse(json['startDate']) 
          : null,
      endDate: json['endDate'] != null 
          ? DateTime.parse(json['endDate']) 
          : null,
      metadata: json['metadata'],
      lastReset: json['lastReset'] != null
          ? DateTime.parse(json['lastReset'])
          : null,
    );
  }

  factory Quest.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Quest(
      id: doc.id,
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      iconPath: data['iconPath'] ?? '',
      type: QuestType.values.firstWhere(
        (e) => e.toString() == 'QuestType.${data['type']}',
      ),
      action: QuestAction.values.firstWhere(
        (e) => e.toString() == 'QuestAction.${data['action']}',
      ),
      status: QuestStatus.values.firstWhere(
        (e) => e.toString() == 'QuestStatus.${data['status']}',
      ),
      targetValue: data['targetValue'] ?? 0,
      xpReward: data['xpReward'] ?? 0,
      coinReward: data['coinReward'] ?? 0,
      startDate: data['startDate'] != null 
          ? (data['startDate'] as Timestamp).toDate() 
          : null,
      endDate: data['endDate'] != null 
          ? (data['endDate'] as Timestamp).toDate() 
          : null,
      metadata: data['metadata'],
      lastReset: data['lastReset'] != null
          ? (data['lastReset'] as Timestamp).toDate()
          : null
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'iconPath': iconPath,
      'type': type.toString().split('.').last,
      'action': action.toString().split('.').last,
      'status': status.toString().split('.').last,
      'targetValue': targetValue,
      'xpReward': xpReward,
      'coinReward': coinReward,
      'startDate': startDate?.toIso8601String(),
      'endDate': endDate?.toIso8601String(),
      'lastReset': lastReset?.toIso8601String(),
      'metadata': metadata,
    };
  }

  Map<String, dynamic> toFirestore() {
    return {
      'title': title,
      'description': description,
      'iconPath': iconPath,
      'type': type.toString().split('.').last,
      'action': action.toString().split('.').last,
      'status': status.toString().split('.').last,
      'targetValue': targetValue,
      'xpReward': xpReward,
      'coinReward': coinReward,
      'startDate': startDate != null ? Timestamp.fromDate(startDate!) : null,
      'endDate': endDate != null ? Timestamp.fromDate(endDate!) : null,
      'lastReset': lastReset != null ? Timestamp.fromDate(lastReset!) : null,
      'metadata': metadata,
    };
  }

  Quest copyWith({
    String? id,
    String? title,
    String? description,
    String? iconPath,
    QuestType? type,
    QuestAction? action,
    QuestStatus? status,
    int? targetValue,
    int? xpReward,
    int? coinReward,
    DateTime? startDate,
    DateTime? endDate,
    Map<String, dynamic>? metadata,
    DateTime? lastReset
  }) {
    return Quest(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      iconPath: iconPath ?? this.iconPath,
      type: type ?? this.type,
      action: action ?? this.action,
      status: status ?? this.status,
      targetValue: targetValue ?? this.targetValue,
      xpReward: xpReward ?? this.xpReward,
      coinReward: coinReward ?? this.coinReward,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      metadata: metadata ?? this.metadata,
      lastReset: lastReset ?? this.lastReset
    );
  }

  // Görev rengini döndür
  Color get typeColor {
    switch (type) {
      case QuestType.daily:
        return Colors.blue;
      case QuestType.weekly:
        return Colors.purple;
      case QuestType.special:
        return Colors.orange;
      case QuestType.event:
        return Colors.red;
    }
  }

  // Görev ikonunu döndür
  IconData get actionIcon {
    switch (action) {
      case QuestAction.feedAnimals:
        return Icons.restaurant;
      case QuestAction.loveAnimals:
        return Icons.favorite;
      case QuestAction.playWithAnimals:
        return Icons.sports_esports;
      case QuestAction.healAnimals:
        return Icons.healing;
      case QuestAction.buyAnimals:
        return Icons.shopping_cart;
      case QuestAction.levelUpAnimals:
        return Icons.trending_up;
      case QuestAction.collectAnimals:
        return Icons.collections;
      case QuestAction.streakDays:
        return Icons.local_fire_department;
      case QuestAction.spendXP:
        return Icons.remove_circle;
      case QuestAction.earnXP:
        return Icons.add_circle;
    }
  }

  // Görevin süresi dolmuş mu?
  bool get isExpired {
    if (endDate == null) return false;
    return DateTime.now().isAfter(endDate!);
  }

  // Görev aktif mi?
  bool get isActive {
    if (startDate != null && DateTime.now().isBefore(startDate!)) {
      return false;
    }
    return !isExpired;
  }
}

class UserQuest {
  final String id;
  final String userId;
  final String questId;
  final int progress;
  final QuestStatus status;
  final DateTime? completedAt;
  final DateTime lastUpdated;

  UserQuest({
    required this.id,
    required this.userId,
    required this.questId,
    required this.progress,
    this.status = QuestStatus.active,
    this.completedAt,
    required this.lastUpdated,
  });

  factory UserQuest.fromJson(Map<String, dynamic> json) {
    return UserQuest(
      id: json['id'],
      userId: json['userId'],
      questId: json['questId'],
      progress: json['progress'] ?? 0,
      status: QuestStatus.values.firstWhere(
        (e) => e.toString() == 'QuestStatus.${json['status']}',
      ),
      completedAt: json['completedAt'] != null 
          ? DateTime.parse(json['completedAt']) 
          : null,
      lastUpdated: DateTime.parse(json['lastUpdated']),
    );
  }

  factory UserQuest.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return UserQuest(
      id: doc.id,
      userId: data['userId'] ?? '',
      questId: data['questId'] ?? '',
      progress: data['progress'] ?? 0,
      status: QuestStatus.values.firstWhere(
        (e) => e.toString() == 'QuestStatus.${data['status']}',
      ),
      completedAt: data['completedAt'] != null 
          ? (data['completedAt'] as Timestamp).toDate() 
          : null,
      lastUpdated: (data['lastUpdated'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'questId': questId,
      'progress': progress,
      'status': status.toString().split('.').last,
      'completedAt': completedAt?.toIso8601String(),
      'lastUpdated': lastUpdated.toIso8601String(),
    };
  }

  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'questId': questId,
      'progress': progress,
      'status': status.toString().split('.').last,
      'completedAt': completedAt != null ? Timestamp.fromDate(completedAt!) : null,
      'lastUpdated': Timestamp.fromDate(lastUpdated),
    };
  }

  UserQuest copyWith({
    String? id,
    String? userId,
    String? questId,
    int? progress,
    QuestStatus? status,
    DateTime? completedAt,
    DateTime? lastUpdated,
  }) {
    return UserQuest(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      questId: questId ?? this.questId,
      progress: progress ?? this.progress,
      status: status ?? this.status,
      completedAt: completedAt ?? this.completedAt,
      lastUpdated: lastUpdated ?? this.lastUpdated,
    );
  }
}

