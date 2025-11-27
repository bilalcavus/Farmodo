import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_localization/easy_localization.dart';

enum LottiePackType { small, medium, advanced, unknown }

String lottiePackTypeToString(LottiePackType type) {
  switch (type) {
    case LottiePackType.small:
      return 'small';
    case LottiePackType.medium:
      return 'medium';
    case LottiePackType.advanced:
      return 'advanced';
    case LottiePackType.unknown:
      return 'unknown';
  }
}

LottiePackType lottiePackTypeFromString(String? value) {
  switch (value?.toLowerCase()) {
    case 'small':
      return LottiePackType.small;
    case 'medium':
      return LottiePackType.medium;
    case 'advanced':
      return LottiePackType.advanced;
    default:
      return LottiePackType.unknown;
  }
}

extension LottiePackTypeReadable on LottiePackType {
  String get readableName {
    switch (this) {
      case LottiePackType.small:
        return 'store.small_pack'.tr();
      case LottiePackType.medium:
        return 'store.medium_pack'.tr();
      case LottiePackType.advanced:
        return 'store.advanced_pack'.tr();
      case LottiePackType.unknown:
        return 'Unknown Pack';
    }
  }
}

class PurchasableLottie {
  final String id;
  final String name;
  final String assetPath;
  final int price;
  final String description;
  final bool isAvailable;
  final String type;
  final DateTime createdAt;
  final String? productId;

  PurchasableLottie({
    required this.id,
    required this.name,
    required this.assetPath,
    required this.price,
    required this.description,
    required this.isAvailable,
    required this.type,
    required this.createdAt,
    this.productId,
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
      type: json['type'] ?? '', 
      productId: json['productId'],
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
      type: data['type'] ?? '',
      productId: data['productId'],
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
      'type': type,
      'productId': productId,
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
      'type': type,
      'productId': productId,
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
    String? type,
    String? productId,
  }) {
    return PurchasableLottie(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      assetPath: assetPath ?? this.assetPath,
      price: price ?? this.price,
      isAvailable: isAvailable ?? this.isAvailable,
      createdAt: createdAt ?? this.createdAt,
      type: type ?? this.type,
      productId: productId ?? this.productId,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is PurchasableLottie && other.id == id;
  }
  
  @override
  int get hashCode => id.hashCode;

  LottiePackType get packType => lottiePackTypeFromString(type);
}
