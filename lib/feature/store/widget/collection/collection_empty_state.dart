import 'package:farmodo/core/utility/extension/dynamic_size_extension.dart';
import 'package:farmodo/core/utility/extension/sized_box_extension.dart';
import 'package:flutter/material.dart';

class CollectionEmptyState extends StatelessWidget {
  const CollectionEmptyState({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(context.dynamicHeight(0.02)),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Row(
        children: [
          Icon(Icons.pets_outlined, color: Colors.grey[400]),
          context.dynamicWidth(0.02).width,
          Text(
            'No animals in your collection yet',
            style: TextStyle(color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }
}

