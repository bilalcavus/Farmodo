import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String id;
  final String email;
  final String displayName;
  final int level;
  final int xp;
  final int totalPomodoro;
  final String? avatarUrl;
  final DateTime createdAt;
  final DateTime? lastLoginAt;
  final bool isActive;
  final Map<String, dynamic>? userPreferences;
  final bool isPremiumUser;
  final String? fcmToken;

  UserModel({
    required this.id,
    required this.email,
    required this.displayName,
    required this.level,
    required this.xp,
    required this.totalPomodoro,
    this.avatarUrl,
    required this.createdAt,
    this.lastLoginAt,
    this.isActive = true,
    this.userPreferences,
    this.isPremiumUser = false,
    this.fcmToken,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'],
      email: json['email'],
      displayName: json['display_name'],
      level: json['level'],
      xp: json['xp'],
      totalPomodoro: json['total_pomodoro'],
      avatarUrl: json['avatar_url'],
      createdAt: DateTime.parse(json['created_at']),
      lastLoginAt: json['last_login_at'] != null 
          ? DateTime.parse(json['last_login_at']) 
          : null,
      isActive: json['is_active'] == 1,
      userPreferences: json['user_preferences_json'] != null
          ? Map<String, dynamic>.from(jsonDecode(json['user_preferences_json']))
          : null,
      isPremiumUser: json['is_premium_user'] ?? false,
      fcmToken: json['fcm_token'],
    );
  }

  factory UserModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return UserModel(
      id: doc.id,
      email: data['email'] ?? '',
      displayName: data['displayName'] ?? '',
      level: data['level'] ?? 0,
      xp: data['xp'] ?? 0,
      totalPomodoro: data['totalPomodoro'] ?? 0,
      avatarUrl: data['avatarUrl'],
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      lastLoginAt: data['lastLoginAt'] != null 
          ? (data['lastLoginAt'] as Timestamp).toDate() 
          : null,
      isActive: data['isActive'] ?? true,
      userPreferences: data['userPreferences'],
      isPremiumUser: data['isPremiumUser'] ?? false,
      fcmToken: data['fcmToken'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'display_name': displayName,
      'level': level,
      'xp': xp,
      'total_pomodoro': totalPomodoro,
      'avatar_url': avatarUrl,
      'created_at': createdAt.toIso8601String(),
      'last_login_at': lastLoginAt?.toIso8601String(),
      'is_active': isActive ? 1 : 0,
      'user_preferences_json': userPreferences != null ? jsonEncode(userPreferences) : null,
      'is_premium_user': isPremiumUser,
      'fcm_token': fcmToken,
    };
  }

  Map<String, dynamic> toFirestore() {
    return {
      'email': email,
      'displayName': displayName,
      'level': level,
      'xp': xp,
      'totalPomodoro': totalPomodoro,
      'avatarUrl': avatarUrl,
      'createdAt': Timestamp.fromDate(createdAt),
      'lastLoginAt': lastLoginAt != null ? Timestamp.fromDate(lastLoginAt!) : null,
      'isActive': isActive,
      'userPreferences': userPreferences,
      'isPremiumUser': isPremiumUser,
      'fcmToken': fcmToken,
    };
  }

  UserModel copyWith({
    String? id,
    String? email,
    String? displayName,
    int? level,
    int? xp,
    int? totalPomodoro,
    String? avatarUrl,
    DateTime? createdAt,
    DateTime? lastLoginAt,
    bool? isActive,
    Map<String, dynamic>? userPreferences,
    bool? isPremiumUser,
    String? fcmToken,
  }) {
    return UserModel(
      id: id ?? this.id,
      email: email ?? this.email,
      displayName: displayName ?? this.displayName,
      level: level ?? this.level,
      xp: xp ?? this.xp,
      totalPomodoro: totalPomodoro ?? this.totalPomodoro,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      createdAt: createdAt ?? this.createdAt,
      lastLoginAt: lastLoginAt ?? this.lastLoginAt,
      isActive: isActive ?? this.isActive,
      userPreferences: userPreferences ?? this.userPreferences,
      isPremiumUser: isPremiumUser ?? this.isPremiumUser,
      fcmToken: fcmToken ?? this.fcmToken,
    );
  }

  @override
  String toString() {
    return 'User(id: $id, email: $email, displayName: $displayName)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is UserModel && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}

class UserSession {
  final int id;
  final String userId;
  final String sessionToken;
  final String? deviceInfo;
  final String? ipAddress;
  final DateTime createdAt;
  final DateTime expiresAt;
  final bool isActive;

  UserSession({
    required this.id,
    required this.userId,
    required this.sessionToken,
    this.deviceInfo,
    this.ipAddress,
    required this.createdAt,
    required this.expiresAt,
    this.isActive = true,
  });

  factory UserSession.fromJson(Map<String, dynamic> json) {
    return UserSession(
      id: json['id'],
      userId: json['user_id'],
      sessionToken: json['session_token'],
      deviceInfo: json['device_info'],
      ipAddress: json['ip_address'],
      createdAt: DateTime.parse(json['created_at']),
      expiresAt: DateTime.parse(json['expires_at']),
      isActive: json['is_active'] == 1,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'session_token': sessionToken,
      'device_info': deviceInfo,
      'ip_address': ipAddress,
      'created_at': createdAt.toIso8601String(),
      'expires_at': expiresAt.toIso8601String(),
      'is_active': isActive ? 1 : 0,
    };
  }

  bool get isExpired => DateTime.now().isAfter(expiresAt);

  bool get isValid => isActive && !isExpired;
} 