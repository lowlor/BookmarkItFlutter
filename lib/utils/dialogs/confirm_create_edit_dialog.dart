import 'package:bookmarkit/utils/dialogs/generic_dialog.dart';
import 'package:flutter/material.dart';

Future<bool> confirmCreateEditDialog(BuildContext context, String detail) {
  return showGenericDialog(context, "Confirm", detail, {
    "Yes": true,
    "No": false,
  }).then((value) => value ?? false);
}
