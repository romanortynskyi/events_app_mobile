import 'package:events_app_mobile/models/matched_substring.dart';

class StructuredFormatting {
  late String mainText;
  late List<MatchedSubstring> mainTextMatchedSubstrings;
  late String? secondaryText;

  StructuredFormatting.fromMap(Map<String, dynamic> map) {
    mainText = map['mainText'];
    secondaryText = map['secondaryText'];
    mainTextMatchedSubstrings = map['mainTextMatchedSubstrings']
        .map((substringMap) => MatchedSubstring.fromMap(substringMap))
        .toList()
        .cast<MatchedSubstring>();
  }
}
