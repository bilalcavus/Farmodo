import 'package:cloud_firestore/cloud_firestore.dart';

class PurchasableLottie {
  final String id;
  final String name;
  final String assetPath;
  final int price;
  final String description;
  final bool isAvailable;
  final DateTime createdAt;

  PurchasableLottie({
    required this.id,
    required this.name,
    required this.assetPath,
    required this.price,
    required this.description,
    required this.isAvailable,
    required this.createdAt,
  });

  factory PurchasableLottie.fromJson(Map<String, dynamic> json){
    return PurchasableLottie(
      id: json['id'],
      name: json['name'],
      assetPath: json['assetPath'],
      price: json['price'],
      description: json['description'],
      isAvailable: json['isAvailable'] ?? true,
      createdAt: DateTime.parse(json['createdAt']),
    );
  }

  factory PurchasableLottie.fromFirestore(DocumentSnapshot doc){
    final data = doc.data() as Map<String, dynamic>;
    
    DateTime dateTime;
    if (data['createdAt'] != null) {
      dateTime = (data['createdAt'] as Timestamp).toDate();
    } else if (data['purchasedAt'] != null) {
      dateTime = (data['purchasedAt'] as Timestamp).toDate();
    } else {
      dateTime = DateTime.now();
    }
    
    return PurchasableLottie(
      id: data['id'] ?? doc.id,
      name: data['name'] ?? '',
      description: data['description'] ?? '',
      assetPath: data['assetPath'] ?? '',
      isAvailable: data['isAvailable'] ?? true,
      price: data['price'] ?? 0,
      createdAt: dateTime,
    );
  }

  Map<String, dynamic> toJson(){
    return {
      'id': id,
      'name': name,
      'description': description,
      'assetPath': assetPath,
      'isAvailable': isAvailable,
      'price': price,
      'createdAt': createdAt.toIso8601String(),
    };
  }
  
  Map<String, dynamic> toFirestore(){
    return {
      'id': id,
      'name': name,
      'description': description,
      'assetPath': assetPath,
      'isAvailable': isAvailable,
      'price': price,
      'createdAt': Timestamp.fromDate(createdAt)
    };
  }

  PurchasableLottie copyWith({
    String? id,
    String? name,
    String? description,
    String? assetPath,
    int? price,
    bool? isAvailable,
    DateTime? createdAt,
  }) {
    return PurchasableLottie(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      assetPath: assetPath ?? this.assetPath,
      price: price ?? this.price,
      isAvailable: isAvailable ?? this.isAvailable,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is PurchasableLottie && other.id == id;
  }
  
  @override
  int get hashCode => id.hashCode;
}