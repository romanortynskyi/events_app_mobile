import 'package:events_app_mobile/models/autocomplete_places_prediction.dart';

class AutocompletePlacesResponse {
  late Iterable<AutocompletePlacesPrediction>? items;

  AutocompletePlacesResponse({
    this.items,
  });

  AutocompletePlacesResponse.fromMap(Map<String, dynamic> map) {
    items = (map['items'] as List)
        .map((predictionMap) =>
            AutocompletePlacesPrediction.fromMap(predictionMap))
        .toList();
  }
}
