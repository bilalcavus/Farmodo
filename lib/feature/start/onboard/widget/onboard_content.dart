import 'package:farmodo/core/utility/extension/dynamic_size_extension.dart';
import 'package:farmodo/core/utility/extension/sized_box_extension.dart';
import 'package:flutter/material.dart';
import 'package:kartal/kartal.dart';

class OnboardContent extends StatelessWidget {
  const OnboardContent({
    super.key, required this.title, required this.description,
  });

  final String title;
  final String description;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        children: [
          Text(title, style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold
          )),
          context.dynamicHeight(0.02).height,
          Padding(
            padding: context.padding.horizontalMedium,
            child: Text(description,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w400),
              textAlign: TextAlign.center
            ),
          )
        ],
      ));
  }
}