import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

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
        image: CachedNetworkImageProvider(src),
        width: width,
        height: height,
      ),
    );
  }
}
