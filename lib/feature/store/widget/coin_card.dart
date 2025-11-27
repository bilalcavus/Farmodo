import 'package:easy_localization/easy_localization.dart';
import 'package:farmodo/core/theme/app_colors.dart';
import 'package:farmodo/core/utility/extension/dynamic_size_extension.dart';
import 'package:farmodo/core/utility/extension/sized_box_extension.dart';
import 'package:farmodo/data/models/purchasable_coin.dart';
import 'package:flutter/material.dart';
import 'package:kartal/kartal.dart';

class CoinCard extends StatelessWidget {
  final PurchasableCoin coin;
  final double cardRadius;
  final VoidCallback onBuy;
  final bool isBuying;

  const CoinCard({
    super.key,
    required this.coin,
    required this.cardRadius,
    required this.onBuy,
    this.isBuying = false,
  });

  @override
  Widget build(BuildContext context) {
    final double padding = context.dynamicHeight(0.01);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final priceLabel = coin.displayPrice ??
        (coin.adaptyAmount != null
            ? coin.adaptyAmount!.toStringAsFixed(2)
            : (coin.price > 0 ? '${coin.price}' : 'Free'));

    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: context.dynamicWidth(0.015),
        vertical: context.dynamicHeight(0.001),
      ),
      child: Container(
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
          borderRadius: context.border.normalBorderRadius,
        ),
        child: Padding(
          padding: EdgeInsets.all(padding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                flex: 3,
                child: Container(
                  decoration: BoxDecoration(
                    color: isDark
                        ? const Color.fromARGB(255, 10, 16, 28)
                        : Colors.grey.shade100,
                    borderRadius: context.border.normalBorderRadius,
                  ),
                  child: Center(
                    child: Image.asset(
                      coin.assetPath,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Icon(
                          Icons.monetization_on,
                          size: context.dynamicHeight(0.06),
                          color: Colors.amber,
                        );
                      },
                    ),
                  ),
                ),
              ),
              Expanded(
                flex: 1,
                child: Text(
                  coin.name,
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                ),
              ),
              Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    priceLabel,
                    style: Theme.of(context).textTheme.labelLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Colors.orange.shade800,
                        ),
                  ),
                  context.dynamicHeight(0.006).height,
                  TextButton(
                    onPressed: isBuying ? null : onBuy,
                    
                    child: isBuying
                        ? SizedBox(
                            height: context.dynamicHeight(0.02),
                            width: context.dynamicHeight(0.02),
                            child: const CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                                'store.buy'.tr(),
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyMedium
                                    ?.copyWith(
                                      color: Colors.green,
                                      fontWeight: FontWeight.bold,
                                    ),
                              ),
                              context.dynamicWidth(0.01).width,
                              Icon(Icons.shopping_cart, color: Colors.green,)
                          ],
                        ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
