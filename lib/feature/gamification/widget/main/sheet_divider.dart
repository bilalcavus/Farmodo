import 'package:farmodo/core/utility/extension/dynamic_size_extension.dart';
import 'package:flutter/material.dart';

class SheetDivider extends StatelessWidget {
  const SheetDivider({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: context.dynamicWidth(0.08),
        height: context.dynamicHeight(0.005),
        decoration: BoxDecoration(
          color: Colors.grey.shade300,
          borderRadius: BorderRadius.circular(context.dynamicWidth(0.005)),
        ),
      ),
    );
  }
}
