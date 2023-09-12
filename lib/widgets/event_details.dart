import 'package:events_app_mobile/consts/light_theme_colors.dart';
import 'package:events_app_mobile/models/event.dart';
import 'package:events_app_mobile/widgets/event_date.dart';
import 'package:flutter/material.dart';

class EventDetails extends StatelessWidget {
  final Event event;

  const EventDetails({
    super.key,
    required this.event,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 20, left: 15),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            event.title,
            style: TextStyle(
              color: LightThemeColors.text,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 10),
          EventDate(
            caption: 'Beginning',
            date: event.startDate,
            width: MediaQuery.of(context).size.width - 291,
          ),
          EventDate(
            caption: 'End',
            date: event.endDate,
            width: MediaQuery.of(context).size.width - 291,
          ),
        ],
      ),
    );
  }
}
