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
import 'package:intl/intl.dart';
import 'package:latlng/latlng.dart' as latlng;
import 'package:graphql_flutter/graphql_flutter.dart';

String getEvents =
    """
  query GET_EVENTS(\$skip: Float!, \$limit: Float!){
    getEvents(skip: \$skip, limit: \$limit) {
      items {
        id
        image {
          src
        }
        createdAt
        updatedAt
        placeId
        title
        place {
          url
          name
          country
          locality
          geometry {
            location {
              lat
              lng
            }
          }
        }
        description
        startDate
        endDate
        ticketPrice
      }
      totalPagesCount
    }
  }
""";

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<StatefulWidget> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Month> _months = [];
  int _skip = 0;
  final TextEditingController _textEditingController = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  Location? _location;
  late ScrollController _scrollController;
  bool _isLoadingEvents = true;
  bool _isLoadingLocation = true;

  List<Month> _getMonths(response) {
    List<Event> events = response.data?['getEvents']['items']
        .map((item) => Event.fromMap(item))
        .toList()
        .cast<Event>();

    if (events.isEmpty) {
      return _months;
    }

    Set<String> uniqueMonthNames = events
        .map((event) => DateFormat('MMM yyyy').format(event.startDate))
        .toSet();

    List<Month> months = uniqueMonthNames.map((monthName) {
      List<Event> eventsByMonth = events
          .where((event) =>
              DateFormat('MMM yyyy').format(event.startDate) == monthName)
          .toList();

      return Month(
        name: monthName,
        events: eventsByMonth,
      );
    }).toList();

    if (_months.isNotEmpty) {
      Month lastMonthFromState = _months.last;
      Month firstMonthFromResponse =
          months.where((month) => month.name == lastMonthFromState.name).first;
      Month updatedLastMonth = Month(
        name: lastMonthFromState.name,
        events: [
          ...lastMonthFromState.events,
          ...firstMonthFromResponse.events,
        ],
      );

      List<Month> updatedMonths = [
        ..._months.where((month) => month.name != updatedLastMonth.name),
        updatedLastMonth,
        ...months.sublist(1),
      ];

      return updatedMonths;
    }

    return months;
  }

  void _getEvents() async {
    GraphQLClient client = GraphQLProvider.of(context).value;
    var response = await client.query(QueryOptions(
      document: gql(getEvents),
      variables: {
        'skip': _skip,
        'limit': 10,
      },
    ));

    List<Month> months = _getMonths(response);

    setState(() {
      _months = months;
      _skip += 10;
      _isLoadingEvents = false;
    });
  }

  @override
  void initState() {
    super.initState();

    _getCurrentLocation();

    _scrollController = ScrollController();

    _scrollController.addListener(() async {
      var nextPageTrigger = 0.8 * _scrollController.position.maxScrollExtent;
      if (_scrollController.position.pixels >= nextPageTrigger &&
          !_isLoadingEvents) {
        _getEvents();
      }
    });
  }

  @override
  void didChangeDependencies() {
    _getEvents();

    super.didChangeDependencies();
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

    if (position != null && mounted) {
      GraphQLClient client = GraphQLProvider.of(context).value;
      var response = await client.query(QueryOptions(
        document: gql(getGeolocationByCoords),
        variables: {
          'latitude': position.latitude,
          'longitude': position.longitude,
        },
      ));

      Map<String, dynamic> data = response.data ?? {};

      if (mounted) {
        setState(() {
          _location = Location.fromMap(data['getGeolocationByCoords']);
          _isLoadingLocation = false;
        });
      }
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
                  physics: const AlwaysScrollableScrollPhysics(),
                  controller: _scrollController,
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
      MaterialPageRoute(builder: (context) => EventScreen(id: event.id)),
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _isLoadingEvents || _isLoadingLocation
        ? Center(
            child: CircularProgressIndicator(
              color: LightThemeColors.primary,
            ),
          )
        : Column(
            children: [
              Container(
                margin: const EdgeInsets.all(20),
                child: HomeHeader(
                  imgSrc: 'https://source.unsplash.com/random/',
                  location: _location,
                ),
              ),
              Container(
                margin: const EdgeInsets.only(
                  right: 20,
                  bottom: 20,
                  left: 20,
                ),
                child: AppAutocomplete<String>(
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
              ),
              Expanded(
                child: ListView.builder(
                  controller: _scrollController,
                  shrinkWrap: true,
                  itemCount: _months.length,
                  itemBuilder: (context, index) {
                    final month = _months[index];

                    return Column(
                      children: [
                        Container(
                          margin: const EdgeInsets.only(bottom: 20),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              MonthTile(text: month.name),
                              EventsCounter(count: month.events.length),
                            ],
                          ),
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
