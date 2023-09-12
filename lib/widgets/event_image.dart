import 'package:flutter/material.dart';

class EventImage extends StatelessWidget {
  final String src;
  final double width;
  final double height;

  const EventImage({
    super.key,
    required this.src,
    required this.width,
    required this.height,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(10.0),
      child: Image(
        fit: BoxFit.cover,
        image: NetworkImage(src),
        width: width,
        height: height,
      ),
    );
  }
}
