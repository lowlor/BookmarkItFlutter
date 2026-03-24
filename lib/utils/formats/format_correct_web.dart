import 'dart:developer';

String formatCorrectWeb(String content) {
  if (content.length < 8) {
    log('no $content');
    return 'http://$content';
  } else {
    String isInclude = content.substring(0, 8);
    log(isInclude);
    if (isInclude == 'https://') {
      log('return isinclue $content');
      return content;
    } else {
      log('add http $content');
      return 'http://$content';
    }
  }
}
