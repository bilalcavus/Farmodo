

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
          title:  Text(title),
          content:  Text(content),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
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