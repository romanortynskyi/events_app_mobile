import 'package:events_app_mobile/models/mathed_substring.dart';
import 'package:events_app_mobile/models/structured_formatting.dart';
import 'package:events_app_mobile/models/term.dart';

class AutocompletePlacesPrediction {
  String? description;
  String? placeId;
  Iterable<MatchedSubstring>? matchedSubstrings;
  StructuredFormatting? structuredFormatting;
  Iterable<Term>? terms;
  Iterable<String>? types;

  AutocompletePlacesPrediction({
    this.description,
    this.placeId,
    this.matchedSubstrings,
    this.structuredFormatting,
    this.terms,
    this.types,
  });

  AutocompletePlacesPrediction.fromMap(Map<String, dynamic> map) {
    description = map['description'];
    placeId = map['placeId'];
    matchedSubstrings = (map['matchedSubstrings'] as List)
        .map((matchedSubstringMap) => MatchedSubstring.fromMap(
            matchedSubstringMap as Map<String, dynamic>))
        .toList();
    structuredFormatting =
        StructuredFormatting.fromMap(map['structuredFormatting']);
    terms =
        (map['terms'] as List).map((termMap) => Term.fromMap(termMap)).toList();
    types = (map['types'] as List).map((type) => type as String).toList();
  }
}
