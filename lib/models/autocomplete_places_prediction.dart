import 'package:events_app_mobile/models/structured_formatting.dart';

class AutocompletePlacesPrediction {
  late String imgSrc;
  late String originalId;
  late StructuredFormatting structuredFormatting;

  AutocompletePlacesPrediction({
    required this.imgSrc,
    required this.originalId,
    required this.structuredFormatting,
  });

  AutocompletePlacesPrediction.fromMap(Map<String, dynamic> map) {
    imgSrc = map['imgSrc'];
    originalId = map['originalId'];
    structuredFormatting =
        StructuredFormatting.fromMap(map['structuredFormatting']);
  }
}
