import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:events_app_mobile/consts/light_theme_colors.dart';
import 'package:events_app_mobile/models/event.dart';
import 'package:events_app_mobile/models/location.dart';
import 'package:events_app_mobile/models/month.dart';
import 'package:events_app_mobile/widgets/app_autocomplete.dart';
import 'package:events_app_mobile/widgets/event_card.dart';
import 'package:events_app_mobile/widgets/events_counter.dart';
import 'package:events_app_mobile/widgets/home_header.dart';
import 'package:events_app_mobile/widgets/month_tile.dart';
import 'package:events_app_mobile/widgets/touchable_opacity.dart';
import 'package:flutter/material.dart';
import 'package:latlng/latlng.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<StatefulWidget> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Month> months = [
    Month(
      name: 'SEP',
      events: [
        Event(
          title: 'some cool event',
          startDate: DateTime(2023, 9, 7, 9, 30),
          endDate: DateTime(2023, 9, 7, 12, 30),
          imgSrc: 'https://source.unsplash.com/random/',
          location: Location(
            latLng: const LatLng(34, 45),
            name: 'some nice location',
          ),
        ),
        Event(
          title: 'some cool event',
          startDate: DateTime(2023),
          endDate: DateTime(2023),
          imgSrc: 'https://source.unsplash.com/random/',
          location: Location(
            latLng: const LatLng(34, 45),
            name: 'some nice location',
          ),
        ),
        Event(
          title: 'some cool event',
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
          title: 'some cool event',
          startDate: DateTime(2024),
          endDate: DateTime(2024),
          imgSrc: 'https://source.unsplash.com/random/',
          location: Location(
            latLng: const LatLng(34, 45),
            name: 'some nice location',
          ),
        ),
        Event(
          title: 'some cool event',
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

  final TextEditingController _textEditingController = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  Iterable<String> optionsBuilder(TextEditingValue textEditingValue) {
    if (textEditingValue.text == '') {
      return const Iterable<String>.empty();
    }

    return ['hello', 'pryvito'].where((String option) {
      return option.contains(textEditingValue.text.toLowerCase());
    });
  }

  Widget optionsViewBuilder(
    BuildContext context,
    onAutoCompleteSelect,
    Iterable<String> options,
  ) {
    return Container(
      margin: const EdgeInsets.only(left: 20),
      child: Align(
          alignment: Alignment.topLeft,
          child: Material(
            color: LightThemeColors.grey,
            elevation: 4.0,
            child: SizedBox(
                width: MediaQuery.of(context).size.width - 40,
                child: ListView.separated(
                  shrinkWrap: true,
                  padding: const EdgeInsets.all(8.0),
                  itemCount: options.length,
                  separatorBuilder: (context, i) {
                    return const Divider();
                  },
                  itemBuilder: (BuildContext context, int index) {
                    if (options.isNotEmpty) {
                      return GestureDetector(
                        onTap: () =>
                            onAutoCompleteSelect(options.elementAt(index)),
                        child: Text(options.elementAt(index)),
                      );
                    }

                    return null;
                  },
                )),
          )),
    );
  }

  void onClearSearch() {
    _textEditingController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const HomeHeader(
          imgSrc: 'https://source.unsplash.com/random/',
          location: 'Lviv, Ukraine',
        ),
        const SizedBox(height: 20),
        AppAutocomplete<String>(
          textEditingController: _textEditingController,
          focusNode: _focusNode,
          borderRadius: 35,
          prefixIcon: const Icon(Icons.search),
          suffixIcon: _textEditingController.text.isNotEmpty
              ? TouchableOpacity(
                  onTap: onClearSearch,
                  child: const Icon(Icons.close),
                )
              : null,
          hintText: 'Search for events...',
          optionsBuilder: optionsBuilder,
          optionsViewBuilder: optionsViewBuilder,
          onSelected: (String selection) {
            debugPrint('You just selected $selection');
          },
        ),
        const SizedBox(height: 20),
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
    );
  }
}
