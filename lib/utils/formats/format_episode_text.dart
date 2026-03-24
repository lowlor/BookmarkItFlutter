import 'dart:developer';

String formatEpisodeText(String content) {
  String originalText = content;
  String decimalSide = originalText.split('.').last;
  String fullNumber = originalText.split('.').first;
  log(decimalSide.toString());
  if (int.parse(decimalSide) > 0) {
    return originalText;
  } else {
    return fullNumber;
  }
}
