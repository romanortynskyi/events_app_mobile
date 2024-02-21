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
    return Expanded(
      child: Container(
        margin: const EdgeInsets.only(top: 20, right: 20, left: 15),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              event.title ?? '',
              style: TextStyle(
                color: LightThemeColors.text,
                fontWeight: FontWeight.bold,
              ),
              softWrap: true,
            ),
            const SizedBox(height: 10),
            EventDate(
              caption: 'Beginning',
              date: event.startDate ?? DateTime.now(),
            ),
            EventDate(
              caption: 'End',
              date: event.endDate ?? DateTime.now(),
            ),
          ],
        ),
      ),
    );
  }
}
