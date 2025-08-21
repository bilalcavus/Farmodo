
import 'package:farmodo/core/theme/app_colors.dart';
import 'package:farmodo/core/utility/extension/dynamic_size_extension.dart';
import 'package:flutter/material.dart';
import 'package:get/get_rx/src/rx_types/rx_types.dart';

class CollectionList extends StatelessWidget {
  const CollectionList({
    super.key,
    required this.ownedItems,
  });

  final RxList ownedItems;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: context.dynamicHeight(0.15),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListView.separated(
        padding: EdgeInsets.symmetric(horizontal: context.dynamicWidth(0.02), vertical: context.dynamicHeight(0.01)),
        scrollDirection: Axis.horizontal,
        itemCount: ownedItems.length,
        separatorBuilder: (context, index) => SizedBox(width: context.dynamicWidth(0.02)),
        itemBuilder: (context, index) {
          final reward = ownedItems[index];
          return Container(
            width: context.dynamicWidth(0.25),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.primary.withOpacity(0.1)),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset(
                  reward.imageUrl,
                  height: context.dynamicHeight(0.08),
                ),
                SizedBox(height: context.dynamicHeight(0.01)),
                Text(
                  reward.name,
                  style: TextStyle(fontWeight: FontWeight.w500),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
