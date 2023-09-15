import 'package:events_app_mobile/models/model.dart';

import './event.dart';

class Month {
  late String name;
  late List<Event> events;

  Month({
    required this.name,
    required this.events,
  });
}
