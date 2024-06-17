import 'package:events_app_mobile/abstract/model.dart';
import 'package:events_app_mobile/models/geolocation.dart';

class Place extends Model<Place> {
  late Geolocation? location;
  late String? country;
  late String? locality;
  late String? googleMapsUri;
  late String? originalId;
  late String? imgSrc;
  late String? name;
  late double? predictedSalesPercentage;

  Place(
      {int? id,
      DateTime? createdAt,
      DateTime? updatedAt,
      this.location,
      this.country,
      this.locality,
      this.googleMapsUri,
      this.originalId,
      this.imgSrc,
      this.name,
      this.predictedSalesPercentage})
      : super(
          id: id,
          createdAt: createdAt,
          updatedAt: updatedAt,
        );

  Place.fromMap(Map<String, dynamic> map) {
    super.fromMap(map);

    originalId = map['originalId'];
    location =
        map['location'] == null ? null : Geolocation.fromMap(map['location']);
    country = map['country'];
    locality = map['locality'];
    googleMapsUri = map['googleMapsUri'];
    imgSrc = map['imgSrc'];
    name = map['name'];
    predictedSalesPercentage = map['predictedSalesPercentage'] == null
        ? null
        : double.parse(map['predictedSalesPercentage'].toString());
  }
}
