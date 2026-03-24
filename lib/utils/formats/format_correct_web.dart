
String formatCorrectWeb(String content) {
  if (content.length < 8) {
    return 'http://$content';
  } else {
    String isInclude = content.substring(0, 8);
    if (isInclude == 'https://') {
      return content;
    } else {
      return 'http://$content';
    }
  }
}
