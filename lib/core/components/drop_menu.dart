import 'package:farmodo/core/utility/extension/dynamic_size_extension.dart';
import 'package:flutter/material.dart';

class DropMenu extends StatelessWidget {
  const DropMenu({super.key, required this.controller, required this.label, required this.hint, required this.items, this.itemLabels});

  final TextEditingController controller;
  final String label;
  final String hint;
  final List items;
  final List<String>? itemLabels;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: context.dynamicWidth(0.01)),
          child: Text(
            label,
            // style: TextStyle(
            //   fontSize: context.dynamicHeight(0.015),
            //   fontWeight: FontWeight.w500,
            //   color: const Color(0xff4e5155),
            // ),
          ),
        ),
        SizedBox(height: context.dynamicHeight(0.01)),
        Container(
          height: context.dynamicHeight(0.065),
          padding: EdgeInsets.symmetric(horizontal: context.dynamicWidth(0.025)),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(context.dynamicWidth(0.04)),
            border: Border.all(color: Colors.black.withAlpha(20))
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButtonFormField<String>(
              value: controller.text.isEmpty ? null : controller.text,
              hint: Text(
                hint,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.black38
                ),
              ),
              icon: Icon(Icons.keyboard_arrow_down, color: Colors.grey[600]),
              decoration: InputDecoration(
                contentPadding: EdgeInsets.symmetric(vertical: context.dynamicWidth(0.02)),
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
              ),
              borderRadius: BorderRadius.circular(context.dynamicWidth(0.04)),
              dropdownColor: Colors.white,
              elevation: 3,
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                color: Colors.black87,
                fontSize: context.dynamicHeight(0.3),
              ),
              items: List.generate(items.length, (index) {
                return DropdownMenuItem<String>(
                  value: items[index],
                  child: Text(
                    itemLabels != null ? itemLabels![index] : items[index],
                    style: TextStyle(fontSize: context.dynamicHeight(0.018)),
                  ),
                );
              }),
              onChanged: (value) {
                if (value != null) {
                  controller.text = value;
                }
              },
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return '$label seçilmesi zorunludur';
                }
                return null;
              },
              menuMaxHeight: 300,
              isExpanded: true,
            ),
          ),
        ),
        SizedBox(height: context.dynamicHeight(0.007))
      ],
    );
  }
}