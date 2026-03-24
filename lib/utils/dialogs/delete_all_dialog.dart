import 'package:bookmarkit/utils/dialogs/generic_dialog.dart';
import 'package:flutter/material.dart';

Future<bool> deleteAllDialog(BuildContext context) {
  return showGenericDialog(context, 'Delete', 'Do you want to delete all?', {
    'Yes': true,
    'No': false,
  }).then((value) => value ?? false);
}
