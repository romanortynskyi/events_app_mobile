// ignore_for_file: use_build_context_synchronously

import 'package:events_app_mobile/consts/light_theme_colors.dart';
import 'package:events_app_mobile/models/event.dart';
import 'package:events_app_mobile/models/month.dart';
import 'package:events_app_mobile/screens/event_screen.dart';
import 'package:events_app_mobile/widgets/app_autocomplete.dart';
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
        title
        place {
          originalId
          googleMapsUri
          location {
            latitude
            longitude
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

String autocompleteEvents =
    """
  query AUTOCOMPLETE_EVENTS(\$input: AutocompleteEventsInput!) {
    autocompleteEvents(input: \$input) {
      items {
        id
        image {
          src
        }
        createdAt
        updatedAt
        title
        place {
          originalId
          googleMapsUri
          location {
            latitude
            longitude
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
  final FocusNode _focusNode = FocusNode();

  TextEditingController? _textEditingController;

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

    List<Month> months = _getMonths(response);

    if (mounted) {
      setState(() {
        _months = months;
        _skip += 10;
        _isLoadingEvents = false;
      });
    }
  }

  @override
  void initState() {
    super.initState();

    _scrollController = ScrollController();
    _textEditingController = TextEditingController(text: widget.query);

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
    _textEditingController?.clear();
  }

  void onEventPressed(BuildContext context, Event event) {
    Navigator.push(
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

  Future<Iterable<String>> optionsBuilder(
      TextEditingValue textEditingValue) async {
    String text = textEditingValue.text;

    if (text == '') {
      return const Iterable<String>.empty();
    }

    List<String> options = [];

    GraphQLClient client = GraphQLProvider.of(context).value;
    var response = await client.query(QueryOptions(
      document: gql(autocompleteEvents),
      variables: {
        'input': {
          'query': text,
          'skip': 0,
          'limit': 10,
        },
      },
    ));

    Map<String, dynamic> data = response.data ?? {};

    Set eventTitles = (data['autocompleteEvents']['items'])
        .map((eventMap) => Event.fromMap(eventMap).title)
        .toSet();

    eventTitles.forEach((title) => options.add(title));

    return options;
  }

  Widget optionsViewBuilder(
    BuildContext context,
    onAutoCompleteSelect,
    Iterable<String> options,
  ) {
    return Align(
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
        ));
  }

  void onAutocompleteSelected(BuildContext context, String text) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => SearchResultsScreen(query: text)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.deepPurple.shade200, LightThemeColors.primary],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        title: AppAutocomplete(
          textEditingController:
              _textEditingController ?? TextEditingController(),
          textInputAction: TextInputAction.search,
          focusNode: _focusNode,
          backgroundColor: Colors.transparent,
          enabledBorderColor: Colors.transparent,
          focusedBorderColor: Colors.transparent,
          placeholderColor: Colors.white,
          hintText: 'Search for events...',
          optionsBuilder: optionsBuilder,
          optionsViewBuilder: optionsViewBuilder,
          onSelected: (String selection) {
            onAutocompleteSelected(context, selection);
          },
          maxLines: 1,
        ),
      ),
      body: _isLoadingEvents
          ? Center(
              child: CircularProgressIndicator(
                color: LightThemeColors.primary,
              ),
            )
          : RefreshIndicator(
              onRefresh: () => onRefresh(context),
              child: Expanded(
                child: ListView.builder(
                  controller: _scrollController,
                  shrinkWrap: true,
                  itemCount: _months.length,
                  itemBuilder: (context, index) {
                    final month = _months[index];

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
              )),
    );
  }
}
