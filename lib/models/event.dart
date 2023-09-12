import 'package:events_app_mobile/models/location.dart';

class Event {
  late String title;
  late DateTime startDate;
  late DateTime endDate;
  late Location location;
  late String imgSrc;

  Event({
    required this.title,
    required this.startDate,
    required this.endDate,
    required this.location,
    required this.imgSrc,
  });
}
