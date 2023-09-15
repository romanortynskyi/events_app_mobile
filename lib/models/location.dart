import 'package:latlng/latlng.dart';

class Location {
  late LatLng? latLng;
  late String? country;
  late String? locality;

  Location({this.latLng, this.country, this.locality});

  Location.fromMap(Map<String, dynamic> map) {
    double latitude = map['latitude'];
    double longitude = map['longitude'];
    final LatLng ll = LatLng(latitude, longitude);

    latLng = ll;
    country = map['country'];
    locality = map['locality'];
  }
}
