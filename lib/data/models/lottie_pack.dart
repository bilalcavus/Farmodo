import 'package:farmodo/data/models/purchasable_lottie.dart';

class LottiePack {
  final LottiePackType type;
  final String name;
  final String description;
  final int price;
  final List<PurchasableLottie> lotties;
  final String? productId;

  const LottiePack({
    required this.type,
    required this.name,
    required this.description,
    required this.price,
    required this.lotties,
    this.productId,
  });

  PurchasableLottie? get previewLottie => lotties.isNotEmpty ? lotties.first : null;

  LottiePack copyWith({
    LottiePackType? type,
    String? name,
    String? description,
    int? price,
    List<PurchasableLottie>? lotties,
    String? productId,
  }) {
    return LottiePack(
      type: type ?? this.type,
      name: name ?? this.name,
      description: description ?? this.description,
      price: price ?? this.price,
      lotties: lotties ?? this.lotties,
      productId: productId ?? this.productId,
    );
  }
}
