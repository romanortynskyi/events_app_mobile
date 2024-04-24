import 'package:events_app_mobile/models/geolocation.dart';

class AutocompletePlacesPrediction {
  late Geolocation? location;
  late String? country;
  late String? locality;
  late String? googleMapsUri;
  late String? originalId;

  AutocompletePlacesPrediction(
      {this.location,
      this.country,
      this.locality,
      this.googleMapsUri,
      this.originalId});

  AutocompletePlacesPrediction.fromMap(Map<String, dynamic> map) {
    location = Geolocation.fromMap(map['location']);
    country = map['country'];
    locality = map['locality'];
    googleMapsUri = map['googleMapsUri'];
  }
}
