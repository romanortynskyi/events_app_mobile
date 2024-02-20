import 'package:events_app_mobile/models/asset.dart';
import 'package:events_app_mobile/models/geolocation.dart';
import 'package:events_app_mobile/models/model.dart';
import 'package:latlng/latlng.dart';

class Event extends Model {
  late String? title;
  late String? description;
  late DateTime? startDate;
  late DateTime? endDate;
  late Geolocation? location;
  late Asset? image;
  late int? distance;
  late String? placeId;
  late Geolocation? geolocation;

  Event({
    int? id,
    DateTime? createdAt,
    DateTime? updatedAt,
    this.title,
    this.description,
    this.startDate,
    this.endDate,
    this.location,
    this.image,
    this.distance,
    this.placeId,
    this.geolocation,
  }) : super(
          id: id,
          createdAt: createdAt,
          updatedAt: updatedAt,
        );

  Event.fromMap(Map<String, dynamic> map)
      : super(
          id: map['id'],
          createdAt: map['createdAt'] == null
              ? null
              : DateTime.parse(map['createdAt']),
          updatedAt: map['updatedAt'] == null
              ? null
              : DateTime.parse(map['updatedAt']),
        ) {
    title = map['title'];
    description = map['description'];
    startDate =
        map['startDate'] == null ? null : DateTime.parse(map['startDate']);
    endDate = map['endDate'] == null ? null : DateTime.parse(map['endDate']);
    distance = map['distance'];
    geolocation = Geolocation(
        latitude: map['geolocation']?['latitude'] ?? 0,
        longitude: map['geolocation']?['longitude'] ?? 0);
    location = Geolocation(
      country: map['place']?['country'],
      locality: map['place']?['locality'],
      url: map['place']?['url'],
      latitude: map['place']?['location'] == null
          ? null
          : map['place']?['location']?['latitude'],
      longitude: map['place']?['location'] == null
          ? null
          : map['place']?['location']?['longitude'],
    );
    image = Asset(
      src: map['image']?['src'] ?? '',
    );
    placeId = map['placeId'];
  }
}
