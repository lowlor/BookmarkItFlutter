import 'package:bookmarkit/utils/dialogs/generic_dialog.dart';
import 'package:flutter/material.dart';

Future<bool> deleteSingleDialog(
  BuildContext context
) {
  return showGenericDialog<bool>(
    context,
    "Delete",
    "Do you want to delete this bookmark?",
    {
      'Yes' : true,
      'No' : false
    },
  ).then((value) => value ?? false);
}
