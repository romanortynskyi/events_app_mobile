import 'package:events_app_mobile/models/asset.dart';
import 'package:events_app_mobile/models/location.dart';
import 'package:events_app_mobile/models/model.dart';
import 'package:latlng/latlng.dart';

class Event extends Model {
  late String title;
  late String description;
  late DateTime startDate;
  late DateTime endDate;
  late Location location;
  late Asset image;
  late int distance;
  late String? placeId;

  Event({
    required int id,
    required DateTime createdAt,
    required DateTime updatedAt,
    required this.title,
    required this.description,
    required this.startDate,
    required this.endDate,
    required this.location,
    required this.image,
    required this.distance,
    this.placeId,
  }) : super(
          id: id,
          createdAt: createdAt,
          updatedAt: updatedAt,
        );

  Event.fromMap(Map<String, dynamic> map)
      : super(
          id: map['id'],
          createdAt: DateTime.parse(map['createdAt']),
          updatedAt: DateTime.parse(map['updatedAt']),
        ) {
    title = map['title'];
    description = map['description'];
    startDate = DateTime.parse(map['startDate']);
    endDate = DateTime.parse(map['endDate']);
    distance = map['distance'] ?? 0;
    location = Location(
      country: map['place']['country'],
      locality: map['place']['locality'],
      url: map['place']['url'],
      latLng: LatLng(
        map['place']['geometry']['location']['lat'],
        map['place']['geometry']['location']['lng'],
      ),
    );
    image = Asset(
      src: map['image']['src'],
    );
    placeId = map['placeId'];
  }
}
