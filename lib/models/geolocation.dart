class Geolocation {
  late double? latitude;
  late double? longitude;
  late String? country;
  late String? locality;
  late String? url;
  late String? placeId;

  Geolocation(
      {this.latitude,
      this.longitude,
      this.country,
      this.locality,
      this.url,
      this.placeId});

  Geolocation.fromMap(Map<String, dynamic> map) {
    latitude = map['latitude'] ?? 0;
    longitude = map['longitude'] ?? 0;
    country = map['country'];
    locality = map['locality'];
    placeId = map['placeId'];
  }
}
