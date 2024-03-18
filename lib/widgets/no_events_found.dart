import 'package:events_app_mobile/consts/light_theme_colors.dart';
import 'package:flutter/material.dart';

class NoEventsFound extends StatelessWidget {
  const NoEventsFound({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        'No events found',
        style: TextStyle(
          color: LightThemeColors.text,
        ),
      ),
    );
  }
}
