import 'package:events_app_mobile/models/geolocation.dart';

class AutocompletePlacesResult {
  late Geolocation? location;
  late String? country;
  late String? locality;
  late String? googleMapsUri;
  late String? originalId;

  AutocompletePlacesResult(
      {this.location,
      this.country,
      this.locality,
      this.googleMapsUri,
      this.originalId});

  AutocompletePlacesResult.fromMap(Map<String, dynamic> map) {
    location = Geolocation.fromMap(map['location']);
    country = map['country'];
    locality = map['locality'];
    googleMapsUri = map['googleMapsUri'];
  }
}
