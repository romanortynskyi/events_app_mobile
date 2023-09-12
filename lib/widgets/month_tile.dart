import 'package:events_app_mobile/consts/light_theme_colors.dart';
import 'package:flutter/material.dart';

class MonthTile extends StatelessWidget {
  final String text;

  const MonthTile({
    super.key,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 50.0,
      width: 80.0,
      color: Colors.transparent,
      child: Container(
          decoration: BoxDecoration(
            color: LightThemeColors.primary,
            borderRadius: const BorderRadius.only(
              topRight: Radius.circular(30.0),
              bottomRight: Radius.circular(30.0),
            ),
          ),
          child: Center(
            child: Text(
              text,
              style: const TextStyle(fontSize: 22, color: Colors.white),
              textAlign: TextAlign.center,
            ),
          )),
    );
  }
}
