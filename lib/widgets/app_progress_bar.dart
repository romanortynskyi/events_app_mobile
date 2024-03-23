import 'package:flutter/material.dart';

class AppProgressBar extends StatelessWidget {
  const AppProgressBar({
    super.key,
    required this.duration,
    required this.color,
    required this.height,
    required this.radius,
    required this.padding,
    required this.value,
  });

  final int duration;
  final Color color;
  final double height;
  final double radius;
  final double padding;
  final num value;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      final maxWidth = constraints.maxWidth;

      return Stack(
        alignment: Alignment.centerLeft,
        children: [
          AnimatedContainer(
            duration: Duration(milliseconds: duration),
            width: maxWidth,
            height: height + (padding * 2),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(radius),
            ),
          ),
          AnimatedContainer(
            duration: Duration(milliseconds: duration),
            width: (value / 100) * maxWidth,
            height: height,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(radius),
            ),
          ),
        ],
      );
    });
  }
}
