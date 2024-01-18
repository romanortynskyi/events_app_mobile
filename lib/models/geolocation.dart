import 'package:latlng/latlng.dart';

class Geolocation {
  late LatLng? latLng;
  late String? country;
  late String? locality;
  late String? url;
  late String? placeId;

  Geolocation(
      {this.latLng, this.country, this.locality, this.url, this.placeId});

  Geolocation.fromMap(Map<String, dynamic> map) {
    double latitude = map['latitude'] ?? 0;
    double longitude = map['longitude'] ?? 0;
    final LatLng ll = LatLng(latitude, longitude);
    latLng = ll;

    country = map['country'];
    locality = map['locality'];
    placeId = map['placeId'];
  }
}
