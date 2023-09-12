import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:events_app_mobile/models/event.dart';
import 'package:events_app_mobile/models/location.dart';
import 'package:events_app_mobile/models/month.dart';
import 'package:events_app_mobile/widgets/event_card.dart';
import 'package:events_app_mobile/widgets/events_counter.dart';
import 'package:events_app_mobile/widgets/home_header.dart';
import 'package:events_app_mobile/widgets/month_tile.dart';
import 'package:flutter/material.dart';
import 'package:latlng/latlng.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<StatefulWidget> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final items = const [
    Icon(Icons.home, size: 30),
    Icon(Icons.search_outlined, size: 30),
    Icon(Icons.person, size: 30),
  ];

  List<Month> months = [
    Month(
      name: 'SEP',
      events: [
        Event(
          title: 'Royal Blood',
          startDate: DateTime(2023, 9, 7, 9, 30),
          endDate: DateTime(2023, 9, 7, 12, 30),
          imgSrc: 'https://source.unsplash.com/random/',
          location: Location(
            latLng: const LatLng(34, 45),
            name: 'some nice location',
          ),
        ),
        Event(
          title: 'Royal Blood',
          startDate: DateTime(2023),
          endDate: DateTime(2023),
          imgSrc: 'https://source.unsplash.com/random/',
          location: Location(
            latLng: const LatLng(34, 45),
            name: 'some nice location',
          ),
        ),
        Event(
          title: 'Royal Blood',
          startDate: DateTime(2023),
          endDate: DateTime(2023),
          imgSrc: 'https://source.unsplash.com/random/',
          location: Location(
            latLng: const LatLng(34, 45),
            name: 'some nice location',
          ),
        ),
      ],
    ),
    Month(
      name: 'OCT',
      events: [
        Event(
          title: 'Royal Blood',
          startDate: DateTime(2024),
          endDate: DateTime(2024),
          imgSrc: 'https://source.unsplash.com/random/',
          location: Location(
            latLng: const LatLng(34, 45),
            name: 'some nice location',
          ),
        ),
        Event(
          title: 'Royal Blood',
          startDate: DateTime(2024),
          endDate: DateTime(2024),
          imgSrc: 'https://source.unsplash.com/random/',
          location: Location(
            latLng: const LatLng(34, 45),
            name: 'some nice location',
          ),
        ),
      ],
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: CurvedNavigationBar(
        items: items,
        color: const Color(0xFFA491D3),
        backgroundColor: Colors.transparent,
        height: 70,
      ),
      body: SafeArea(
        child: Column(
          children: [
            const HomeHeader(
              imgSrc: 'https://source.unsplash.com/random/',
              location: 'Lviv, Ukraine',
            ),
            Expanded(
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: months.length,
                itemBuilder: (context, index) {
                  final month = months[index];

                  return Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          MonthTile(text: month.name),
                          EventsCounter(count: month.events.length),
                        ],
                      ),
                      ListView.builder(
                        physics: const NeverScrollableScrollPhysics(),
                        shrinkWrap: true,
                        itemCount: month.events.length,
                        itemBuilder: (context, eventIndex) {
                          Event event = month.events[eventIndex];

                          return EventCard(event: event);
                        },
                      ).build(context),
                    ],
                  );
                },
              ).build(context),
            ),
          ],
        ),
      ),
    );
  }
}
