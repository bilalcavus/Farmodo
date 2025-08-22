import 'package:cloud_firestore/cloud_firestore.dart';

class AnimalStatus {
  final double hunger; // 0.0 - 1.0 (açlık durumu)
  final double love; // 0.0 - 1.0 (sevgi durumu)
  final double energy; // 0.0 - 1.0 (enerji durumu)
  final double health; // 0.0 - 1.0 (sağlık durumu)
  final DateTime lastFed; // Son beslenme zamanı
  final DateTime lastLoved; // Son sevgi gösterilme zamanı
  final DateTime lastPlayed; // Son oynama zamanı

  AnimalStatus({
    required this.hunger,
    required this.love,
    required this.energy,
    required this.health,
    required this.lastFed,
    required this.lastLoved,
    required this.lastPlayed,
  });

  factory AnimalStatus.defaultStatus() {
    final now = DateTime.now();
    return AnimalStatus(
      hunger: 1.0,
      love: 0.5,
      energy: 1.0,
      health: 1.0,
      lastFed: now,
      lastLoved: now,
      lastPlayed: now,
    );
  }

  factory AnimalStatus.fromJson(Map<String, dynamic> json) {
    return AnimalStatus(
      hunger: (json['hunger'] as num).toDouble(),
      love: (json['love'] as num).toDouble(),
      energy: (json['energy'] as num).toDouble(),
      health: (json['health'] as num).toDouble(),
      lastFed: DateTime.parse(json['lastFed']),
      lastLoved: DateTime.parse(json['lastLoved']),
      lastPlayed: DateTime.parse(json['lastPlayed']),
    );
  }

  factory AnimalStatus.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return AnimalStatus(
      hunger: (data['hunger'] as num?)?.toDouble() ?? 1.0,
      love: (data['love'] as num?)?.toDouble() ?? 0.5,
      energy: (data['energy'] as num?)?.toDouble() ?? 1.0,
      health: (data['health'] as num?)?.toDouble() ?? 1.0,
      lastFed: (data['lastFed'] as Timestamp?)?.toDate() ?? DateTime.now(),
      lastLoved: (data['lastLoved'] as Timestamp?)?.toDate() ?? DateTime.now(),
      lastPlayed: (data['lastPlayed'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'hunger': hunger,
      'love': love,
      'energy': energy,
      'health': health,
      'lastFed': lastFed.toIso8601String(),
      'lastLoved': lastLoved.toIso8601String(),
      'lastPlayed': lastPlayed.toIso8601String(),
    };
  }

  Map<String, dynamic> toFirestore() {
    return {
      'hunger': hunger,
      'love': love,
      'energy': energy,
      'health': health,
      'lastFed': Timestamp.fromDate(lastFed),
      'lastLoved': Timestamp.fromDate(lastLoved),
      'lastPlayed': Timestamp.fromDate(lastPlayed),
    };
  }

  AnimalStatus copyWith({
    double? hunger,
    double? love,
    double? energy,
    double? health,
    DateTime? lastFed,
    DateTime? lastLoved,
    DateTime? lastPlayed,
  }) {
    return AnimalStatus(
      hunger: hunger ?? this.hunger,
      love: love ?? this.love,
      energy: energy ?? this.energy,
      health: health ?? this.health,
      lastFed: lastFed ?? this.lastFed,
      lastLoved: lastLoved ?? this.lastLoved,
      lastPlayed: lastPlayed ?? this.lastPlayed,
    );
  }

  // Durum güncelleme metodları
  AnimalStatus updateHunger(double newHunger) {
    return copyWith(hunger: newHunger.clamp(0.0, 1.0), lastFed: DateTime.now());
  }

  AnimalStatus updateLove(double newLove) {
    return copyWith(love: newLove.clamp(0.0, 1.0), lastLoved: DateTime.now());
  }

  AnimalStatus updateEnergy(double newEnergy) {
    return copyWith(energy: newEnergy.clamp(0.0, 1.0), lastPlayed: DateTime.now());
  }

  AnimalStatus updateHealth(double newHealth) {
    return copyWith(health: newHealth.clamp(0.0, 1.0));
  }

  // Durum kontrol metodları
  bool get isHungry => hunger < 0.3;
  bool get isVeryHungry => hunger < 0.1;
  bool get needsLove => love < 0.3;
  bool get isTired => energy < 0.3;
  bool get isSick => health < 0.5;
  bool get isHappy => love > 0.7 && hunger > 0.5 && health > 0.7;
}

class FarmAnimal {
  final String id;
  final String userId;
  final String rewardId;
  final String name;
  final String imageUrl;
  final String description;
  final AnimalStatus status;
  final DateTime acquiredAt;
  final int level;
  final int experience;
  final String nickname;
  final bool isFavorite;

