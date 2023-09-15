import 'package:events_app_mobile/models/asset.dart';
import 'package:events_app_mobile/models/location.dart';
import 'package:events_app_mobile/models/model.dart';

class Event extends Model {
  late String title;
  late String description;
  late DateTime startDate;
  late DateTime endDate;
  late Location location;
  late Asset image;

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
  }) : super(
          id: id,
          createdAt: createdAt,
          updatedAt: updatedAt,
        );
}
