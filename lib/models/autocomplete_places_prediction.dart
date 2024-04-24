import 'package:events_app_mobile/models/structured_formatting.dart';

class AutocompletePlacesPrediction {
  late String placeId;
  late StructuredFormatting structuredFormatting;

  AutocompletePlacesPrediction({
    required this.placeId,
    required this.structuredFormatting,
  });

  AutocompletePlacesPrediction.fromMap(Map<String, dynamic> map) {
    placeId = map['placeId'];
    structuredFormatting =
        StructuredFormatting.fromMap(map['structuredFormatting']);
  }
}
