import 'package:events_app_mobile/models/mathed_substring.dart';

class StructuredFormatting {
  String? mainText;
  Iterable<MatchedSubstring>? mainTextMatchedSubstrings;
  String? secondaryText;

  StructuredFormatting({
    this.mainText,
    this.mainTextMatchedSubstrings,
    this.secondaryText,
  });

  StructuredFormatting.fromMap(Map<String, dynamic> map) {
    mainText = map['mainText'];
    mainTextMatchedSubstrings = (map['mainTextMatchedSubstrings'] as List)
        .map((matchedSubstringMap) =>
            MatchedSubstring.fromMap(matchedSubstringMap))
        .toList();
    secondaryText = map['secondaryText'];
  }
}
