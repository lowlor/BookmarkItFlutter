import 'package:flutter/material.dart';

typedef optionBuild<T> = Map<String, T?> Function();

Future<T?> showGenericDialog<T>(
  BuildContext context,
  String title,
  String content,
  Map<String, T?> option,
) {
  return showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: Text(title),
        content: Text(content),
        actions: option.keys.map((curr) {
          final value = option[curr];
          return TextButton(
            onPressed: () {
              if (value != null) {
                Navigator.of(context).pop(value);
              } else {
                Navigator.of(context).pop();
              }
            },
            child: Text(curr),
          );
        }).toList(),
      );
    },
  );
}
