import 'package:events_app_mobile/consts/light_theme_colors.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class EventDate extends StatelessWidget {
  final String caption;
  final DateTime date;

  const EventDate({
    super.key,
    required this.caption,
    required this.date,
  });

  @override
  Widget build(BuildContext context) {
    String formattedDate = DateFormat('HH:mm').format(date);

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          caption,
          style: const TextStyle(
            color: Colors.grey,
          ),
        ),
        const Spacer(),
        Text(
          formattedDate,
          style: TextStyle(
            color: LightThemeColors.text,
          ),
        ),
      ],
    );
  }
}
