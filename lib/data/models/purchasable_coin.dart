import 'package:cloud_firestore/cloud_firestore.dart';

class PurchasableCoin {
  final String id;
  final String name;
  final String assetPath;
  final int price;
  final String description;
  final bool isAvailable;
  final DateTime createdAt;
  final int value;

  PurchasableCoin({
    required this.id,
    required this.name,
    required this.assetPath,
    required this.price,
    required this.description,
    required this.isAvailable,
    required this.createdAt,
    required this.value,
  });

  factory PurchasableCoin.fromJson(Map<String, dynamic> json){
    return PurchasableCoin(
      id: json['id'],
      name: json['name'],
      assetPath: json['assetPath'],
      price: json['price'],
      description: json['description'],
      isAvailable: json['isAvailable'] ?? true,
      createdAt: DateTime.parse(json['createdAt']),
      value: json['value'],
    );
  }

  factory PurchasableCoin.fromFirestore(DocumentSnapshot doc){
    final data = doc.data() as Map<String, dynamic>;
    return PurchasableCoin(
      id: doc.id,
      name: data['name'] ?? '',
      description: data['description'] ?? '',
      assetPath: data['assetPath'] ?? '',
      isAvailable: data['isAvailable'] ?? true,
      price: data['price'] ?? 0,
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      value: data['value'] ?? 0,
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
      'value': value,
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
      'createdAt': Timestamp.fromDate(createdAt),
      'value': value,
    };
  }

  PurchasableCoin copyWith({
    String? id,
    String? name,
    String? description,
    String? assetPath,
    int? price,
    bool? isAvailable,
    DateTime? createdAt,
    int? value,
  }) {
    return PurchasableCoin(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      assetPath: assetPath ?? this.assetPath,
      price: price ?? this.price,
      isAvailable: isAvailable ?? this.isAvailable,
      createdAt: createdAt ?? this.createdAt,
      value: value ?? this.value,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is PurchasableCoin && other.id == id;
  }
  
  @override
  int get hashCode => id.hashCode;
}