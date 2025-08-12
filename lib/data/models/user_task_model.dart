
import 'package:cloud_firestore/cloud_firestore.dart';

class UserTaskModel {
  final String id;
  final String focusType;
  final String title;
  final int xpReward;
  final bool isCompleted;
  final int duration;
  final DateTime createdAt;

  UserTaskModel({
    required this.id,
    required this.focusType,
    required this.title,
    required this.xpReward,
    required this.isCompleted,
    required this.duration,
    required this.createdAt,
    
  });

  factory UserTaskModel.fromJson(Map<String, dynamic> json) {
    return UserTaskModel(
      id: json['id'],
      focusType: json['focusType'] ?? '',
      title: json['title'] ?? '',
      xpReward: json['xpReward'] ?? 0,
      isCompleted: json['isCompleted'] ?? false,
      duration: json['duration'] ?? 0,
      createdAt: DateTime.parse(json['created_at']),
    );
  }

  factory UserTaskModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return UserTaskModel(
      id: doc.id,
      focusType: data['focusType'] ?? '',
      title: data['title'] ?? '',
      xpReward: data['xpReward'] ?? 0,
      isCompleted: data['isCompleted'] ?? false,
      duration: data['duration'] ?? 0,
      createdAt: (data['createdAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'focusType': focusType,
      'title': title,
      'xpReward': xpReward,
      'isCompleted': isCompleted,
      'duration': duration,
      'created_at': createdAt.toIso8601String(),
    };
  }

  Map<String, dynamic> toFirestore() {
    return {
      'focusType': focusType,
      'title': title,
      'xpReward': xpReward,
      'isCompleted': isCompleted,
      'duration': duration,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  UserTaskModel copyWith({
    String? id,
    String? focusType,
    String? title,
    int? xpReward,
    bool? isCompleted,
    int? duration,
    DateTime? createdAt,
  }) {
    return UserTaskModel(
      id: id ?? this.id,
      focusType: focusType ?? this.focusType,
      title: title ?? this.title,
      xpReward: xpReward ?? this.xpReward,
      isCompleted: isCompleted ?? this.isCompleted,
      duration: duration ?? this.duration,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  String toString() {
    return 'UserTaskModel(id: $id, title: $title, focusType: $focusType)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is UserTaskModel && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
