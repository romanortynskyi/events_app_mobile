// ignore_for_file: use_build_context_synchronously

import 'package:events_app_mobile/consts/light_theme_colors.dart';
import 'package:events_app_mobile/models/event.dart';
import 'package:events_app_mobile/models/month.dart';
import 'package:events_app_mobile/screens/event_screen.dart';
import 'package:events_app_mobile/widgets/event_card.dart';
import 'package:events_app_mobile/widgets/events_counter.dart';
import 'package:events_app_mobile/widgets/month_tile.dart';
import 'package:events_app_mobile/widgets/touchable_opacity.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:graphql_flutter/graphql_flutter.dart';

String searchEvents =
    """
  query SEARCH_EVENTS(\$input: SearchEventsInput!) {
    searchEvents(input: \$input) {
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

class SearchResultsScreen extends StatefulWidget {
  final String query;

  const SearchResultsScreen({super.key, required this.query});

  @override
  State<StatefulWidget> createState() => _SearchResultsScreenState();
}

class _SearchResultsScreenState extends State<SearchResultsScreen> {
  List<Month> _months = [];
  int _skip = 0;
  late ScrollController _scrollController;
  bool _isLoadingEvents = true;

  final TextEditingController _textEditingController = TextEditingController();

  List<Month> _getMonths(response) {
    List<Event> events = response.data?['searchEvents']['items']
        .map((item) => Event.fromMap(item))
        .toList()
        .cast<Event>();

    if (events.isEmpty) {
      return _months;
    }

    Set<String> uniqueMonthNames = events
        .map((event) =>
            DateFormat('MMM yyyy').format(event.startDate ?? DateTime.now()))
        .toSet();

    List<Month> months = uniqueMonthNames.map((monthName) {
      List<Event> eventsByMonth = events
          .where((event) =>
              DateFormat('MMM yyyy')
                  .format(event.startDate ?? DateTime.now()) ==
              monthName)
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

  Future<void> _searchEvents(FetchPolicy fetchPolicy) async {
    GraphQLClient client = GraphQLProvider.of(context).value;
    var response = await client.query(QueryOptions(
      document: gql(searchEvents),
      variables: {
        'input': {
          'query': widget.query,
          'skip': _skip,
          'limit': 10,
        },
      },
      fetchPolicy: fetchPolicy,
    ));
    print(response);
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

    _scrollController = ScrollController();

    _scrollController.addListener(() async {
      var nextPageTrigger = 0.8 * _scrollController.position.maxScrollExtent;
      if (_scrollController.position.pixels >= nextPageTrigger &&
          !_isLoadingEvents) {
        _searchEvents(FetchPolicy.networkOnly);
      }
    });
  }

  @override
  void didChangeDependencies() {
    _searchEvents(FetchPolicy.cacheFirst);

    super.didChangeDependencies();
  }

  void onClearSearch() {
    _textEditingController.clear();
  }

  void onEventPressed(BuildContext context, Event event) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => EventScreen(id: event.id ?? -1)),
    );
  }

  Future<void> onRefresh(BuildContext context) async {
    return _searchEvents(FetchPolicy.networkOnly);
  }

  @override
  void dispose() {
    _scrollController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _isLoadingEvents
        ? Center(
            child: CircularProgressIndicator(
              color: LightThemeColors.primary,
            ),
          )
        : RefreshIndicator(
            onRefresh: () => onRefresh(context),
            child: Column(
              children: [
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