  FarmAnimal({
    required this.id,
    required this.userId,
    required this.rewardId,
    required this.name,
    required this.imageUrl,
    required this.description,
    required this.status,
    required this.acquiredAt,
    this.level = 1,
    this.experience = 0,
    this.nickname = '',
    this.isFavorite = false,
  });

  factory FarmAnimal.fromReward({
    required String userId,
    required String rewardId,
    required String name,
    required String imageUrl,
    required String description,
  }) {
    return FarmAnimal(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      userId: userId,
      rewardId: rewardId,
      name: name,
      imageUrl: imageUrl,
      description: description,
      status: AnimalStatus.defaultStatus(),
      acquiredAt: DateTime.now(),
    );
  }

  factory FarmAnimal.fromJson(Map<String, dynamic> json) {
    return FarmAnimal(
      id: json['id'],
      userId: json['userId'],
      rewardId: json['rewardId'],
      name: json['name'],
      imageUrl: json['imageUrl'],
      description: json['description'],
      status: AnimalStatus.fromJson(json['status']),
      acquiredAt: DateTime.parse(json['acquiredAt']),
      level: json['level'] ?? 1,
      experience: json['experience'] ?? 0,
      nickname: json['nickname'] ?? '',
      isFavorite: json['isFavorite'] ?? false,
    );
  }

  factory FarmAnimal.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return FarmAnimal(
      id: doc.id,
      userId: data['userId'] ?? '',
      rewardId: data['rewardId'] ?? '',
      name: data['name'] ?? '',
      imageUrl: data['imageUrl'] ?? '',
      description: data['description'] ?? '',
      status: AnimalStatus.fromFirestore(doc),
      acquiredAt: (data['acquiredAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      level: data['level'] ?? 1,
      experience: data['experience'] ?? 0,
      nickname: data['nickname'] ?? '',
      isFavorite: data['isFavorite'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'rewardId': rewardId,
      'name': name,
      'imageUrl': imageUrl,
      'description': description,
      'status': status.toJson(),
      'acquiredAt': acquiredAt.toIso8601String(),
      'level': level,
      'experience': experience,
      'nickname': nickname,
      'isFavorite': isFavorite,
    };
  }

  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'rewardId': rewardId,
      'name': name,
      'imageUrl': imageUrl,
      'description': description,
      ...status.toFirestore(),
      'acquiredAt': Timestamp.fromDate(acquiredAt),
      'level': level,
      'experience': experience,
      'nickname': nickname,
      'isFavorite': isFavorite,
    };
  }

  FarmAnimal copyWith({
    String? id,
    String? userId,
    String? rewardId,
    String? name,
    String? imageUrl,
    String? description,
    AnimalStatus? status,
    DateTime? acquiredAt,
    int? level,
    int? experience,
    String? nickname,
    bool? isFavorite,
  }) {
    return FarmAnimal(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      rewardId: rewardId ?? this.rewardId,
      name: name ?? this.name,
      imageUrl: imageUrl ?? this.imageUrl,
      description: description ?? this.description,
      status: status ?? this.status,
      acquiredAt: acquiredAt ?? this.acquiredAt,
      level: level ?? this.level,
      experience: experience ?? this.experience,
      nickname: nickname ?? this.nickname,
      isFavorite: isFavorite ?? this.isFavorite,
    );
  }

  // Hayvan bakım metodları
  FarmAnimal feed() {
    final newStatus = status.updateHunger(1.0);
    return copyWith(status: newStatus);
  }

  FarmAnimal love() {
    final newStatus = status.updateLove(status.love + 0.2);
    return copyWith(status: newStatus);
  }

  FarmAnimal play() {
    final newStatus = status.updateEnergy(status.energy + 0.3);
    return copyWith(status: newStatus);
  }

  FarmAnimal heal() {
    final newStatus = status.updateHealth(1.0);
    return copyWith(status: newStatus);
  }

  FarmAnimal updateNickname(String newNickname) {
    return copyWith(nickname: newNickname);
  }

  FarmAnimal toggleFavorite() {
    return copyWith(isFavorite: !isFavorite);
  }

  // Deneyim ve seviye sistemi
  FarmAnimal addExperience(int exp) {
    final newExp = experience + exp;
    final newLevel = (newExp / 100).floor() + 1;
    return copyWith(
      experience: newExp,
      level: newLevel,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is FarmAnimal && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
