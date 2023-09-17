// ignore_for_file: use_build_context_synchronously

import 'package:events_app_mobile/consts/light_theme_colors.dart';
import 'package:events_app_mobile/graphql/queries/get_geolocation_by_coords.dart';
import 'package:events_app_mobile/models/asset.dart';
import 'package:events_app_mobile/models/event.dart';
import 'package:events_app_mobile/models/location.dart';
import 'package:events_app_mobile/models/month.dart';
import 'package:events_app_mobile/screens/event_screen.dart';
import 'package:events_app_mobile/widgets/app_autocomplete.dart';
import 'package:events_app_mobile/widgets/event_card.dart';
import 'package:events_app_mobile/widgets/events_counter.dart';
import 'package:events_app_mobile/widgets/home_header.dart';
import 'package:events_app_mobile/widgets/month_tile.dart';
import 'package:events_app_mobile/widgets/touchable_opacity.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlng/latlng.dart' as latlng;
import 'package:graphql_flutter/graphql_flutter.dart';

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
          id: 5,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
          description:
              '''Lorem Ipsum is simply dummy text of the printing and typesetting industry. Lorem Ipsum has been the industry's standard dummy text ever since the 1500s, when an unknown printer took a galley of type and scrambled it to make a type specimen book. It has survived not only five centuries, but also the leap into electronic typesetting, remaining essentially unchanged. It was popularised in the 1960s with the release of Letraset sheets containing Lorem Ipsum passages, and more recently with desktop publishing software like Aldus PageMaker including versions of Lorem Ipsum.''',
          title: 'some cool event',
          startDate: DateTime(2024),
          endDate: DateTime(2024),
          image: Asset(
            src:
                'https://images.unsplash.com/photo-1687360441387-0179af118555?ixlib=rb-4.0.3&ixid=M3wxMjA3fDF8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D&auto=format&fit=crop&w=1854&q=80',
          ),
          location: Location(
            latLng: const latlng.LatLng(34, 45),
            locality: 'Kyiv',
            country: 'Ukraine',
          ),
        ),
      ],
    ),
    Month(
      name: 'OCT',
      events: [
        Event(
          id: 6,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
          description:
              '''Lorem Ipsum is simply dummy text of the printing and typesetting industry. Lorem Ipsum has been the industry's standard dummy text ever since the 1500s, when an unknown printer took a galley of type and scrambled it to make a type specimen book. It has survived not only five centuries, but also the leap into electronic typesetting, remaining essentially unchanged. It was popularised in the 1960s with the release of Letraset sheets containing Lorem Ipsum passages, and more recently with desktop publishing software like Aldus PageMaker including versions of Lorem Ipsum.''',
          title: 'some cool event',
          startDate: DateTime(2024),
          endDate: DateTime(2024),
          image: Asset(
            src:
                'https://images.unsplash.com/photo-1687360441387-0179af118555?ixlib=rb-4.0.3&ixid=M3wxMjA3fDF8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D&auto=format&fit=crop&w=1854&q=80',
          ),
          location: Location(
            latLng: const latlng.LatLng(34, 45),
            locality: 'Kyiv',
            country: 'Ukraine',
          ),
        ),
      ],
    ),
  ];

  final TextEditingController _textEditingController = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  Location? _location;

  @override
  void initState() {
    super.initState();

    _getCurrentLocation();
  }

  void _getCurrentLocation() async {
    LocationPermission permission;
    Position? position;

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        print('Denied');
      } else {
        position = await Geolocator.getCurrentPosition(
            desiredAccuracy: LocationAccuracy.high);
      }
    } else {
      position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);
    }

    if (position != null) {
      GraphQLClient client = GraphQLProvider.of(context).value;
      var response = await client.query(QueryOptions(
        document: gql(getGeolocationByCoords),
        variables: {
          'latitude': position.latitude,
          'longitude': position.longitude,
        },
      ));

      setState(() {
        Map<String, dynamic> data = response.data ?? {};
        _location = Location.fromMap(data['getGeolocationByCoords']);
      });
    }
  }

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

  void onEventPressed(BuildContext context, Event event) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => EventScreen(event.id)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        HomeHeader(
          imgSrc: 'https://source.unsplash.com/random/',
          location: _location,
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

                      return TouchableOpacity(
                        onTap: () => onEventPressed(context, event),
                        child: EventCard(event: event),
                      );
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
