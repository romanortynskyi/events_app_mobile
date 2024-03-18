// ignore_for_file: use_build_context_synchronously

import 'package:events_app_mobile/consts/light_theme_colors.dart';
import 'package:events_app_mobile/controllers/home_screen_controller.dart';
import 'package:events_app_mobile/graphql/home_screen/home_screen_queries.dart';
import 'package:events_app_mobile/models/event.dart';
import 'package:events_app_mobile/models/geolocation.dart';
import 'package:events_app_mobile/models/month.dart';
import 'package:events_app_mobile/screens/event_screen.dart';
import 'package:events_app_mobile/screens/search_results_screen.dart';
import 'package:events_app_mobile/services/event_service.dart';
import 'package:events_app_mobile/services/geolocation_service.dart';
import 'package:events_app_mobile/services/location_service.dart';
import 'package:events_app_mobile/widgets/app_autocomplete.dart';
import 'package:events_app_mobile/widgets/event_card.dart';
import 'package:events_app_mobile/widgets/events_counter.dart';
import 'package:events_app_mobile/widgets/home_header.dart';
import 'package:events_app_mobile/widgets/month_tile.dart';
import 'package:events_app_mobile/widgets/touchable_opacity.dart';
import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<StatefulWidget> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Month> _months = [];
  int _skip = 0;
  final FocusNode _focusNode = FocusNode();
  Geolocation? _geolocation;
  late ScrollController _scrollController;
  bool _isLoadingEvents = true;
  bool _isLoadingLocation = true;

  late EventService _eventService;
  late LocationService _locationService;
  late GeolocationService _geolocationService;
  late HomeScreenController _homeScreenController;

  final TextEditingController _textEditingController = TextEditingController();

  @override
  void initState() {
    super.initState();

    _eventService = EventService();
    _locationService = LocationService();
    _geolocationService = GeolocationService();

    _homeScreenController = HomeScreenController(
      context: context,
      eventService: _eventService,
      locationService: _locationService,
      geolocationService: _geolocationService,
    );

    _homeScreenController.getCurrentGeolocation(
      HomeScreenQueries.getGeolocationByCoords,
      _onCurrentGeolocationLoaded,
    );

    _scrollController = ScrollController();

    _scrollController.addListener(() async {
      var nextPageTrigger = 0.8 * _scrollController.position.maxScrollExtent;
      if (_scrollController.position.pixels >= nextPageTrigger &&
          !_isLoadingEvents) {
        await _homeScreenController.getEvents(
          graphqlDocument: HomeScreenQueries.getEvents,
          skip: _skip,
          limit: 10,
          fetchPolicy: FetchPolicy.networkOnly,
          callback: _onEventsLoaded,
        );
      }
    });
  }

  void _didChangeDependencies() async {
    await _homeScreenController.getEvents(
      graphqlDocument: HomeScreenQueries.getEvents,
      skip: _skip,
      limit: 10,
      fetchPolicy: FetchPolicy.networkOnly,
      callback: _onEventsLoaded,
    );
  }

  @override
  void didChangeDependencies() {
    _didChangeDependencies();

    super.didChangeDependencies();
  }

  void _onEventsLoaded(List<Event> events) {
    if (mounted) {
      setState(() {
        _months = _homeScreenController.getMonths(events, _months);
        _skip += 10;
        _isLoadingEvents = false;
      });
    }
  }

  Future<void> _onCurrentGeolocationLoaded(Geolocation geolocation) async {
    if (mounted) {
      setState(() {
        _geolocation = geolocation;
        _isLoadingLocation = false;
      });
    }
  }

  void onClearSearch() {
    _textEditingController.clear();
  }

  void onAutocompleteSelected(BuildContext context, String text) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => SearchResultsScreen(query: text)),
    );
  }

  void onEventPressed(BuildContext context, Event event) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => EventScreen(id: event.id ?? -1)),
    );
  }

  Future<void> onRefresh(BuildContext context) async {
    _homeScreenController.getCurrentGeolocation(
      HomeScreenQueries.getGeolocationByCoords,
      _onCurrentGeolocationLoaded,
    );

    await _homeScreenController.getEvents(
      graphqlDocument: HomeScreenQueries.getEvents,
      skip: _skip,
      limit: 10,
      fetchPolicy: FetchPolicy.networkOnly,
      callback: _onEventsLoaded,
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoadingEvents || _isLoadingLocation) {
      return Center(
        child: CircularProgressIndicator(
          color: LightThemeColors.primary,
        ),
      );
    }

    Widget autocomplete = Container(
      margin: const EdgeInsets.only(
        right: 20,
        bottom: 20,
        left: 20,
      ),
      child: AppAutocomplete(
        textEditingController: _textEditingController,
        focusNode: _focusNode,
        borderRadius: 35,
        prefixIcon: const Icon(Icons.search),
        hintText: 'Search for events...',
        optionsBuilder: (TextEditingValue textEditingValue) =>
            _homeScreenController.autocompleteEventsOptionsBuilder(
          textEditingValue: textEditingValue,
          graphqlDocument: HomeScreenQueries.autocompleteEvents,
          query: _textEditingController.text,
          skip: 0,
          limit: 10,
          fetchPolicy: FetchPolicy.networkOnly,
        ),
        optionsViewBuilder: (
          BuildContext context,
          onAutoCompleteSelect,
          Iterable<String> options,
        ) =>
            _homeScreenController.autocompleteEventsOptionsViewBuilder(
          context: context,
          onAutoCompleteSelect: onAutoCompleteSelect,
          options: options,
          scrollController: _scrollController,
        ),
        onSelected: (String selection) {
          onAutocompleteSelected(context, selection);
        },
        onSubmitted: (String value) {
          onAutocompleteSelected(context, value);
        },
      ),
    );

    if (_months.isEmpty) {
      return Column(
        children: [
          Container(
            margin: const EdgeInsets.all(20),
            child: HomeHeader(
              imgSrc: 'https://source.unsplash.com/random/',
              geolocation: _geolocation,
            ),
          ),
          autocomplete,
          Center(
            child: Text(
              'No events found',
              style: TextStyle(
                color: LightThemeColors.text,
              ),
            ),
          )
        ],
      );
    } else {
      return RefreshIndicator(
          onRefresh: () => onRefresh(context),
          child: Column(
            children: [
              Container(
                margin: const EdgeInsets.all(20),
                child: HomeHeader(
                  imgSrc: 'https://source.unsplash.com/random/',
                  geolocation: _geolocation,
                ),
              ),
              autocomplete,
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
          ));
    }
  }
}
