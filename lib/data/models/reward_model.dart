import 'package:cloud_firestore/cloud_firestore.dart';

// /// Enum for different types of rewards in the store
// enum RewardType {
//   theme,
//   avatar,
//   badge,
//   powerUp,
//   customization,
// }


class Reward {
  final String id;
  final String name;
  final String imageUrl;
  final String coverUrl;
  final int xpCost;
  final String description;
  // final RewardType type;
  final bool isAvailable;
  final bool isPremium;
  final Map<String, dynamic>? metadata;
  final DateTime createdAt;
  final DateTime? expiresAt;

  Reward({
    required this.id,
    required this.name,
    required this.imageUrl,
    required this.coverUrl,
    required this.xpCost,
    required this.description,
    // required this.type,
    this.isAvailable = true,
    this.isPremium = false,
    this.metadata,
    required this.createdAt,
    this.expiresAt,
  });

  factory Reward.fromJson(Map<String, dynamic> json) {
    return Reward(
      id: json['id'],
      name: json['name'],
      imageUrl: json['imageUrl'],
      coverUrl: json['coverUrl'],
      xpCost: json['xpCost'],
      description: json['description'],
      // type: RewardType.values.firstWhere(
      //   (e) => e.toString() == 'RewardType.${json['type']}',
      //   orElse: () => RewardType.customization,
      // ),
      isAvailable: json['isAvailable'] ?? true,
      isPremium: json['isPremium'] ?? false,
      metadata: json['metadata'],
      createdAt: DateTime.parse(json['createdAt']),
      expiresAt: json['expiresAt'] != null 
          ? DateTime.parse(json['expiresAt']) 
          : null,
    );
  }

  factory Reward.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Reward(
      id: doc.id,
      name: data['name'] ?? '',
      imageUrl: data['imageUrl'] ?? '',
      coverUrl: data['coverUrl'] ?? '',
      xpCost: data['xpCost'] ?? 0,
      description: data['description'] ?? '',
      // type: RewardType.values.firstWhere(
      //   (e) => e.toString() == 'RewardType.${data['type']}',
      //   orElse: () => RewardType.customization,
      // ),
      isAvailable: data['isAvailable'] ?? true,
      isPremium: data['isPremium'] ?? false,
      metadata: data['metadata'],
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      expiresAt: data['expiresAt'] != null 
          ? (data['expiresAt'] as Timestamp).toDate() 
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'imageUrl': imageUrl,
      'coverUrl': coverUrl,
      'xpCost': xpCost,
      'description': description,
      // 'type': type.toString().split('.').last,
      'isAvailable': isAvailable,
      'isPremium': isPremium,
      'metadata': metadata,
      'createdAt': createdAt.toIso8601String(),
      'expiresAt': expiresAt?.toIso8601String(),
    };
  }

  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'imageUrl': imageUrl,
      'xpCost': xpCost,
      'description': description,
      'coverUrl': coverUrl,
      // 'type': type.toString().split('.').last,
      'isAvailable': isAvailable,
      'isPremium': isPremium,
      'metadata': metadata,
      'createdAt': Timestamp.fromDate(createdAt),
      'expiresAt': expiresAt != null ? Timestamp.fromDate(expiresAt!) : null,
    };
  }

  Reward copyWith({
    String? id,
    String? name,
    String? imageUrl,
    String? coverUrl,
    int? xpCost,
    String? description,
    // RewardType? type,
    bool? isAvailable,
    bool? isPremium,
    Map<String, dynamic>? metadata,
    DateTime? createdAt,
    DateTime? expiresAt,
  }) {
    return Reward(
      id: id ?? this.id,
      name: name ?? this.name,
      imageUrl: imageUrl ?? this.imageUrl,
      coverUrl: coverUrl ?? this.coverUrl,
      xpCost: xpCost ?? this.xpCost,
      description: description ?? this.description,
      // type: type ?? this.type,
      isAvailable: isAvailable ?? this.isAvailable,
      isPremium: isPremium ?? this.isPremium,
      metadata: metadata ?? this.metadata,
      createdAt: createdAt ?? this.createdAt,
      expiresAt: expiresAt ?? this.expiresAt,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Reward && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}

/// Model class representing a user's purchased reward
class UserReward {
  final String id;
  final String userId;
  final String rewardId;
  final DateTime purchasedAt;
  final bool isActive;
  final Map<String, dynamic>? customization;
  final int quantity;

  UserReward({
    required this.id,
    required this.userId,
    required this.rewardId,
    required this.purchasedAt,
    this.isActive = false,
    this.customization,
    required this.quantity,
  });

  factory UserReward.fromJson(Map<String, dynamic> json) {
    return UserReward(
      id: json['id'],
      userId: json['userId'],
      rewardId: json['rewardId'], 
      purchasedAt: DateTime.parse(json['purchasedAt']),
      isActive: json['isActive'] ?? false,
      customization: json['customization'],
      quantity: json['quantity']
    );
  }

  factory UserReward.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return UserReward(
      id: doc.id,
      userId: data['userId'] ?? '',
      rewardId: data['rewardId'] ?? '',
      purchasedAt: (data['purchasedAt'] as Timestamp).toDate(),
      isActive: data['isActive'] ?? false,
      customization: data['customization'],
      quantity: data['quantity'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'rewardId': rewardId,
      'purchasedAt': purchasedAt.toIso8601String(),
      'isActive': isActive,
      'customization': customization,
      'quantity': quantity
    };
  }

  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'rewardId': rewardId,
      'purchasedAt': Timestamp.fromDate(purchasedAt),
      'isActive': isActive,
      'customization': customization,
      'quantity': quantity,
    };
  }

  UserReward copyWith({
    String? id,
    String? userId,
    String? rewardId,
    DateTime? purchasedAt,
    bool? isActive,
    Map<String, dynamic>? customization,
    int? quantity
  }) {
    return UserReward(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      rewardId: rewardId ?? this.rewardId,
      purchasedAt: purchasedAt ?? this.purchasedAt,
      isActive: isActive ?? this.isActive,
      customization: customization ?? this.customization,
      quantity: quantity ?? this.quantity
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is UserReward && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
