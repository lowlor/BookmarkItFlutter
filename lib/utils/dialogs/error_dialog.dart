import 'package:bookmarkit/utils/dialogs/generic_dialog.dart';
import 'package:flutter/material.dart';

Future<void> showErrorDialog(BuildContext context, String content) {
  return showGenericDialog<void>(context, 'An error occured', content, {
    'OK': null,
  });
}
