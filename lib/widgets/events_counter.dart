import 'package:flutter/material.dart';

class EventsCounter extends StatelessWidget {
  final int count;

  const EventsCounter({
    super.key,
    required this.count,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(right: 20.0),
      child: Text(
        '$count Events',
        style: const TextStyle(
          color: Colors.grey,
        ),
      ),
    );
  }
}
