import 'package:events_app_mobile/consts/light_theme_colors.dart';
import 'package:events_app_mobile/models/event.dart';
import 'package:events_app_mobile/widgets/event_details.dart';
import 'package:events_app_mobile/widgets/event_image.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class EventCard extends StatelessWidget {
  final Event event;

  const EventCard({
    super.key,
    required this.event,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 50),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(width: 30),
          Padding(
            padding: const EdgeInsets.only(top: 20),
            child: Column(
              children: [
                Text(
                  event.startDate.day.toString(),
                  style: TextStyle(
                    color: LightThemeColors.text,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 15),
                Text(
                  DateFormat('MMM').format(event.startDate).toUpperCase(),
                  style: const TextStyle(
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 30),
          EventImage(
            src: event.image.src,
            width: 120,
            height: 180,
          ),
          EventDetails(event: event),
        ],
      ),
    );
  }
}
