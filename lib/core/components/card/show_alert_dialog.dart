

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

Future<bool?> showAlertDialog({
  required BuildContext context,
  required String title,
  required String content,
  required VoidCallback onPressed,
  required String buttonText
  }) {
    return showAdaptiveDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog.adaptive(
          titleTextStyle: Theme.of(context).textTheme.bodyLarge,
          
          title: Text(title),
          content: Text(content),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('common.cancel'.tr()),
            ),
            TextButton(
              onPressed: () {
                onPressed();
                Navigator.of(context).pop();
              },
              child: Text(buttonText),
            ),
          ],
        );
    });
  }