import 'package:events_app_mobile/models/asset.dart';
import 'package:events_app_mobile/models/geolocation.dart';
import 'package:events_app_mobile/abstract/model.dart';
import 'package:events_app_mobile/models/place.dart';

class Event extends Model<Event> {
  late String? title;
  late String? description;
  late DateTime? startDate;
  late DateTime? endDate;
  late Asset? horizontalImage;
  late Asset? verticalImage;
  late int? distance;
  late Geolocation? geolocation;
  late Place? place;

  Event({
    int? id,
    DateTime? createdAt,
    DateTime? updatedAt,
    this.title,
    this.description,
    this.startDate,
    this.endDate,
    this.horizontalImage,
    this.verticalImage,
    this.distance,
    this.geolocation,
    this.place,
  }) : super(
          id: id,
          createdAt: createdAt,
          updatedAt: updatedAt,
        );

  @override
  Event fromMap(Map<String, dynamic> map) {
    super.fromMap(map);

    title = map['title'];
    description = map['description'];
    startDate =
        map['startDate'] == null ? null : DateTime.parse(map['startDate']);
    endDate = map['endDate'] == null ? null : DateTime.parse(map['endDate']);
    distance = map['distance'];
    geolocation = Geolocation(
        latitude: map['geolocation']?['latitude'] ?? 0,
        longitude: map['geolocation']?['longitude'] ?? 0);
    horizontalImage = Asset(
      src: map['horizontalImage']?['src'] ?? '',
    );
    verticalImage = Asset(
      src: map['verticalImage']?['src'] ?? '',
    );
    place = Place.fromMap(map['place']);

    return this;
  }
}
